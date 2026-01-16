package com.base.common.net.interceptor;

import androidx.annotation.NonNull;

import java.io.IOException;

import okhttp3.Interceptor;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class ResultInterceptor implements Interceptor {
    @NonNull
    @Override
    public Response intercept(Chain chain) throws IOException {
        Response proceed = chain.proceed(chain.request());
        ResponseBody responseBody = proceed.body();

        //如果data对应的是对象，但data无数据时，返回的是"",而不是null，导致解析data异常
        //所以将""替换成null。
        String resultBody = responseBody.string().replaceAll(":\"\"", ":null");
        ResponseBody newResponseBody = ResponseBody.create(responseBody.contentType(), resultBody);
        return proceed.newBuilder().body(newResponseBody).build();
    }
}
