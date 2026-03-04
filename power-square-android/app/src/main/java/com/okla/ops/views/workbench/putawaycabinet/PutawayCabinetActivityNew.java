package com.okla.ops.views.workbench.putawaycabinet;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.location.Address;
import android.location.Geocoder;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.dialog.CustomDialog;
import com.base.common.image.preview.ImagePreviewDialog;
import com.base.common.image.select.SelectImageFactory;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.ToastUtils;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.custom.deviceinfo.MyGridItemDecoration;
import com.okla.ops.databinding.ActivityPutawayCabinetNewBinding;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.okla.ops.utils.ScanUtils;
import com.okla.ops.views.PromoteWebActivity;
import com.okla.ops.views.workbench.selectaddress.SelectAddressActivity;
import com.okla.ops.weight.SnSearchInfoView;
import com.orhanobut.logger.Logger;
import com.okla.ops.R;
import com.okla.ops.beans.AddressBean;
import com.okla.ops.beans.ImageBean;
import com.okla.ops.beans.NewCabinetBean;
import com.okla.ops.custom.station.StationInfoSimpleView;
import com.okla.ops.custom.station.StationInfoView;
import com.okla.ops.utils.EventUtils;
import com.okla.ops.views.workbench.QRCodeActivity;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;


/**
 * @Date: DATE.{TIME}
 * @Author: joe
 * @Description:
 * @Version:
 */
public class PutawayCabinetActivityNew extends BaseNormalVActivity<PutawayCabinetViewModelNew, ActivityPutawayCabinetNewBinding> {

    private BottomSheetDialog mBottomSheetDialog;
    private SelectImageFactory selectImageFactory;
    private List<ImageBean> mImageBeanList;//存储图片集合
    private final List<String> mImageUrlList = new ArrayList<>();
    private SingleDataBindingNoPUseAdapter adapter;
    private AddressBean addressBean;
    private Observer<List<String>> mUpdateImageObserver;
    private Observer<String> mUploadImageObserver;
    private Observer<String> mPutawayCabinetObserver;
    //解析地址
    private Observable<Address> geoLocationObserver;
    private Observer<String> getSnByPidObserver;
    private Consumer<Address> geoConsumer;

    public static Intent getIntents(Context context) {
        Intent intent = new Intent(context, PutawayCabinetActivityNew.class);
        return intent;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_putaway_cabinet_new;
    }

    @Override
    protected PutawayCabinetViewModelNew onCreateViewModel() {
        return new ViewModelProvider(this).get(PutawayCabinetViewModelNew.class);
    }

//    @Override
//    public boolean isInitImmersionBar() {
//        return false;
//    }

//    @Override
//    public boolean isImmersive() {
//        return  false;
//    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        mBinding.setViewModel(viewModel);
        mBinding.setView(this);
        initRecyclerview();
        initSelectImgFactory();
        stationInfoSimpleView = new StationInfoSimpleView(this);
        initObserver();
        initEditViewListener();
        filterBatteryTimes();
    }

    private String stationSn="";
    private void initEditViewListener() {
        mBinding.vStationInfo.setOnStationInfoListener(new StationInfoView.OnStationInfoListener() {
            @Override
            public void onScanClick() {
                isScanSN = true;
                batteryScan(QRCodeActivity.NORMAL);
            }

            @Override
            public void onEditTextNotHasFocus(String inputContent) {
                getCabinetNameAndType(inputContent);
            }
        });
        mBinding.vStationInfo.setOnEditTextActionListener(new StationInfoView.OnEditTextActionListener() {
            @Override
            public void onActionDone() {
                getCabinetNameAndType(mBinding.vStationInfo.getBatteryCabinetSn());
            }
        });
        mBinding.vStationInfo.setOnClearInputListener(new SnSearchInfoView.OnClearInputListener() {
            @Override
            public void onCleared() {
                stationSn="";
                mBinding.vStationInfo.removeAllViews();
                mBinding.tvCabinetNameValue.setText("");
                mBinding.etBatteryCabinetAddress.setText("");
                mBinding.tvBatteryCabinetLonAndLat.setText("");
                mBinding.etBatteryExchangeIndicatorValue.setText("");
                adapter.setNewData(null);
                imgs="";
                mUploadImgList.clear();
                addressBean=null;
                enableBtnConfirm();
            }
        });
        mBinding.etBatteryCabinetAddress.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    hideSoftInput();
                    geoLocationObserver.subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe(geoConsumer);
                    return true;
                }
                return false;
            }
        });
        mBinding.etBatteryCabinetAddress.setHorizontallyScrolling(false);
        mBinding.etBatteryCabinetAddress.setMaxLines(2);
    }


    private void initRecyclerview() {
        mBinding.rvPhotos.setLayoutManager(new GridLayoutManager(this, 3));
        mBinding.rvPhotos.addItemDecoration(new MyGridItemDecoration(3, DensityUtil.dp2px(12)));
        adapter = new SingleDataBindingNoPUseAdapter<ImageBean>(R.layout.item_photo) {
            @Override
            protected void convert(BaseViewHolder helper, ImageBean item) {
                super.convert(helper, item);
                if (item.isAdd) {
                    helper.getView(R.id.ivDeletePhoto).setVisibility(View.GONE);
                } else {
                    helper.getView(R.id.ivDeletePhoto).setVisibility(View.VISIBLE);
                }
                ImageView imageView = helper.getView(R.id.ivPhoto);
                if (item.fileUri == null) {
                    imageView.setScaleType(ImageView.ScaleType.CENTER);
                } else {
                    imageView.setScaleType(ImageView.ScaleType.FIT_XY);
                }
                Glide.with(PutawayCabinetActivityNew.this).load(item.fileUri).apply(RequestOptions.bitmapTransform(new RoundedCorners(DensityUtil.dp2px(4))).centerCrop()).error(R.drawable.ic_camera_img).into(imageView);
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
                        enableBtnConfirm();
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
        mBinding.tvBatteryCabinetPhotoNum.setText("(" + String.format(getString(R.string.cabinet_detail_photo_num), i) + ")");
    }

    String imgs = "";
    StringBuilder imgsStringBuilder;
    private List<String> mUploadImgList;
    private StationInfoSimpleView stationInfoSimpleView;
    private Geocoder geocoder;

    private void initObserver() {
        geoLocationObserver = Observable.create(emitter -> {
            if (Geocoder.isPresent()) {
                if (geocoder == null) {
                    geocoder = new Geocoder(this);
                }
                try {
                    String adr = mBinding.etBatteryCabinetAddress.getText().toString();
                    List<Address> fromLocation = geocoder.getFromLocationName(adr, 1);
                    if (fromLocation != null && fromLocation.size() > 0) {
                        for (Address address : fromLocation) {
                            Logger.e("address: Latitude= " + address.getLatitude() + "Longitude= " + address.getLongitude());
                            emitter.onNext(address);
                            break;
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        geoConsumer = address -> {
            if (addressBean == null) {
                addressBean = new AddressBean();
            }
            addressBean.setLatitude(address.getLatitude());
            addressBean.setLontitude(address.getLongitude());
            mBinding.tvBatteryCabinetLonAndLat.setText(address.getLongitude() + "," + address.getLatitude());
        };
        getSnByPidObserver = deviceSn -> {
            if (!TextUtils.isEmpty(deviceSn)) {
                if (!deviceSn.contains("sn=") && deviceSn.contains("http")) {
                    startActivityForResult(PromoteWebActivity.getIntents(mContext, deviceSn, true), PromoteWebActivity.PARSE_REQUEST_CODE);
                } else {
                    getCabinetNameAndType(deviceSn);
                }
            }
        };
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
                String num = mBinding.etBatteryExchangeIndicatorValue.getText().toString();
                getViewModel().putawayCabinet(
                                getCabinetPid(),
                                mBinding.vStationInfo.getBatteryCabinetSn(),
                                imgs,
                                addressBean.getLatitude(),
                                addressBean.getLontitude(),
                                mBinding.tvCabinetNameValue.getText().toString(),
                                getStationModel(),
                                TextUtils.isEmpty(num) ? 0 : Integer.parseInt(num),
                                0,
                                0,
                                mBinding.etBatteryCabinetAddress.getText().toString())
                        .observe(PutawayCabinetActivityNew.this, mPutawayCabinetObserver);
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
        getViewModel().mUploadImageBean.observe(PutawayCabinetActivityNew.this, new Observer<ImageBean>() {
            @Override
            public void onChanged(ImageBean imageBean) {
                mImageBeanList.add(mImageBeanList.size() - 1, imageBean);
                setPhotoNum(mImageBeanList.size() - 1);
                if (mImageBeanList.size() > 5) {
                    adapter.remove(mImageBeanList.size() - 1);
                }
                adapter.setNewData(mImageBeanList);
                enableBtnConfirm();
            }
        });
        //上传柜子信息
        mPutawayCabinetObserver = new Observer<String>() {
            @Override
            public void onChanged(String str) {
                getLoading().onFinish();
                if (TextUtils.isEmpty(str)) {
                    EventUtils.INSTANCE.getUnshelveReaderData().setValue(true);
                    finish();
                }
            }
        };
        getViewModel().newCabinetBeanMutableLiveData.observe(PutawayCabinetActivityNew.this, newCabinetBean -> {
            if (newCabinetBean == null) {
                stationSn="";
                ToastUtils.showShort(getString(R.string.invalid_qr_code));
            } else {
                if (stationInfoSimpleView != null)
                    stationInfoSimpleView.setData(newCabinetBean);
                String sn = newCabinetBean.getSn();
                stationSn=sn;
                mBinding.vStationInfo.updateData(sn, stationInfoSimpleView);
            }
            enableBtnConfirm();
        });
        mBinding.tvCabinetNameValue.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {;
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                enableBtnConfirm();
            }
        });
        mBinding.etBatteryCabinetAddress.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                enableBtnConfirm();
            }
        });
        mBinding.etBatteryExchangeIndicatorValue.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                enableBtnConfirm();
            }
        });

    }

    boolean isScanSN;

    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.ivBack:
                finish();
                break;
            case R.id.ivLocate:
                startActivityForResult(new Intent(this, SelectAddressActivity.class), 111);
                break;
            case R.id.llBottom:
                if (TextUtils.isEmpty(mBinding.tvCabinetNameValue.getText().toString())) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_input_cabinet_name));
                    return;
                }
                if (TextUtils.isEmpty(mBinding.vStationInfo.getBatteryCabinetSn())) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_sn_toast_tip));
                    return;
                }
                if (TextUtils.isEmpty(mBinding.etBatteryCabinetAddress.getText().toString())) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_address_tip));
                    return;
                }
                if (TextUtils.isEmpty(mBinding.tvBatteryCabinetLonAndLat.getText().toString()) || addressBean == null) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_coordinate_tip));
                    return;
                }
                if (TextUtils.isEmpty(mBinding.etBatteryExchangeIndicatorValue.getText().toString())) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_battery_exchange_tip));
                    return;
                }
                if (adapter.getItemCount() == 1) {
                    ToastUtils.showShort(getString(R.string.putaway_cabinet_more_than_one_picture_tip));
                    return;
                }
                showTipDialog();
                break;
            default:
                break;
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
                    PermissionManager.checkPermission(PutawayCabinetActivityNew.this, onPermissionListener, perms);
                    mBottomSheetDialog.dismiss();
                }
            });
            pictureBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    selectImageFactory.gallery(PutawayCabinetActivityNew.this);
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
            enableBtnConfirm();
        }
        selectImageFactory = new SelectImageFactory() {

            @Override
            public void upLoadImageFile(Uri file) {
                getViewModel().uploadImage(new ImageBean(file, false)).observe(PutawayCabinetActivityNew.this, mUploadImageObserver);
            }

            @Override
            public void upLoadImageFile(File file) {
            }
        };
    }

    private final PermissionListenerImpl onPermissionListener = new PermissionListenerImpl() {

        @Override
        public void passPermission() {
            selectImageFactory.cameraPhotoFile(PutawayCabinetActivityNew.this);
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
                if (isScanSN) {
                    isScanSN = false;
                    if(mScanedMessage.contains("http")||mScanedMessage.contains("https")){
                        if(mScanedMessage.contains("?")){
                            mScanedMessage= mScanedMessage.substring(mScanedMessage.indexOf("?")+1,mScanedMessage.length());
                        }else if(mScanedMessage.contains("？")){
                            mScanedMessage= mScanedMessage.substring(mScanedMessage.indexOf("？")+1,mScanedMessage.length());
                        }
                    }
                    getCabinetNameAndType(mScanedMessage);
//                    if (mScanedMessage.contains("sn=")) {
//                        //正常扫描换电
//                        int index = mScanedMessage.indexOf("sn=");
//                        if (index > -1) {
//                            mScanedMessage = mScanedMessage.substring(index + 3);
//                        }
//                        getCabinetNameAndType(mScanedMessage);
//                    } else if (!TextUtils.isEmpty(mScanedMessage)) {
//                        getViewModel().getDeviceSn(mScanedMessage).observe(this, getSnByPidObserver);
//                        return;
//                    }
                }
            }
        } else if (requestCode == 111) {
            if (data != null) {
                addressBean = (AddressBean) data.getSerializableExtra("addressBean");
                if (addressBean != null) {
                    mBinding.etBatteryCabinetAddress.setText(addressBean.getAddress());
                    mBinding.tvBatteryCabinetLonAndLat.setText(addressBean.getLontitude() + "," + addressBean.getLatitude());
                    /*Geocoder gcd = new Geocoder(this, Locale.getDefault());
                    try {
                        List<Address> fromLocation = gcd.getFromLocation(Double.parseDouble(addressBean.getLatitudeStr()), Double.parseDouble(addressBean.getLontitudeStr()), 1);
                        if (fromLocation.size() > 0) {
                            String locality = fromLocation.get(0).getLocality();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }*/
                }
            }
        } else if (requestCode == PromoteWebActivity.PARSE_REQUEST_CODE) {
            if (data != null) {
                String parseResult = data.getStringExtra("parse_result");
                if(!TextUtils.isEmpty(parseResult)){
                    if(parseResult.contains("http")||parseResult.contains("https")){
                        if(parseResult.contains("?")){
                            parseResult= parseResult.substring(parseResult.indexOf("?")+1,parseResult.length());
                        }else if(parseResult.contains("？")){
                            parseResult= parseResult.substring(parseResult.indexOf("？")+1,parseResult.length());
                        }
                    }
                    getCabinetNameAndType(parseResult);
                }
                //                if (!TextUtils.isEmpty(parseResult) && parseResult.contains("sn=")) {
//                    //正常扫描换电
//                    int index = parseResult.indexOf("sn=");
//                    if (index > -1) {
//                        parseResult = parseResult.substring(index + 3);
//                    }
//                }
//                getCabinetNameAndType(parseResult);
            }
        } else {
            selectImageFactory.onActivityResult(requestCode, resultCode, data, null, this);
        }
        isScanSN = false;
    }

    private void getCabinetNameAndType(String cabinetId) {
        if (TextUtils.isEmpty(cabinetId)) {
            return;
        }
        getViewModel().getStationSource("1", cabinetId);
    }

    private String getCabinetPid() {
        NewCabinetBean value = viewModel.newCabinetBeanMutableLiveData.getValue();
        if (value == null || value.getPid() == null) {
            return "";
        }
        return value.getPid();
    }

    private String getStationModel() {
        NewCabinetBean value = viewModel.newCabinetBeanMutableLiveData.getValue();
        if (value == null || value.getStationModel() == null) {
            return "";
        }
        return value.getStationModel();
    }

    private void enableBtnConfirm(){
        if(!TextUtils.isEmpty(stationSn)&&!TextUtils.isEmpty(mBinding.etBatteryCabinetAddress.getText())
                &&!TextUtils.isEmpty(mBinding.etBatteryExchangeIndicatorValue.getText())
                &&!TextUtils.isEmpty(mBinding.tvCabinetNameValue.getText())
                &&adapter.getItemCount()>1){
            mBinding.tvConfirm.setEnabled(true);
        }else {
            mBinding.tvConfirm.setEnabled(false);
        }
    }

    private CustomDialog tipDialog;
    private CustomDialog.Builder builder;

    public void showTipDialog() {
        builder = new CustomDialog.Builder(getActivity())
                .setTitle(getString(R.string.putaway_cabinet_confirm_title))
                .setMessage(getString(R.string.putaway_cabinet_submit_tip))
//                .setPositiveButtonTextColor(R.color.color_ff12b34b)
                .setPositiveButton((dialog, which) -> {
                    getLoading().onStart();
                    getViewModel().updateCabinetImages(mUploadImgList).observe(PutawayCabinetActivityNew.this, mUpdateImageObserver);
                    dialog.dismiss();
                })
                .setNegativeButton((dialog, which) -> {
                    dialog.dismiss();
                });
        tipDialog = builder.create();
        tipDialog.show();
    }


    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            // 无论是在 Fragment 还是 Activity 布局里的 EditText，都能拿到当前焦点
            View v = getCurrentFocus();
            if (v instanceof EditText) {
                // 计算点击区域是否在 EditText 之外
                Rect outRect = new Rect();
                v.getGlobalVisibleRect(outRect);
                if (!outRect.contains((int) ev.getRawX(), (int) ev.getRawY())) {
                    // 清除焦点并隐藏键盘
                    v.clearFocus();
                    InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                    if (imm != null) {
                        imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                    }
                }
            }
        }
        return super.dispatchTouchEvent(ev);
    }

    private void filterBatteryTimes() {
        InputFilter positiveIntFilter = new InputFilter() {
            @Override
            public CharSequence filter(CharSequence source, int start, int end,
                                       Spanned dest, int dstart, int dend) {
                // 拼接新的输入内容
                String newValue = dest.toString().substring(0, dstart)
                        + source.subSequence(start, end)
                        + dest.toString().substring(dend);

                // 允许删除
                if (newValue.isEmpty()) {
                    return null;
                }

                // 限制最大长度为 2 位
                if (newValue.length() > 2) {
                    return "";
                }

                try {
                    int num = Integer.parseInt(newValue);
                    // 拦截非正数
                    if (num <= 0) {
                        return "";
                    }
                } catch (NumberFormatException e) {
                    return ""; // 非数字拦截
                }

                return null; // 允许输入
            }
        };
        mBinding.etBatteryExchangeIndicatorValue.setFilters(new InputFilter[]{positiveIntFilter});
    }

}