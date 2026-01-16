package com.okla.ops.utils

import androidx.lifecycle.MutableLiveData


/**
 * @Auther Administrator
 * @Date 2022/7/11 17:15
 * @Describe: 界面之间的传值工具类
 */
object EventUtils {

    /**
     * 服务返回成功的code值
     */
    val successResponeCode : Int = 1000

//    val msgDetail : MutableLiveData<MsgCenterBean> by lazy { MutableLiveData<MsgCenterBean>() }
    val updateMsgReaderData : MutableLiveData<Boolean> by lazy { MutableLiveData<Boolean>() }
    val carSnData : MutableLiveData<String> by lazy { MutableLiveData<String>() }
//    val selectCabinetByStateData : MutableLiveData<SelectCabinetStateBean> by lazy { MutableLiveData<SelectCabinetStateBean>() }
    val unshelveReaderData : MutableLiveData<Boolean> by lazy { MutableLiveData<Boolean>() }

}

