package com.base.common.net.interceptor;

import androidx.annotation.NonNull;

import com.base.common.utils.DataStoreKeyUtils;
import com.base.common.utils.DataStoreUtils;
import com.base.common.utils.LanguageUtils;
import com.orhanobut.logger.Logger;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

public class HeadersInterceptor implements Interceptor {

    private final Map<String, String> headers;

    public HeadersInterceptor(Map<String, String> headers) {
        this.headers = headers;

    }

    @NonNull
    @Override
    public Response intercept(@NonNull Chain chain) throws IOException {
        Logger.e("MyInterceptor HeadersInterceptor " + chain.request().url());
        String accessToken = DataStoreUtils.readStringData(DataStoreKeyUtils.Companion.getACCESSTOKEN(), "");
        String selectLanguage = DataStoreUtils.readStringData(DataStoreKeyUtils.Companion.getLANGUAGE_SETTING(),
                LanguageUtils.LanguageType.ENGLISH.getLanguage());
        Request.Builder builder = chain.request().newBuilder();
        builder.addHeader("AccessToken", accessToken);
        builder.addHeader("Accept-Language", selectLanguage);
        builder.addHeader("Accept-Encoding", "identity");
        builder.addHeader("Cache-Control", "no-cache");
        if (headers != null && !headers.isEmpty()) {
            Set<String> keys = headers.keySet();
            for (String headerKey : keys) {
                String value = headers.get(headerKey);
                if (value != null) {
                    builder.addHeader(headerKey, value).build();
                }
            }
        }
        return chain.proceed(builder.build());
    }
}
