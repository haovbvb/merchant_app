package com.base.common.permission;

public interface OnPermissionListener {
    /**
     * 权限校验通过
     */
    void passPermission();

    /**
     * 用户拒绝了该权限，没有选中『不再询问』，可进行弹窗说明，确认后重新请求权限
     */
    void showRequestPermissionRationale();

    /**
     * 用户拒绝了该权限，选中『不再询问』，可进行二次弹窗，确认后进入app设置页面
     */
    void deniedPermission();

    /**
     * 发生错误
     *
     * @param throwable
     */
    void onError(Throwable throwable);
}
