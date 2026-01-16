package com.okla.ops.views.map.select;

import com.base.common.beans.LocationData;
import com.okla.ops.beans.AddressBean;

public interface IMapCallbackSelectAddr {
    void addressLoc(AddressBean address);
    void onMapClick();
    void onMapReady();
    void cameraIdle(LocationData locationData);
}
