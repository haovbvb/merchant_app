package com.base.library.base.mvvm;

import android.os.Bundle;
import android.view.View;

import androidx.databinding.ViewDataBinding;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.base.library.base.delegate.RefreshLoadMoreListener;
import com.base.library.base.delegate.StateViewClickListener;

import java.util.List;

/**
 * @Date: 2019/10/25 16:27
 * @Author: Jayden
 * @Description:  默认使用刷新功能，和状态页，使用最原生的Adapter
 * @Version:
 */
public abstract class BaseListVFragment<VM extends BaseViewModel, V extends ViewDataBinding>
        extends BaseVFragment<VM, V>
        implements RefreshLoadMoreListener, StateViewClickListener {
    protected int defaultStartPageIndex = 1;
    protected int pageIndex = defaultStartPageIndex;
    protected int pageSize = 10;
    protected RecyclerView.Adapter adapter;

    protected abstract RecyclerView.Adapter createAdapter();

    protected abstract RecyclerView getRecyclerView();

    public RecyclerView.Adapter getAdapter() {
        return adapter;
    }

    public void setAdapter(RecyclerView.Adapter adapter) {
        this.adapter = adapter;
    }

    protected abstract void initPageData();

    protected abstract void replaceData(List items);

    protected abstract void addData(List items);

    protected abstract List getData();

    protected List<? extends RecyclerView.ItemDecoration> buildItemDecorations() {
        return null;
    }

    protected RecyclerView.LayoutManager buildLayoutManager() {
        return new LinearLayoutManager(this.getContext());
    }

    public int getPageIndex() {
        return pageIndex;
    }

    public void setPageIndex(int pageIndex) {
        this.pageIndex = pageIndex;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public int getDefaultStartPageIndex() {
        return defaultStartPageIndex;
    }

    public void setDefaultStartPageIndex(int defaultStartPageIndex) {
        this.defaultStartPageIndex = defaultStartPageIndex;
        setPageIndex(defaultStartPageIndex);
    }

    @Override
    protected void initViews(View view, Bundle savedInstanceState) {
        super.initViews(view, savedInstanceState);
        setAdapter(createAdapter());
        if (getRecyclerView() != null) {
            getRecyclerView().setLayoutManager(buildLayoutManager());
            if (buildItemDecorations() != null)
                for (RecyclerView.ItemDecoration itemDecoration : buildItemDecorations()) {
                    getRecyclerView().addItemDecoration(itemDecoration);
                }
            getRecyclerView().setItemAnimator(new DefaultItemAnimator());

            if (getAdapter() != null) {
                getRecyclerView().setAdapter(getAdapter());
            }
        }
    }

    public void updateListItems(List items) {
        updateListItems(items, defaultStartPageIndex);
    }

    public void updateListItems(List items, int defaultStartPageIndex) {
        if (getAdapter() == null) return;
        if (items == null || items.size() == 0) {
            if (pageIndex == defaultStartPageIndex) {
                onEmpty();
            } else getStatusView().onLoadMoreEnd();
        } else {
            onSuccess();
            if (pageIndex == defaultStartPageIndex)
                this.replaceData(items);
            else addData(items);
            pageIndex++;
        }
    }


    @Override
    public void onEmpty() {
        super.onEmpty();
        pageIndex = defaultStartPageIndex;
        if (getAdapter() != null && getData() != null) {
            getData().clear();
            getAdapter().notifyDataSetChanged();
        }
    }

    @Override
    public void onRefresh() {
        pageIndex = defaultStartPageIndex;
        initPageData();
    }

    @Override
    public void onLoadMore() {
        initPageData();
    }

    @Override
    public void onStateViewClick(View view) {
        onRefresh();
    }
}
