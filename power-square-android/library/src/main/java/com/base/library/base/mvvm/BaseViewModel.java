package com.base.library.base.mvvm;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.orhanobut.logger.Logger;

import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;

/**
 * @Date: 2020/9/21 9:56
 * @Author: Jayden
 * @Description:
 * @Version:
 */
public class BaseViewModel extends ViewModel {
    public MutableLiveData<State> loadState = new MutableLiveData<State>(new State());
    private CompositeDisposable mCompositeDisposable;

    @Override
    protected void onCleared() {
        super.onCleared();
        removeAllDisposable();
    }

    //添加指定的请求
    public Disposable addDisposable(Disposable disposable) {
        if (mCompositeDisposable == null)
            mCompositeDisposable = new CompositeDisposable();
        if (disposable != null)
            mCompositeDisposable.add(disposable);
        return disposable;
    }

    //移除指定的请求
    public void removeDisposable(Disposable disposable) {
        if (mCompositeDisposable != null && disposable != null)
            mCompositeDisposable.remove(disposable);
    }

    //取消所有的请求Tag
    public void removeAllDisposable() {
        Logger.i("BaseViewModel onCleared removeAllDisposable");
        if (mCompositeDisposable != null)
            mCompositeDisposable.clear();
    }

}
