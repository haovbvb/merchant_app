package com.base.library.net;

import com.orhanobut.logger.Logger;

import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.functions.Function;

/**
 * Date: 2018/5/22. 17:35
 * Author: base
 * Description: 重试机制
 * Version:
 */

public class ApiRetryFunc implements Function<Observable<? extends Throwable>, Observable<?>> {

    private final int maxRetries;//重试次数
    private final int retryDelayMillis;//重试间隔时间（毫秒）
    private int retryCount;

    public ApiRetryFunc(int maxRetries, int retryDelayMillis) {
        this.maxRetries = maxRetries;
        this.retryDelayMillis = retryDelayMillis;
    }

    @Override
    public Observable<?> apply(Observable<? extends Throwable> observable) throws Exception {
        return observable
                .flatMap((Function<Throwable, ObservableSource<?>>) throwable -> {
                    if (++retryCount <= maxRetries && (throwable instanceof SocketTimeoutException
                            || throwable instanceof ConnectException)) {
                        Logger.d("get response data error, it will try after " + retryDelayMillis + " millisecond, retry count " + retryCount);
                        return Observable.timer(retryDelayMillis, TimeUnit.MILLISECONDS);
                    }
                    Logger.d("get response data error, it will try after " + 0 + " millisecond, retry count " + 0);
                    return Observable.error(throwable);
                });
    }
}
