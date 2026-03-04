package com.base.common.utils;

import android.app.Activity;
import android.os.Build;
import android.view.View;

import androidx.annotation.IdRes;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

/**
 * 状态栏适配工具（智能适配刘海屏 & 曲面屏 / 普通屏）
 */
public class WindowInsetsHelper {

    /**
     * 为 Toolbar 或任意 View 自动加上状态栏高度的 paddingTop。
     * 只会在沉浸式（即布局延伸进状态栏时）生效。
     */
    public static void applyForToolbar(Activity activity, @IdRes int toolbarId) {
        if (activity == null) return;
        View toolbar = activity.findViewById(toolbarId);
        if (toolbar == null) return;

        // Android 11+ 推荐用 WindowInsets
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            toolbar.setOnApplyWindowInsetsListener((v, insets) -> {
                int statusBarHeight = insets.getSystemWindowInsetTop();
                if (statusBarHeight > 0) {
                    v.setPadding(
                            v.getPaddingLeft(),
                            statusBarHeight,
                            v.getPaddingRight(),
                            v.getPaddingBottom()
                    );
                }
                return insets;
            });
        } else {
            // 旧版本回退方案
            int resourceId = activity.getResources().getIdentifier("status_bar_height", "dimen", "android");
            if (resourceId > 0) {
                int statusBarHeight = activity.getResources().getDimensionPixelSize(resourceId);
                if (statusBarHeight > 0) {
                    toolbar.setPadding(
                            toolbar.getPaddingLeft(),
                            statusBarHeight,
                            toolbar.getPaddingRight(),
                            toolbar.getPaddingBottom()
                    );
                }
            }
        }
    }

    /**
     * 为底部布局自动加上导航栏高度 paddingBottom。
     * 适配曲面屏 / 刘海屏 / 手势导航。
     */
    public static void applyForBottom(Activity activity, @IdRes int viewId) {
        if (activity == null) return;
        View bottomView = activity.findViewById(viewId);
        if (bottomView == null) return;

        ViewCompat.setOnApplyWindowInsetsListener(bottomView, (v, insets) -> {
            // 获取系统导航栏高度
            int navBarHeight = insets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom;
            if (navBarHeight > 0) {
                v.setPadding(
                        v.getPaddingLeft(),
                        v.getPaddingTop(),
                        v.getPaddingRight(),
                        navBarHeight
                );
            }
            return insets;
        });
    }

    public static void applyForBottom(View bottomView) {
        if (bottomView == null) return;
        ViewCompat.setOnApplyWindowInsetsListener(bottomView, (v, insets) -> {
            int navBarHeight = insets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom;
            v.setPadding(v.getPaddingLeft(), v.getPaddingTop(), v.getPaddingRight(), navBarHeight);
            return insets;
        });
    }


    /**
     * 判断给定 View 的顶部状态栏高度是否大于 0
     */
    public static boolean hasStatusBar(View view) {
        if (view == null) return false;

        WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(view);
        if (insets == null) return false;

        // 旧方法：getSystemWindowInsetTop()
        return insets.getSystemWindowInsetTop() > 0;
    }

    /**
     * 判断给定 View 的底部导航栏高度是否大于 0
     */
    public static boolean hasNavigationBar(View view) {
        if (view == null) return false;

        WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(view);
        if (insets == null) return false;

        // 新方法：getInsets(WindowInsetsCompat.Type.systemBars())
        int navBarHeight = insets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom;
        return navBarHeight > 0;
    }
    /**
     * 获取顶部状态栏高度（px），没有则返回 0
     */
    public static int getStatusBarHeight(View view) {
        if (view == null) return 0;

        WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(view);
        if (insets == null) return 0;

        return insets.getSystemWindowInsetTop();
    }

    /**
     * 获取底部导航栏高度（px），没有则返回 0
     */
    public static int getNavigationBarHeight(View view) {
        if (view == null) return 0;

        WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(view);
        if (insets == null) return 0;

        return insets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom;
    }
}
