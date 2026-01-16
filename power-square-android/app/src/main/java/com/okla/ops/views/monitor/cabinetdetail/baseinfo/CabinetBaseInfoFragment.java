package com.okla.ops.views.monitor.cabinetdetail.baseinfo;

import android.Manifest;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import androidx.annotation.Nullable;
import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.image.preview.ImagePreviewDialog;
import com.base.common.image.select.SelectImageFactory;
import com.base.common.net.loading.DialogLoading;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.timepicker.CustomDatePicker;
import com.base.common.timepicker.DateFormatUtils;
import com.base.common.utils.ClipboardUtils;
import com.base.common.utils.LanguageUtils;
import com.base.common.utils.ToastUtils;
import com.bumptech.glide.Glide;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.luck.picture.lib.utils.SdkVersionUtils;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.databinding.FragmentCabinetBaseInfoBinding;
import com.google.android.flexbox.FlexboxLayoutManager;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.okla.ops.R;
import com.okla.ops.beans.AddressBean;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.beans.CurrentPointBean;
import com.okla.ops.beans.ImageBean;
import com.okla.ops.dialog.SelectPointTypeDialog;
import com.okla.ops.views.monitor.cabinetdetail.baseinfo.personliable.SelectPersonLiableActivity;
import com.okla.ops.views.monitor.cabinetdetail.layoutrecord.LayoutRecordActivity;
import com.okla.ops.views.workbench.selectaddress.SelectAddressActivity;

import java.util.ArrayList;
import java.util.List;

/**
 * @Date: 2021/1/26 14:09
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinetBaseInfoFragment extends BaseNormalVFragment<CabinetBaseInfoViewModel, FragmentCabinetBaseInfoBinding> {

    private Observer<CabinetDetailBaseInfoBean> baseInfoObserver;
    CabinetDetailBaseInfoBean mBaseInfoBean;
    private SingleDataBindingNoPUseAdapter adapter;
    private String mCabinetSN;
    private Observer<List<CurrentPointBean>> mCurrentAndPointObserver;
    private List<CurrentPointBean> mCurrentAndPointBeans;
    private SelectPointTypeDialog mSelectPointTypeDialog;
    private CustomDatePicker mTimerPicker;
    private Observer<List<ImageBean>> imageObserver;
    private List<ImageBean> mImageBeanList = new ArrayList<>();
    private List<String> mImageUrlList = new ArrayList<>();
    private BottomSheetDialog mBottomSheetDialog;
    private SelectImageFactory selectImageFactory;
    private Observer<List<String>> mUpdateImageObserver;
    private Observer<String> modifyInfoObserver;
    private SingleDataBindingNoPUseAdapter<CabinetDetailBaseInfoBean.ManagerBean> mFlexBoxAdapter;
    private DialogLoading loadingDialog;
    private boolean isStationEditPermission=false;


    public static CabinetBaseInfoFragment getInstance(String sn,boolean isStationEditPermission) {
        CabinetBaseInfoFragment fragment = new CabinetBaseInfoFragment();
        Bundle bundle = new Bundle();
        bundle.putString("sn", sn);
        bundle.putBoolean("isStationEditPermission", isStationEditPermission);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_cabinet_base_info;
    }

    @Override
    protected CabinetBaseInfoViewModel onCreateViewModel() {
        return new ViewModelProvider(getActivity()).get(CabinetBaseInfoViewModel.class);
    }
    private PermissionManager permissionManager;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        permissionManager = PermissionManager.getInstance(
                requireActivity().getActivityResultRegistry(),
                this.getClass().getName(),
                this
        );

        getLifecycle().addObserver(permissionManager);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        mBinding.setView(this);
        initAdapter();
        initObserver();
        initSelectImgFactory();
    }

    private void initAdapter() {
        mBinding.rvPhotos.setLayoutManager(new StaggeredGridLayoutManager(3, StaggeredGridLayoutManager.VERTICAL));
        adapter = new SingleDataBindingNoPUseAdapter<ImageBean>(R.layout.item_putaway_cabinet_photo) {
            @Override
            public void convert(BaseViewHolder helper, ImageBean item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                if (item.isEdit) {
                    if (item.isAdd) {
                        helper.getView(R.id.ivDeletePhoto).setVisibility(View.GONE);
                    } else {
                        helper.getView(R.id.ivDeletePhoto).setVisibility(View.VISIBLE);
                    }
                } else {
                    helper.getView(R.id.ivDeletePhoto).setVisibility(View.GONE);
                }
                Glide.with(getActivity()).load(item.fileUri).error(R.mipmap.ic_add_photo).into((ImageView) helper.getView(R.id.ivPhoto));
                helper.getView(R.id.ivDeletePhoto).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mImageBeanList.remove(item);
                        if (mImageBeanList.size() == 4 && !mImageBeanList.get(3).isAdd) {
                            mImageBeanList.add(new ImageBean(true));
                        }
                        setPhotoNum(mImageBeanList.size() - 1);
                        adapter.setNewData(mImageBeanList);
                    }
                });
            }
        };
        adapter.setOnItemClickListener(new BaseQuickAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(BaseQuickAdapter adapter, View view, int position) {
                if (position == mImageBeanList.size() - 1 && mImageBeanList.get(position).isAdd) {
                    initBottomSheet();
                } else {
                    mImageUrlList.clear();
                    for (int i = 0; i < mImageBeanList.size(); i++) {
                        if (!mImageBeanList.get(i).isAdd) {
                            mImageUrlList.add(mImageBeanList.get(i).fileUri.toString());
                        }
                    }
                    ImagePreviewDialog.getInstance(mImageUrlList, position).showNow(getParentFragmentManager(), "");
                }
            }
        });
        mBinding.rvPhotos.setAdapter(adapter);
    }

    /**
     * 初始化拍照底部弹框
     */
    public void initBottomSheet() {
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = new BottomSheetDialog(getContext());
            View view = LayoutInflater.from(getContext()).inflate(com.base.common.R.layout.dialog_take_photo_sheet, null, false);
            Button takePhotoBt = (Button) view.findViewById(com.base.common.R.id.take_photo_bt);
            Button pictureBt = (Button) view.findViewById(com.base.common.R.id.picture_bt);
            Button btnCancel = (Button) view.findViewById(com.base.common.R.id.btn_cancel);
            takePhotoBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    askCameraPermission();
                    mBottomSheetDialog.dismiss();
                }
            });
            pictureBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    selectImageFactory.gallery(CabinetBaseInfoFragment.this);
                    mBottomSheetDialog.dismiss();
                }
            });
            btnCancel.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mBottomSheetDialog.dismiss();
                }
            });
            mBottomSheetDialog.setContentView(view);
        }
        mBottomSheetDialog.show();
    }
    private void askCameraPermission() {
        List<String> permissions = new ArrayList<>();
        permissions.add(Manifest.permission.CAMERA);
        // Android 13 (Tiramisu) 以上版本不再需要 READ_EXTERNAL_STORAGE 权限
        if (SdkVersionUtils.isTIRAMISU()) {
            permissions.remove(Manifest.permission.READ_EXTERNAL_STORAGE);
        }

        permissionManager.checkPermissions(new PermissionListenerImpl() {
            @Override
            public void passPermission() {
                super.passPermission();
                selectImageFactory.cameraPhotoFile(CabinetBaseInfoFragment.this);
            }

            @Override
            public void showRequestPermissionRationale() {
                super.showRequestPermissionRationale();
                PermissionManager.askForPermission(mActivity, "");
            }
        }, permissions.toArray(new String[0]));
    }



    private void initSelectImgFactory() {
        selectImageFactory = new SelectImageFactory() {
            @Override
            public void upLoadImageFile(Uri file) {
                mImageBeanList.add(mImageBeanList.size() - 1, new ImageBean(file, false,true));
                setPhotoNum(mImageBeanList.size() - 1);
                if (mImageBeanList.size() > 5) {
                    adapter.remove(mImageBeanList.size() - 1);
                }
                adapter.setNewData(mImageBeanList);
            }
        };
    }

    private void setPhotoNum(int i) {
        mBinding.tvBaseInfoPhotoNum.setText(String.format(getString(R.string.cabinet_detail_photo_num), i));
    }


    String imgs = "";
    StringBuilder imgsStringBuilder;

    private void initObserver() {
        mCabinetSN = getArguments().getString("sn");
        isStationEditPermission = getArguments().getBoolean("isStationEditPermission");

        baseInfoObserver = cabinetDetailBaseInfoBean -> {
//            getLoading().onFinish();
            loadingDialog.onFinish();
            if (cabinetDetailBaseInfoBean == null) {
                return;
            }
            labelCode = cabinetDetailBaseInfoBean.getLabel() + "";
            mBaseInfoBean = cabinetDetailBaseInfoBean;
            mBinding.setData(cabinetDetailBaseInfoBean);
            //TODO
//            EventBus.getDefault().post(new MaxcEventBusBean(Double.parseDouble(cabinetDetailBaseInfoBean.getMaxC()) / 10));
            setPersonLiable(mBaseInfoBean.getManager());
            getFileAndShowImages();
            if(mBaseInfoBean.isEditFlag()||isStationEditPermission){
                mBinding.clBottom.setVisibility(View.VISIBLE);
            }else {
                mBinding.clBottom.setVisibility(View.GONE);
            }
        };
        if (loadingDialog == null) {
            loadingDialog = new DialogLoading(getContext(), false);
        }
        loadingDialog.onStart();
//        getLoading().onStart();
        getViewModel().getCabinetBaseInfo(mCabinetSN).observe(this, baseInfoObserver);
        //获取充电电流列表 和 设置点类型
        mCurrentAndPointObserver = currentAndPointBeans -> {
            if (currentAndPointBeans != null) {
                mCurrentAndPointBeans = currentAndPointBeans;
//                setPointType();
            }
        };
        getViewModel().getCurrentAndPoints().observe(this, mCurrentAndPointObserver);

        //上传图片
        mUpdateImageObserver = strList -> {
            showImagesNotEdit();
            mBinding.tvBaseInfoPhotoNum.setVisibility(View.GONE);
            mBinding.tvBaseInfoPhotoEdit.setVisibility(View.VISIBLE);
            mBinding.ivLocate.setVisibility(View.GONE);
            mBinding.etBaseInfoAddress.setEnabled(false);
            mBinding.tvPointTypeValue.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0);
            mBinding.tvPersonLiable.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0);
            mBinding.tvBaseInfoPhotoSave.setVisibility(View.GONE);
            mBinding.tvBaseInfoPhotoCancel.setVisibility(View.GONE);
            if (strList != null && strList.size() == 1) {
                imgs = strList.get(0);
            } else {
                imgsStringBuilder = new StringBuilder();
                for (int i = 0; i < strList.size(); i++) {
                    if (i == 0) {
                        imgsStringBuilder.append(strList.get(i));
                    } else {
                        imgsStringBuilder.append(",");
                        imgsStringBuilder.append(strList.get(i));
                    }
                }
                imgs = imgsStringBuilder.toString();
            }
            getViewModel().modifyCabinetInfo(mCabinetSN, mBinding.etBaseInfoAddress.getText().toString(),
                    mAddressBean == null ? (mBaseInfoBean == null ? "" : mBaseInfoBean.getLongitude() + "," + mBaseInfoBean.getLatitude())
                            : mAddressBean.getLontitudeStr() + "," + mAddressBean.getLatitudeStr(), imgs, labelCode)
                    .observe(this, modifyInfoObserver);
        };
        modifyInfoObserver = str -> {
            getViewModel().getCabinetBaseInfo(mCabinetSN).observe(this, baseInfoObserver);
        };
    }

    private void startEdit() {
        for (int i = 0; i < mImageBeanList.size(); i++) {
            mImageBeanList.get(i).setEdit(true);
        }
        if (mImageBeanList.size() > 0 && !mImageBeanList.get(mImageBeanList.size() - 1).isAdd) {
            setPhotoNum(mImageBeanList.size());
            if(mImageBeanList.size() < 5) {
                mImageBeanList.add(new ImageBean(true));
            }
        } else {
            if (mImageBeanList.size() == 0) {
                setPhotoNum(0);
                mImageBeanList.add(new ImageBean(true));
            } else {
                setPhotoNum(mImageBeanList.size() - 1);
            }
        }
        adapter.setNewData(mImageBeanList);
    }

    private void showImagesNotEdit() {
        for (int i = 0; i < mImageBeanList.size(); i++) {
            mImageBeanList.get(i).setEdit(false);
        }
        if (mImageBeanList.size() > 0 && mImageBeanList.get(mImageBeanList.size() - 1).isAdd) {
            mImageBeanList.remove(mImageBeanList.size() - 1);
        }
        adapter.setNewData(mImageBeanList);
    }

    //将image url转换为File展示
    private void getFileAndShowImages() {
        imageObserver = imageBeans -> {
            mImageBeanList.clear();
            mImageBeanList.addAll(imageBeans);
            adapter.setNewData(mImageBeanList);
        };
        /*if (!TextUtils.isEmpty(mBaseInfoBean.getImgs())) {
            imgs = mBaseInfoBean.getImgs();
            getViewModel().getImagesList(imgs).observe(this, imageObserver);
        }*/
        if (mBaseInfoBean.getImgs() != null && !mBaseInfoBean.getImgs().isEmpty()) {
            getViewModel().getImagesList(mBaseInfoBean.getImgs()).observe(this, imageObserver);
        }
    }

    //设置责任人
    private void setPersonLiable(List<CabinetDetailBaseInfoBean.ManagerBean> managerBeanList) {
        mBinding.rvFlexBox.setLayoutManager(new FlexboxLayoutManager(getContext()));
        mFlexBoxAdapter = new SingleDataBindingNoPUseAdapter<>(R.layout.item_flexbox_responsible_person);
        mBinding.rvFlexBox.setAdapter(mFlexBoxAdapter);
        mFlexBoxAdapter.setNewData(managerBeanList);
    }

    //设置地点类型
    private void setPointType() {
        if (mBaseInfoBean == null || mCurrentAndPointBeans == null || mCurrentAndPointBeans.size() <= 0) {
            return;
        }
        for (int i = 0; i < mCurrentAndPointBeans.size(); i++) {
            if (String.valueOf(mBaseInfoBean.getLabel()).equals(mCurrentAndPointBeans.get(i).getCode())) {
                mBinding.tvPointTypeValue.setText(mCurrentAndPointBeans.get(i).getValue());
            }
        }
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.tvPersonLiable:
                if (mBinding.tvBaseInfoPhotoEdit.getVisibility() == View.VISIBLE) {
                    return;
                }
                if (mBaseInfoBean != null) {
                    startActivityForResult(SelectPersonLiableActivity.getIntents(getActivity(), mCabinetSN,
                            (ArrayList<CabinetDetailBaseInfoBean.ManagerBean>) mBaseInfoBean.getManager()), 333);
                } else {
                    startActivityForResult(SelectPersonLiableActivity.getIntents(getActivity(), mCabinetSN, null), 333);
                }
                break;
            case R.id.tvSnCopy:
                if (!TextUtils.isEmpty(mBinding.tvSnValue.getText().toString())) {
                    ClipboardUtils.setClipboardCopyText(getActivity(), mBinding.tvSnValue.getText().toString(), getString(R.string.textCopySuccess));
                }
                break;
            case R.id.tvPidCopy:
                if (!TextUtils.isEmpty(mBinding.tvPidValue.getText().toString())) {
                    ClipboardUtils.setClipboardCopyText(getActivity(), mBinding.tvPidValue.getText().toString(), getString(R.string.textCopySuccess));
                }
                break;
            case R.id.ivLocate:
                startActivityForResult(new Intent(getContext(), SelectAddressActivity.class), 111);
                break;
            case R.id.tvLayoutTime:
                if (mBaseInfoBean != null) {
                    startActivity(LayoutRecordActivity.getIntents(getActivity(), mBaseInfoBean.getSn()));
                }
//                initTimerPicker();
//                if(mBaseInfoBean != null && !TextUtils.isEmpty(mBinding.tvLayoutTimeValue.getText().toString())) {
//                    mTimerPicker.show(mBinding.tvLayoutTimeValue.getText().toString());
//                }else {
//                    mTimerPicker.show(System.currentTimeMillis());
//                }
                break;
            case R.id.tvPointType:
                if (mBinding.tvBaseInfoPhotoEdit.getVisibility() == View.VISIBLE) {
                    return;
                }
                initPointTypeDialog();
                break;
            case R.id.tvBaseInfoPhotoSave:
                if (mImageBeanList.size() > 0  && !mImageBeanList.get(0).isAdd) {
                    if (loadingDialog == null) {
                        loadingDialog = new DialogLoading(getContext(), false);
                    }
                    loadingDialog.onStart();
                    getViewModel().updateCabinetImage(mBinding.tvPidValue.getText().toString(),
                            mImageBeanList).observe(CabinetBaseInfoFragment.this, mUpdateImageObserver);
                }else {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_more_than_one_picture_tip));
                }
                break;
            case R.id.tvBaseInfoPhotoEdit:
                mBinding.tvBaseInfoPhotoNum.setVisibility(View.VISIBLE);
                mBinding.tvBaseInfoPhotoEdit.setVisibility(View.GONE);
                mBinding.tvBaseInfoPhotoSave.setVisibility(View.VISIBLE);
                mBinding.tvBaseInfoPhotoCancel.setVisibility(View.VISIBLE);
                mBinding.ivLocate.setVisibility(View.VISIBLE);
                mBinding.etBaseInfoAddress.setEnabled(true);
                mBinding.tvPointTypeValue.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, R.mipmap.arrow_next, 0);
                mBinding.tvPersonLiable.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, R.mipmap.arrow_next, 0);
                startEdit();
                break;
            case R.id.tvBaseInfoPhotoCancel:
                mBinding.tvBaseInfoPhotoNum.setVisibility(View.GONE);
                showImagesNotEdit();
                mBinding.tvBaseInfoPhotoEdit.setVisibility(View.VISIBLE);
                mBinding.ivLocate.setVisibility(View.GONE);
                mBinding.etBaseInfoAddress.setEnabled(false);
                mBinding.tvPointTypeValue.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0);
                mBinding.tvPersonLiable.setCompoundDrawablesRelativeWithIntrinsicBounds(0, 0, 0, 0);
                mBinding.tvBaseInfoPhotoSave.setVisibility(View.GONE);
                mBinding.tvBaseInfoPhotoCancel.setVisibility(View.GONE);
                break;

            default:
                break;
        }
    }

    private void initTimerPicker() {
        String beginTime = "2015/01/01 01:00:00";
        String endTime = DateFormatUtils.long2Str(System.currentTimeMillis(), true, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());

        // 通过日期字符串初始化日期，格式请用：yyyy-MM-dd HH:mm
        mTimerPicker = new CustomDatePicker(getContext(), new CustomDatePicker.Callback() {
            @Override
            public void onTimeSelected(long timestamp) {
                mBinding.tvLayoutTimeValue.setText(DateFormatUtils.long2Str(timestamp, true,LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage()));
            }
        }, beginTime, endTime);
        // 允许点击屏幕或物理返回键关闭
        mTimerPicker.setCancelable(true);
        // 显示时和分
        mTimerPicker.setCanShowPreciseTime(true);
        // 允许循环滚动
        mTimerPicker.setScrollLoop(true);
        // 允许滚动动画
        mTimerPicker.setCanShowAnim(true);
    }

    String labelCode;

    private void initPointTypeDialog() {
        if (mCurrentAndPointBeans == null || mCurrentAndPointBeans.size() <= 0) {
            return;
        }
        if (mSelectPointTypeDialog == null) {
            mSelectPointTypeDialog = new SelectPointTypeDialog(getContext(), mCurrentAndPointBeans)
                    .setOnSelectClickListener(bean -> {
                        labelCode = bean.getCode();
                        mBinding.tvPointTypeValue.setText(bean.getValue());
                    });
        }
        if (!mSelectPointTypeDialog.isShowing()) {
            mSelectPointTypeDialog.showPopupWindow();
        }
    }

    AddressBean mAddressBean;
    ArrayList<CabinetDetailBaseInfoBean.ManagerBean> mPersonLiableList;

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 111) {
            if (data != null) {
                mAddressBean = (AddressBean) data.getSerializableExtra("addressBean");
                if (mAddressBean != null) {
                    mBinding.etBaseInfoAddress.setText(mAddressBean.getAddress());
                    mBinding.tvBaseInfoLonAndLat.setText(mAddressBean.getLatitudeStr() + "," + mAddressBean.getLontitudeStr());
                }
            }
        } else if (requestCode == 333) {
            if (data != null && mBaseInfoBean != null) {
                mPersonLiableList = data.getParcelableArrayListExtra("list");
                mBaseInfoBean.getManager().clear();
                mBaseInfoBean.getManager().addAll(mPersonLiableList);
                setPersonLiable(mPersonLiableList);
            }
        } else {
            selectImageFactory.onActivityResult(requestCode, resultCode, data, CabinetBaseInfoFragment.this, null);
        }

    }

    private int nID = 1;
    public void reFreshSn(String mCabinetPID, String mCabinetSN, int nID) {
        this.mCabinetSN = mCabinetSN;
        this.nID = nID;
        if (nID == 1) {
            //主柜
            mBinding.tvPersonLiable.setEnabled(true);
            mBinding.tvPersonLiable.setCompoundDrawablesWithIntrinsicBounds(0, 0, R.mipmap.arrow_next, 0);
            mBinding.clBottom.setVisibility(View.VISIBLE);
//            mBinding.tvBusinessHoursDateValue.setCompoundDrawablesWithIntrinsicBounds(0, 0, R.mipmap.arrow_next, 0);
//            isMainCabinet = true;
        } else {
            //副柜不可操作基本信息和干系人
            mBinding.tvPersonLiable.setEnabled(false);
            mBinding.tvPersonLiable.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0);
            mBinding.clBottom.setVisibility(View.GONE);
//            mBinding.tvBusinessHoursDateValue.setCompoundDrawablesWithIntrinsicBounds(0, 0, 0, 0);
//            isMainCabinet = false;
        }
//        mTimeQuantumAdapter.notifyDataSetChanged();
        mBinding.tvSnValue.setText(mCabinetSN);
        mBinding.tvPidValue.setText(mCabinetPID);
//        getViewModel().getCabinetBaseInfo(mCabinetSN).observe(this, baseInfoObserver);
    }
}