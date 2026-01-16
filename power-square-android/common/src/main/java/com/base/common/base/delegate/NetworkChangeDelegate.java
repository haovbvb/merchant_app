package com.base.common.base.delegate;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import com.base.common.utils.NetworkUtils;

public class NetworkChangeDelegate {

    private final static String TAG = "NetworkChangeDelegate";

    private ConnectivityManager connectivityManager;

    public void register(Context context) {
        connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivityManager != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                connectivityManager.registerDefaultNetworkCallback(networkCallBack);
            } else {
                connectivityManager.registerNetworkCallback(new NetworkRequest.Builder().build(), networkCallBack);
            }
        }
    }

    public void unregister() {
        if (connectivityManager != null) {
            connectivityManager.unregisterNetworkCallback(networkCallBack);
        }
    }

    private final ConnectivityManager.NetworkCallback networkCallBack = new ConnectivityManager.NetworkCallback() {
        //当网络状态修改但仍旧是可用状态时调用
        @Override
        public void onCapabilitiesChanged(@NonNull Network network, @NonNull NetworkCapabilities networkCapabilities) {
            super.onCapabilitiesChanged(network, networkCapabilities);
            if (NetworkUtils.isConnected()) {
                Log.d(TAG, "onCapabilitiesChanged ---> ====网络可正常上网===网络类型为： " + NetworkUtils.getNetworkType());
            }

            //表明此网络连接验证成功
            if (networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)) {
                if (onNetworkChangeListener != null)
                    onNetworkChangeListener.onChange();
                if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                    Log.d(TAG, "===当前在使用Mobile流量上网===");
                } else if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                    Log.d(TAG, "====当前在使用WiFi上网===");
                } else if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH)) {
                    Log.d(TAG, "=====当前使用蓝牙上网=====");
                } else if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                    Log.d(TAG, "=====当前使用以太网上网=====");
                } else if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN)) {
                    Log.d(TAG, "===当前使用VPN上网====");
                } else if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI_AWARE)) {
                    Log.d(TAG, "===表示此网络使用Wi-Fi感知传输====");
                } else if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_LOWPAN)) {
                    Log.d(TAG, "=====表示此网络使用LoWPAN传输=====");
                } else if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_USB)) {
                    Log.d(TAG, "=====表示此网络使用USB传输=====");
                }
            }
        }
    };

    public interface OnNetworkChangeListener {
        void onChange();
    }

    private OnNetworkChangeListener onNetworkChangeListener;

    public void setOnNetworkChangeListener(OnNetworkChangeListener onNetworkChangeListener) {
        this.onNetworkChangeListener = onNetworkChangeListener;
    }
}
