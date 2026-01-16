package com.okla.ops.views.workbench.qm.roadassistance;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.beans.RxEvent;
import com.base.common.image.preview.ImagePreviewDialog;
import com.base.common.permission.PermissionListenerImpl;
import com.base.common.permission.PermissionManager;
import com.base.common.utils.DateTimeUtils;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.LanguageUtils;
import com.base.common.utils.LocationAddressUtils;
import com.base.common.utils.NumToStrUtil;
import com.base.common.utils.ToastUtils;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.PayTypeObject;
import com.okla.ops.custom.deviceinfo.MyGridItemDecoration;
import com.okla.ops.databinding.ActivityRoadsideOrderDetailBinding;
import com.okla.ops.dialog.RoadSidePaymentDialog;
import com.okla.ops.utils.StringUtils;
import com.okla.ops.utils.ViewClickUtils;
import com.okla.ops.views.workbench.qm.RoadSideOrderDetail;
import com.okla.ops.views.workbench.sales.depositrefund.ViewReceiptDialogFragment;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class RoadSideOrderDetailActivity extends BaseNormalVActivity<RoadSideViewModel, ActivityRoadsideOrderDetailBinding> {
    private Integer sheetStatus = -1;
    private ArrayList<String> voucherList = new ArrayList<String>();

    public static Intent getIntents(Context context, String sheetNo, boolean isRoadSideAssistant) {
        Intent intent = new Intent(context, RoadSideOrderDetailActivity.class);
        intent.putExtra("sheetNo", sheetNo);
        return intent;
    }

    private String mSheetNo;

    @Override
    protected void getIntentExtras(Intent intent) {
        super.getIntentExtras(intent);
        mSheetNo = intent.getStringExtra("sheetNo");
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        initAdapter();
        initObservable();
        initClick();
        refreshData();

    }

    private void refreshData() {
        getViewModel().queryRoadOrderDetail(mSheetNo);
    }

    private void initClick() {
        mBinding.btnFinish.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            if (sheetStatus == 0) {
                //待救援
                RoadSideOrderDealActivity.Companion.getIntents(mContext, mSheetNo);
            } else if (sheetStatus == 1) {
                //进行中
                RoadSidePaymentDialog.Companion.getInstance(mSheetNo, RoadSidePaymentDialog.TYPE_ROADSIDE)
                        .show(getSupportFragmentManager(), "roadside_detail");
            }
        });
        mBinding.imgDis.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            if (mLatitude == 0 || mLongitude == 0) {
                return;
            }
            startNavigation();
        });
        mBinding.tvAddress.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            if (mLatitude == 0 || mLongitude == 0) {
                return;
            }
            startNavigation();
        });
        mBinding.imgPhone.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            //打电话
            if (TextUtils.isEmpty(phoneStr)) {
                return;
            }
            askPhonePermission();

        });
        mBinding.tvViewVoucher.setOnClickListener(v -> {
            if (ViewClickUtils.isFastClick()) {
                return;
            }
            ViewReceiptDialogFragment dialog = new ViewReceiptDialogFragment(voucherList);
            dialog.show(getSupportFragmentManager(), "view_receipt");
        });
    }

    private String phoneStr = "";

    private void initObservable() {

        getViewModel().getMRoadSideDetailLiveData().observe(this, roadSideOrderDetail -> {
            if (roadSideOrderDetail == null) return;
            sheetStatus = roadSideOrderDetail.getStatus();
            phoneStr = roadSideOrderDetail.getRiderPhone();
            mBinding.tvWorkId.setText("No." + roadSideOrderDetail.getRecordNo());
            if (!TextUtils.isEmpty(roadSideOrderDetail.getDescription())) {
                mBinding.tvDescContent.setText(roadSideOrderDetail.getDescription());
            }
            setDetailAddress(mBinding.tvAddress, roadSideOrderDetail);
            if (null != roadSideOrderDetail.getOpResponse()) {
                mBinding.tvResponseContent.setText(roadSideOrderDetail.getOpResponse());
            }
            if (null != roadSideOrderDetail.getProcessTime()) {
                mBinding.tvResponseDate.setText(DateTimeUtils.getTimeString(DateTimeUtils.dateFormatNormal, roadSideOrderDetail.getProcessTime()));
            }
            String imgList = roadSideOrderDetail.getImgList();
            if (TextUtils.isEmpty(imgList)) {
                mBinding.rvPhotos.setVisibility(View.GONE);
            } else {
                mBinding.rvPhotos.setVisibility(View.VISIBLE);
                String[] imgPaths = imgList.split(",");
                mImageUrlList.clear();
                mImageUrlList.addAll(Arrays.asList(imgPaths));
                adapter.setNewData(mImageUrlList);
            }
            String deviceSn = roadSideOrderDetail.getDeviceSn();
            if (!TextUtils.isEmpty(deviceSn)) {
                mBinding.tvDeviceSn.setText("SN: " + deviceSn);
                Glide.with(getActivity()).load(roadSideOrderDetail.getImg()).into(mBinding.ivDevice);
                mLatitude = roadSideOrderDetail.getLatitude();
                mLongitude = roadSideOrderDetail.getLongitude();
            }
            //头像
            Glide.with(mContext).load(roadSideOrderDetail.getImg()).into(mBinding.imgHeader);
            if (!TextUtils.isEmpty(roadSideOrderDetail.getCardNum())) {
                mBinding.tvUserid.setText("ID:" + roadSideOrderDetail.getCardNum());
            }
            if (!TextUtils.isEmpty(roadSideOrderDetail.getLastName())) {
                mBinding.tvUsername.setText(roadSideOrderDetail.getFirstName() + " " + roadSideOrderDetail.getLastName());
            }
//            if (LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage() == Locale.US) {
//                if (!TextUtils.isEmpty(roadSideOrderDetail.getLastName())) {
//                    mBinding.tvUsername.setText(roadSideOrderDetail.getFirstName() + " " + roadSideOrderDetail.getLastName());
//                }
//            } else {
//                if (!TextUtils.isEmpty(roadSideOrderDetail.getLastName())) {
//                    mBinding.tvUsername.setText(roadSideOrderDetail.getLastName() + " " + roadSideOrderDetail.getFirstName());
//                }
//            }
            if (roadSideOrderDetail.getSource() == 1) {
                //后台
                mBinding.tvReportSource.setText(mContext.getString(R.string.str_admin_console));
            } else if (roadSideOrderDetail.getSource() == 2) {
                //骑手
                mBinding.tvReportSource.setText(mContext.getString(R.string.text_rider));
            }
            mBinding.tvTime.setText(formatOccurrenceTime(roadSideOrderDetail.getCreateTime()) + " " + mContext.getString(R.string.str_occurrence));
            mBinding.tvCreatorValue.setText(roadSideOrderDetail.getCreator());
            mBinding.tvCreateTimeValue.setText(DateTimeUtils.getTimeString(DateTimeUtils.defaultFormat, roadSideOrderDetail.getReportTime(), LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage()));
            sheetStatus = roadSideOrderDetail.getStatus();
            switch (sheetStatus) {
                case 0:
                    mBinding.clFooter.setVisibility(View.VISIBLE);
                    mBinding.btnFinish.setText(mContext.getString(R.string.str_processing_result));
                    mBinding.tvStatus.setText(getString(R.string.str_waiting_for_rescue));
                    mBinding.imgStatus.setImageResource(R.mipmap.icon_roadside_status_wait);
                    mBinding.clResponse.setVisibility(View.GONE);
                    mBinding.grouppayinfo.setVisibility(View.GONE);
                    break;
                case 1:
                    if (roadSideOrderDetail.getPayWay() == PayTypeObject.TYPE_ONLINE) {
                        mBinding.clFooter.setVisibility(View.GONE);
                    } else {
                        mBinding.clFooter.setVisibility(View.VISIBLE);
                    }
                    mBinding.btnFinish.setText(mContext.getString(R.string.str_payment));
                    mBinding.tvStatus.setText(getString(R.string.str_in_progress));
                    mBinding.imgStatus.setImageResource(R.mipmap.icon_roadside_status_pending);
                    mBinding.clResponse.setVisibility(View.VISIBLE);
                    if (roadSideOrderDetail.getResult() == 1) {
                        mBinding.tvResultStatus.setText(mContext.getString(R.string.str_return_to_factory));
                        mBinding.imgResult.setImageResource(R.mipmap.icon_green_return_factory);
                    } else if (roadSideOrderDetail.getResult() == 2) {
                        mBinding.tvResultStatus.setText(mContext.getString(R.string.str_completed));
                        mBinding.imgResult.setImageResource(R.mipmap.icon_result_completed_green);
                    }

                    mBinding.grouppayinfo.setVisibility(View.GONE);
                    break;
                case 2:
                    mBinding.clFooter.setVisibility(View.GONE);
                    mBinding.tvStatus.setText(getString(R.string.str_completed));
                    mBinding.imgStatus.setImageResource(R.mipmap.icon_roadside_status_completed);
                    mBinding.clResponse.setVisibility(View.VISIBLE);
                    if (roadSideOrderDetail.getResult() == 1) {
                        mBinding.tvResultStatus.setText(mContext.getString(R.string.str_return_to_factory));
                        mBinding.imgResult.setImageResource(R.mipmap.icon_green_return_factory);
                    } else if (roadSideOrderDetail.getResult() == 2) {
                        mBinding.tvResultStatus.setText(mContext.getString(R.string.str_completed));
                        mBinding.imgResult.setImageResource(R.mipmap.icon_result_completed_green);
                    }
                    mBinding.grouppayinfo.setVisibility(View.VISIBLE);
                    if (roadSideOrderDetail.getAttachment() != null && !TextUtils.isEmpty(roadSideOrderDetail.getAttachment())) {
                        mBinding.tvViewVoucher.setVisibility(View.VISIBLE);
                        voucherList.addAll(StringUtils.Companion.strToList(roadSideOrderDetail.getAttachment()));
                        if (roadSideOrderDetail.getPayWay() == PayTypeObject.TYPE_CASH) {
                            mBinding.tvPaymethod.setText(mContext.getString(R.string.text_cash) + " | ");
                        } else if (roadSideOrderDetail.getPayWay() == PayTypeObject.TYPE_ONLINE) {
                            mBinding.tvPaymethod.setText(mContext.getString(R.string.text_online) + " | ");
                        }
                    } else {
                        mBinding.tvViewVoucher.setVisibility(View.GONE);
                        if (roadSideOrderDetail.getPayWay() == PayTypeObject.TYPE_CASH) {
                            mBinding.tvPaymethod.setText(mContext.getString(R.string.text_cash));
                        } else if (roadSideOrderDetail.getPayWay() == PayTypeObject.TYPE_ONLINE) {
                            mBinding.tvPaymethod.setText(mContext.getString(R.string.text_online));
                        }
                    }
                    mBinding.tvAmount.setText("$" + NumToStrUtil.INSTANCE.DoubleToStrWith2(roadSideOrderDetail.getFee()));
                    break;
            }
        });
    }

    private final List<String> mImageUrlList = new ArrayList<>();
    private SingleDataBindingNoPUseAdapter adapter;
    private RequestOptions options;

    private void initAdapter() {
        options = new RequestOptions();
        options.transform(new RoundedCorners(DensityUtil.dp2px(4)));
        mBinding.rvPhotos.setLayoutManager(new GridLayoutManager(this, 3));
        mBinding.rvPhotos.addItemDecoration(new MyGridItemDecoration(3, DensityUtil.dp2px(12)));
        adapter = new SingleDataBindingNoPUseAdapter<String>(R.layout.item_device_info_photo) {
            @Override
            public void convert(BaseViewHolder helper, String item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                Glide.with(getActivity()).load(item).error(R.mipmap.ic_add_photo).apply(RequestOptions.bitmapTransform(new RoundedCorners(DensityUtil.dp2px(4))).centerCrop()).into((ImageView) helper.getView(R.id.ivPhoto));
            }
        };
        adapter.setOnItemClickListener((adapter, view, position) -> ImagePreviewDialog.getInstance(mImageUrlList, position).showNow(getSupportFragmentManager(), ""));
        mBinding.rvPhotos.setAdapter(adapter);
    }

    private PermissionManager permissionManager;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        permissionManager = PermissionManager.getInstance(getActivityResultRegistry(), RoadSideOrderDetailActivity.this.toString(), this);
        getLifecycle().addObserver(permissionManager);
    }

    @Override
    protected RoadSideViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(RoadSideViewModel.class);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_roadside_order_detail;
    }

    @Override
    public int title() {
        return R.string.title_roadside_assistant;
    }

    private double mLatitude;
    private double mLongitude;

    //在google官网：Maps SDK for Android-->启动 Google 地图
    private void startNavigation() {
        String latitude = String.valueOf(mLatitude);
        String longitude = String.valueOf(mLongitude);
        String mStringBuilder = "google.navigation:q=" +
                latitude +
                "," +
                longitude;
        Uri googleAddrUri = Uri.parse(mStringBuilder);
        Intent mapIntent = new Intent(Intent.ACTION_VIEW, googleAddrUri);
        mapIntent.setPackage("com.google.android.apps.maps");
        try {
            startActivity(mapIntent);
        } catch (Exception e) {
            ToastUtils.showShort(getString(R.string.google_map_install_tip));
        }
    }

    private String formatOccurrenceTime(long timestamp) {
        String pattern;
        Locale currentLocale = LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage();
        if ("zh".equals(currentLocale.getLanguage())) {
            pattern = "M月dd日, yyyy HH:mm";
        } else {
            pattern = "MMM dd, yyyy HH:mm";
        }
        SimpleDateFormat sdf = new SimpleDateFormat(pattern, currentLocale);
        Date date = new Date(timestamp);
        return sdf.format(date);
    }

    // 假设是在 Activity 中调用
    private ExecutorService executor = Executors.newSingleThreadExecutor();

    private void setDetailAddress(TextView tvDetailAddress, RoadSideOrderDetail item) {
        String address = LocationAddressUtils.INSTANCE.getAddressByLocal(
                item.getLatitude() != null ? item.getLatitude() : 0.0,
                item.getLongitude() != null ? item.getLongitude() : 0.0,
                item.getDeviceSn() != null ? item.getDeviceSn() : ""
        );

        if (TextUtils.isEmpty(address)) {
            executor.execute(() -> getAddressAsync(item, tvDetailAddress));
        } else {
            tvDetailAddress.setText(address);
        }
    }

    private void getAddressAsync(RoadSideOrderDetail info, TextView tvAddress) {
        if (info.getDeviceSn() != null && info.getLatitude() != null && info.getLongitude() != null) {
            // 调用协程替代方法，这里改为 Java 实现的网络请求或 Geocoder 操作
            String result = LocationAddressUtils.INSTANCE.getAddressByCoroutine(
                    info.getLatitude(),
                    info.getLongitude(),
                    this
            );

            LocationAddressUtils.INSTANCE.saveAddressToLocal(
                    info.getLatitude(),
                    info.getLongitude(),
                    info.getRecordNo(), //救援单号
                    result
            );

            runOnUiThread(() -> tvAddress.setText(result));
        }
    }

    @Override
    protected boolean isBindEventBusHere() {
        return true;
    }

    //支付处理完成
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void paySucess(RxEvent.RoadSidePaySucessEvent event) {
        refreshData();
    }


    //不支付
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void notPay(RxEvent.RoadSideNotPayEvent event) {
        finish();
    }

    //道路救援处理成功
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void dealSucess(RxEvent.RoadSideDealSuccessEvent event) {
        refreshData();
    }

    private void askPhonePermission() {
        List<String> permissions = new ArrayList<>();
        permissions.add(Manifest.permission.CALL_PHONE);

        permissionManager.checkPermissions(
                new PermissionListenerImpl() {
                    @Override
                    public void passPermission() {
                        super.passPermission();
                        callPhone();
                    }

                    @Override
                    public void showRequestPermissionRationale() {
                        super.showRequestPermissionRationale();
                        PermissionManager.askForPermission(RoadSideOrderDetailActivity.this, "");
                    }
                },
                // varargs String…
                permissions.toArray(new String[0])
        );
    }

    private void callPhone() {
        Context ctx = mContext;
        if (ctx != null && !TextUtils.isEmpty(phoneStr)) {
            Intent intent = new Intent(Intent.ACTION_CALL);
            intent.setData(Uri.parse("tel:" + phoneStr));
            ctx.startActivity(intent);
        }
    }

}
