package com.okla.ops.views.workbench.selectaddress;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.Preferences;
import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.DensityUtil;
import com.base.library.utils.StringUtil;
import com.okla.ops.databinding.ActivitySelectAddressBinding;
import com.okla.ops.utils.StringUtils;
import com.okla.ops.views.map.IGeolocation;
import com.okla.ops.views.map.LocationCallback;
import com.okla.ops.views.map.MapFactory;
import com.okla.ops.views.map.select.IMapCallbackSelectAddr;
import com.okla.ops.views.map.select.IMapViewSelectAddr;
import com.orhanobut.logger.Logger;
import com.okla.ops.R;
import com.okla.ops.beans.AddressBean;
import com.base.common.beans.LocationData;
/**
 * @Date: 2021/1/19 19:34
 * @Author: craz
 * @Description:
 * @Version:
 */

public class SelectAddressActivity extends BaseNormalVActivity<SelectAddressViewModel, ActivitySelectAddressBinding> implements IMapCallbackSelectAddr, LocationCallback {
    private IMapViewSelectAddr mMapView;
    private IGeolocation mMapLoc;
    private LocationData myPosition;

    public static Intent getIntents(Context context) {
        Intent intent = new Intent(context, SelectAddressActivity.class);
        return intent;
    }

    @Override
    public int title() {
        return R.string.select_address_title;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_select_address;
    }

    @Override
    protected SelectAddressViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(SelectAddressViewModel.class);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setView(this);
//        mBinding.includeTitle.topRight.setText(R.string.select_address_search);
        mBinding.includeTitle.topRight.setCompoundDrawablesRelativeWithIntrinsicBounds(R.mipmap.search,0,0,0);
        mBinding.includeTitle.topRight.setCompoundDrawablePadding(DensityUtil.dp2px(8));
        initMap(savedInstanceState);
        initClick();

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                refreshLocation();
            }
        }, 1000);
    }

    private void initClick() {
        mBinding.includeTitle.topRight.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(myPosition != null) {
                    startActivityForResult(SearchAddressActivity.getIntents(SelectAddressActivity.this, myPosition.getLatitude(),myPosition.getLongitude()),222);
                }else {
                    startActivityForResult(SearchAddressActivity.getIntents(SelectAddressActivity.this, 0.0,0.0),222);
                }
            }
        });
    }

    private void initMap(Bundle savedInstanceState) {
        mMapView = MapFactory.INSTANCE.getMapSelectAddrInstance(mContext);
        mMapLoc = MapFactory.INSTANCE.getMapLocInstance(this);
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
        mMapView.onResume();
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

    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.tvConfirm:
                if(mAddressBean != null){
                    Intent intent = new Intent();
                    intent.putExtra("addressBean",mAddressBean);
                    setResult(111,intent);
                    finish();
                }
                break;
            case R.id.ivLocate:
                refreshLocation();
                mMapView.setCenter();
                break;
            default:
                break;
        }
    }

    AddressBean mAddressBean;
    @Override
    public void addressLoc(AddressBean bean) {
        mAddressBean = bean;
        mBinding.setData(mAddressBean);
        if(TextUtils.isEmpty(mAddressBean.getName())){
            mBinding.tvName.setText("-");
        }else {
            mBinding.tvName.setText(mAddressBean.getName());
        }
        if(!TextUtils.isEmpty(mAddressBean.getDistance())){
            mBinding.tvDistance.setText(mAddressBean.getDistance());
        }else {
            mBinding.tvDistance.setText("- m");
        }
        mBinding.tvCoordinate.setText(getString(R.string.text_coordinates_str, " " +  StringUtils.Companion.formatLatLng(mAddressBean.getLontitude()))+" "+StringUtils.Companion.formatLatLng(mAddressBean.getLatitude()));
    }

    @Override
    public void onMapClick() {

    }

    boolean isMapReady;
    @Override
    public void onMapReady() {
        isMapReady = true;
        if(myPosition != null) {
            mMapView.setCenter(myPosition);
        }
    }


    @Override
    public void cameraIdle(LocationData locationData) {

    }
    boolean isFirst = true;
    @Override
    public void onLocationChanged(LocationData data) {
        myPosition = data;
        mMapView.refreshCenterPoi(data);
        if(isMapReady && isFirst){
            isFirst = false;
            mMapView.setCenter();
        }
        mBinding.ivMiddleMarker.setVisibility(View.VISIBLE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(requestCode == 222 && data != null){
            mAddressBean = (AddressBean) data.getSerializableExtra("addressBean");
            mBinding.setData(mAddressBean);
            mMapView.isRefreshAddress(false);
            if(TextUtils.isEmpty(mAddressBean.getName())){
                mBinding.tvName.setText("-");
            }else {
                mBinding.tvName.setText(mAddressBean.getName());
            }
            if(!TextUtils.isEmpty(mAddressBean.getDistance())){
                mBinding.tvDistance.setText(mAddressBean.getDistance());
            }else {
                mBinding.tvDistance.setText("- m");
            }
            mBinding.tvCoordinate.setText(getString(R.string.text_coordinates_str, " " + StringUtils.Companion.formatLatLng(mAddressBean.getLatitude()) + " " + StringUtils.Companion.formatLatLng(mAddressBean.getLontitude())));
            mMapView.setCenter(new LocationData(mAddressBean.getLatitude(),mAddressBean.getLontitude()),false);
        }
    }
    private void refreshLocation(){
        requestPermission();
        //获取位置管理器
        LocationManager locationManager = (LocationManager) getActivity().getSystemService(LOCATION_SERVICE);
        //获取最新的定位信息
        Location location = locationManager.getLastKnownLocation(LocationManager.PASSIVE_PROVIDER);
        //将最新的定位信息，传递给LocationUpdates()方法
        if(null != location) {
            locationUpdates(location);
        }else{
            locationUpdates(locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER));
        }


    }
    public void locationUpdates(Location location) {
        if (null != location) {
            LocationData data=new LocationData(location.getLatitude(),location.getLongitude());
            mMapView.refreshCenterPoi(data);
            Preferences.getInstance().setLatitude(data.getLatitudeStr());
            Preferences.getInstance().setLontitude(data.getLongitudeStr());
            myPosition = data;
            mMapView.refreshCenterPoi(data);
            if(isMapReady && isFirst){
                isFirst = false;
                mMapView.setCenter();
            }
            mBinding.ivMiddleMarker.setVisibility(View.VISIBLE);


        } else {
            Logger.d("没有获取到GPS信息");
        }
    }
    private void requestPermission() {
        String[] perms = {Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION};
        PermissionManager.checkPermission(this, new PermissionListenerImpl() {
            @Override
            public void passPermission() {

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
}