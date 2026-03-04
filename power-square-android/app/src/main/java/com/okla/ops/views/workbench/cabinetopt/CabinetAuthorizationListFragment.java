package com.okla.ops.views.workbench.cabinetopt;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.RelativeSizeSpan;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.base.mvvm.BaseNormalListVFragment;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.WindowInsetsHelper;
import com.base.library.utils.StringUtil;
import com.bumptech.glide.Glide;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.databinding.FragmentCabinetAuthorizationListBinding;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.okla.ops.R;
import com.okla.ops.beans.CabinetAuthorization;
import com.okla.ops.beans.CabinetAuthorizationList;
import com.okla.ops.custom.cabinetopt.CabinetAuthorizationDetailView;
import com.okla.ops.utils.ScanUtils;
import com.okla.ops.views.workbench.QRCodeActivity;

public class CabinetAuthorizationListFragment extends BaseNormalListVFragment<CabinetAuthorizationOperateViewModel, FragmentCabinetAuthorizationListBinding> {

    private Observer<CabinetAuthorizationList> mCabinetAuthorizationListSearchObserver;

    private SingleDataBindingNoPUseAdapter mAdapter;

    @Override
    protected RecyclerView.Adapter createAdapter() {
        mAdapter = new SingleDataBindingNoPUseAdapter<CabinetAuthorization>(R.layout.item_cabinet_authorization) {
            @Override
            public void convert(BaseViewHolder helper, CabinetAuthorization item, ViewDataBinding viewDataBinding) {
                if (TextUtils.equals(stationSn, item.getStationSn())) {
                    helper.getView(R.id.ivSelect).setVisibility(View.VISIBLE);
                } else {
                    helper.getView(R.id.ivSelect).setVisibility(View.GONE);
                }
                helper.setText(R.id.tvCabinetName, "SN: " + item.getStationSn());
                Glide.with(helper.itemView).load(item.getStandardImg()).into((ImageView) helper.getView(R.id.imDevice));
                int onlineStatus = item.getOnlineStatus();
                if (onlineStatus == 0) {//离线
                    ((TextView) (helper.getView(R.id.tvStatus))).setTextColor(ContextCompat.getColor(getContext(), R.color.color_fa4b51));
                    ((TextView) (helper.getView(R.id.tvStatus))).setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(getContext(), R.drawable.icon_wifi_us), null, null, null);
                    (helper.getView(R.id.tvStatus)).setBackground(ContextCompat.getDrawable(getContext(), R.drawable.bg_line_fa4b51_r4));
                } else {
                    ((TextView) (helper.getView(R.id.tvStatus))).setTextColor(ContextCompat.getColor(getContext(), R.color.main_color));
                    ((TextView) (helper.getView(R.id.tvStatus))).setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(getContext(), R.drawable.icon_wifi_s), null, null, null);
                    (helper.getView(R.id.tvStatus)).setBackground(ContextCompat.getDrawable(getContext(), R.drawable.bg_line_maincolor_r4));
                }
                ((LinearLayout) (helper.getView(R.id.ll_detail))).removeAllViews();
                for (int i = 0; i < 5; i++) {
                    CabinetAuthorizationDetailView cabinetAuthorizationDetailView = new CabinetAuthorizationDetailView(getContext());
                    LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                    if (i == 4) {
                        layoutParams.setMargins(DensityUtil.dp2px(12), DensityUtil.dp2px(12), DensityUtil.dp2px(12), 0);
                    } else {
                        layoutParams.setMargins(DensityUtil.dp2px(12), DensityUtil.dp2px(12), 0, 0);
                    }
                    cabinetAuthorizationDetailView.setLayoutParams(layoutParams);
                    if (i == 0) {
                        cabinetAuthorizationDetailView.setTitle(getString(R.string.cabinet_opt_authorization_detail_cabinet_num));
                        cabinetAuthorizationDetailView.setValue(StringUtil.isDataNumberEmpty(item.getStoreNum()));
                    }
                    if (i == 1) {
                        cabinetAuthorizationDetailView.setTitle(getString(R.string.cabinet_opt_authorization_detail_cabinet_fault_num));
                        cabinetAuthorizationDetailView.setValue(StringUtil.isDataNumberEmpty(item.getDamageNum()), ContextCompat.getColor(getContext(), R.color.color_fa4b51));
                    }
                    if (i == 2) {
                        cabinetAuthorizationDetailView.setTitle(getString(R.string.cabinet_opt_authorization_detail_cabinet_lost_num));
                        cabinetAuthorizationDetailView.setValue(StringUtil.isDataNumberEmpty(item.getOfflineNum()));
                    }
                    if (i == 3) {
                        cabinetAuthorizationDetailView.setTitle(getString(R.string.cabinet_opt_authorization_detail_replace_battery_count));
                        String standardSwapTime = item.getStandardSwapTime();
                        if (!TextUtils.isEmpty(standardSwapTime)) {
                            try {
                                int index = standardSwapTime.indexOf(" ");
                                SpannableString spannableString = new SpannableString(standardSwapTime);
                                RelativeSizeSpan relativeSizeSpan = new RelativeSizeSpan(0.76f);
                                spannableString.setSpan(relativeSizeSpan, index, standardSwapTime.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                                cabinetAuthorizationDetailView.setValue(spannableString);
                            } catch (Exception e) {
                                cabinetAuthorizationDetailView.setValue(standardSwapTime);
                            }
                        }
                    }
                    if (i == 4) {
                        cabinetAuthorizationDetailView.setTitle(getString(R.string.cabinet_opt_authorization_detail_seven_day));
                        cabinetAuthorizationDetailView.setValue(item.getAvg7DaySwapTime());
                    }
                    ((LinearLayout) (helper.getView(R.id.ll_detail))).addView(cabinetAuthorizationDetailView);
                }
            }
        };
        mAdapter.setOnItemClickListener((adapter, view, position) -> {
            CabinetAuthorization cabinetAuthorization = (CabinetAuthorization) getData().get(position);
            if (getView() != null) {
                NavController navController = Navigation.findNavController(getView());
                if (navController.getPreviousBackStackEntry() != null) {
                    navController.getPreviousBackStackEntry().getSavedStateHandle().set("SN", cabinetAuthorization.getStationSn());
                    navController.popBackStack();
                }
            }
        });
        return mAdapter;
    }

    @Override
    protected RecyclerView getRecyclerView() {
        return mBinding.rvCabinetList;
    }

    @Override
    protected void initPageData() {
        getCabinetAuthorizationList();
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_cabinet_authorization_list;
    }

    @Override
    protected CabinetAuthorizationOperateViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(CabinetAuthorizationOperateViewModel.class);
    }

    private String stationSn;

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        getStatusView().setEnableLoadMore(true);
        getStatusView().setEnableRefresh(true);
        WindowInsetsHelper.applyForToolbar(mActivity, mBinding.rootlayout.getId());
        initObserver();
        initClicks();
        initData();
    }

    private void initObserver() {
        mCabinetAuthorizationListSearchObserver = bean -> {
            if (bean != null)
                updateListItems(bean.getList());
            getLoading().onFinish();
            getStatusView().onFinishRefresh();
        };
        mBinding.etInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (TextUtils.isEmpty(s.toString())) {
                    mBinding.imClear.setVisibility(View.GONE);
                    inputString = "";
                    onRefresh();
                } else {
                    mBinding.imClear.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                inputString = s.toString();
            }
        });
    }

    String inputString = "";
    boolean isScanSN;

    private void initClicks() {
        mBinding.etInput.setOnEditorActionListener((v, actionId, event) -> {

            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                hideSoftInput();
                onRefresh();
                return true;
            }
            return false;
        });
        mBinding.imClear.setOnClickListener(v -> {
            mBinding.etInput.setText("");
        });
        mBinding.imScan.setOnClickListener(v -> {
            isScanSN = true;
            stationScan(QRCodeActivity.NORMAL);
        });
        mBinding.includeTitle.topBack.setOnClickListener(v -> {
            if (!Navigation.findNavController(v).popBackStack()) {
                mActivity.finish();
            }
        });
    }

    private void initData() {
        Bundle arguments = getArguments();
        if (arguments != null) {
            stationSn = arguments.getString("sn");
        }
        mBinding.includeTitle.topTitle.setText(getString(R.string.cabinet_opt_cabinet_select_title));
        mBinding.includeTitle.topTitle.setGravity(Gravity.CENTER);
        onRefresh();
    }

    private void getCabinetAuthorizationList() {
        getViewModel().getCabinetAuthorizationListSearchData(inputString, pageIndex, pageSize).observe(this, mCabinetAuthorizationListSearchObserver);
    }

    private void stationScan(int type) {
        IntentIntegrator.forSupportFragment(this)
                .setOrientationLocked(false)
                .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
//                .setDesiredBarcodeFormats(IntentIntegrator.QR_CODE)
                .setCaptureActivity(QRCodeActivity.class)
                .initiateScan(); //  初始化扫描
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
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
                    mScanedMessage= ScanUtils.Companion.parseStationQr(requireContext(),mScanedMessage).getSn();
                    inputString = mScanedMessage;
                    mBinding.etInput.setText(inputString);
                    onRefresh();
                }
            }
        }
        isScanSN = false;
    }

}
