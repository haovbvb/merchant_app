package com.okla.ops.views.monitor.cabinetdetail.search;

import android.os.Bundle;
import android.view.View;

import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.base.mvvm.BaseNormalVFragment;
import com.base.common.dialog.CustomDialog;
import com.base.common.utils.DateTimeUtils;
import com.base.common.utils.LanguageUtils;
import com.okla.ops.R;
import com.okla.ops.databinding.FragmentSearchBinding;
import com.okla.ops.views.monitor.cabinetdetail.search.cabinetversion.CabinetVersionActivity;
import com.okla.ops.views.monitor.cabinetdetail.search.localstatus.LocalStatusActivity;

/**
 * @Date: 2021/1/26 14:27
 * @Author: craz
 * @Description:
 * @Version:
 */

public class SearchFragment extends BaseNormalVFragment<SearchViewModel, FragmentSearchBinding> {

    private String mCabinetPID;
    private Observer<Long> timeObserver;
    private CustomDialog.Builder builder;

    public static SearchFragment getInstance(String pid) {
        SearchFragment fragment = new SearchFragment();
        Bundle bundle = new Bundle();
        bundle.putString("pid", pid);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_search;
    }

    @Override
    protected SearchViewModel onCreateViewModel() {
        return new ViewModelProvider(getActivity()).get(SearchViewModel.class);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        mCabinetPID = getArguments().getString("pid");
        mBinding.setView(this);
        initObserver();
    }

    long timeLong;
    private void initObserver() {
        timeObserver = new Observer<Long>() {
            @Override
            public void onChanged(Long aLong) {
                timeLong = aLong;
                showTimeDialog();
            }
        };
    }

    public void onClickView(View view) {
        switch (view.getId()) {
            case R.id.search_status:
                startActivity(LocalStatusActivity.getIntents(getContext(),mCabinetPID));
                break;
            case R.id.search_time:
                getViewModel().getCabinetTime(mCabinetPID).observe(getActivity(),timeObserver);
                break;
            case R.id.search_version:
                startActivity(CabinetVersionActivity.getIntents(getContext(),mCabinetPID));
                break;
            default:
                break;
        }
    }

    private void showTimeDialog() {
        builder = new CustomDialog.Builder(getActivity())
                .setMessage(DateTimeUtils.utc2Local(timeLong,"yyyy/MM/dd HH:mm:ss", LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage()))
                .setIKnowButton((dialog, which) -> {
                    dialog.dismiss();
                });
        builder.create().show();
    }


    public void reFreshSn(String mCabinetPID,String mCabinetSN){
        this.mCabinetPID = mCabinetPID;
//        this.mCabinetSN = mCabinetSN;
    }
}