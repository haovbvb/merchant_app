package com.base.library.net.exception;

/**
 * Date: 2018/5/8. 18:22
 * Author: base
 * Description:
 * Version:
 */

public class APIResultException extends Exception {

    private int errorCode;

    public APIResultException(int errorCode, String errorMsg) {
        super(errorMsg);
        this.errorCode = errorCode;
    }

    public APIResultException(int errorCode) {
        this.errorCode = errorCode;
    }


    public int getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(int errorCode) {
        this.errorCode = errorCode;
    }

    @Override
    public String toString() {
        return "APIResultException{" +
                "errorCode=" + errorCode +
                '}';
    }
}