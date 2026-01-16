package com.base.common.permission;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.provider.Settings;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.ActivityResultRegistry;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.OnLifecycleEvent;

import com.base.common.R;
import com.orhanobut.logger.Logger;
import com.tbruyelle.rxpermissions2.RxPermissions;

import java.util.List;
import java.util.Map;

import io.reactivex.disposables.Disposable;

public class PermissionManager implements LifecycleObserver {
    private ActivityResultRegistry registry;
    ActivityResultLauncher<String[]> permissionResultLauncher;
    private OnPermissionListener listener;
    private String key;

    public PermissionManager(ActivityResultRegistry registry, String key, LifecycleOwner owner) {
        this.registry = registry;
        this.key = key;
        onCreate(owner);
    }

    public static PermissionManager getInstance(ActivityResultRegistry registry, String key, LifecycleOwner owner) {
        return new PermissionManager(registry, key, owner);
    }

    public void onCreate(LifecycleOwner owner) {
        if (owner == null || registry == null) {
            return;
        }
        if (permissionResultLauncher == null) {
            permissionResultLauncher = registry.register(key == null ? "PermissionManager" + System.currentTimeMillis() : key, owner, new ActivityResultContracts.RequestMultiplePermissions(), result -> {
                checkPermissionsDatas(result);
            });
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    public void onDestroy(LifecycleOwner owner) {
        listener = null;
        registry = null;
        permissionResultLauncher = null;
    }

    public void checkPermissions(OnPermissionListener listener, String... permissions) {
        this.listener = listener;
        if (permissionResultLauncher == null && registry != null) {
            permissionResultLauncher = registry.register(key == null ? "PermissionManager" + System.currentTimeMillis() : key, new ActivityResultContracts.RequestMultiplePermissions(), this::checkPermissionsDatas);
        }
        if (permissionResultLauncher != null) {
            permissionResultLauncher.launch(permissions);
        }
    }

    public boolean checkPermissionsDatas(Map<String, Boolean> result) {
        boolean allPass = true;
        for (Map.Entry<String, Boolean> entry : result.entrySet()) {
            Logger.i("checkPermissions result %s = %s", entry.getKey(), entry.getValue());
            if (!entry.getValue()) {
                allPass = false;
            }
        }
        if (listener != null) {
            if (allPass) {
                listener.passPermission();
            } else {
                listener.deniedPermission();
            }
        }
        return allPass;
    }

    public static void askForPermission(Activity mActivity, String msg) {
        AlertDialog.Builder builder = new AlertDialog.Builder(mActivity);
        builder.setTitle(mActivity.getString(R.string.permission_set_permission));
        builder.setMessage(String.format(mActivity.getString(R.string.permission_permission_tip), msg));
        builder.setNegativeButton(mActivity.getString(R.string.permission_cancel), (dialog, which) -> {

        });
        builder.setPositiveButton(mActivity.getString(R.string.permission_to_set), (dialog, which) -> {
            Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            intent.setData(Uri.parse("package:" + mActivity.getPackageName())); // 根据包名打开对应的设置界面
            mActivity.startActivity(intent);
        });
        builder.create().show();
    }
    /**
     * 判断一组权限是否全部已授权
     *
     * @param context     上下文
     * @param permissions 需要检查的权限列表
     * @return 全部授权返回 true，否则返回 false
     */
    public static boolean hasPermissions(Context context, List<String> permissions) {
        for (String perm : permissions) {
            if (ContextCompat.checkSelfPermission(context, perm)
                    != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    public static Disposable checkPermission(Fragment context, OnPermissionListener listener, String... permissions) {
        return checkPermissionImp(new RxPermissions(context), listener, permissions);
    }

    public static Disposable checkPermission(FragmentActivity context, OnPermissionListener listener, String... permissions) {
        return checkPermissionImp(new RxPermissions(context), listener, permissions);
    }

    /**
     * 申请权限 未定义任何默认操作
     *
     * @param rxPermissions
     * @param listener
     * @param permissions
     * @return
     */
    private static Disposable checkPermissionImp(RxPermissions rxPermissions, OnPermissionListener listener, String... permissions) {
        return rxPermissions.requestEachCombined(permissions)
                .subscribe(permission -> {
                    if (permission.granted) {
                        Logger.i("PermissionManager 用户同意了该权限");
                        if (listener != null)
                            listener.passPermission();
                    } else if (permission.shouldShowRequestPermissionRationale) {
                        Logger.i("PermissionManager 用户拒绝了该权限，没有选中『不再询问』，可进行弹窗说明，确认后重新请求权限");
                        if (listener != null)
                            listener.showRequestPermissionRationale();
                    } else {
                        Logger.i("PermissionManager 用户拒绝了该权限，选中『不再询问』，可进行二次弹窗，确认后进入app设置页面");
                        if (listener != null)
                            listener.deniedPermission();
                    }
                }, throwable -> {
                    if (listener != null)
                        listener.onError(throwable);
                    Logger.e("PermissionManager " + throwable.getMessage());
                });
    }

}