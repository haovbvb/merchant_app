package com.okla.ops.views.workbench.selectaddress;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.TextView;

import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.base.mvvm.BaseNormalListVActivity;
import com.base.common.beans.LocationData;
import com.base.common.net.loading.DialogLoading;
import com.base.common.utils.NumToStrUtil;
import com.base.library.utils.StringUtil;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.AddressBean;
import com.okla.ops.databinding.ActivitySearchAddressBinding;
import com.okla.ops.utils.StringUtils;
import com.okla.ops.views.map.MapFactory;
import com.okla.ops.views.map.places.IPlacesCallback;
import com.okla.ops.views.map.places.IPlacesMethod;

import java.util.List;

/**
 * @Date: 2021/2/19 9:25
 * @Author: craz
 * @Description:
 * @Version:
 */

public class SearchAddressActivity extends BaseNormalListVActivity<SearchAddressViewModel, ActivitySearchAddressBinding> implements IPlacesCallback {
    private LocationData myPosition;
    private double latitude;
    private double longitude;
    private IPlacesMethod placesMethod;
    private String inputString;
    private List<AddressBean> placesList;
    private SingleDataBindingNoPUseAdapter<AddressBean> addressAdapter;
    private AddressBean mAddressBean;
    private DialogLoading loadingDialog;

    public static Intent getIntents(Context context, double latitude, double longitude) {
        Intent intent = new Intent(context, SearchAddressActivity.class);
        intent.putExtra("latitude", latitude);
        intent.putExtra("longitude", longitude);
        return intent;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_search_address;
    }

    @Override
    protected SearchAddressViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(SearchAddressViewModel.class);
    }

    @Override
    protected RecyclerView.Adapter createAdapter() {
        addressAdapter = new SingleDataBindingNoPUseAdapter<AddressBean>(R.layout.item_search_address) {
            @Override
            public void convert(BaseViewHolder helper, AddressBean item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                if (TextUtils.isEmpty(item.getDistance()) || "null".equals(item.getDistance())) {
                    ((TextView) helper.getView(R.id.tvAddress)).setText(item.getAddress());
                    ((TextView) helper.getView(R.id.tvCoordinates)).setVisibility(View.GONE);
                    ((TextView) helper.getView(R.id.tvDistance)).setVisibility(View.GONE);
                } else {
//                    ((TextView)helper.getView(R.id.tvAddress)).setText(
//                            String.format(getString(R.string.select_address_distance_address),item.getDistance(),item.getAddress()));
                    ((TextView) helper.getView(R.id.tvCoordinates)).setVisibility(View.VISIBLE);
                    ((TextView) helper.getView(R.id.tvDistance)).setVisibility(View.VISIBLE);
                    ((TextView) helper.getView(R.id.tvAddress)).setText(item.getAddress());
                    ((TextView) helper.getView(R.id.tvCoordinates)).setText(getString(R.string.text_coordinates_str, " " +StringUtils.Companion.formatLatLng(item.getLontitude())+" "+  StringUtils.Companion.formatLatLng(item.getLatitude()) + " "));
                    if(!TextUtils.isEmpty(item.getDistance())){
                        ((TextView) helper.getView(R.id.tvDistance)).setText(item.getDistance());
                    }else {
                        ((TextView) helper.getView(R.id.tvDistance)).setText("- m");
                    }
                }
            }
        };
        addressAdapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                mAddressBean = (AddressBean) adapter.getData().get(position);
//                placesMethod.getPlaceByPlaceId(mAddressBean.getPlaceId());
                Intent intent = new Intent();
                intent.putExtra("addressBean", mAddressBean);
                setResult(333, intent);
                finish();
            }
        });
        return addressAdapter;
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvPlacesList;
    }

    @Override
    protected void initPageData() {
        placesMethod.getPlaces(latitude, longitude, mBinding.etInput.getText().toString());
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        getStatusView().setEnableLoadMore(false);
        getStatusView().setEnableRefresh(false);
        Intent intent = getIntent();
        latitude = intent.getDoubleExtra("latitude", 0.0);
        longitude = intent.getDoubleExtra("longitude", 0.0);
        placesMethod = MapFactory.INSTANCE.getPlacesMethod(this);
        placesMethod.oncreate(this);
        mBinding.setView(this);
        initObserver();
        initClick();
        onRefresh();
    }

    private void initClick() {
        mBinding.ivBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideSoftInput();
                finish();
            }
        });
        mBinding.etInput.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                    hideSoftInput();
                    if (loadingDialog == null) {
                        loadingDialog = new DialogLoading(SearchAddressActivity.this, false);
                    }
                    loadingDialog.onStart();
                    hideSoftInput();
                    onRefresh();
                    return true;
                }
                return false;
            }
        });
    }

    private void initObserver() {
        mBinding.etInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                mBinding.setData(s.toString());
                inputString = s.toString();
            }
        });
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.ivDelete:
                mBinding.etInput.setText("");
                break;
            default:
                break;
        }
    }

    @Override
    public void getPlaces(List<AddressBean> list) {
        updateListItems(list);
        if (loadingDialog != null) {
            loadingDialog.onFinish();
        }
    }

    @Override
    public void getPlacesByPlaceId(String name, String address, double latitude, double longitude, String distance) {
        if (latitude != 0 && longitude != 0) {
            Intent intent = new Intent();
            mAddressBean.setAddress(address);
            mAddressBean.setName(name);
            mAddressBean.setDistance(distance);
            mAddressBean.setLatitude(latitude);
            mAddressBean.setLontitude(longitude);
            mAddressBean.setLatitudeStr(String.valueOf(latitude));
            mAddressBean.setLontitudeStr(String.valueOf(longitude));
            intent.putExtra("addressBean", mAddressBean);
            setResult(333, intent);
            finish();
        }
    }
}