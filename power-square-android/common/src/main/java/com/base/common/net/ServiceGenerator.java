package com.base.common.net;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.base.common.GlobalConfigure;
import com.base.common.net.interceptor.GzipRequestInterceptor;
import com.base.common.net.interceptor.HeadersInterceptor;
import com.base.common.net.interceptor.HttpErrorInterceptor;
import com.base.common.net.interceptor.TokenInterceptor;
import com.base.common.utils.DataStoreKeyUtils;
import com.base.common.utils.DataStoreUtils;
import com.base.common.utils.NetworkUtils;
import com.base.common.BuildConfig;
import com.base.library.base.BaseApplication;
import com.base.library.net.ApiRetryFunc;
import com.base.library.net.HttpsUtils;
import com.base.library.net.cookie.CookieManger;
import com.base.library.net.down.DownProgress;
import com.base.library.net.down.DownloadManager;
import com.base.library.net.exception.APIResultException;
import com.base.library.net.interceptor.HttpLogInterceptor;
import com.base.library.utils.FileUtils;
import com.orhanobut.logger.Logger;

import org.reactivestreams.Publisher;

import java.io.File;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLSession;

import io.reactivex.BackpressureStrategy;
import io.reactivex.Flowable;
import io.reactivex.FlowableOnSubscribe;
import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.ObservableTransformer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;
import okhttp3.Cache;
import okhttp3.Cookie;
import okhttp3.CookieJar;
import okhttp3.HttpUrl;
import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;

public class ServiceGenerator {
    private static HttpsUtils.SSLParams sslParams;

    public static <S> S createService(Class<S> serviceClass, String baseUrl, boolean hasToken) {
        return createService(serviceClass, baseUrl, hasToken, 30);
    }

    public static <S> S createService(Class<S> serviceClass, String baseUrl, boolean hasToken, int timeOut) {
        Retrofit.Builder sBuilder = new Retrofit.Builder()
                .baseUrl(baseUrl)
                .addConverterFactory(GsonConverterFactory.create())
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .client(getClient(hasToken, timeOut));

        Retrofit retrofit = sBuilder.build();
        return retrofit.create(serviceClass);
    }

    public static <S> S createService(Class<S> serviceClass, String baseUrl) {
        Retrofit.Builder sBuilder = new Retrofit.Builder()
                .baseUrl(baseUrl)
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .addConverterFactory(GsonConverterFactory.create())
                .client(getClient(false, 30));

        Retrofit retrofit = sBuilder.build();
        return retrofit.create(serviceClass);
    }

    public static <S> S createService2(Class<S> serviceClass, String baseUrl) {
        Retrofit.Builder sBuilder = new Retrofit.Builder()
                .baseUrl(baseUrl)
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .addConverterFactory(GsonConverterFactory.create())
                .client(getClient(false, 30));

        Retrofit retrofit = sBuilder.build();
        return retrofit.create(serviceClass);
    }

    private static OkHttpClient getClient(boolean hasToken, int timeOut) {
        setCertificates(null, null);
//        Map<String, String> headers  = new HashMap<>();
//        headers.put("AccessToken",token);
        //okHttpClient
        return new OkHttpClient().newBuilder()
                .cache(provideCache())
                //错误重连
                .retryOnConnectionFailure(true)
                //连接超时
                .connectTimeout(timeOut, TimeUnit.SECONDS)
                //读取超时
                .readTimeout(timeOut, TimeUnit.SECONDS)
                .hostnameVerifier(new DefaultHostnameVerifier())//https的全局访问规则
                .addNetworkInterceptor(new HttpLogInterceptor().setLevel(BuildConfig.DEBUG ? HttpLogInterceptor.Level.BODY : HttpLogInterceptor.Level.NONE))
//                .addInterceptor(getCacheRequestInterceptor(30))
//                .addNetworkInterceptor(getCacheResponseNetInterceptor())
                .addInterceptor(new TokenInterceptor())
                .addInterceptor(new HeadersInterceptor(null))
                .addInterceptor(new HttpErrorInterceptor())
                .sslSocketFactory(sslParams.sSLSocketFactory, sslParams.trustManager)
                .cookieJar(new CookieJar() {
                    private final HashMap<HttpUrl, List<Cookie>> cookieStore = new HashMap<>();

                    @Override
                    public void saveFromResponse(HttpUrl url, List<Cookie> cookies) {
                        cookieStore.put(HttpUrl.parse(url.host()), cookies);
                    }

                    @Override
                    public List<Cookie> loadForRequest(HttpUrl url) {
                        List<Cookie> cookies = cookieStore.get(HttpUrl.parse(url.host()));
                        return cookies != null ? cookies : new ArrayList<Cookie>();
                    }
                })
                .cookieJar(new CookieManger(BaseApplication.getInstance()))
                .build();
    }


    public static Cache provideCache() {
        return new Cache(new File(FileUtils.getHttpCacheDir()), 10 * 1024 * 1024);
    }

    /**
     * 缓存 拦截器 （只能缓存GET请求）
     * 接口配置了 @Headers(“Cache-Control:public ,max-age=0”) 的接口将会缓存；
     * max-age=0时有网不使用，无网用缓存；max-age>0时配置有网无网会先用缓存
     *
     * @return
     */
    public static Interceptor getCacheRequestInterceptor(int offlineCacheTime) {
        return chain -> {
            Request request = chain.request();
            //拦截请求头 判断哪些接口配置上了缓存（该配置是在retrofit上配置）
            String cacheControl = request.cacheControl().toString();
            //如果没有配置过 那么就是走正常的访问，这里直接return回去了，并没有对请求做处理
            if (TextUtils.isEmpty(cacheControl)) {
                return chain.proceed(request);
            }
            //如果没有网络的情况下，并且配置了缓存，那么我们就设置强制读取缓存，没有读到就抛异常，但是并不会去服务器请求数据
            if (!NetworkUtils.isConnected()) {
                request = request.newBuilder()
                        //only-if-cached 强制使用缓存
                        //max-stale 跟max-age同样用，只是这两个谁的值大，就用谁的值
                        .header("Cache-Control", "public, only-if-cached, max-stale=" + offlineCacheTime)
                        .build();
            }
            return chain.proceed(request);
        };
    }

    /**
     * 缓存 网络拦截器 （只能缓存GET请求）
     *
     * @return
     */
    public static Interceptor getCacheResponseNetInterceptor() {
        return chain -> {
            Request request = chain.request();
            Response response = chain.proceed(request);

            String cacheControl = request.cacheControl().toString();
            //同理获取请求头看看有没有配置过缓存，如果没有配置过就设置成无缓存
            if (TextUtils.isEmpty(cacheControl) || "no-store".contains(cacheControl)) {
                //响应头设置成无缓存
                cacheControl = "no-store";
            }
            return response.newBuilder()
                    //移除掉Pragma 避免服务器默认返回的Pragma对我们自己的缓存配置产生影响
                    .removeHeader("Pragma")
                    .header("Cache-Control", cacheControl)
                    .build();
        };
    }


    /**
     * https的全局自签名证书 or https双向认证证书
     */
    public static void setCertificates(InputStream bksFile, String password, InputStream... certificates) {
        sslParams = HttpsUtils.getSslSocketFactory(bksFile, password, certificates);
    }

    /**
     * 此类是用于主机名验证的基接口。 在握手期间，如果 URL 的主机名和服务器的标识主机名不匹配，
     * 则验证机制可以回调此接口的实现程序来确定是否应该允许此连接。策略可以是基于证书的或依赖于其他验证方案。
     * 当验证 URL 主机名使用的默认规则失败时使用这些回调。如果主机名是可接受的，则返回 true
     */
    public static class DefaultHostnameVerifier implements HostnameVerifier {
        @Override
        public boolean verify(String hostname, SSLSession session) {
            return true;
        }
    }

    public static class UnSafeHostnameVerifier implements HostnameVerifier {
        private String host;

        public UnSafeHostnameVerifier(String host) {
            this.host = host;
            Logger.i("###############　UnSafeHostnameVerifier " + host);
        }

        @Override
        public boolean verify(String hostname, SSLSession session) {
            Logger.i("############### verify " + hostname + " " + this.host);
            if (this.host == null || "".equals(this.host) || !this.host.contains(hostname))
                return false;
            return true;
        }

    }

    public static <T> ObservableTransformer<T, T> uiScheduler() {
        return upstream -> upstream.onTerminateDetach()
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

    public static <T> ObservableTransformer<T, T> newThreadUiScheduler() {
        return upstream -> upstream.onTerminateDetach()
                .subscribeOn(Schedulers.newThread())
                .unsubscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

    /**
     * 自动重试机制
     *
     * @param maxRetries
     * @param retryDelayMillis
     * @param <T>
     * @return
     */
    public static <T> ObservableTransformer<T, T> apiRetryTransformer(int maxRetries, int retryDelayMillis) {
        return upstream -> upstream.retryWhen(new ApiRetryFunc(maxRetries, retryDelayMillis));
    }

    /**
     * 自动重试机制 3次 间隔2s
     *
     * @param <T>
     * @return
     */
    public static <T> ObservableTransformer<T, T> apiRetryTransformer() {
        return apiRetryTransformer(3, 2000);
    }

    public static <T> ObservableTransformer<BaseResponse<T>, Optional<T>> transformerOptionalData() {
        return upstream -> upstream
                .flatMap((Function<BaseResponse<T>, ObservableSource<Optional<T>>>) result -> {
                    if (result.getCode() != 1000) {
                        return Observable.error(new APIResultException(result.getCode(), result.getMsg()));
                    }
                    return Observable.just(Optional.ofNullable(result.getResult()));
                });
    }

    public static <T> ObservableTransformer<BaseResponse<T>, T> transformerData() {
        return upstream -> upstream
                .flatMap((Function<BaseResponse<T>, ObservableSource<T>>) result -> {
                    if (result.getCode() == ErrorMessageFactory.API_REFRESH_TOKEN_EXPIRED) {
                        //token 失效
                        DataStoreUtils.INSTANCE.saveSyncStringData(DataStoreKeyUtils.Companion.getACCESSTOKEN(), "");
                    }
                    if (result.getCode() != 1000) {
                        return Observable.error(new APIResultException(result.getCode(), result.getMsg()));
                    }
                    if (result.getResult() == null) {
                        return Observable.empty();
                    } else {
                        return Observable.just(result.getResult());
                    }
                });
    }

    public static <T> ObservableTransformer<T, T> transformerDataGoogle() {
        return upstream -> upstream
                .flatMap((Function<T, ObservableSource<T>>) result -> {
                    if (result == null) {
                        return Observable.empty();
                    } else {
                        return Observable.just(result);
                    }
                });
    }

    /**
     * 文件下载观察者
     *
     * @param start    已下载大小 0L
     * @param filePath 文件存储路径
     * @param fileName 文件名 new.apk
     * @param <T>
     * @return
     */
    public static <T> ObservableTransformer<ResponseBody, DownProgress> transformerFileDown(long start, @Nullable String filePath, @Nullable String fileName) {
        return upstream -> upstream
                .subscribeOn(Schedulers.io())
                .unsubscribeOn(Schedulers.io())
                .toFlowable(BackpressureStrategy.LATEST)
                .flatMap((Function<ResponseBody, Publisher<DownProgress>>) responseBody ->
                        Flowable.create((FlowableOnSubscribe<DownProgress>) subscriber -> {
                            String name = DownloadManager.getRealFileName(fileName, responseBody);
                            String path = DownloadManager.getRealFilePath(filePath, name);
                            DownloadManager.saveFile(subscriber, path, start, responseBody);
                        }, BackpressureStrategy.LATEST))
                .observeOn(AndroidSchedulers.mainThread())
                .toObservable();
    }

}
