package com.base.common.net.interceptor;

import com.base.common.beans.RxEvent;
import com.base.common.net.BaseResponse;
import com.base.library.net.interceptor.base.BaseExpiredInterceptor;
import com.base.library.utils.GsonUtils;
import com.orhanobut.logger.Logger;

import org.greenrobot.eventbus.EventBus;

import java.io.IOException;

import okhttp3.Response;

import static com.base.common.net.ErrorMessageFactory.API_ACCESS_TOKEN_EXPIRED;
import static com.base.common.net.ErrorMessageFactory.API_ERROR_SIGN;
import static com.base.common.net.ErrorMessageFactory.API_OTHER_PHONE_LOGINED;
import static com.base.common.net.ErrorMessageFactory.API_REFRESH_TOKEN_EXPIRED;
import static com.base.common.net.ErrorMessageFactory.API_TIMESTAMP_ERROR;

import android.util.Log;

public class TokenInterceptor extends BaseExpiredInterceptor {
    BaseResponse baseResponse;

    @Override
    public boolean isResponseExpired(Response response, String bodyString) {
        Logger.e("MyInterceptor TokenInterceptor " + bodyString);
        baseResponse = GsonUtils.fromGson(bodyString, BaseResponse.class);
        if (baseResponse != null) {
            int code = baseResponse.getCode();
            return code == API_ACCESS_TOKEN_EXPIRED
                    || code == API_REFRESH_TOKEN_EXPIRED
                    || code == API_OTHER_PHONE_LOGINED
                    || code == API_ERROR_SIGN
                    || code == API_TIMESTAMP_ERROR;
        }
        return false;
    }

    @Override
    public Response responseExpired(Chain chain, String bodyString) {
        try {
            switch (baseResponse.getCode()) {
                case API_ACCESS_TOKEN_EXPIRED: //AccessToken错误或已过期
                    refreshToken();
                    break;
                case API_REFRESH_TOKEN_EXPIRED://RefreshToken错误或已过期
                    reLogin();
                    break;
                case API_OTHER_PHONE_LOGINED://帐号在其它手机已登录
                    notifyLoginExit(baseResponse.getMsg());
                    break;
                case API_ERROR_SIGN://签名错误
                    break;
                case API_TIMESTAMP_ERROR://timestamp过期
                    break;
                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    //同步请求refreshToken
    public void refreshToken() throws IOException {
    }

    /**
     * 同步请求重新登录
     *
     * @return
     * @throws IOException
     */
    private void reLogin() throws IOException {
        EventBus.getDefault().post(new RxEvent.LoginOut());
    }

    private void notifyLoginExit(String msg) {
    }

}
