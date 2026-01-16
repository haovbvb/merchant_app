package com.okla.ops.views.workbench.putawaycabinet;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.dialog.CustomDialog;
import com.base.common.image.preview.ImagePreviewDialog;
import com.base.common.image.select.SelectImageFactory;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.ToastUtils;
import com.bumptech.glide.Glide;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.databinding.ActivityPutawayCabinetBinding;
import com.okla.ops.databinding.ItemPutawayCabinetPhotoFooterviewBinding;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.okla.ops.R;
import com.okla.ops.beans.AddressBean;
import com.okla.ops.beans.CabinetAndCameraBoundBean;
import com.okla.ops.beans.CityCode;
import com.okla.ops.beans.CurrentPointBean;
import com.okla.ops.beans.ImageBean;
import com.okla.ops.beans.NewCabinetBean;
import com.okla.ops.dialog.SelectChargeCurrentDialog;
import com.okla.ops.dialog.SelectCityCenterDialog;
import com.okla.ops.dialog.SelectPointTypeDialog;
import com.okla.ops.utils.EventUtils;
import com.okla.ops.utils.ScanUtils;
import com.okla.ops.views.workbench.QRCodeActivity;
import com.okla.ops.views.workbench.selectaddress.SelectAddressActivity;

import java.io.File;
import java.util.ArrayList;
import java.util.List;


/**
 * @Date: DATE.{TIME}
 * @Author: hong_world
 * @Description:
 * @Version:
 */
public class PutawayCabinetActivity extends BaseNormalVActivity<PutawayCabinetViewModel, ActivityPutawayCabinetBinding> implements View.OnFocusChangeListener {

    private BottomSheetDialog mBottomSheetDialog;
    private SelectImageFactory selectImageFactory;
    private List<ImageBean> mImageBeanList;//存储图片集合
    private List<String> mImageUrlList = new ArrayList<>();
    private SingleDataBindingNoPUseAdapter adapter;
    private AddressBean addressBean;
    private Observer<List<CurrentPointBean>> mCurrentAndPointObserver;
    private SelectChargeCurrentDialog mSelectChargeCurrentDialog;
    private SelectPointTypeDialog mSelectPointTypeDialog;
    private Observer<List<String>> mUpdateImageObserver;
    private Observer<String> mUploadImageObserver;
    private ItemPutawayCabinetPhotoFooterviewBinding footvewBinding;
    private SelectCityCenterDialog mSelectCityCenterDialog;
    private List<CityCode> mCityCodeList;
    private Observer<List<CityCode>> mCityCodeObserver;
    private Observer<String> mPutawayCabinetObserver;
    private Observer<CabinetAndCameraBoundBean> mCabinetAndCameraBoundObserver;
    private Observer<String> mUnbindCabinetAndCameraObserver;
    private CustomDialog tipDialog;
    private CustomDialog.Builder builder;
    private CabinetAndCameraBoundBean mCabinetAndCameraBoundBean;

    public static Intent getIntents(Context context) {
        Intent intent = new Intent(context, PutawayCabinetActivity.class);
        return intent;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_putaway_cabinet;
    }

    @Override
    protected PutawayCabinetViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(PutawayCabinetViewModel.class);
    }

    @Override
    public int title() {
        return R.string.putaway_cabinet_title;
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setViewModel(viewModel);
        mBinding.setView(this);
        initRecyclerview();
        initSelectImgFactory();
        initObserver();
        initEditViewListener();
    }

    private void initEditViewListener() {
        mBinding.etBatteryCabinetSN.setOnFocusChangeListener(this);
    }

    private void initRecyclerview() {
        mBinding.rvPhotos.setLayoutManager(new StaggeredGridLayoutManager(3, StaggeredGridLayoutManager.VERTICAL));
        adapter = new SingleDataBindingNoPUseAdapter<ImageBean>(R.layout.item_putaway_cabinet_photo) {
            @Override
            protected void convert(BaseViewHolder helper, ImageBean item) {
                super.convert(helper, item);
                if (item.isAdd) {
                    helper.getView(R.id.ivDeletePhoto).setVisibility(View.GONE);
                } else {
                    helper.getView(R.id.ivDeletePhoto).setVisibility(View.VISIBLE);
                }
                Glide.with(PutawayCabinetActivity.this).load(item.fileUri).error(R.mipmap.ic_add_photo).into((ImageView) helper.getView(R.id.ivPhoto));
                helper.getView(R.id.ivDeletePhoto).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mUploadImgList != null) {
                            int index = 0;
                            for (int i = 0; i < mImageBeanList.size(); i++) {
                                if (mImageBeanList.get(i) != null && mImageBeanList.get(i).equals(item)) {
                                    index = i;
                                    break;
                                }
                            }
                            if (mUploadImgList.size() > index) {
                                mUploadImgList.remove(index);
                            }
                        }
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
                    ImagePreviewDialog.getInstance(mImageUrlList, position).showNow(getSupportFragmentManager(), "");
                }
            }
        });
        mBinding.rvPhotos.setAdapter(adapter);
    }

    private void setPhotoNum(int i) {
        mBinding.tvBatteryCabinetPhotoNum.setText(String.format(getString(R.string.cabinet_detail_photo_num), i));
    }

    //    CurrentAndPointBean mCurrentAndPointBean;
    List<CurrentPointBean> mCurrentPointBeans;
    String imgs = "";
    StringBuilder imgsStringBuilder;

    private List<String> mUploadImgList;

    private void initObserver() {
        //获取城市列表
        mCityCodeObserver = new Observer<List<CityCode>>() {
            @Override
            public void onChanged(List<CityCode> list) {
                if (mCityCodeList == null) {
                    mCityCodeList = new ArrayList<>();
                }
                if (list != null && list.size() > 0) {
                    mCityCodeList.clear();
                    mCityCodeList.addAll(list);
                }
            }
        };
//        getViewModel().getCityCodeList().observe(this, mCityCodeObserver);

        //获取充电电流列表 和 设置点类型
        mCurrentAndPointObserver = new Observer<List<CurrentPointBean>>() {
            @Override
            public void onChanged(List<CurrentPointBean> currentPointBeans) {
                if (currentPointBeans != null) {
                    mCurrentPointBeans = currentPointBeans;
                }
            }
        };
        getViewModel().getCurrentAndPoints().observe(this, mCurrentAndPointObserver);

        //上传图片
        mUpdateImageObserver = new Observer<List<String>>() {
            @Override
            public void onChanged(List<String> strList) {
                if (strList != null) {
                    if (strList.size() == 1) {
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
                }
                getViewModel().putawayCabinet(mBinding.etBatteryCabinetSN.getText().toString(),
                        mBinding.etBatteryCabinetSN.getText().toString(),
                        mCityCode != null ? mCityCode.getCode() : "",
                        addressBean.getLatitude(),
                        addressBean.getLontitude(),
//                        22.5340017,113.9371933,
                        0L,
                        getCabinetName(),
                        getStationModel(),
                        mBinding.etBatteryCabinetSerialNum.getText().toString(),
                        mBinding.etBatteryCabinetVerificationCode.getText().toString(),
                        "",
                        mCurrentPointBean != null ? mCurrentPointBean.getCode() : "",
                        imgs,
                        mBinding.etBatteryCabinetAddress.getText().toString()
                        /*"xxxxxxxxxx"*/).observe(PutawayCabinetActivity.this, mPutawayCabinetObserver);
            }
        };
        mUploadImageObserver = new Observer<String>() {
            @Override
            public void onChanged(String s) {
                if (mUploadImgList == null) {
                    mUploadImgList = new ArrayList<>();
                }
                mUploadImgList.add(s);
            }
        };
        getViewModel().mUploadImageBean.observe(PutawayCabinetActivity.this, new Observer<ImageBean>() {
            @Override
            public void onChanged(ImageBean imageBean) {
                mImageBeanList.add(mImageBeanList.size() - 1, imageBean);
                setPhotoNum(mImageBeanList.size() - 1);
                if (mImageBeanList.size() > 5) {
                    adapter.remove(mImageBeanList.size() - 1);
                }
                adapter.setNewData(mImageBeanList);
            }
        });
        //上传柜子信息
        mPutawayCabinetObserver = new Observer<String>() {
            @Override
            public void onChanged(String str) {
                getLoading().onFinish();
                EventUtils.INSTANCE.getUnshelveReaderData().setValue(true);
                finish();
            }
        };
        //校验柜子摄像头是否存在绑定关系
        mCabinetAndCameraBoundObserver = mBean -> {
            //status=  0正常  1摄像头已经绑定了换电柜xxxxxxx  2换电柜已经绑定了其他摄像头
            mCabinetAndCameraBoundBean = mBean;
            if (mCabinetAndCameraBoundBean.getStatus() == 0) {
                //上传图片
//                getViewModel().updateCabinetImages(mBinding.etBatteryCabinetSN.getText().toString(),
//                        mImageBeanList).observe(PutawayCabinetActivity.this, mUpdateImageObserver);
                getViewModel().updateCabinetImages(mUploadImgList).observe(PutawayCabinetActivity.this, mUpdateImageObserver);
            } else if (mCabinetAndCameraBoundBean.getStatus() == 1) {
                getLoading().onFinish();
                //解绑弹窗
                showTipDialog();
            } else if (mCabinetAndCameraBoundBean.getStatus() == 2) {
                getLoading().onFinish();
                //解绑弹窗
                showTipDialog();
            }
        };
        //解绑摄像头或者柜子
        mUnbindCabinetAndCameraObserver = str -> {
            if (mCabinetAndCameraBoundBean == null) {
                return;
            }
            if (mCabinetAndCameraBoundBean.getStatus() == 1) {
                //校验柜子是否也有绑定摄像头
                getViewModel().checkCabinetAndCameraBound(mBinding.etBatteryCabinetSerialNum.getText().toString(),
                        mBinding.etBatteryCabinetSN.getText().toString()).observe(this, mCabinetAndCameraBoundObserver);
            } else {
                //上传图片
//                getViewModel().updateCabinetImages(mBinding.etBatteryCabinetSN.getText().toString(),
//                        mImageBeanList).observe(PutawayCabinetActivity.this, mUpdateImageObserver);
                getViewModel().updateCabinetImages(mUploadImgList).observe(PutawayCabinetActivity.this, mUpdateImageObserver);
            }
        };
    }


    @SuppressLint("StringFormatInvalid")
    public void showTipDialog() {
        if (mCabinetAndCameraBoundBean.getStatus() == 1) {
            builder = new CustomDialog.Builder(getActivity())
                    .setMessage(String.format(getString(R.string.putaway_camera_binded), mCabinetAndCameraBoundBean.getSn()))
                    .setPositiveButton((dialog, which) -> {
                        getLoading().onStart();
                        getViewModel().unbindCabinetAndCamera("", mBinding.etBatteryCabinetSerialNum.getText().toString(),
                                mCabinetAndCameraBoundBean.getSn(), mBinding.etBatteryCabinetSN.getText().toString(), mBinding.etBatteryCabinetVerificationCode.getText().toString()
                        ).observe(this, mUnbindCabinetAndCameraObserver);
                        dialog.dismiss();
                    })
                    .setNegativeButton((dialog, which) -> {
                        dialog.dismiss();
                    });
        } else if (mCabinetAndCameraBoundBean.getStatus() == 2) {
            builder = new CustomDialog.Builder(getActivity())
                    .setMessage(getString(R.string.putaway_cabinet_binded))
                    .setPositiveButton((dialog, which) -> {
                        getLoading().onStart();
                        getViewModel().unbindCabinetAndCamera(mCabinetAndCameraBoundBean.getSn(), mBinding.etBatteryCabinetSerialNum.getText().toString(),
                                "", mBinding.etBatteryCabinetSN.getText().toString(), mBinding.etBatteryCabinetVerificationCode.getText().toString()
                        ).observe(this, mUnbindCabinetAndCameraObserver);
                        dialog.dismiss();
                    })
                    .setNegativeButton((dialog, which) -> {
                        dialog.dismiss();
                    });
        }
        tipDialog = builder.create();
        tipDialog.show();
    }

    boolean isScanId;
    boolean isScanSN;
    boolean isScanSerialNum;

    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.ivScanID:
                isScanId = true;
                batteryScan(QRCodeActivity.NORMAL);
                break;
            case R.id.ivScanSN:
                isScanSN = true;
                batteryScan(QRCodeActivity.NORMAL);
                break;
            case R.id.ivLocate:
                startActivityForResult(new Intent(this, SelectAddressActivity.class), 111);
                break;
            case R.id.tvChooseCityDesc:
                initSelectCityCenterDialog();
                break;
            case R.id.tvBatteryCabinetChargingDesc:
                initChargingCurrentDialog();
                break;
            case R.id.tvBatteryCabinetPointTypeDesc:
                initPointTypeDialog();
                break;
            case R.id.ivScamSerialNumID:
                isScanSerialNum = true;
                batteryScan(QRCodeActivity.NORMAL);
                break;
            case R.id.llBottom:
                if (TextUtils.isEmpty(mBinding.etBatteryCabinetSN.getText().toString())) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_sn_toast_tip));
                    return;
                }
//                if (TextUtils.isEmpty(mBinding.etBatteryCabinetId.getText().toString())) {
//                    ToastUtils.showShort(getString(R.string.putaway_cabinet_id_toast_tip));
//                    return;
//                }
                if (TextUtils.isEmpty(mBinding.etBatteryCabinetAddress.getText().toString())) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_address_tip));
                    return;
                }
                if (TextUtils.isEmpty(mBinding.tvBatteryCabinetLonAndLat.getText().toString())) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_coordinate_tip));
                    return;
                }
//                if (TextUtils.isEmpty(mBinding.tvBatteryCabinetCharging.getText().toString())) {
//                    ToastUtils.showShort(getString(R.string.putaway_cabinet_current_tip));
//                    return;
//                }
//                if (TextUtils.isEmpty(mBinding.tvChooseCity.getText().toString())) {
//                    ToastUtils.showShort(getString(R.string.putaway_cabinet_city_tip));
//                    return;
//                }
                if (adapter.getItemCount() == 1) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_more_than_one_picture_tip));
                    return;
                }
                getLoading().onStart();
                if (TextUtils.isEmpty(mBinding.etBatteryCabinetSerialNum.getText().toString())) {
                    //上传图片
//                    getViewModel().updateCabinetImages(mBinding.etBatteryCabinetSN.getText().toString(),
//                            mImageBeanList).observe(PutawayCabinetActivity.this, mUpdateImageObserver);
                    getViewModel().updateCabinetImages(mUploadImgList).observe(PutawayCabinetActivity.this, mUpdateImageObserver);
                } else {
                    //校验柜子是否也有绑定摄像头
                    getViewModel().checkCabinetAndCameraBound(mBinding.etBatteryCabinetSerialNum.getText().toString(),
                            mBinding.etBatteryCabinetSN.getText().toString()).observe(this, mCabinetAndCameraBoundObserver);
                }
                break;
            default:
                break;
        }
    }

    //    CurrentAndPointBean.ElectricsBean mElectricsBean;
    CurrentPointBean mCurrentPointBean;
    //    CurrentAndPointBean.LabelsBean mLabelsBean;
    CityCode mCityCode;

    private void initSelectCityCenterDialog() {
        if (mCityCodeList == null || mCityCodeList.size() <= 0) {
            ToastUtils.showShort(getString(com.base.common.R.string.textNoData));
            return;
        }
        if (mSelectCityCenterDialog == null) {
            mSelectCityCenterDialog = new SelectCityCenterDialog(this, mCityCodeList)
                    .setOnSelectClickListener(bean -> {
                        mCityCode = bean;
                        mBinding.tvChooseCity.setText(mCityCode.getName());
                    });
        }
        if (!mSelectCityCenterDialog.isShowing()) {
            mSelectCityCenterDialog.showPopupWindow();
        }
    }

    private void initChargingCurrentDialog() {
        if (mCurrentPointBeans == null || mCurrentPointBeans.size() <= 0) {
            ToastUtils.showShort(getString(com.base.common.R.string.textNoData));
            return;
        }
        if (mSelectChargeCurrentDialog == null) {
            mSelectChargeCurrentDialog = new SelectChargeCurrentDialog(this, mCurrentPointBeans)
                    .setOnSelectClickListener(bean -> {
                        mCurrentPointBean = bean;
                        mBinding.tvBatteryCabinetCharging.setText(mCurrentPointBean.getValue());
                    });
        }
        if (!mSelectChargeCurrentDialog.isShowing()) {
            mSelectChargeCurrentDialog.showPopupWindow();
        }
    }

    private void initPointTypeDialog() {
        if (mCurrentPointBeans == null || mCurrentPointBeans.size() <= 0) {
            ToastUtils.showShort(getString(com.base.common.R.string.textNoData));
            return;
        }
        if (mSelectPointTypeDialog == null) {
            mSelectPointTypeDialog = new SelectPointTypeDialog(this, mCurrentPointBeans)
                    .setOnSelectClickListener(bean -> {
                        mCurrentPointBean = bean;
                        mBinding.tvBatteryCabinetPointType.setText(mCurrentPointBean.getValue());
                    });
        }
        if (!mSelectPointTypeDialog.isShowing()) {
            mSelectPointTypeDialog.showPopupWindow();
        }
    }

    private void batteryScan(int type) {
        new IntentIntegrator(this)
                .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
                .setOrientationLocked(false)
                .setCaptureActivity(QRCodeActivity.class) // 设置自定义的activity是CustomActivity
                .initiateScan(); //  初始化扫描
    }


    /**
     * 初始化拍照底部弹框
     */
    public void initBottomSheet() {
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = new BottomSheetDialog(this);
            View view = LayoutInflater.from(this).inflate(R.layout.dialog_take_photo_sheet, null, false);
            Button takePhotoBt = (Button) view.findViewById(R.id.take_photo_bt);
            Button pictureBt = (Button) view.findViewById(R.id.picture_bt);
            Button btnCancel = (Button) view.findViewById(R.id.btn_cancel);
            takePhotoBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    String[] perms = {Manifest.permission.CAMERA};
                    PermissionManager.checkPermission(PutawayCabinetActivity.this, onPermissionListener, perms);
                    mBottomSheetDialog.dismiss();
                }
            });
            pictureBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    selectImageFactory.gallery(PutawayCabinetActivity.this);
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

    private void initSelectImgFactory() {
        if (mImageBeanList == null) {
            mImageBeanList = new ArrayList<>();
            mImageBeanList.add(new ImageBean(true));
            setPhotoNum(0);
            adapter.setNewData(mImageBeanList);
        }
        selectImageFactory = new SelectImageFactory() {

            @Override
            public void upLoadImageFile(Uri file) {
                getViewModel().uploadImage(new ImageBean(file, false)).observe(PutawayCabinetActivity.this, mUploadImageObserver);
            }

            @Override
            public void upLoadImageFile(File file) {
//                mImageBeanList.add(mImageBeanList.size() - 1, new ImageBean(file, false));
//                setPhotoNum(mImageBeanList.size() - 1);
//                if (mImageBeanList.size() > 5) {
//                    adapter.remove(mImageBeanList.size() - 1);
//                }
//                adapter.setNewData(mImageBeanList);
            }
        };
    }

    private PermissionListenerImpl onPermissionListener = new PermissionListenerImpl() {

        @Override
        public void passPermission() {
            selectImageFactory.cameraPhotoFile(PutawayCabinetActivity.this);
        }
    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            String mScanedMessage = null;
            IntentResult intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data);
            if (intentResult != null && intentResult.getContents() != null) {
                mScanedMessage = intentResult.getContents();
            }
            if (!TextUtils.isEmpty(mScanedMessage)) {
                if (isScanId) {
                    isScanId = false;
                    String sn =  ScanUtils.Companion.getDeviceSn(mContext,mScanedMessage);
//                    if (mScanedMessage.contains("pid=")) {
//                        String cabinetId = "";
//                        //正常扫描换电
//                        int index = mScanedMessage.indexOf("pid=");
//                        if (index > -1) {
//                            cabinetId = mScanedMessage.substring(index + 4);
//                        }
//                        mBinding.etBatteryCabinetId.setText(cabinetId);
//                    } else  {
//                        //正常扫描换电
//                        String sn = ScanUtils.Companion.getDeviceSn(mContext,mScanedMessage);
//                        if (index > -1) {
//                            sn = mScanedMessage.substring(index + 3);
////                            mBinding.etBatteryCabinetSN.setText(sn);
////                           getCabinetNameAndType("sn", sn);
//                        }
//                        mBinding.etBatteryCabinetId.setText(sn);
//                    }
//
//                } else if (isScanSN) {
//                    isScanSN = false;
//                    if (mScanedMessage.contains("sn=")) {
//                        //正常扫描换电
//                        int index = mScanedMessage.indexOf("sn=");
//                        if (index > -1) {
//                            mScanedMessage = mScanedMessage.substring(index + 3);
////                            mBinding.etBatteryCabinetSN.setText(sn);
////                            getCabinetNameAndType("sn", sn);
//                        }
//                    } else if (mScanedMessage.contains("pid=")) {
//                        String cabinetId = "";
//                        //正常扫描换电
//                        int index = mScanedMessage.indexOf("pid=");
//                        if (index > -1) {
//                            mScanedMessage = mScanedMessage.substring(index + 4);
////                           mBinding.etBatteryCabinetId.setText(cabinetId);
//                        }
//                    }
                    getCabinetNameAndType("sn", sn);
                } else if (isScanSerialNum) {
                    isScanSerialNum = false;
                    String[] strings = mScanedMessage.split("\r");
                    if (strings.length > 3) {
                        mBinding.etBatteryCabinetSerialNum.setText(strings[1]);
                        mBinding.etBatteryCabinetVerificationCode.setText(strings[2]);
                    }
                }
            }
        } else if (requestCode == 111) {
            if (data != null) {
                addressBean = (AddressBean) data.getParcelableExtra("addressBean");
                if (addressBean != null) {
                    mBinding.etBatteryCabinetAddress.setText(addressBean.getAddress());
                    mBinding.tvBatteryCabinetLonAndLat.setText(addressBean.getLontitude() + "," + addressBean.getLatitude());
                }
            }
        } else {
            selectImageFactory.onActivityResult(requestCode, resultCode, data, null, this);
        }
        isScanId = false;
        isScanSN = false;
        isScanSerialNum = false;
    }

    private void getCabinetNameAndType(String type, String cabinetId) {
        if (TextUtils.isEmpty(cabinetId)) {
            return;
        }
        getViewModel().getStationType(type, cabinetId);
    }

    private String getCabinetName() {
        NewCabinetBean value = viewModel.newCabinetBeanMutableLiveData.getValue();
        if (value == null || value.getStationName() == null) {
            return "";
        }
        return value.getStationName();
    }

    private String getStationModel() {
        NewCabinetBean value = viewModel.newCabinetBeanMutableLiveData.getValue();
        if (value == null || value.getStationModel() == null) {
            return "";
        }
        return value.getStationModel();
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        if (!hasFocus) {
            String inputContent = ((EditText) v).getText().toString();
            getCabinetNameAndType("sn", inputContent);
        }
    }
}