package com.okla.ops.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.okla.ops.R;
import com.okla.ops.views.workbench.ModuleItem;

import java.util.List;

public class WorkbenchGridViewAdapter extends BaseAdapter {
    private final Context context;
    private final List<ModuleItem> list;

    public WorkbenchGridViewAdapter(Context context, List<ModuleItem> list) {
        this.context = context;
        this.list = list;
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public Object getItem(int position) {
        return list.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = View.inflate(context, R.layout.item_workbench, null);
        ImageView ivImg = (ImageView) view.findViewById(R.id.imgWorkbenchItem);
        TextView tvWorkbenchItem = (TextView) view.findViewById(R.id.tvWorkbenchItem);
        ModuleItem item = list.get(position);
        ivImg.setImageResource(item.getModule().getIconRes());
        tvWorkbenchItem.setText(context.getString(item.getModule().getTitleResId()));
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                item.getOnClick().invoke();
            }
        });
        return view;
    }
}

