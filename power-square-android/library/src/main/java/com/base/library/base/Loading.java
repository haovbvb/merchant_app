package com.base.library.base;

/**
 * @Date: 2019/9/24 11:29
 * @Author: Jayden
 * @Description:
 * @Version:
 */
public interface Loading {
    void onStart();

    void onFinish();

    void onError(Throwable e);

    void setOnCancelListener(OnCancelListener listener);

}
