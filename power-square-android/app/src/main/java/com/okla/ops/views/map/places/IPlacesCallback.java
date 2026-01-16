package com.okla.ops.views.map.places;


import com.okla.ops.beans.AddressBean;

import java.util.List;

/**
 * @Date: 2021/1/11 9:55
 * @Author: Craz
 * @Description:
 * @Version:
 */
public interface IPlacesCallback {
    void getPlaces(List<AddressBean> list);
    void getPlacesByPlaceId(String name ,String address,double latitude,double longitude,String distance);
}
