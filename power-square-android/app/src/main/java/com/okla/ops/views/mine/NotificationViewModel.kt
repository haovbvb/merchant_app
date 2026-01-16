package com.okla.ops.views.mine

import androidx.lifecycle.MutableLiveData
import com.base.common.net.NullAbleObserver
import com.base.library.base.mvvm.BaseViewModel
import com.base.library.base.mvvm.State
import com.base.library.net.exception.ErrorMsgBean
import com.okla.ops.beans.MessageItem
import com.okla.ops.beans.MessageListResponse
import com.okla.ops.http.HttpMethods

class NotificationViewModel : BaseViewModel() {
    var msgListLiveData = MutableLiveData<List<MessageItem>?>()

    /**
     * 分页查询消息
     */
    fun getMsgList(pageIndex: Int, pageSize: Int) {
        val map = HashMap<String, Any>()
        map["pageIndex"] = pageIndex
        map["pageSize"] = pageSize
        addDisposable(
            HttpMethods.getMsgList(map)
                .subscribeWith(object : NullAbleObserver<MessageListResponse>() {
                    override fun onSuccess(data: MessageListResponse) {
                        msgListLiveData.value = data?.list
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        msgListLiveData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR).setErrorMsgBean(e)
                    }
                })
        )
    }

    var setMsgReadLiveData = MutableLiveData<Any?>()

    /**
     * 设置消息已读
     */
    fun setMsgRead(flag: Int, msgId: Int) {
        val map = HashMap<String, Any>()
        map["flag"] = flag
        map["msgId"] = msgId
        addDisposable(
            HttpMethods.setMsgRead(map)
                .subscribeWith(object : NullAbleObserver<Any>() {
                    override fun onSuccess(data: Any) {
                        setMsgReadLiveData.value = data
                    }

                    override fun onFail(e: ErrorMsgBean?) {
                        setMsgReadLiveData.value = null
                        loadState.value =
                            State.getInstance(State.ERROR)
                    }
                })
        )
    }
}