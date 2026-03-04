package com.okla.ops.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.RecyclerView;

import com.base.common.utils.DensityUtil;
import com.base.common.utils.Utils;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.R;
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter;
import com.okla.ops.beans.City;
import com.okla.ops.beans.WarehouseBean;
import com.okla.ops.beans.WarehouseBeanType;
import com.okla.ops.custom.NoDataView;
import com.lxj.xpopup.XPopup;

import net.lucode.hackware.magicindicator.FragmentContainerHelper;
import net.lucode.hackware.magicindicator.MagicIndicator;
import net.lucode.hackware.magicindicator.buildins.UIUtil;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.CommonNavigator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.CommonNavigatorAdapter;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerIndicator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.abs.IPagerTitleView;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.indicators.LinePagerIndicator;
import net.lucode.hackware.magicindicator.buildins.commonnavigator.titles.ColorTransitionPagerTitleView;

import java.util.ArrayList;
import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/**
 * Author: Joe
 * Date: 2024/1/26 14:12
 * Description:
 */
public class SelectWarehouseReceiveDialog extends Dialog implements View.OnClickListener {

    private final Activity activity;
    private List<WarehouseBean> mListData;

    private List<City> mCityList;
    private final List<WarehouseBean> mTempListData;
    private final String title;
    private String mSelectNo;

    public SelectWarehouseReceiveDialog(Context context, List<WarehouseBean> list, String title) {
        super(context, com.base.common.R.style.ShareBottomDialogs);
        this.activity = (Activity) context;
        this.mTempListData = new ArrayList<>();
        this.mListData = list;
        this.title = title;
        this.setCancelable(true);
        this.setCanceledOnTouchOutside(false);
        this.setContentView(inflateView());
        resetTempList();//初始化
        showNoDataView();
    }

    public OnClickListener mOnClickListener;

    public void setOnClickListener(OnClickListener onClickListener) {
        this.mOnClickListener = onClickListener;
    }

    public interface OnClickListener {
        public void onItemClick(WarehouseBean warehouseBean);

        public void onSelectCity(City city);

        public void onKeyWordChange(String content);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.iv_close) {
            Utils.setBackgroundAlpha(activity, 1.0f);
            dismiss();
        } else if (v.getId() == R.id.tvCity) {
            showCityListDialog((ArrayList<City>) mCityList);
        }
    }

    @Override
    public void show() {
        super.show();
        initWindow();
        mSelectType = -1;
        filterName = "";
        editText.setText("");
        tvCity.setText(getContext().getString(R.string.text_all_city));
        if (mOnClickListener != null) {
            mOnClickListener.onKeyWordChange(filterName);
            mOnClickListener.onSelectCity(new City());
        }
        Utils.setBackgroundAlpha(activity, 0.5f);
    }

    public void initWindow() {
        Window window = getWindow();
        if (window != null) {
            WindowManager.LayoutParams wl = window.getAttributes();
//            wl.height = ViewGroup.LayoutParams.MATCH_PARENT;
            wl.height = (int) (DensityUtil.getScreenHeight(getContext()) * 0.7f);
            wl.width = ViewGroup.LayoutParams.MATCH_PARENT;
            wl.gravity = Gravity.BOTTOM;
            window.setAttributes(wl);
        }
    }

    @Override
    public void dismiss() {
        Utils.setBackgroundAlpha(activity, 1.0f);
        mSelectType = -1;
        filterName = "";
        editText.setText("");
        tvCity.setText(getContext().getString(R.string.text_all_city));
        super.dismiss();
//        magicIndicator.onPageSelected(0);
    }

    private SingleDataBindingNoPUseAdapter<WarehouseBean> wareHouseAdapter;
    private MagicIndicator magicIndicator;
    private String filterName;
    private int mSelectType;
    private EditText editText;
    private NoDataView noDataView;
    private AppCompatTextView tvCity;

    private RecyclerView recyclerView;

    public View inflateView() {
        View view = LayoutInflater.from(this.getContext()).inflate(R.layout.dialog_select_warehouse_list, null);
        view.findViewById(R.id.iv_close).setOnClickListener(this);
        TextView tvTitle = view.findViewById(R.id.tv_title);
        tvTitle.setText(title);
//        magicIndicator = view.findViewById(R.id.magic_indicator);
        noDataView = view.findViewById(R.id.vNoDataView);
//        initIndicator();
        editText = view.findViewById(R.id.etInput);
        editText.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                filterName = editText.getText().toString();
//                if (TextUtils.isEmpty(filterName)) {
//                    filterListByType(mSelectType);//清空输入筛选
//                } else {
//                    filterListByName(filterName, mSelectType);
//                }
                if (mOnClickListener != null) {
                    mOnClickListener.onKeyWordChange(filterName);
                }
                showNoDataView();
                updateData();
            }
            return false;
        });
        tvCity = view.findViewById(R.id.tvCity);
        tvCity.setOnClickListener(this);
        recyclerView = view.findViewById(R.id.recyclerView);
//        recyclerView.addItemDecoration(new SpaceItemDecoration(DensityUtil.dp2px(8.0f), 0));
        wareHouseAdapter = new SingleDataBindingNoPUseAdapter<WarehouseBean>(R.layout.item_device_transport_warehouse) {
            @Override
            protected void convert(@NonNull BaseViewHolder helper, WarehouseBean item) {
                super.convert(helper, item);
                helper.setText(R.id.tv_name, item.getInWarehouseName().trim());
                AppCompatTextView tvAddress = helper.getView(R.id.tv_address);
                String cityName = item.getCityName();
                if (TextUtils.isEmpty(cityName)) {
                    tvAddress.setVisibility(View.GONE);
                } else {
                    tvAddress.setText(item.getCityName().trim());
                    tvAddress.setVisibility(View.VISIBLE);
                }
                String inWarehouseNo = item.getInWarehouseNo();
                ImageView ivImg = helper.getView(R.id.ivSelected);
                ConstraintLayout itemLayout = helper.getView(R.id.itemlayout);
                if (TextUtils.equals(mSelectNo, inWarehouseNo)) {
                    ivImg.setVisibility(View.VISIBLE);
                    itemLayout.setBackgroundColor(Color.parseColor("#FFF5FCF2"));
                } else {
                    ivImg.setVisibility(View.GONE);
                    itemLayout.setBackgroundColor(Color.parseColor("#ffffff"));
                }
            }
        };
        wareHouseAdapter.setNewData(mTempListData);
        recyclerView.setAdapter(wareHouseAdapter);
        wareHouseAdapter.setOnItemClickListener((adapter, v, position) -> {
            dismiss();
            WarehouseBean warehouseBean = mTempListData.get(position);
            String inWarehouseNo = warehouseBean.getInWarehouseNo();
            if (!TextUtils.equals(mSelectNo, inWarehouseNo)) {
                mSelectNo = inWarehouseNo;
                wareHouseAdapter.notifyDataSetChanged();
                if (mOnClickListener != null) {
                    mOnClickListener.onItemClick(warehouseBean);
                }
            }

        });
        return view;
    }

    /**
     * 更新数据
     *
     * @param list
     */
    public void updateList(List<WarehouseBean> list) {
        mListData = list;
        resetTempList();//刷新数据
        showNoDataView();
        if (wareHouseAdapter != null) {
            wareHouseAdapter.setNewData(mTempListData);
        } else {
            recyclerView.setAdapter(wareHouseAdapter);
        }
    }

    /**
     * 设置城市列表
     */
    public void setCityList(List<City> cityList) {
        mCityList = cityList;
    }

    public void updateData() {
        if (wareHouseAdapter != null)
            wareHouseAdapter.notifyDataSetChanged();
    }

    /**
     * 重置数据
     */
    private void resetTempList() {
        mTempListData.clear();
        if (mListData != null && mListData.size() > 0) {
            mTempListData.addAll(mListData);
        }
    }

    /**
     * 根据输入名称过虑数据
     *
     * @param name 名称
     */
    private void filterListByName(String name, Integer type) {
        if (mListData.size() > 0) {
            List<WarehouseBean> filterList = new ArrayList<>();
            for (WarehouseBean warehouseBean : mListData) {
                String inWarehouseName = warehouseBean.getInWarehouseName();
                Integer warehouseType = warehouseBean.getWarehouseType();
                if (inWarehouseName.contains(name) && (type == -1 || type.equals(warehouseType))) {
                    filterList.add(warehouseBean);
                }
            }
            mTempListData.clear();
            mTempListData.addAll(filterList);
        }
    }

    /**
     * 根据输入名称过虑数据
     *
     * @param type 仓库类型
     */
    private void filterListByType(int type) {
        mSelectType = type;
        if (mListData.size() > 0) {
            List<WarehouseBean> filterList = new ArrayList<>();
            if (type != -1) {
                for (WarehouseBean warehouseBean : mListData) {
                    Integer warehouseType = warehouseBean.getWarehouseType();
                    if (warehouseType != null && warehouseType.equals(type)) {
                        filterList.add(warehouseBean);
                    }
                }
            } else {
                filterList.addAll(mListData);
            }
            mTempListData.clear();
            mTempListData.addAll(filterList);
        }
    }

    private void showNoDataView() {
        if (mTempListData.isEmpty()) {
            noDataView.setVisibility(View.VISIBLE);
        } else {
            noDataView.setVisibility(View.GONE);
        }
    }

    private final List<String> mTitleDataList = new ArrayList<>();
    private final FragmentContainerHelper mFragmentContainerHelper = new FragmentContainerHelper();

    private void initIndicator() {
        mTitleDataList.add(activity.getString(R.string.transport_all));
        mTitleDataList.add(activity.getString(R.string.transport_main_warehouse));
        mTitleDataList.add(activity.getString(R.string.transport_city_warehouse));
        mTitleDataList.add(activity.getString(R.string.transport_service_warehouse));
        CommonNavigator commonNavigator = new CommonNavigator(activity);
        commonNavigator.setAdapter(new CommonNavigatorAdapter() {
            @Override
            public int getCount() {
                return mTitleDataList.size();
            }

            @Override
            public IPagerTitleView getTitleView(Context context, int index) {
                ColorTransitionPagerTitleView simplePagerTitleView = new ColorTransitionPagerTitleView(context);
                simplePagerTitleView.setText(mTitleDataList.get(index));
                simplePagerTitleView.setNormalColor(Color.parseColor("#800C0C0D"));
                simplePagerTitleView.setSelectedColor(Color.parseColor("#E60C0C0D"));
                simplePagerTitleView.setTextSize(14f);
                simplePagerTitleView.setOnClickListener(v -> {
                    mFragmentContainerHelper.handlePageSelected(index);
                    int type = -1;
                    switch (index) {
                        case 1:
                            type = WarehouseBeanType.TYPE_MAIN;
                            break;
                        case 2:
                            type = WarehouseBeanType.TYPE_CITY;
                            break;
                        case 3:
                            type = WarehouseBeanType.TYPE_SERVICE;
                            break;
                    }
                    filterListByType(type);
                    showNoDataView();
                    updateData();
                });
                return simplePagerTitleView;
            }

            @Override
            public IPagerIndicator getIndicator(Context context) {
                LinePagerIndicator linePagerIndicator = new LinePagerIndicator(context);
                linePagerIndicator.setMode(LinePagerIndicator.MODE_EXACTLY);
                linePagerIndicator.setLineWidth(UIUtil.dip2px(context, 30.0) * 1.0f);
                linePagerIndicator.setColors(Color.parseColor("#FF08983B"));
                return linePagerIndicator;
            }
        });
        magicIndicator.setNavigator(commonNavigator);
        mFragmentContainerHelper.attachMagicIndicator(magicIndicator);
    }


    private DialogCityList dialogCityList;
    private String mCityCode = "";

    private void showCityListDialog(ArrayList<City> cityList) {
        if (dialogCityList == null) {
            dialogCityList = new DialogCityList(getContext(), cityList, new Function1<City, Unit>() {
                @Override
                public Unit invoke(City city) {
                    mCityCode = city.getCode() != null ? city.getCode() : "";
                    tvCity.setText(city.getName());
                    if (mOnClickListener != null) {
                        mOnClickListener.onSelectCity(city);
                    }
                    return Unit.INSTANCE;
                }
            });

        } else {
            dialogCityList.setCityList(cityList);
        }
        int maxHeight = (int) (DensityUtil.getScreenHeight(getContext()) * 0.5); // 高度限制为屏幕的50%
        new XPopup.Builder(getContext())
                .maxHeight(maxHeight)
                .asCustom(dialogCityList).show();
    }
}
