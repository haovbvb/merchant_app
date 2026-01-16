package com.okla.ops.views.workbench.devicedetail;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;

import androidx.core.content.ContextCompat;
import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.image.preview.ImagePreviewDialog;
import com.base.common.utils.DataStoreKeyUtils;
import com.base.common.utils.DataStoreUtils;
import com.base.common.utils.DateTimeUtils;
import com.base.common.utils.DensityUtil;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.DeviceInfo;
import com.okla.ops.custom.deviceinfo.MyGridItemDecoration;
import com.okla.ops.databinding.FragmentDeviceBaseInfoBinding;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class DeviceBaseInfoFragment extends BaseNormalVFragment<DeviceDetailViewModel, FragmentDeviceBaseInfoBinding> {

    public static DeviceBaseInfoFragment getInstance(int type) {
        DeviceBaseInfoFragment fragment = new DeviceBaseInfoFragment();
        Bundle bundle = new Bundle();
        bundle.putInt("type", type);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_device_base_info;
    }

    @Override
    protected DeviceDetailViewModel onCreateViewModel() {
        return new ViewModelProvider(getActivity()).get(DeviceDetailViewModel.class);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        int type = 0;
        Bundle arguments = getArguments();
        if (arguments != null) {
            type = arguments.getInt("type", 0);
            mBinding.setType(type);
        }
        mBinding.setData(getViewModel().mDeviceInfo.getValue());
        initAdapter();
        initData(type);
    }

    private final List<String> mImageUrlList = new ArrayList<>();
    private SingleDataBindingNoPUseAdapter adapter;

    private void initAdapter() {
        mBinding.rvPhotos.setLayoutManager(new GridLayoutManager(getContext(), 3));
        mBinding.rvPhotos.addItemDecoration(new MyGridItemDecoration(3, DensityUtil.dp2px(12)));
        adapter = new SingleDataBindingNoPUseAdapter<String>(R.layout.item_device_info_photo) {
            @Override
            public void convert(BaseViewHolder helper, String item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                Glide.with(getActivity()).load(item).error(R.mipmap.ic_add_photo)
                        .apply(RequestOptions.bitmapTransform(new RoundedCorners(DensityUtil.dp2px(4))).centerCrop())
                        .into((ImageView) helper.getView(R.id.ivPhoto));
            }
        };
        adapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                ImagePreviewDialog.getInstance(mImageUrlList, position).showNow(getParentFragmentManager(), "");
            }
        });
        mBinding.rvPhotos.setAdapter(adapter);
    }

    private void initData(int type) {
        DeviceInfo deviceInfo = getViewModel().mDeviceInfo.getValue();
        if (deviceInfo != null) {
            if (!TextUtils.isEmpty(deviceInfo.getImgList())) {
                String[] imgPaths = deviceInfo.getImgList().split(",");
                mImageUrlList.addAll(Arrays.asList(imgPaths));
                adapter.setNewData(mImageUrlList);
            }
//            List<ManagerInfo> managerList = deviceInfo.getManagerList();
//            if (managerList != null && managerList.size() > 0) {
//                StringBuilder stringBuilder = new StringBuilder();
//                for (int i = 0; i < managerList.size(); i++) {
//                    ManagerInfo managerInfo = managerList.get(i);
//                    stringBuilder.append(managerInfo.getShowName());
//                    if (i != managerList.size() - 1) {
//                        stringBuilder.append(",");
//                    }
//                }
//                mBinding.invManagers.setValue(stringBuilder.toString());
//            }
            if (type == DeviceDetailFragment.DEVICE_TYPE_CAR || type == DeviceDetailFragment.DEVICE_TYPE_CABIN) {
                mBinding.invDeviceStatus.setVisibility(View.GONE);
            } else {
                mBinding.invDeviceStatus.setVisibility(View.VISIBLE);
                Integer onlineStatus = deviceInfo.getOnlineStatus();
                if (onlineStatus != null) {
                    if (onlineStatus == 1) {
                        mBinding.invDeviceStatus.setValue(getContext().getString(R.string.online));
                        mBinding.invDeviceStatus.addValueDrawable(ContextCompat.getDrawable(getContext(), R.mipmap.icon_signal_online));
                    } else {
                        mBinding.invDeviceStatus.setValue(getContext().getString(R.string.offline));
                        mBinding.invDeviceStatus.addValueDrawable(ContextCompat.getDrawable(getContext(), R.mipmap.icon_signal_offline));
                    }
                } else {
                    mBinding.invDeviceStatus.setValue("-");
                }
            }
            mBinding.invUserName.setValueColor(ContextCompat.getColor(mActivity, R.color.color_0b61d9));
            mBinding.invUserPhone.setValueColor(ContextCompat.getColor(mActivity, R.color.color_0b61d9));
            String phone = "-";
            if (!TextUtils.isEmpty(deviceInfo.getBindUserPhone())) {
                phone = DataStoreUtils.readStringData(
                        DataStoreKeyUtils.Companion.getAREA_CODE(),
                        ""
                ) + " " + deviceInfo.getBindUserPhone();
            }
            mBinding.invUserPhone.setValue(phone);
            String boundTime = "-";
            if (!TextUtils.isEmpty(deviceInfo.getBindTime())) {
                boundTime = deviceInfo.getBindTime();
                mBinding.invBindTime.setValue(DateTimeUtils.getTimeFormatString("yyyy-MM-dd HH:mm:ss", boundTime));
            } else {
                mBinding.invBindTime.setValue("-");
            }

            if (type == DeviceDetailFragment.DEVICE_TYPE_CABIN) {
                mBinding.llBindInfo.setVisibility(View.GONE);
                mBinding.llStationBindinfo.setVisibility(View.VISIBLE);
                if(deviceInfo.getInstallStatus()!=null){
                    if (deviceInfo.getInstallStatus() == 0) {
                        mBinding.invBindState.addValueDrawable(ContextCompat.getDrawable(getContext(), R.drawable.shape_circle_fa4b51));
                        mBinding.invBindState.setValue(getString(R.string.device_detail_status_not_boarded));
                    } else if (deviceInfo.getInstallStatus() == 1) {
                        mBinding.invBindState.addValueDrawable(ContextCompat.getDrawable(getContext(), R.drawable.shape_circle_56b327));
                        mBinding.invBindState.setValue(getString(R.string.device_detail_status_onboarded));
                    }
                }else {
                    mBinding.invBindState.setValue("-");

                }
                if (deviceInfo.getManagerList()!=null&& !deviceInfo.getManagerList().isEmpty()) {
                    if (deviceInfo.getManagerList().get(0) != null) {
                        if (deviceInfo.getManagerList().get(0).getShowName() != null) {
                            mBinding.invResonsible.setValue(deviceInfo.getManagerList().get(0).getShowName());
                        } else {
                            mBinding.invResonsible.setValue("-");
                        }
                    } else {
                        mBinding.invResonsible.setValue("-");
                    }
                } else {
                    mBinding.invResonsible.setValue("-");
                }
            } else {
                mBinding.llStationBindinfo.setVisibility(View.GONE);
                mBinding.llBindInfo.setVisibility(View.VISIBLE);
            }
        }
    }

}
