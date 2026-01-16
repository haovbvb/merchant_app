package com.okla.ops.views.workbench.warehouse.devicetransport;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.okla.ops.R;
import com.okla.ops.beans.DeviceType;
import com.okla.ops.beans.DeviceTypeObject;

import java.util.List;

public class DeviceTypeGridViewAdapter extends BaseAdapter {

    private Context context;
    private List<DeviceType> list;

    public DeviceTypeGridViewAdapter(Context context, List<DeviceType> list) {
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
        View view = View.inflate(context, R.layout.item_roles, null);
        ImageView ivBg = view.findViewById(R.id.iv_content);
        ImageView ivImg = (ImageView) view.findViewById(R.id.iv_icon);
        TextView tvNameItem = (TextView) view.findViewById(R.id.tv_name);
        DeviceType deviceType = list.get(position);
        switch (deviceType.getDeviceType()) {
            case DeviceTypeObject.TYPE_BATTERY:
                tvNameItem.setText(context.getString(R.string.transport_battery));
                ivImg.setImageDrawable(ContextCompat.getDrawable(context, R.mipmap.icon_transport_battery));
                break;
            case DeviceTypeObject.TYPE_VEHICLE:
                tvNameItem.setText(context.getString(R.string.transport_vehicle));
                ivImg.setImageDrawable(ContextCompat.getDrawable(context, R.mipmap.icon_transport_vehicel));
                break;
            case DeviceTypeObject.TYPE_STATION:
                tvNameItem.setText(context.getString(R.string.transport_station));
                ivImg.setImageDrawable(ContextCompat.getDrawable(context, R.mipmap.icon_transport_station));
                break;
        }
        return view;
    }
}
