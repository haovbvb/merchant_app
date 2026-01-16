package com.okla.ops.views.workbench.devicedetail;

import static android.content.Context.LOCATION_SERVICE;

import android.Manifest;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.app.ActivityCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.beans.LocationData;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.ToastUtils;
import com.base.library.utils.StringUtil;
import com.okla.ops.beans.BatteryCabinetBean;
import com.okla.ops.R;
import com.okla.ops.beans.BatteryDevice;
import com.okla.ops.beans.DeviceInfo;
import com.okla.ops.beans.NearByVehicle;
import com.okla.ops.beans.PolylinePointsBean;
import com.okla.ops.databinding.FragmentDeviceLocationBinding;
import com.okla.ops.utils.GooglePolyUtils;
import com.okla.ops.utils.ViewClickUtils;
import com.okla.ops.views.map.IGeolocation;
import com.okla.ops.views.map.LocationCallback;
import com.okla.ops.views.map.MapFactory;
import com.okla.ops.views.map.main.IMapCallback;
import com.okla.ops.views.map.main.IMapView;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;

public class DeviceLocationFragment extends BaseNormalVFragment<DeviceDetailViewModel, FragmentDeviceLocationBinding> implements IMapCallback, LocationCallback {

    private IMapView mMapView;
    private IGeolocation mMapLoc;
    private PermissionManager permissionManager;

    public static DeviceLocationFragment getInstance(int type) {
        DeviceLocationFragment fragment = new DeviceLocationFragment();
        Bundle bundle = new Bundle();
        bundle.putInt("type", type);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_device_location;
    }

    @Override
    protected DeviceDetailViewModel onCreateViewModel() {
        return new ViewModelProvider(getActivity()).get(DeviceDetailViewModel.class);
    }

    private int type;


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        permissionManager = PermissionManager.getInstance(this.getActivity().getActivityResultRegistry(), this.getClass().getName(), this);
        getLifecycle().addObserver(permissionManager);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        Bundle arguments = getArguments();
        if (arguments != null) {
            type = arguments.getInt("type", 0);
        }
        mBinding.setData(getViewModel().mDeviceInfo.getValue());
        initMap(savedInstanceState);
        initObserver();
        initClicks();
    }

    private void initMap(Bundle savedInstanceState) {
        mMapView = MapFactory.INSTANCE.getMapInstance(mActivity);
        mMapLoc = MapFactory.INSTANCE.getMapLocInstance(mActivity);
        mMapLoc.initLocationClient();
        FrameLayout mapView = mMapView.createMapView(savedInstanceState, this);
        ConstraintLayout.LayoutParams params = new ConstraintLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        mBinding.map.addView(mapView, params);
    }

    @Override
    public void onStart() {
        super.onStart();
        mMapLoc.onStartLocate(this);
        mMapView.onStart();
    }

    @Override
    public void onResume() {
        super.onResume();
        isResume = true;
        mMapView.onResume();
        refreshLocation();
    }

    @Override
    public void onPause() {
        super.onPause();
        mMapView.onPause();
        mMapLoc.onPauseLocate();
    }

    @Override
    public void onStop() {
        super.onStop();
        mMapView.onStop();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mMapView.onDestroy();
        mMapLoc.onStopLocate();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        mMapView.onLowMemory();
    }

    @Override
    public void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
        mMapView.onSaveInstanceState(outState);
    }

    private Observer<PolylinePointsBean> mPolyLineObserver;
    //解析地址
    private Observable<Address> geoLocationObserver;
    private Consumer<Address> geoConsumer;
    private Geocoder geocoder;
    private StringBuilder addressBuilder;

    private void initObserver() {
        //轨迹
        mPolyLineObserver = polyLine -> {
            if (polyLine == null || polyLine.getRoutes() == null || polyLine.getRoutes().size() <= 0 || polyLine.getRoutes().get(0).getOverview_polyline() == null) {
                return;
            }
            mMapView.drawPolyLine(GooglePolyUtils.decodePoly(polyLine));
        };
        geoLocationObserver = Observable.create(emitter -> {
            if (Geocoder.isPresent()) {
                if (geocoder == null) {
                    geocoder = new Geocoder(getContext());
                }
                try {
                    List<Address> fromLocation = geocoder.getFromLocation(mSelectedBatteryCabinet.getLatitude(), mSelectedBatteryCabinet.getLongitude(), 1);
                    if (fromLocation != null && fromLocation.size() > 0) {
                        for (Address address : fromLocation) {
//                            Logger.e("address: size= " + address.getMaxAddressLineIndex() + "address: " + address.toString());
                            emitter.onNext(address);
                        }
                    } else {
                        mBinding.tvAddress.setText("--");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        geoConsumer = address -> {
            if (address.getMaxAddressLineIndex() > 0) {
                addressBuilder = new StringBuilder();
                for (int maxAddressLineIndex = address.getMaxAddressLineIndex(); maxAddressLineIndex >= 0; maxAddressLineIndex--) {
                    addressBuilder.append(address.getAddressLine(maxAddressLineIndex));
                    addressBuilder.append(" ");
                }
                mBinding.tvAddress.setText(addressBuilder.toString());
            } else {
                mBinding.tvAddress.setText(address.getAddressLine(0));
            }
        };
    }

    private void initClicks() {
        mBinding.btnNav.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
//            getPolyLineData();
            startNavigation();
        });
    }

    private BatteryCabinetBean mSelectedBatteryCabinet;

    private void initData() {
        DeviceInfo deviceInfo = getViewModel().mDeviceInfo.getValue();
        if (deviceInfo != null) {
            if (deviceInfo.getLatitude() != null && deviceInfo.getLongitude() != null) {
                mBinding.tvPosition.setText(deviceInfo.getLongitude() + " " + deviceInfo.getLatitude());
                mSelectedBatteryCabinet = new BatteryCabinetBean(
                        0,
                        deviceInfo.getSn() == null ? "" : deviceInfo.getSn(),
                        deviceInfo.getSn() == null ? "" : deviceInfo.getSn(),
                        deviceInfo.getStationName() == null ? "" : deviceInfo.getStationName(),
                        deviceInfo.getAddress() == null ? "" : deviceInfo.getAddress(),
                        deviceInfo.getLatitude(),
                        deviceInfo.getLongitude(),
                        deviceInfo.getOnlineStatus() == null ? 0 : deviceInfo.getOnlineStatus(),
                        0,
                        0,
                        0,
                        0,
                        0,
                        "",
                        "",
                        "",
                        new ArrayList<>()
                );
//                List<BatteryCabinetBean> mBatteryCabinetList = new ArrayList<>();
//                mBatteryCabinetList.add(mSelectedBatteryCabinet);
//                mMapView.updateBatteryCabinet(0, new ArrayList<>(), mBatteryCabinetList);
                mMapView.drawMarker(deviceInfo.getLatitude(),deviceInfo.getLongitude(),type);
                mMapView.setCenter(new LocationData(mSelectedBatteryCabinet.getLatitude(), mSelectedBatteryCabinet.getLongitude()), false);
                geoLocationObserver.subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe(geoConsumer);
                getPolyLineData();
            } else {
                mBinding.tvPosition.setText("--");
                mBinding.btnNav.setVisibility(View.GONE);
            }
        }
    }

    boolean isFirst = true;
    boolean isResume = false;


    @Override
    public void onLocationChanged(LocationData data) {
        if (data != null) {
            mMapView.refreshCenterPoi(data);
            mMiddleMarkerPos = data;
            if (isMapReady && isFirst && isResume) {
                isFirst = false;
                getPolyLineData();
            }
        }
    }

//    @Override
//    public void onMapMarkerClick(BatteryDevice batteryDevice) {
//        getPolyLineData();
//    }


    @Override
    public void onMapClick() {

    }

    boolean isMapReady;

    @Override
    public void onMapReady() {
        isMapReady = true;
//        if (mMiddleMarerPos != null) {
//            mMapView.setCenter(mMiddleMarerPos);
//        }
        initData();
    }

    LocationData mMiddleMarkerPos;

    @Override
    public void cameraIdle(LocationData locationData, boolean isRefresh) {
        mMiddleMarkerPos = locationData;
    }

    ApplicationInfo appInfo;
    String google_key;

    private void getPolyLineData() {
        DeviceInfo deviceInfo = getViewModel().mDeviceInfo.getValue();
        if (deviceInfo != null && deviceInfo.getLatitude() != null && deviceInfo.getLongitude() != null && mMiddleMarkerPos != null) {
            try {
                if (appInfo == null || StringUtil.isEmpty(appInfo)) {
                    appInfo = mActivity.getPackageManager().getApplicationInfo(mActivity.getPackageName(), PackageManager.GET_META_DATA);
                    google_key = appInfo.metaData.getString("direction.api.key", "");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            String longitude = String.valueOf(deviceInfo.getLongitude());
            String latitude = String.valueOf(deviceInfo.getLatitude());
            getViewModel().getPolyLine(mMiddleMarkerPos.getLatitude() + "," + mMiddleMarkerPos.getLongitude(),
                    latitude + "," + longitude, "highways",
                    "WALKING", google_key).observe(this, mPolyLineObserver);
        }
    }

    StringBuilder mStringBuilder;
    Intent mapIntent;
    Uri googleAddrUri;

    //在google官网：Maps SDK for Android-->启动 Google 地图
    private void startNavigation() {
        String latitude = "";
        String longitude = "";
//        if (mMapView.getMarkerType() == GoogleMapView.STATION_MARKER) {
//            latitude = String.valueOf(mSelectedBatteryCabinet.getLatitude());
//            longitude = String.valueOf(mSelectedBatteryCabinet.getLongitude());
//        }
        mStringBuilder = new StringBuilder();
        mStringBuilder.append("google.navigation:q=");
        mStringBuilder.append(latitude);
        mStringBuilder.append(",");
        mStringBuilder.append(longitude);
        googleAddrUri = Uri.parse(mStringBuilder.toString());
        mapIntent = new Intent(Intent.ACTION_VIEW, googleAddrUri);
        mapIntent.setPackage("com.google.android.apps.maps");
        try {
            startActivity(mapIntent);
        } catch (Exception e) {
            ToastUtils.showShort(getString(R.string.google_map_install_tip));
        }
    }

    private void refreshLocation() {
        requestPermission();

    }

    public void locationUpdates(Location location) {
        if (null != location) {
            LocationData data = new LocationData(location.getLatitude(), location.getLongitude());
            mMapView.refreshCenterPoi(data);
            mMiddleMarkerPos = data;
        } else {
//            Logger.d("没有获取到GPS信息");
        }
    }

    private void requestPermission() {
        String[] perms = {Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION};
        permissionManager.checkPermissions(new PermissionListenerImpl() {
            @Override
            public void passPermission() {
                //获取位置管理器
                LocationManager locationManager = (LocationManager) getActivity().getSystemService(LOCATION_SERVICE);
                //获取最新的定位信息
                if (ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(getContext(), Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    Location location = locationManager.getLastKnownLocation(LocationManager.PASSIVE_PROVIDER);
                    //将最新的定位信息，传递给LocationUpdates()方法
                    if (null != location) {
                        locationUpdates(location);
                    } else {
                        locationUpdates(locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER));
                    }
                }
            }

            @Override
            public void showRequestPermissionRationale() {
                super.showRequestPermissionRationale();
//                PermissionManager.askForPermission(getActivity(), getString(R.string.permission_location));
            }

            @Override
            public void deniedPermission() {
                super.deniedPermission();
//                PermissionManager.askForPermission(getActivity(), getString(R.string.permission_location));
            }
        }, perms);
    }

    @Override
    public void onMapMarkerClick(@NonNull BatteryDevice battery) {
        getPolyLineData();
    }

    @Override
    public void onMapMarkerVehicleClick(@NonNull NearByVehicle battery) {

    }
}
