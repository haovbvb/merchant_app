package com.okla.ops.views.mine

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.common.net.loading.LoadingTransHelper
import com.base.common.utils.ToastUtils
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.Personal
import com.okla.ops.http.HttpMethods
import okhttp3.MultipartBody

class MineViewModel : BaseViewModel() {

    val logoutLiveData = MutableLiveData<Any>()

    /**
     * 登出
     */
    fun logout() {
        addDisposable(
            HttpMethods.logout()
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        logoutLiveData.value = Any()
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val personalLiveData = MutableLiveData<Personal>()

    /**
     * 获取个人信息
     */
    fun getPersonalInfo() {
        addDisposable(
            HttpMethods.getPersonalInfo()
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Personal>() {
                    override fun onSuccess(personal: Personal) {
                        personalLiveData.value = personal
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    val editNicknameLiveData = MutableLiveData<String>()

    /**
     * 修改昵称
     */
    fun editNickname(nickname: String) {
        val map = HashMap<String, String>()
        map["newNickName"] = nickname
        addDisposable(
            HttpMethods.editNickName(map)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        editNicknameLiveData.value = nickname
                    }

                    override fun onFail(e: ErrorMsgBean) {
                        ToastUtils.showShort(e.msg)
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

    var editAvatarLiveData = MutableLiveData<Any>()

    /**
     * 修改头像
     */
    fun editAvatar(avatarFile: MultipartBody.Part) {
        addDisposable(
            HttpMethods.editAvatar(avatarFile)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(any: Any?) {
                        editAvatarLiveData.value = Any()
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e).setShowToast(true)
                    }
                })
        )
    }

    var unReadMsgLiveData = MutableLiveData<Int?>()

    /**
     * 获取未读消息数
     */
    fun getUnReadMsgCount() {
        addDisposable(
            HttpMethods.getUnReadMsgCount()
                .subscribeWith(object : NullAbleObserver<Int>() {
                    override fun onSuccess(resp: Int?) {
                        unReadMsgLiveData.value = resp ?: 0
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        unReadMsgLiveData.value = 0
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }

}