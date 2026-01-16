package com.base.library.net.exception;

import com.base.library.R;

/**
 * @Date: 2018/5/25. 11:25
 * @Author: base
 * @Description: 网络请求失败or数据错误，返回code 和msg数据给view进行处理
 * @Version:
 */

public class ErrorMsgBean {
    //系统异常和其它bug
    public final static int DEFAULT_TYPE_ERROR = R.integer.DEFAULT_TYPE_ERROR;
    //网络异常
    public final static int NET_TYPE_ERROR = R.integer.NET_TYPE_ERROR;
    //api异常
    public final static int API_TYPE_ERROR = R.integer.API_TYPE_ERROR;

    private int type;
    private int code;
    private String msg;

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg == null ? "" : msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }
}
