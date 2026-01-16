package com.okla.ops.custom.deviceinfo;

import android.graphics.Rect;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class MyGridItemDecoration extends RecyclerView.ItemDecoration {

    private final int rowCount;
    private final int interval;

    public MyGridItemDecoration(int rowCount, int interval) {
        this.rowCount = rowCount;
        this.interval = interval;
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);
        int childAdapterPosition = parent.getChildAdapterPosition(view);
        int row = childAdapterPosition % rowCount;
        if (row == 0) {
            outRect.set(0, 0, interval / 2, 0);
        } else if (row == rowCount - 1) {
            outRect.set(interval / 2, 0, 0, 0);
        } else {
            outRect.set(interval / 4, 0, interval / 4, 0);
        }
        outRect.bottom = interval;
    }
}
