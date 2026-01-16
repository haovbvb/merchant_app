package com.base.common.base.delegate;

import androidx.annotation.StringRes;

public interface ToolBarEvent {
    default public void onBack() {
    }

    default public void onRightAction() {
    }

    default public void onRightImage() {
    }

    @StringRes
    default public int title() {
        return 0;
    }
}
