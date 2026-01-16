package com.okla.ops.adapter;

import android.view.View;
import android.view.ViewGroup;

import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;

import com.chad.library.adapter.base.BaseQuickAdapter;
import com.chad.library.adapter.base.BaseViewHolder;
import com.okla.ops.BR;

public class SingleDataBindingNoPUseAdapter<T> extends BaseQuickAdapter<T, BaseViewHolder> {

    public SingleDataBindingNoPUseAdapter(int layoutResId) {
        super(layoutResId, null);
        this.setHasStableIds(true);
        setMultiTypeDelegate();
    }

    public SingleDataBindingNoPUseAdapter() {
        super(null);
        this.setHasStableIds(true);
        setMultiTypeDelegate();
    }

    public void setMultiTypeDelegate() {
    }

    @Override
    protected void convert(BaseViewHolder helper, T item) {
        ViewDataBinding binding = getViewDataBinding(helper);
        binding.setVariable(BR.data, item);
        binding.executePendingBindings();
        convert(helper, item, binding);
    }

    public ViewDataBinding getViewDataBinding(BaseViewHolder helper) {
        return (ViewDataBinding) helper.itemView.getTag(com.chad.library.R.id.BaseQuickAdapter_databinding_support);
    }

    @Override
    protected View getItemView(int layoutResId, ViewGroup parent) {
        ViewDataBinding binding = DataBindingUtil.inflate(mLayoutInflater, layoutResId, parent, false);
        if (binding == null) {
            return super.getItemView(layoutResId, parent);
        }
        View view = binding.getRoot();
        view.setTag(com.chad.library.R.id.BaseQuickAdapter_databinding_support, binding);
        return view;
    }

    public void convert(BaseViewHolder helper, T item, ViewDataBinding viewDataBinding) {

    }
}
