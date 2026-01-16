

package com.base.library.net.interceptor.base;


import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.nio.charset.Charset;

import okhttp3.Interceptor;
import okhttp3.MediaType;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;
import okio.Buffer;
import okio.BufferedSource;

import static com.base.library.net.interceptor.HttpUtil.UTF8;

/**
 * Date: 2018/5/8. 17:18
 * Author: base
 * Description: 判断响应是否有效的处理
 * 继承后扩展各种无效响应处理：包括token过期、账号异地登录、时间戳过期、签名sign错误等<br>
 * Version:
 */
public abstract class BaseExpiredInterceptor implements Interceptor {
    @Override
    public Response intercept(Chain chain) throws IOException {
        Request request = chain.request();
        Response response;
        try {
            response = chain.proceed(request);
        } catch (Exception e) {
            Logger.e(e.toString());
            throw e;
        }
        ResponseBody responseBody = response.body();
        Charset charset = UTF8;
        MediaType contentType = responseBody.contentType();
        if (contentType != null) {
            charset = contentType.charset(UTF8);
        }
        boolean isText = isText(contentType);
        if (!isText) {
            return response;
        }
        BufferedSource source = responseBody.source();
        source.request(Long.MAX_VALUE); // Buffer the entire body.
        Buffer buffer = source.buffer();
        String bodyString = buffer.clone().readString(charset);
        Logger.i("BaseExpiredInterceptor 网络拦截器:" + bodyString + " host:" + request.url().toString());
        //判断响应是否过期（无效）
        if (isResponseExpired(response, bodyString)) {
            Response responseExpired = responseExpired(chain, bodyString);
            return responseExpired == null ? response : responseExpired;
        }
        return response;
    }

    private boolean isText(MediaType mediaType) {
        if (mediaType == null)
            return false;
        if (mediaType.type() != null && mediaType.type().equals("text")) {
            return true;
        }
        if (mediaType.subtype() != null) {
            if (mediaType.subtype().equals("json")) {
                return true;
            }
        }
        return false;
    }

    /**
     * 处理响应是否有效
     */
    public abstract boolean isResponseExpired(Response response, String bodyString);

    /**
     * 无效响应处理
     */
    public abstract Response responseExpired(Chain chain, String bodyString);
}
