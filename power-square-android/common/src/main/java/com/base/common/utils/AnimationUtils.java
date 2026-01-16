package com.base.common.utils;

import android.view.animation.OvershootInterpolator;
import android.view.animation.TranslateAnimation;

import com.base.common.CommonApplication;

public class AnimationUtils {
    public static TranslateAnimation getFromTheTopDown(float fromYDelta) {
        TranslateAnimation translateAnimation = new TranslateAnimation(0f, 0f, -DensityUtil.dp2px(CommonApplication.getInstance(), fromYDelta), 0);
        translateAnimation.setDuration(450);
        translateAnimation.setInterpolator(new OvershootInterpolator(1));
        return translateAnimation;
    }

    public static TranslateAnimation getFromTheDownTop(float fromYDelta) {
        TranslateAnimation translateAnimation = new TranslateAnimation(0f, 0f, 0, -DensityUtil.dp2px(CommonApplication.getInstance(), fromYDelta));
        translateAnimation.setDuration(450);
        translateAnimation.setInterpolator(new OvershootInterpolator(-4));
        return translateAnimation;
    }
}
