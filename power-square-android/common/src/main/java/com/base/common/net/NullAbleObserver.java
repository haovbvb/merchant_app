package com.base.common.net;

public abstract class NullAbleObserver<T> extends BaseObserver<T> {
    private T t;
    private boolean isError;

    @Override
    public void onNext(T t) {
        this.t = t;
        super.onNext(t);
    }

    @Override
    public void onError(Throwable e) {
        isError = true;
        super.onError(e);
    }

    @Override
    public void onComplete() {
        super.onComplete();
        if (t == null && !isError) {
            onNext(null);
        }
    }
}
