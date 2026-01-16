package com.base.common.custom;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class BackgroundItemDecoration extends RecyclerView.ItemDecoration {

    private final Paint paint;

    public BackgroundItemDecoration(int color) {
        paint = new Paint();
        paint.setColor(color); // 设置背景颜色
        paint.setStyle(Paint.Style.FILL);
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        LinearLayoutManager linearLayoutManager = (LinearLayoutManager) parent.getLayoutManager();
        if (linearLayoutManager != null) {
            if (linearLayoutManager.getOrientation() == LinearLayoutManager.VERTICAL) {
                if (parent.getChildAdapterPosition(view) == 0) {
                    outRect.top = 0;
                } else if (parent.getChildAdapterPosition(view) == linearLayoutManager.getItemCount() - 1) {
                    outRect.bottom = 0;
                }
            }
        }
    }

    @Override
    public void onDraw(@NonNull Canvas canvas, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        super.onDraw(canvas, parent, state);

        int childCount = parent.getChildCount();
        for (int i = 0; i < childCount; i++) {
            View child = parent.getChildAt(i);

            // 获取 item 的边界
            Rect bounds = new Rect();
            parent.getDecoratedBoundsWithMargins(child, bounds);

            // 绘制背景
            canvas.drawRect(bounds, paint);
        }
    }
}