package com.base.library.base.delegate;

import android.app.Activity;
import android.view.View;
import android.view.ViewStub;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.OnLifecycleEvent;

import com.base.library.R;
import com.base.library.utils.StringUtil;

public class StatusViewDelegate<T> extends StatusViewImpl<T> {
    private View netErrorView;
    private View dataErrorView;
    private View contentDataView;
    private ViewStub netErrorViewStub;
    private ViewStub dataErrorViewStub;

    public void onViewCreated(View view) {
        if (view == null) {
            return;
        }
        setNetErrorView(view.findViewById(R.id.netErrorView));
        setDataErrorView(view.findViewById(R.id.dataErrorView));
        setContentDataView(view.findViewById(R.id.contentDataView));
        setNetErrorViewStub(view.findViewById(R.id.netErrorViewSub));
        setDataErrorViewStub(view.findViewById(R.id.dataErrorViewSub));
    }

    @Override
    public void initStatusView(View view, Activity activity) {
        super.initStatusView(view, activity);
        if (view != null) {
            onViewCreated(view);
        } else if (activity != null) {
            onCreated(activity);
        }
    }

    public void onCreated(Activity view) {
        if (view == null) {
            return;
        }
        setNetErrorView(view.findViewById(R.id.netErrorView));
        setDataErrorView(view.findViewById(R.id.dataErrorView));
        setContentDataView(view.findViewById(R.id.contentDataView));
        setNetErrorViewStub(view.findViewById(R.id.netErrorViewSub));
        setDataErrorViewStub(view.findViewById(R.id.dataErrorViewSub));
    }

    @Override
    public View getNetErrorView() {
        return netErrorView;
    }

    @Override
    public void setNetErrorView(View netErrorView) {
        this.netErrorView = netErrorView;
    }

    @Override
    public View getDataErrorView() {
        return dataErrorView;
    }

    @Override
    public void setDataErrorView(View dataErrorView) {
        this.dataErrorView = dataErrorView;
    }

    @Override
    public View getContentDataView() {
        return contentDataView;
    }

    @Override
    public void setContentDataView(View contentDataView) {
        this.contentDataView = contentDataView;
    }

    @Override
    public ViewStub getNetErrorViewStub() {
        return netErrorViewStub;
    }

    @Override
    public void setNetErrorViewStub(ViewStub netErrorViewStub) {
        this.netErrorViewStub = netErrorViewStub;
    }

    @Override
    public ViewStub getDataErrorViewStub() {
        return dataErrorViewStub;
    }

    @Override
    public void setDataErrorViewStub(ViewStub dataErrorViewStub) {
        this.dataErrorViewStub = dataErrorViewStub;
    }

    @Override
    public void showNetErrorView(String msg) {
        super.showNetErrorView(msg);
        if (getNetErrorViewStub() != null && getNetErrorView() == null) {
            initNetErrorView();
        }
        if (getNetErrorView() != null) {
            hindContentView();
            getNetErrorView().setVisibility(View.VISIBLE);
            TextView errorInfoTv = getNetErrorView().findViewById(R.id.netErrorInfoTv);
            if (errorInfoTv != null && StringUtil.isNotEmpty(msg)) {
                errorInfoTv.setText(msg);
            }
        }
    }

    @Override
    public void showDataErrorView(String msg) {
        showDataErrorView(msg,0);
    }
    @Override
    public void showDataErrorView(String msg,int imgId) {
        super.showDataErrorView(msg);
        if (getDataErrorViewStub() != null && getDataErrorView() == null) {
            initDataErrorView();
        }
        if (getDataErrorView() != null) {
            hindContentView();
            getDataErrorView().setVisibility(View.VISIBLE);
            TextView errorInfoTv = getDataErrorView().findViewById(R.id.dataErrorInfoTv);
            ImageView errorInfoIv = getDataErrorView().findViewById(R.id.dataErrorInfoIv);
            if (errorInfoTv != null && StringUtil.isNotEmpty(msg)) {
                errorInfoTv.setText(msg);
            }
            if (errorInfoIv != null && imgId != 0) {
                errorInfoIv.setImageResource(imgId);
            }
        }
    }

    @Override
    public void hindContentView() {
        super.hindContentView();
        if (getContentDataView() != null) {
            getContentDataView().setVisibility(View.GONE);
        }
    }

    @Override
    public void showContentView() {
        super.showContentView();
        if (getContentDataView() != null) {
            getContentDataView().setVisibility(View.VISIBLE);
        }
        if (getDataErrorView() != null) {
            getDataErrorView().setVisibility(View.GONE);
        }
        if (getNetErrorView() != null) {
            getNetErrorView().setVisibility(View.GONE);
        }
    }

    @Override
    public void initDataErrorView() {
        super.initDataErrorView();
        if (getDataErrorViewStub() != null && getDataErrorView() == null) {
            setDataErrorView(getDataErrorViewStub().inflate());
        }
        if (getDataErrorView() != null) {
            getDataErrorView().setOnClickListener(view -> onStateViewClick(view));
        }

    }

    @Override
    public void initNetErrorView() {
        super.initNetErrorView();
        if (getNetErrorViewStub() != null && getNetErrorView() == null) {
            setNetErrorView(getNetErrorViewStub().inflate());
        }
        if (getNetErrorView() != null) {
            getNetErrorView().setOnClickListener(view -> onStateViewClick(view));
        }

    }

    private StateViewClickListener stateViewClickListener;

    public StateViewClickListener getStateViewClickListener() {
        return stateViewClickListener;
    }

    public StatusViewDelegate setStateViewClickListener(StateViewClickListener stateViewClickListener) {
        this.stateViewClickListener = stateViewClickListener;
        return this;
    }

    public void onStateViewClick(View view) {
        if (stateViewClickListener != null) {
            stateViewClickListener.onStateViewClick(view);
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    @Override
    public void onDestroy() {
        super.onDestroy();
        stateViewClickListener = null;
        netErrorView = null;
        dataErrorView = null;
        contentDataView = null;
        netErrorViewStub = null;
        dataErrorViewStub = null;
    }
}
