package com.base.common.beans

class RxEvent {
    /**
     * 绑定设备完成
     */
    class BingDeviceDone {

    }

    /**
     * 注销账号
     */
    class CancelAccount {

    }


    /**
     * 上传文件
     */
    data class UploadFile(var url: String) {

    }


    /**
     * 回到地图页面
     */
    class GoMainMap {

    }


    /**
     * 登录成功
     */
    class LoginState {

    }

    /**
     * 登出成功
     */
    class LoginOut {

    }

    /**
     * 修改昵称
     */
    class NickName(var nickName: String)

    /**
     * 改变语言
     */
    class ChangeLanguage()


    class  GetUnshelveReaderDataRefreshEvent(){

    }

    class RoadSidePaySucessEvent{

    }

    class RoadSideNotPayEvent{

    }

    class MaintenancePaySucessEvent{

    }

    class RoadSideDealSuccessEvent{

    }

    class  QrcodeListPageBackEvent{

    }

}