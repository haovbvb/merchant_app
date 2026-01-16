package com.okla.ops.views.workbench.cabinetopt;

import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.style.ClickableSpan;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.content.ContextCompat;
import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

import com.base.common.base.mvvm.BaseNormalListVFragment;
import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.utils.DensityUtil;
import com.base.common.utils.ToastUtils;
import com.base.library.utils.GsonUtils;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.Cabin;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.custom.BatteryCapacityView;
import com.okla.ops.custom.deviceinfo.MyGridItemDecoration;
import com.okla.ops.databinding.FragmentCabinetOfflineWarehouseBinding;
import com.okla.ops.utils.Attr;
import com.okla.ops.utils.BluetoothBleUtil;
import com.okla.ops.utils.CabinetData;
import com.okla.ops.utils.CabinetDataType;
import com.okla.ops.utils.CabinetInfo;
import com.okla.ops.utils.CabinetParam;
import com.okla.ops.utils.CabinetParamName;
import com.okla.ops.utils.CabinetSignal;
import com.okla.ops.utils.ResultInfo;
import com.google.android.material.bottomsheet.BottomSheetDialog;

import java.util.ArrayList;
import java.util.List;

import razerdp.basepopup.QuickPopupBuilder;
import razerdp.basepopup.QuickPopupConfig;
import razerdp.widget.QuickPopup;

public class CabinetOfflineWarehouseFragment extends BaseNormalVFragment<CabinetOfflineViewModel, FragmentCabinetOfflineWarehouseBinding> {

    public static CabinetOfflineWarehouseFragment getInstance(String sn, String swapThreshold) {
        CabinetOfflineWarehouseFragment fragment = new CabinetOfflineWarehouseFragment();
        Bundle bundle = new Bundle();
        bundle.putString("sn", sn);
        bundle.putString("swapThreshold", swapThreshold);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_cabinet_offline_warehouse;
    }

    @Override
    protected CabinetOfflineViewModel onCreateViewModel() {
        return new ViewModelProvider(requireActivity()).get(CabinetOfflineViewModel.class);
    }

    @Override
    public void onResume() {
        super.onResume();
        BluetoothBleUtil.getInstance().addDataCallback(callback);
        parseAllData(getViewModel().getAllData());
    }

    @Override
    public void onPause() {
        super.onPause();
        BluetoothBleUtil.getInstance().removeDataCallback(callback);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        initAdapter();
        initObserver();
        initClick();
        initData();
    }

    private void initClick() {

    }

    private void initObserver() {
        getViewModel().baseInfoDataLiveData.observe(this, cabinetDetailBaseInfoBean -> {
            mCabinList.clear();
            if (cabinetDetailBaseInfoBean != null) {
                try {
                    int i =cabinetDetailBaseInfoBean.getStoreNum();
                    for (int j = 0; j < i; j++) {
                        mCabinList.add(new Cabin(j + 1, getString(R.string.slot_d, j + 1), "", 0, "", 0, "", 0, "", 0, "", 0));
                    }
                } catch (Exception e) {

                }
            }
            adapter.setNewData(mCabinList);
            parseAllData(getViewModel().getAllData());
        });
    }

    private String deviceSn;
    private int swapThreshold;

    private void initData() {
        Bundle arguments = getArguments();
        if (arguments != null) {
            deviceSn = arguments.getString("sn");
            String swapT = arguments.getString("swapThreshold");
            if (!TextUtils.isEmpty(swapT)) {
                swapThreshold = Integer.parseInt(swapT);
            } else {
                swapThreshold = 100;
            }
        }
        getViewModel().getCabinetBaseInfo(deviceSn);
    }

    private void getCabinetDetail() {
        if (BluetoothBleUtil.getInstance().isConnected()) {
            List<CabinetParam> params = getViewModel().buildParamSetting(CabinetSignal.ALL_DATA, "0");
            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.QUERY_REQUEST, deviceSn, params));
            BluetoothBleUtil.getInstance().addDataToQueue(gson);
            getLoading().onStart();
        }
    }

    private final BluetoothBleUtil.BluetoothBleDataCallback callback = new BluetoothBleUtil.BluetoothBleDataCallback() {
        @Override
        public void onAuthorization() {
            getCabinetDetail();
        }

        @Override
        public void onReceiveData(String data) {
            CabinetData cabinetData = GsonUtils.fromGson(data, CabinetData.class);
            if (cabinetData != null) {
                if (cabinetData.isFull() != null && cabinetData.isFull() == 1) {
                    getLoading().onFinish();
                    parseAllData(data);
                }
                if (cabinetData.getMsgType() == CabinetDataType.QUERY_RESPONSE) {
                    List<ResultInfo> resultList = cabinetData.getResultList();
                    if (resultList != null && !resultList.isEmpty()) {
                        for (ResultInfo resultInfo : resultList) {
                            if (CabinetParamName.CAB_SOC.equals(resultInfo.getId())) {
                                try {
                                    swapThreshold = Integer.parseInt(resultInfo.getValue());
                                } catch (Exception e) {
                                    swapThreshold = 0;
                                }
                                for (int i = 0; i < mCabinList.size(); i++) {
                                    mCabinList.get(i).setSwapFlag(mCabinList.get(i).getBatterySoc() >= swapThreshold ? 1 : 0);
                                    if (adapter != null)
                                        adapter.notifyItemChanged(i);
                                }
                                break;
                            }
                        }
                    }
                }
                if (cabinetData.getMsgType() == CabinetDataType.CONTROL_RESPONSE) {
                    if (cabinetData.getResult() != null && cabinetData.getResult() == 1) {//成功

                    }
                }
            }
        }

        @Override
        public void onDisconnect() {
            getLoading().onFinish();
        }

    };

    private void parseAllData(String data) {
        if(TextUtils.isEmpty(data)){
            return;
        }
        CabinetData cabinetData = GsonUtils.fromGson(data, CabinetData.class);
        if (cabinetData != null) {
            if (cabinetData.getMsgType() == CabinetDataType.ATTRIBUTE_REQUEST) {
                List<Attr> attrList = cabinetData.getAttrList();
                if (attrList != null && !attrList.isEmpty()) {
                    for (Attr attr : attrList) {
                        if (CabinetSignal.CABINET_BATTERY_SWAP_STATUS.equals(attr.getId())) {
                            String doorId = attr.getDoorId();
                            for (int i = 0; i < mCabinList.size(); i++) {
                                if (mCabinList.get(i).getPortNo() == Integer.parseInt(doorId)) {
                                    int i1 = Integer.parseInt(attr.getValue());
                                    mCabinList.get(i).setBatteryStatus(i1 == 0 ? i1 : 1);
                                    if (adapter != null)
                                        adapter.notifyItemChanged(i);
                                    break;
                                }
                            }
                        }
                        if (CabinetSignal.BATTERY_SN.equals(attr.getId())) {
                            String doorId = attr.getDoorId();
                            for (int i = 0; i < mCabinList.size(); i++) {
                                if (mCabinList.get(i).getPortNo() == Integer.parseInt(doorId)) {
                                    mCabinList.get(i).setBatterySn(attr.getValue());
                                    if (adapter != null)
                                        adapter.notifyItemChanged(i);
                                    break;
                                }
                            }
                        }
                        if (CabinetSignal.BATTERY_SOC.equals(attr.getId())) {
                            String doorId = attr.getDoorId();
                            for (int i = 0; i < mCabinList.size(); i++) {
                                if (mCabinList.get(i).getPortNo() == Integer.parseInt(doorId)) {
                                    mCabinList.get(i).setBatterySoc(Integer.parseInt(attr.getValue()));
                                    mCabinList.get(i).setSwapFlag(mCabinList.get(i).getBatterySoc() >= swapThreshold ? 1 : 0);
                                    if (adapter != null)
                                        adapter.notifyItemChanged(i);
                                    break;
                                }
                            }
                        }
                        if (CabinetSignal.CABINET_DOOR_STATUS.equals(attr.getId())) {
                            String doorId = attr.getDoorId();
                            for (int i = 0; i < mCabinList.size(); i++) {
                                if (mCabinList.get(i).getPortNo() == Integer.parseInt(doorId)) {
                                    mCabinList.get(i).setStatus(Integer.parseInt(attr.getValue()));
                                    if (adapter != null)
                                        adapter.notifyItemChanged(i);
                                    break;
                                }
                            }
                        }
                        if (CabinetSignal.CABINET_SWAP_STATUS.equals(attr.getId())) {
                            String doorId = attr.getDoorId();
                            for (int i = 0; i < mCabinList.size(); i++) {
                                if (mCabinList.get(i).getPortNo() == Integer.parseInt(doorId)) {
                                    int i1 = Integer.parseInt(attr.getValue());
                                    mCabinList.get(i).setSwapFlag(i1 > 0 ? 1 : 0);
                                    if (adapter != null)
                                        adapter.notifyItemChanged(i);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private SingleDataBindingNoPUseAdapter adapter;

    private void initAdapter() {
        adapter = new SingleDataBindingNoPUseAdapter<Cabin>(R.layout.item_warehouse) {
            @Override
            public void convert(BaseViewHolder helper, Cabin item, ViewDataBinding viewDataBinding) {
                super.convert(helper, item, viewDataBinding);
                if (item.getStatus() == 0) {
                    ((BatteryCapacityView) helper.getView(R.id.vPowerImg)).setDisable();
                    ((TextView) helper.getView(R.id.tvWarehouseStatus)).setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(getContext(), R.mipmap.icon_cabin_unable), null, null, null);
                    ((TextView) helper.getView(R.id.tvWarehouseStatus)).setText(getString(R.string.cabinet_opt_box_no_use));
                } else if (item.getStatus() == 1 && item.getSwapFlag() == 1) {
                    ((TextView) helper.getView(R.id.tvWarehouseStatus)).setCompoundDrawablesWithIntrinsicBounds(ContextCompat.getDrawable(getContext(), R.mipmap.icon_cabin_enable), null, null, null);
                    ((TextView) helper.getView(R.id.tvWarehouseStatus)).setText(getString(R.string.cabinet_opt_box_can_use));
                }
                ((TextView) helper.getView(R.id.tvPortNum)).setText(String.valueOf(item.getPortNo()));
                ((TextView) helper.getView(R.id.tvBatterySoc)).setText(item.getBatterySoc() + "%");
                ((BatteryCapacityView) helper.getView(R.id.vPowerImg)).setCurrentSwap(item.getBatterySoc(), item.getSwapFlag(), item.getStatus());
                ((TextView) helper.getView(R.id.tvSn)).setText("SN: " + item.getBatterySn());
                ((ConstraintLayout) helper.getView(R.id.btnSetting)).setVisibility(View.VISIBLE);
                ConstraintLayout root = helper.getView(R.id.item_root);
                root.setMinHeight(DensityUtil.dp2px(194));
                ((ConstraintLayout) helper.getView(R.id.btnSetting)).setOnClickListener(v -> {
                    initBottomSheet(item);
                });
            }
        };
        adapter.setOnItemClickListener((adapter, view, position) -> {
        });
        mBinding.rvWarehouseList.setLayoutManager(new StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL));
        mBinding.rvWarehouseList.addItemDecoration(new MyGridItemDecoration(2, DensityUtil.dp2px(12)));
        mBinding.rvWarehouseList.setAdapter(adapter);
    }

    private List<Cabin> mCabinList = new ArrayList<>();

    private BottomSheetDialog mBottomSheetDialog;
    private TextView vTitle;
    private Button openCloseBt;
    private Button enableDisableBt;
    private ArrayList<Integer> portList;
    private Cabin tempCabin;

    /**
     * 初始化操作对话框
     */
    public void initBottomSheet(Cabin item) {
        tempCabin = item;
        if (mBottomSheetDialog == null) {
            mBottomSheetDialog = new BottomSheetDialog(getContext());
            View view = LayoutInflater.from(getContext()).inflate(R.layout.dialog_cabinet_opt_sheet, null, false);
            vTitle = view.findViewById(R.id.tvTitle);
            openCloseBt = (Button) view.findViewById(R.id.open_close_bt);
            Button checkFaultBt = (Button) view.findViewById(R.id.check_fault_bt);
            View line = view.findViewById(R.id.line);
            enableDisableBt = (Button) view.findViewById(R.id.enable_disable_bt);
            Button btnCancel = (Button) view.findViewById(R.id.btn_cancel);
            openCloseBt.setOnClickListener(v -> {
                mBottomSheetDialog.dismiss();
                showTipDialog(1);
            });
            checkFaultBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mBottomSheetDialog.dismiss();
                    if (portList == null) {
                        portList = new ArrayList<>();
                        for (int i = 0; i < mCabinList.size(); i++) {
                            portList.add(mCabinList.get(i).getPortNo());
                        }
                    }
                    startActivity(CabinetOfflineFaultListActivity.getIntents(getContext(), portList, tempCabin.getPortNo(), deviceSn));
                }
            });
            checkFaultBt.setVisibility(View.GONE);
            line.setVisibility(View.GONE);
            enableDisableBt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mBottomSheetDialog.dismiss();
                    showTipDialog(tempCabin.getStatus() == 0 ? 3 : 2);
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
        vTitle.setText(tempCabin.getPortName());
        if (tempCabin.getDoorStatus() == 0) {
            openCloseBt.setTextColor(ContextCompat.getColor(getContext(), R.color.color_e60c0c0d));
            openCloseBt.setText(getString(R.string.cabinet_opt_box_open));
        } else {
            openCloseBt.setTextColor(ContextCompat.getColor(getContext(), R.color.color_4d0c0c0d));
            openCloseBt.setText(getString(R.string.cabinet_opt_box_opened));
        }
        if (tempCabin.getStatus() == 0) {
            enableDisableBt.setTextColor(ContextCompat.getColor(getContext(), R.color.color_e60c0c0d));
            enableDisableBt.setText(getString(R.string.user_state_enable));
        } else {
            enableDisableBt.setTextColor(ContextCompat.getColor(getContext(), R.color.color_fa4b51));
            enableDisableBt.setText(getString(R.string.cabin_cabin_disable));
        }
        mBottomSheetDialog.show();
    }

    private void showTipDialog(int type) {
        try {
            QuickPopup mTipDialog = QuickPopupBuilder.with(getContext())
                    .contentView(R.layout.dialog_warning)
                    .config(new QuickPopupConfig()
                            .gravity(Gravity.CENTER)
                            .outSideTouchable(false)
                            .outSideDismiss(false)
                            .backpressEnable(false)
                            .withClick(R.id.btn_cancel, v -> {
                            }, true)
                            .withClick(R.id.btn_ok, v -> {
                                if (tempCabin != null) {
                                    if (type == 1) {//开仓
                                        if (BluetoothBleUtil.getInstance().isConnected()) {
                                            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParamSetting(CabinetParamName.SWITCH_CONTROL, "04", String.valueOf(tempCabin.getPortNo()))));
                                            BluetoothBleUtil.getInstance().addDataToQueue(gson);
                                        } else {
                                            ToastUtils.showShort(getString(R.string.please_connect_device));
                                        }
                                    }
                                    if (type == 2) {//禁用
                                        if (BluetoothBleUtil.getInstance().isConnected()) {
                                            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParamSetting(CabinetParamName.SWITCH_CONTROL, "06", String.valueOf(tempCabin.getPortNo()))));
                                            BluetoothBleUtil.getInstance().addDataToQueue(gson);
                                        } else {
                                            ToastUtils.showShort(getString(R.string.please_connect_device));
                                        }
                                    }
                                    if (type == 3) {//启动
                                        if (BluetoothBleUtil.getInstance().isConnected()) {
                                            String gson = GsonUtils.toGson(getViewModel().buildFormat(CabinetDataType.CONTROL_REQUEST, deviceSn, getViewModel().buildParamSetting(CabinetParamName.SWITCH_CONTROL, "07", String.valueOf(tempCabin.getPortNo()))));
                                            BluetoothBleUtil.getInstance().addDataToQueue(gson);
                                        } else {
                                            ToastUtils.showShort(getString(R.string.please_connect_device));
                                        }
                                    }
                                }
                            }, true)).build();
            mTipDialog.setBackPressEnable(false);
            mTipDialog.showPopupWindow();
            TextView tvContent = mTipDialog.findViewById(R.id.tvContent);
            if (type == 1) {//开仓
                int portNo = tempCabin.getPortNo();
                String string = getString(R.string.cabinet_opt_box_open_confirm_tips, portNo);
                int start = string.indexOf(String.valueOf(portNo));
                SpannableString spannableString = getSpannableString(start, portNo, string);
                tvContent.setText(spannableString);
            } else if (type == 2) {//禁用
                tvContent.setText(R.string.cabin_detail_remote_disable_cabin_tips);
            } else if (type == 3) {//启用
                tvContent.setText(R.string.cabinet_opt_box_remote_enable);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @NonNull
    private SpannableString getSpannableString(int start, int portNo, String string) {
        int end = start + 1;
        if (portNo > 9)
            end = end + 1;
        SpannableString spannableString = new SpannableString(string);
        spannableString.setSpan(new ClickableSpan() {
            @Override
            public void onClick(@NonNull View widget) {

            }

            @Override
            public void updateDrawState(@NonNull TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(ContextCompat.getColor(mActivity, R.color.main_color));
                ds.setUnderlineText(false);
            }
        }, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        return spannableString;
    }

}
