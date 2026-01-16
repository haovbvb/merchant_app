package com.okla.ops.views.map.select;

import android.os.Bundle;
import android.widget.FrameLayout;

import com.base.common.map.IBaseMapView;

public interface IMapViewSelectAddr extends IBaseMapView {
    FrameLayout createMapView(Bundle bundle, IMapCallbackSelectAddr callback);//创建地图控件

    void isRefreshAddress(boolean isFresh);
}
