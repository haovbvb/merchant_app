package com.okla.ops.views.login

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.User
import com.okla.ops.http.HttpMethods

class LoginViewModel : BaseViewModel() {

    val tokenLiveData = MutableLiveData<User?>()

    fun refreshToken() {
        addDisposable(HttpMethods.refreshToken().subscribeWith(object : NullAbleObserver<User>() {
            override fun onSuccess(user: User) {
                tokenLiveData.value = user
            }

            override fun onFail(e: ErrorMsgBean) {
                tokenLiveData.value = null
            }
        }))
    }

    val userLiveData = MutableLiveData<User>()

    fun login(account: String, password: String) {
        val map = HashMap<String, Any>()
        map["name"] = account
        map["password"] = password
        map["platform"] = 2
        addDisposable(
            HttpMethods.login(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<User>() {
                    override fun onSuccess(user: User) {
                        userLiveData.value = user
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }
}