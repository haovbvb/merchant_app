package com.okla.ops.views.map.select;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.base.common.beans.LocationData;
import com.base.library.utils.StringUtil;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.UiSettings;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.okla.ops.beans.AddressBean;
import com.orhanobut.logger.Logger;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

public class GoogleMapViewSelectAddr implements IMapViewSelectAddr, OnMapReadyCallback,
        GoogleMap.OnCameraMoveStartedListener,
        GoogleMap.OnCameraMoveListener,
        GoogleMap.OnCameraMoveCanceledListener,
        GoogleMap.OnCameraIdleListener,
        GoogleMap.OnMapClickListener, GoogleMap.OnMarkerClickListener {
    Context mContext;
    private MapView mMapView;
    private GoogleMap mGoogleMap;
    private int mMapLevel = 15;//地图等级范围2.0f---22.0f
    private Map<String, Marker> mMapMarkers = new HashMap<>();//地图上图标
    private IMapCallbackSelectAddr callback;

    public GoogleMapViewSelectAddr(Context context) {
        this.mContext = context;
    }

    @Override
    public FrameLayout createMapView(Bundle savedInstanceState, IMapCallbackSelectAddr callback) {
        this.callback = callback;
        mMapView = new MapView(mContext);
        Bundle mapViewBundle = null;
        if (savedInstanceState != null) {
            mapViewBundle = savedInstanceState.getBundle(MAPVIEW_BUNDLE_KEY);
        }
        mMapView.onCreate(mapViewBundle);
        mMapView.getMapAsync(this);
        initObserver();
        return mMapView;
    }

    boolean isRefreshAddress = true;

    @Override
    public void isRefreshAddress(boolean isFresh) {
        isRefreshAddress = isFresh;
    }

    @Override
    public void onStart() {
        mMapView.onStart();
    }

    @Override
    public void onPause() {
        mMapView.onPause();
    }

    @Override
    public void onResume() {
        mMapView.onResume();
    }

    @Override
    public void onStop() {
        mMapView.onStop();
    }

    @Override
    public void onDestroy() {
        mMapView.onDestroy();
    }

    private static final String MAPVIEW_BUNDLE_KEY = "MapViewBundleKey";

    @Override
    public void onSaveInstanceState(Bundle outState) {
        Bundle mapViewBundle = outState.getBundle(MAPVIEW_BUNDLE_KEY);
        if (mapViewBundle == null) {
            mapViewBundle = new Bundle();
            outState.putBundle(MAPVIEW_BUNDLE_KEY, mapViewBundle);
        }
        mMapView.onSaveInstanceState(mapViewBundle);
    }

    @Override
    public void onLowMemory() {
        mMapView.onLowMemory();
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mGoogleMap = googleMap;
        if (callback != null) {
            callback.onMapReady();
        }

        enableMyLocation();

        UiSettings mUiSettings = mGoogleMap.getUiSettings();
        mUiSettings.setMapToolbarEnabled(false);
        mUiSettings.setTiltGesturesEnabled(false);
        mUiSettings.setRotateGesturesEnabled(false);

        mGoogleMap.setOnMapClickListener(this);
        mGoogleMap.setOnMarkerClickListener(this);
        mGoogleMap.setOnCameraIdleListener(this);
        mGoogleMap.setOnCameraMoveStartedListener(this);
        mGoogleMap.setOnCameraMoveListener(this);
        mGoogleMap.setOnCameraMoveCanceledListener(this);
        setMapZoomLevel();
    }

    public void setMapZoomLevel() {
        mGoogleMap.animateCamera(CameraUpdateFactory.zoomTo(mMapLevel));
    }

    @Override
    public void setCenter() {
        if (currentLocation != null) {
            mGoogleMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(currentLocation.getLatitude(), currentLocation.getLongitude()), mMapLevel), 1, null);
        }
    }

    @Override
    public void setCenter(LocationData locationData) {
        mGoogleMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(locationData.getLatitude(), locationData.getLongitude()), mMapLevel), 1, null);
    }

    @Override
    public void setCenter(LocationData locationData, boolean anim) {
        if (anim) {
            mGoogleMap.animateCamera(CameraUpdateFactory.newLatLng(new LatLng(locationData.getLatitude(), locationData.getLongitude())), 1, null);
        } else {
            mGoogleMap.moveCamera(CameraUpdateFactory.newLatLng(new LatLng(locationData.getLatitude(), locationData.getLongitude())));
        }
    }

    LocationData currentLocation;
    Geocoder geocoder;

    @Override
    public void refreshCenterPoi(LocationData locationData) {
        currentLocation = locationData;
        if (mGoogleMap == null) {
            return;
        }
        //绘制中心点和个人位置
        initPhoneAndMidMarkers();
    }

    /**
     * 绘制station Marker
     *
     * @param latLng
     * @param
     * @return
     */
    MarkerOptions mMarkerOptions;

    /**
     * 绘制Marker
     *
     * @param latLng
     * @param resId
     * @return
     */
    private Marker drawMark(LatLng latLng, int resId) {
        //画指针
        mMarkerOptions = new MarkerOptions();
        mMarkerOptions.position(latLng);
        mMarkerOptions.anchor(0.5f, 1.0f);
        mMarkerOptions.icon(BitmapDescriptorFactory.fromBitmap(getBitmap(resId)));
        return mGoogleMap.addMarker(mMarkerOptions);
    }

    /**
     * 转换获取图片
     *
     * @param resId
     * @return
     */
    Drawable drawable;
    Canvas canvas;
    Bitmap bitmap;

    private Bitmap getBitmap(int resId) {
        drawable = ContextCompat.getDrawable(mContext.getApplicationContext(), resId);
        canvas = new Canvas();
        bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        canvas.setBitmap(bitmap);
        drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
        drawable.draw(canvas);
        return bitmap;
    }


    /**
     * 初始化手机和中心点Marker
     *
     * @param curLocation
     */
    private Marker middleMarker;

    private void initPhoneAndMidMarkers() {
//        if (middleMarker == null) {
//            middleMarker = drawMark(new LatLng(currentLocation.getLatitude(), currentLocation.getLongitude()), R.mipmap.monitor_center_marker);
//            middleMarker.setZIndex(100.0f);
//            middleMarker.setTag(new BatteryCabinet());
//        }
    }


    /**
     * Enables the My Location layer if the fine location permission has been granted.
     */
    private void enableMyLocation() {
        if (ContextCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {
            if (mGoogleMap != null) {
                mGoogleMap.setMyLocationEnabled(true);
                mGoogleMap.getUiSettings().setMyLocationButtonEnabled(false);
            }
        } else {
            // Permission to access the location is missing. Show rationale and request permission
//            PermissionUtils.requestPermission(this, LOCATION_PERMISSION_REQUEST_CODE,
//                    Manifest.permission.ACCESS_FINE_LOCATION, true);
        }
    }

    @Override
    public void onMapClick(LatLng latLng) {
        callback.onMapClick();
    }

    /**
     * https://maps.googleapis.com/maps/api/directions/json?origin=22.5340017,113.9371933&destination=22.49476697077505,113.922662101686&avoid=highways&mode=WALKING&key="your key"
     *
     * @param marker
     * @return
     */
    @Override
    public boolean onMarkerClick(Marker marker) {
        if (callback != null) {
        }
        // We return true to indicate that we have consumed the event and that we do not wish
        // for the default behavior to occur (which is for the camera to move such that the
        // marker is centered and for the marker's info window to open, if it has one).
        return true;
    }


    LatLng mCameraIdleLatLng;
    float[] distance = new float[1];
    float diameter = 1000;//多少距离直径内不请求数据
    AddressBean mAddress = new AddressBean();
    StringBuilder addressBuilder;

    @Override
    public void onCameraIdle() {
        mCameraIdleLatLng = mGoogleMap.getCameraPosition().target;
        mAddress.setLatitude(mCameraIdleLatLng.latitude);
        mAddress.setLontitude(mCameraIdleLatLng.longitude);
        //算距离（前提是 currentLocation 不为空）
        if (currentLocation != null) {
            float[] distance = new float[1];
            Location.distanceBetween(
                    currentLocation.getLatitude(),
                    currentLocation.getLongitude(),
                    mCameraIdleLatLng.latitude,
                    mCameraIdleLatLng.longitude,
                    distance
            );
            mAddress.setDistance(StringUtil.m2km(distance[0])); // 或保留米单位
        } else {
            mAddress.setDistance("0");
        }
        geoLocationObserver.subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe(geoConsumer);
        if (callback != null && isRefreshAddress) {
            callback.addressLoc(mAddress);
        }
        isRefreshAddress = true;
    }

    //解析地址
    Observable<Address> geoLocationObserver;
    Consumer<Address> geoConsumer;

    private void initObserver() {
        geoLocationObserver = Observable.create(emitter -> {
            if (Geocoder.isPresent()) {
                if (geocoder == null) {
                    geocoder = new Geocoder(mContext);
                }
                try {
                    List<Address> fromLocation = geocoder.getFromLocation(mCameraIdleLatLng.latitude, mCameraIdleLatLng.longitude, 1);
                    if (fromLocation != null && fromLocation.size() > 0) {
                        for (Address address : fromLocation) {
                            Logger.e("address: size= " + address.getMaxAddressLineIndex() + "address: " + address.toString());
                            emitter.onNext(address);
                        }
                    } else {
                        mAddress.setAddress("");
                        if (callback != null) {
                            callback.addressLoc(mAddress);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        geoConsumer = address -> {
            StringBuilder addressBuilder = new StringBuilder();
            // 拼完整地址
            if (address.getMaxAddressLineIndex() > 0) {
                for (int i = 0; i <= address.getMaxAddressLineIndex(); i++) {
                    addressBuilder.append(address.getAddressLine(i));
                    if (i < address.getMaxAddressLineIndex()) {
                        addressBuilder.append(", ");
                    }
                }
            } else if (address.getAddressLine(0) != null) {
                addressBuilder.append(address.getAddressLine(0));
            }

            // 设置详细地址
            mAddress.setAddress(addressBuilder.toString());
            String name = address.getFeatureName();
             // 优先取街道名 / 建筑名
            if (StringUtil.isEmpty(name)) {
                if (!StringUtil.isEmpty(address.getThoroughfare())) {
                    name = address.getThoroughfare();
                } else if (!StringUtil.isEmpty(address.getSubLocality())) {
                    name = address.getSubLocality();
                } else if (!StringUtil.isEmpty(address.getLocality())) {
                    name = address.getLocality();
                } else if (!StringUtil.isEmpty(address.getAddressLine(0))) {
                    // 从完整地址里取前一段作为简短 name
                    String line = address.getAddressLine(0);
                    if (line.length() > 20) {
                        name = line.substring(0, 20);
                    } else {
                        name = line;
                    }
                } else {
                    name = "-";
                }
            }
            mAddress.setName(name);
            if (callback != null) {
                callback.addressLoc(mAddress);
            }
        };
    }

    @Override
    public void onCameraMoveCanceled() {
    }

    @Override
    public void onCameraMove() {
    }

    @Override
    public void onCameraMoveStarted(int i) {

    }

    @Override
    public void drawMarker(double latitude, double longitude,int deviceType) {

    }
}
