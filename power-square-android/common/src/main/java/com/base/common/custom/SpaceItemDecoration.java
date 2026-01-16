package com.base.common.custom;

import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class SpaceItemDecoration extends RecyclerView.ItemDecoration {

    private final int leftRight;
    private final int topBottom;

    public SpaceItemDecoration(int leftRight, int topBottom) {
        this.leftRight = leftRight;
        this.topBottom = topBottom;
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
                outRect.left = leftRight;
                outRect.right = leftRight;
            } else {
                outRect.left = leftRight;
                if (parent.getChildAdapterPosition(view) == 0) {
                    outRect.left = 0;
                } else if (parent.getChildAdapterPosition(view) == linearLayoutManager.getItemCount() - 1) {
                    outRect.right = 0;
                }
                outRect.top = topBottom;
                outRect.bottom = topBottom;
            }
        }
    }
}
