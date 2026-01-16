package com.okla.ops.weight;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.okla.ops.R;

public class BatteryCapacityView extends View {

    private Bitmap mBackgroundBitmap;
    private Context context;

    public BatteryCapacityView(Context context) {
        super(context);
        init(context);
    }

    public BatteryCapacityView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public BatteryCapacityView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private Paint mBackPaint;
    private Paint mPowerPaint;
    private RectF rectF;
    private float powerLeft;
    private float powerTop;
    private float powerBottom;
    private float maxPowerRight;
    private float currentPower = 1;

    private void init(Context context) {
        this.context = context;
        mBackgroundBitmap = BitmapFactory.decodeResource(context.getResources(), R.mipmap.bg_battery_capacity);
        mBackPaint = new Paint();
        mBackPaint.setAntiAlias(true);
        mPowerPaint = new Paint();
        mPowerPaint.setAntiAlias(true);
        mPowerPaint.setColor(Color.parseColor("#FF0ABF83"));
        rectF = new RectF();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        int widthSize = MeasureSpec.getSize(widthMeasureSpec);
        switch (widthMode) {
            case MeasureSpec.UNSPECIFIED:
                widthSize = mBackgroundBitmap.getWidth();
                powerLeft = widthSize * 0.2f;
                maxPowerRight = widthSize * 0.5f;
                break;
            case MeasureSpec.AT_MOST:
                widthSize = mBackgroundBitmap.getWidth();
                powerLeft = widthSize * 0.2f;
                maxPowerRight = widthSize * 0.5f;
                break;
            case MeasureSpec.EXACTLY:
                break;
        }
        int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        int heightSize = MeasureSpec.getSize(heightMeasureSpec);
        switch (heightMode) {
            case MeasureSpec.UNSPECIFIED:
                heightSize = mBackgroundBitmap.getHeight();
                powerTop = heightSize * 0.3f;
                powerBottom = heightSize * 0.7f;
                break;
            case MeasureSpec.AT_MOST:
                heightSize = mBackgroundBitmap.getHeight();
                powerTop = heightSize * 0.3f;
                powerBottom = heightSize * 0.7f;
                break;
            case MeasureSpec.EXACTLY:
                break;
        }
        setMeasuredDimension(widthSize, heightSize);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        canvas.drawBitmap(mBackgroundBitmap, 0, 0, mBackPaint);
        float right = currentPower * maxPowerRight;
        if (right > 0) {
            rectF.left = powerLeft;
            rectF.top = powerTop;
            rectF.right = right + powerLeft;
            rectF.bottom = powerBottom;
            canvas.drawRect(rectF, mPowerPaint);
        }
    }

    /**
     * 根据电量显示
     *
     * @param power   电量
     * @param lowFlag 低电量 = 1
     */
    public void setCurrentPower(int power, int lowFlag) {
        /*if (lowFlag == 1) {
            mPowerPaint.setColor(Color.parseColor("#FFFA4B51"));
        } else {
            mPowerPaint.setColor(Color.parseColor("#FF0ABF83"));
        }*/
        if (power > 30) {
            mPowerPaint.setColor(Color.parseColor("#FF00BF00"));
        } else if (power > 10) {
            mPowerPaint.setColor(Color.parseColor("#FFF29A00"));
        } else {
            mPowerPaint.setColor(Color.parseColor("#FFFF4E54"));
        }
        currentPower = power / 100f;
        invalidate();
    }

    /**
     * 根据阈值显示
     *
     * @param power    电量
     * @param swapFlag 阈值
     */
    public void setCurrentSwap(int power, int swapFlag) {
        if (swapFlag == 0) {
            mPowerPaint.setColor(Color.parseColor("#FFFA4B51"));
        } else {
            mPowerPaint.setColor(Color.parseColor("#FF0ABF83"));
        }
        currentPower = power / 100f;
        invalidate();
    }

    public void setDisable() {
        mBackgroundBitmap = BitmapFactory.decodeResource(context.getResources(), R.mipmap.bg_battery_capacity_disable);
        mPowerPaint.setColor(Color.parseColor("#330C0C0D"));
        invalidate();
    }

}
