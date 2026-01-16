package com.base.common.net;

import android.content.res.Resources;

import com.base.common.BuildConfig;
import com.base.common.CommonApplication;
import com.base.common.R;
import com.base.common.utils.NetworkUtils;
import com.base.library.net.exception.APIResultException;
import com.base.library.net.exception.ErrorMsgBean;
import com.base.library.net.exception.HttpStatusException;
import com.orhanobut.logger.Logger;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;

import retrofit2.HttpException;

public class ErrorMessageFactory {
    private static final String TAG = "ErrorMessageFactory";
    //系统异常和其它bug
    public final static int DEFAULT_TYPE_ERROR = ErrorMsgBean.DEFAULT_TYPE_ERROR;
    public final static int DEFAULT_ERROR = 2001;
    //网络异常
    public final static int NET_TYPE_ERROR = ErrorMsgBean.NET_TYPE_ERROR;
    public final static int NET_NOT_FIND = 1101;
    public final static int NET_NO_NETWORK = 1102;
    public final static int NET_TIMEOUT = 1103;
    public final static int NET_HTTP_ERROR = 1104;
    //api异常
    public final static int API_TYPE_ERROR = ErrorMsgBean.API_TYPE_ERROR;
    public final static int API_NULL_DATA = 1201;
    //AccessToken错误或已过期
    public static final int API_ACCESS_TOKEN_EXPIRED = 100010101;
    //RefreshToken错误或已过期
    public static final int API_REFRESH_TOKEN_EXPIRED = 1001;
    //timestamp过期
    public static final int API_TIMESTAMP_ERROR = 100010104;
    //签名错误
    public final static int API_ERROR_SIGN = 100010105;
    //帐号在其它手机已登录
    public static final int API_OTHER_PHONE_LOGINED = 100021006;

//    public static ErrorMsgBean create(Exception exception) {
//        ErrorMsgBean bean = new ErrorMsgBean();
//        bean.setCode("");
//        String message = "网络请求失败";
//        if (StringUtil.isNotEmpty(exception.getMessage())) {
//            Logger.e(TAG, exception.getMessage());
//            message = exception.getMessage();
//        }
//
//        if (exception instanceof ConnectException) {
////            message = "无法连接到服务器，请稍后再试" + exception.toString();
//            if (NetworkUtils.isConnected()) {
//                bean.setCode(GlobalConfigure.NOTFIND);
//                message = "无法连接到服务器，请稍后再试";
//            } else {
//                bean.setCode(GlobalConfigure.NONETWORK);
//                message = "请检查网络连接";
//            }
//        } else if (exception instanceof JsonSyntaxException) {
//            message = "json解析错误" + exception.toString();
//        } else if (exception instanceof InterruptedException) {
//            bean.setCode(GlobalConfigure.TIMEOUT);
//            message = "连接超时" + exception.toString();
//        } else if (exception instanceof SocketTimeoutException) {
//            bean.setCode(GlobalConfigure.TIMEOUT);
//            message = "请求超时" + exception.toString();
//        } else if (exception instanceof Resources.NotFoundException || exception instanceof UnknownHostException) {
//            if (NetworkUtils.isConnected()) {
//                bean.setCode(GlobalConfigure.NOTFIND);
//                message = "没有找到" + exception.toString();
//            } else {
//                bean.setCode(GlobalConfigure.NONETWORK);
//                message = "请检查网络连接";
//            }
//        } else if (exception instanceof HttpException) {
//            message = exception.getMessage();
//        } else if (exception instanceof MalformedJsonException) {
//            message = "sessionId错误" + exception.toString();
//        } else if (exception instanceof NullPointerException) {
//            message = "空指针异常->" + exception.toString();
//        } else if (exception instanceof HttpStatusException) {
//            message = ((HttpStatusException) exception).getErrorMsg();
//        } else if (exception instanceof APIResultException) {
//            mTDException = (APIResultException) exception;
//            bean.setCode(GlobalConfigure.DATAERROR);
//            if (mTDException.getErrorCode() == CODE_NO_DATA) {
//                message = StringUtil.isEmpty(mTDException.getErrorMsg()) ? "暂无数据" : mTDException.getErrorMsg();
//            } else if (mTDException.getErrorCode() == CODE_PARAMETER_ERROR) {
//                message = StringUtil.isEmpty(mTDException.getErrorMsg()) ? "请求参数错误" : mTDException.getErrorMsg();
//            } else if (mTDException.getErrorCode() == CODE_OTHER_ERROR) {
//                message = StringUtil.isEmpty(mTDException.getErrorMsg()) ? "其他错误" : mTDException.getErrorMsg();
//            } else if (mTDException.getErrorCode() == CODE_UNKNOWN_ERROR) {
//                message = StringUtil.isEmpty(mTDException.getErrorMsg()) ? "未知错误" : mTDException.getErrorMsg();
//            } else {
//                message = !StringUtil.isEmpty(mTDException.getErrorMsg()) ? mTDException.getErrorMsg() : "未知错误";
//            }
//        }
//        bean.setMsg(message);
//
//        return bean;
//    }

    public static ErrorMsgBean create(Throwable exception) {
        Logger.e(exception != null && exception.getMessage() != null ? exception.getMessage() : "Throwable is null");
        ErrorMsgBean bean = new ErrorMsgBean();
        String message = CommonApplication.getInstance().getString(R.string.error_tip_request_failed);
        bean.setCode(DEFAULT_ERROR);
        bean.setType(DEFAULT_TYPE_ERROR);
        if (exception != null) {
            if (!NetworkUtils.isConnected()) {
                bean.setType(NET_TYPE_ERROR);
                bean.setCode(NET_NO_NETWORK);
                message = CommonApplication.getInstance().getString(R.string.error_tip_check_network_connection);
            } else if (exception instanceof ConnectException
                    || exception instanceof Resources.NotFoundException
                    || exception instanceof UnknownHostException) {
                bean.setType(NET_TYPE_ERROR);
                bean.setCode(NET_NOT_FIND);
                message = CommonApplication.getInstance().getString(R.string.error_tip_unable_connect_server);
            } else if (exception instanceof InterruptedException) {
                bean.setType(NET_TYPE_ERROR);
                bean.setCode(NET_TIMEOUT);
                message = CommonApplication.getInstance().getString(R.string.error_tip_connection_has_been_disconnected);
            } else if (exception instanceof SocketTimeoutException) {
                bean.setType(NET_TYPE_ERROR);
                bean.setCode(NET_TIMEOUT);
                message = CommonApplication.getInstance().getString(R.string.error_tip_time_out);
            } else if (exception instanceof HttpException) {
                bean.setType(NET_TYPE_ERROR);
                bean.setCode(((HttpException) exception).code());
                message = exception.getMessage();
            } else if (exception instanceof APIResultException) {
                //如遇到code != 200 有data 则直接用HttpResult<Object>接收返回数据，再onNext中进httpResult.getCode()结果判断并赋值
                bean.setType(API_TYPE_ERROR);
                bean.setCode(((APIResultException) exception).getErrorCode());
                message = exception.getMessage();
            } else if (exception instanceof HttpStatusException) {
                bean.setType(NET_TYPE_ERROR);
                bean.setCode(((HttpStatusException) exception).getErrorCode());
                message = exception.getMessage();
            } else {
//                CrashReport.postCatchedException(exception);
//                if (BuildConfig.DEBUG) {
//                    StringWriter stringWriter = new StringWriter();
//                    PrintWriter writer = new PrintWriter(stringWriter);
//                    exception.printStackTrace(writer);
//                    writer.flush();
//                    message = "Debug 模式才会出现：\n" + stringWriter.toString();
//                } else {
                    message = CommonApplication.getInstance().getString(R.string.error_tip_request_error);
//                }
            }
        }
        Logger.e(message == null ? "message is null" : message);
        bean.setMsg(message);
        return bean;
    }

}
