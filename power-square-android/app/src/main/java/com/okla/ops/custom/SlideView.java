package com.okla.ops.custom;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.base.common.utils.DensityUtil;

public class SlideView extends View {

    private Paint mBackPaint;
    private Paint mThumbPaint;

    private Path mBackgroundPath;
    private Path mThumbPath;
    private RectF mThumbRectF;
    private float radius;

    public SlideView(Context context) {
        super(context);
        init(context);
    }

    public SlideView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public SlideView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        mBackPaint = new Paint();
        mBackPaint.setAntiAlias(true);
        mBackPaint.setColor(Color.parseColor("#FFEDEFF2"));
        mThumbPaint = new Paint();
        mThumbPaint.setAntiAlias(true);
        mThumbPaint.setColor(Color.parseColor("#FF00B39B"));


        RectF mBackgroundRectF = new RectF();
        mBackgroundRectF.top = 0;
        mBackgroundRectF.bottom = DensityUtil.dp2px(4.0f);
        mBackgroundRectF.left = 0;
        mBackgroundRectF.right = DensityUtil.dp2px(24.0f);
        mBackgroundPath = new Path();
        radius = DensityUtil.dp2px(2.0f);
        mBackgroundPath.addRoundRect(mBackgroundRectF, radius, radius, Path.Direction.CW);

        mThumbRectF = new RectF();
        mThumbRectF.top = 0;
        mThumbRectF.bottom = DensityUtil.dp2px(4.0f);
        mThumbRectF.left = 0;
        mThumbRectF.right = DensityUtil.dp2px(12.0f);
        mThumbPath = new Path();
        mThumbPath.addRoundRect(mThumbRectF, radius, radius, Path.Direction.CW);

        mThumbWidth = DensityUtil.dp2px(12.0f);

    }

    private float mThumbWidth;
    private float currentOffset;

    @Override
    protected void onDraw(Canvas canvas) {
        canvas.drawPath(mBackgroundPath, mBackPaint);
        float left = currentOffset * mThumbWidth;
        if (left < 0) {
            return;
        }
        mThumbRectF.left = left;
        mThumbRectF.right = left + mThumbWidth;
        mThumbPath.reset();
        mThumbPath.addRoundRect(mThumbRectF, radius, radius, Path.Direction.CW);
        canvas.drawPath(mThumbPath, mThumbPaint);
    }

    public void move(float offsetPercent) {
        if (offsetPercent < 0 || offsetPercent > 1) {
            return;
        }
        currentOffset = offsetPercent;
        invalidate();
    }

}
