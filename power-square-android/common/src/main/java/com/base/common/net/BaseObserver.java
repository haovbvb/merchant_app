package com.base.common.net;

import com.base.library.net.exception.ErrorMsgBean;
import com.base.library.utils.EspressoIdlingResource;

import io.reactivex.observers.DisposableObserver;

public abstract class BaseObserver<T> extends DisposableObserver<T> {
    @Override
    protected void onStart() {
        // The network request might be handled in a different thread so make sure Espresso knows
        // that the app is busy until the response is handled.
        EspressoIdlingResource.increment();// App is busy until further notice
        super.onStart();
    }

    @Override
    public void onNext(T t) {
        // This callback may be called twice, once for the cache and once for loading
        // the data from the server API, so we check before decrementing, otherwise
        // it throws "Counter has been corrupted!" exception.
        if (!EspressoIdlingResource.getIdlingResource().isIdleNow()) {
            EspressoIdlingResource.decrement(); // Set app as idle.
        }
        try {
            onSuccess(t);
        } catch (Throwable e) {
            onError(e);
        }
    }

    @Override
    public void onError(Throwable e) {
        if (!EspressoIdlingResource.getIdlingResource().isIdleNow()) {
            EspressoIdlingResource.decrement(); // Set app as idle.
        }
        onFail(ErrorMessageFactory.create(e));
    }

    @Override
    public void onComplete() {
        if (!EspressoIdlingResource.getIdlingResource().isIdleNow()) {
            EspressoIdlingResource.decrement(); // Set app as idle.
        }
    }

    protected abstract void onSuccess(T t);

//    protected abstract void onFail(ErrorMsgBean e);

    protected abstract void onFail(ErrorMsgBean e);

}
