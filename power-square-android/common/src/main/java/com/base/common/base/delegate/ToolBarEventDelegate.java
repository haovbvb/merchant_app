package com.base.common.base.delegate;

import android.app.Activity;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import com.base.common.R;

public class ToolBarEventDelegate {
    public static void initToolBarEvent(Activity view, ToolBarEvent toolBarEvent) {
        if (view == null || toolBarEvent == null) return;
        View topBack = view.findViewById(R.id.topBack);
        if (topBack != null) {
            topBack.setOnClickListener(v -> {
                toolBarEvent.onBack();
            });
        }
        View topRight = view.findViewById(R.id.topRight);
        if (topRight != null) {
            topRight.setOnClickListener(v -> {
                toolBarEvent.onRightAction();
            });
        }
        View topRightImage = view.findViewById(R.id.topRightImage);
        if (topRightImage != null) {
            topRightImage.setOnClickListener(v -> {
                toolBarEvent.onRightImage();
            });
        }
        TextView topTitle = view.findViewById(R.id.topTitle);
        if (topTitle != null && toolBarEvent.title() != 0) {
            topTitle.setGravity(Gravity.CENTER);
            topTitle.setText(view.getString(toolBarEvent.title()));
        }
    }

    public static void initToolBarEvent(View view, ToolBarEvent toolBarEvent) {
        if (view == null || toolBarEvent == null) return;
        View topBack = view.findViewById(R.id.topBack);
        if (topBack != null) {
            topBack.setOnClickListener(v -> {
                toolBarEvent.onBack();
            });
        }
        View topRight = view.findViewById(R.id.topRight);
        if (topRight != null) {
            topRight.setOnClickListener(v -> {
                toolBarEvent.onRightAction();
            });
        }
        View topRightImage = view.findViewById(R.id.topRightImage);
        if (topRightImage != null) {
            topRightImage.setOnClickListener(v -> {
                toolBarEvent.onRightImage();
            });
        }
        TextView topTitle = view.findViewById(R.id.topTitle);
        if (topTitle != null && toolBarEvent.title() != 0) {
            topTitle.setGravity(Gravity.CENTER);
            topTitle.setText(view.getContext().getString(toolBarEvent.title()));
        }
    }
}
