package com.base.common.net.loading;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;

import com.base.library.base.Loading;
import com.base.library.base.mvvm.State;
import com.orhanobut.logger.Logger;

import io.reactivex.ObservableTransformer;

public class LoadingTransHelper {

    public static <T> ObservableTransformer<T, T> loadingDialog(@NonNull Context context) {
        return loadingDialog(context, false);
    }

    public static <T> ObservableTransformer<T, T> loadingDialog(@NonNull Context context, boolean cancelable) {
        return loadingDialog(new DialogLoading(context, cancelable));
    }

    public static <T> ObservableTransformer<T, T> loadingDialog(Loading loading) {
        if (loading == null) return resultObservable -> resultObservable;
        return resultObservable -> resultObservable
                .doOnDispose(() -> {
                    Logger.i("loadingDialog doOnDispose");
                    loading.onFinish();
                }).doOnSubscribe(disposable -> {
                    Logger.i("loadingDialog doOnSubscribe");
                    loading.setOnCancelListener(() -> {
                        if (disposable != null && !disposable.isDisposed()) {
                            disposable.dispose();
                        }
                    });
                    loading.onStart();
                })
                .doOnError(throwable -> {
                    Logger.i("loadingDialog doOnError");
                    loading.onError(throwable);
                })
                .doOnNext(t -> {
                    Logger.i("loadingDialog next");
                    loading.onFinish();
                })
                .doOnComplete(() -> {
                    Logger.i("loadingDialog doOnComplete");
                    loading.onFinish();
                });
    }

    public static <T> ObservableTransformer<T, T> loadingState(MutableLiveData<State> loading) {
        if (loading == null) return resultObservable -> resultObservable;
        return resultObservable -> resultObservable
                .doOnDispose(() -> {
                    Logger.i("loadingDialog doOnDispose");
                    loading.postValue(loading.getValue().setLoadingState(State.FINISH));
                }).doOnSubscribe(disposable -> {
                    Logger.i("loadingDialog doOnSubscribe");
                    loading.postValue(loading.getValue().setLoadingState(State.START));
                })
                .doOnError(throwable -> {
                    Logger.i("loadingDialog doOnError");
                    loading.postValue(loading.getValue().setLoadingState(State.ERROR));
                })
                .doOnNext(t -> {
                    Logger.i("loadingDialog next");
                    loading.postValue(loading.getValue().setLoadingState(State.FINISH));
                })
                .doOnComplete(() -> {
                    Logger.i("loadingDialog doOnComplete");
                    loading.postValue(loading.getValue().setLoadingState(State.FINISH));
                });
    }

}
