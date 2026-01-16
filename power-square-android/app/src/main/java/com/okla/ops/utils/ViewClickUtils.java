package com.okla.ops.utils;


import android.view.MotionEvent;
import android.view.View;

public class ViewClickUtils {
    private static final int MIN_DELAY_TIME = 500;  // 两次点击间隔不能少于1000ms
    private static long lastClickTime;

    public static boolean isFastClick() {
        boolean flag = true;
        long currentClickTime = System.currentTimeMillis();
        if ((currentClickTime - lastClickTime) >= MIN_DELAY_TIME) {
            flag = false;
        }
        lastClickTime = currentClickTime;
        return flag;
    }

    // 判断触摸点是否在View内部
    public static boolean isTouchInsideView(MotionEvent event, View view) {
        int[] viewLocation = new int[2];
        view.getLocationOnScreen(viewLocation);
        float touchX = event.getRawX();
        float touchY = event.getRawY();

        return (touchX >= viewLocation[0] &&
                touchX <= viewLocation[0] + view.getWidth() &&
                touchY >= viewLocation[1] &&
                touchY <= viewLocation[1] + view.getHeight());
    }
}
