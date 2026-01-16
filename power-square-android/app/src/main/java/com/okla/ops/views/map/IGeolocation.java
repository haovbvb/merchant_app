package com.okla.ops.views.map;


public interface IGeolocation {
    //初始化定位
    void initLocationClient();

    //开始定位
    void onStartLocate(LocationCallback listener);

    //停止定位
    void onPauseLocate();

    //销毁定位及监听
    void onStopLocate();
}
