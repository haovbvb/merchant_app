package com.okla.ops.views.map.places;

/**
 * @Date: 2021/2/19 15:50
 * @Author: Craz
 * @Description:
 * @Version:
 */
public interface IPlacesMethod {
    void oncreate(IPlacesCallback callback);
    void getPlaces(double latitude, double longitude, String place);
    void getPlaceByPlaceId(String placeId);
}
