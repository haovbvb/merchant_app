package com.okla.ops.views.map.places;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.location.Location;
import android.util.Log;

import com.base.library.utils.StringUtil;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.libraries.places.api.Places;
import com.google.android.libraries.places.api.model.AutocompletePrediction;
import com.google.android.libraries.places.api.model.AutocompleteSessionToken;
import com.google.android.libraries.places.api.model.Place;
import com.google.android.libraries.places.api.model.TypeFilter;
import com.google.android.libraries.places.api.net.FetchPlaceRequest;
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest;
import com.google.android.libraries.places.api.net.PlacesClient;
import com.okla.ops.beans.AddressBean;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/**
 * @Date: 2021/2/19 15:51
 * @Author: Craz
 * @Description:
 * @Version:
 */
public class GooglePlacesMethod implements IPlacesMethod {
    Context mContext;
    private PlacesClient placesClient;

    public GooglePlacesMethod(Context context) {
        mContext = context;
        if (!Places.isInitialized()) {
            ApplicationInfo appInfo = null;
            try {
                appInfo = mContext.getPackageManager()
                        .getApplicationInfo(mContext.getPackageName(),
                                PackageManager.GET_META_DATA);
                String api_key = appInfo.metaData.getString("com.google.android.geo.API_KEY");
                Places.initialize(context.getApplicationContext(), api_key, Locale.US);
                placesClient = Places.createClient(mContext);
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }

        } else {
            placesClient = Places.createClient(mContext);
        }
    }

    IPlacesCallback mPlacesCallback;

    @Override
    public void oncreate(IPlacesCallback callback) {
        mPlacesCallback = callback;
    }


    List<AddressBean> placesList = new ArrayList<>();
    AddressBean mAddressBean;
    double mMyLatitude;
    double mMyLongitude;
    @Override
    public void getPlaces(double latitude, double longitude, String place) {
        placesList.clear();
        mMyLatitude = latitude;
        mMyLongitude = longitude;

        AutocompleteSessionToken token = AutocompleteSessionToken.newInstance();

        FindAutocompletePredictionsRequest request = FindAutocompletePredictionsRequest.builder()
                .setOrigin(new LatLng(latitude, longitude))
                .setTypeFilter(TypeFilter.ADDRESS)
                .setSessionToken(token)
                .setQuery(place)
                .build();

        placesClient.findAutocompletePredictions(request)
                .addOnSuccessListener((response) -> {
                    if (response.getAutocompletePredictions().isEmpty()) {
                        if (mPlacesCallback != null) mPlacesCallback.getPlaces(placesList);
                        return;
                    }

                    for (AutocompletePrediction prediction : response.getAutocompletePredictions()) {
                        final AddressBean addressBean = new AddressBean();
                        addressBean.setName(prediction.getPrimaryText(null).toString());
                        addressBean.setPlaceId(prediction.getPlaceId());
                        addressBean.setAddress(prediction.getFullText(null).toString());

                        // 使用 PlaceId 获取经纬度
                        List<Place.Field> placeFields = Arrays.asList(Place.Field.LAT_LNG);
                        FetchPlaceRequest placeRequest = FetchPlaceRequest.newInstance(prediction.getPlaceId(), placeFields);
                        placesClient.fetchPlace(placeRequest)
                                .addOnSuccessListener((placeResponse) -> {
                                    LatLng latLng = placeResponse.getPlace().getLatLng();
                                    if (latLng != null) {
                                        addressBean.setLatitude(latLng.latitude);
                                        addressBean.setLontitude(latLng.longitude);

                                        // 计算距离
                                        float[] distance = new float[1];
                                        Location.distanceBetween(mMyLatitude, mMyLongitude,
                                                latLng.latitude, latLng.longitude, distance);
                                        addressBean.setDistance(StringUtil.m2km(distance[0]));

                                        placesList.add(addressBean);

                                        if (mPlacesCallback != null) {
                                            mPlacesCallback.getPlaces(placesList);
                                        }
                                    }
                                }).addOnFailureListener((exception) -> {
                                    // 获取经纬度失败也加入列表，但距离为0
                                    addressBean.setLatitude(0);
                                    addressBean.setLontitude(0);
                                    addressBean.setDistance("0");
                                    placesList.add(addressBean);
                                    if (mPlacesCallback != null) mPlacesCallback.getPlaces(placesList);
                                });
                    }
                }).addOnFailureListener((exception) -> {
                    if (mPlacesCallback != null) mPlacesCallback.getPlaces(placesList);
                });
    }

    @Override
    public void getPlaceByPlaceId(String placeId) {

        // Specify the fields to return.
        final List<Place.Field> placeFields = Arrays.asList(Place.Field.LAT_LNG, Place.Field.NAME,Place.Field.ADDRESS);

        // Construct a request object, passing the place ID and fields array.
        final FetchPlaceRequest request = FetchPlaceRequest.newInstance(placeId, placeFields);

        placesClient.fetchPlace(request).addOnSuccessListener((response) -> {
            if (mPlacesCallback != null) {
                Place place = response.getPlace();
                LatLng latLng = place.getLatLng();
                float[] distance = new float[1];
                Location.distanceBetween(mMyLatitude,mMyLongitude,latLng.latitude,latLng.longitude,distance);
                mPlacesCallback.getPlacesByPlaceId(place.getName(),place.getAddress(),latLng.latitude,latLng.longitude,StringUtil.numDoubleToInt(distance[0]));
                Log.i("Address---name-PlaceId:", "Place found: name" + place.getName() + ",address= " + place.getAddress());
            }
        }).addOnFailureListener((exception) -> {
            if (exception instanceof ApiException) {
                final ApiException apiException = (ApiException) exception;
                if (mPlacesCallback != null) {
                    mPlacesCallback.getPlacesByPlaceId("","",0,0,"0");
                }
                Log.e("Address---name:", "Place not found: " + exception.getMessage());
                final int statusCode = apiException.getStatusCode();
                // TODO: Handle error with given status code.
            }
        });

    }
}
