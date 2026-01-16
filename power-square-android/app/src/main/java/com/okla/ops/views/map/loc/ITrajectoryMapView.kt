package com.okla.ops.views.map.loc

import android.os.Bundle
import android.widget.FrameLayout
import com.base.common.map.IBaseMapView

interface ITrajectoryMapView : IBaseMapView {
    fun createMapView(bundle: Bundle?, callback: ITrajectoryMapCallback): FrameLayout //创建地图控件

    fun drawMarkerLastPark(latitude: Double, longitude: Double, index: Int)
}