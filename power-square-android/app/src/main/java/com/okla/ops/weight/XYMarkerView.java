package com.okla.ops.weight;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.Log;
import android.util.TypedValue;

import androidx.appcompat.widget.AppCompatTextView;

import com.base.common.timepicker.DateFormatUtils;
import com.base.common.utils.DateTimeUtils;
import com.base.common.utils.LanguageUtils;
import com.base.common.utils.NumToStrUtil;
import com.github.mikephil.charting.charts.Chart;
import com.github.mikephil.charting.components.MarkerView;
import com.github.mikephil.charting.data.CandleEntry;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.highlight.Highlight;
import com.github.mikephil.charting.utils.Utils;
import com.okla.ops.R;

import java.util.List;

public class XYMarkerView extends MarkerView {
    private final int ARROW_HEIGHT = dp2px(6); // 箭头的高度
    private final int ARROW_WIDTH = dp2px(20); // 箭头的宽度
    private final float ARROW_OFFSET = dp2px(2);//箭头偏移量
    private final float BG_CORNER = dp2px(10);//背景圆角
    private final AppCompatTextView tvContent;//文本
    private final AppCompatTextView tvDate;//日期

    private final Bitmap bitmapForDot;//选中点图片
    private final int bitmapWidth;//点宽
    private final int bitmapHeight;//点高

    private final Paint bgPaint;
    private final Paint arrowPaint;

    private final String mPrefix;
    private final List<String> mDataList;

    private final Path path;

    public XYMarkerView(Context context, String prefix, List<String> data) {
        super(context, R.layout.view_mark_mileage);

        tvContent = findViewById(R.id.tvValue);
        tvDate = findViewById(R.id.tvDate);
        mPrefix = prefix;
        mDataList = data;
        //图片自行替换
        bitmapForDot = getBitmap(context, R.drawable.icon_brightness_curve_point);
        bitmapWidth = bitmapForDot.getWidth();
        bitmapHeight = bitmapForDot.getHeight();

        //指示器背景画笔
        bgPaint = new Paint();
        bgPaint.setStyle(Paint.Style.FILL);
        bgPaint.setAntiAlias(true);
        bgPaint.setColor(Color.parseColor("#E6030B33"));
        //剪头画笔
        arrowPaint = new Paint();
        arrowPaint.setStyle(Paint.Style.FILL);
        arrowPaint.setAntiAlias(true);
        arrowPaint.setColor(Color.parseColor("#E6030B33"));

        path = new Path();
    }

    private static Bitmap getBitmap(Context context, int vectorDrawableId) {
        Bitmap bitmap = null;
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP) {
            Drawable vectorDrawable = context.getDrawable(vectorDrawableId);
            bitmap = Bitmap.createBitmap(vectorDrawable.getIntrinsicWidth(),
                    vectorDrawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            vectorDrawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
            vectorDrawable.draw(canvas);
        } else {
            bitmap = BitmapFactory.decodeResource(context.getResources(), vectorDrawableId);
        }
        return bitmap;
    }

    @Override
    public void refreshContent(Entry e, Highlight highlight) {
        if (e instanceof CandleEntry) {
            CandleEntry ce = (CandleEntry) e;
            String timestamp = mDataList.get(Integer.parseInt(Utils.formatNumber(ce.getLow(), 0, true)));
            if (timestamp.length() == 1) {
                timestamp = "0" + timestamp;
            }
            String date;
            if (mPrefix.contains("-")) {//年月
                long l = DateTimeUtils.stringToLong(mPrefix + "-" + timestamp, DateTimeUtils.dateFormat, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
                date = DateTimeUtils.getTimeString(DateTimeUtils.dateFormatY, l, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
            } else {//年
                long l = DateTimeUtils.stringToLong(mPrefix + "-" + timestamp + "-01", DateTimeUtils.dateFormat, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
                date = DateTimeUtils.getTimeString(DateTimeUtils.MMM_YYYY, l, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
            }
            tvDate.setText(date);
            tvContent.setText(NumToStrUtil.INSTANCE.FloatToStrWith2(ce.getHigh()));
        } else {
            String timestamp = mDataList.get(Integer.parseInt(Utils.formatNumber(e.getX(), 0, true)));
            if (timestamp.length() == 1) {
                timestamp = "0" + timestamp;
            }
            String date;
            if (mPrefix.contains("-")) {//年月
                long l = DateTimeUtils.stringToLong(mPrefix + "-" + timestamp, DateTimeUtils.dateFormat, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
                date = DateTimeUtils.getTimeString(DateTimeUtils.dateFormatY, l, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
            } else {//年
                long l = DateTimeUtils.stringToLong(mPrefix + "-" + timestamp + "-01", DateTimeUtils.dateFormat, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
                date = DateTimeUtils.getTimeString(DateTimeUtils.MMM_YYYY, l, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
            }
            tvDate.setText(date);
            tvContent.setText(NumToStrUtil.INSTANCE.FloatToStrWith2(e.getY()));
        }
        super.refreshContent(e, highlight);
    }

    @Override
    public void draw(Canvas canvas, float posX, float posY) {
        Chart chart = getChartView();
        if (chart == null) {
            super.draw(canvas, posX, posY);
            return;
        }

        float width = getWidth();
        float height = getHeight();
        float chartWidth = chart.getWidth();

        int saveId = canvas.save();
        //移动画布到点并绘制点
        canvas.translate(posX, posY);
        canvas.drawBitmap(bitmapForDot, -bitmapWidth / 2f, -bitmapHeight / 2f, null);

        //画指示器
//        Path path = new Path();
        path.reset();
        RectF bRectF;
        if (posY < height + ARROW_HEIGHT + ARROW_OFFSET + bitmapHeight / 2f) {//处理超过上边界
            //移动画布并绘制三角形和背景
            canvas.translate(0, height + ARROW_HEIGHT + ARROW_OFFSET + bitmapHeight / 2f);
            path.moveTo(0, -(height + ARROW_HEIGHT));
            path.lineTo(ARROW_WIDTH / 2f, -(height - BG_CORNER));
            path.lineTo(-ARROW_WIDTH / 2f, -(height - BG_CORNER));
            path.lineTo(0, -(height + ARROW_HEIGHT));

            float dx;
            if (posX + width > chartWidth) {//超出右边界
                dx = chartWidth - (posX + width);
                bRectF = new RectF(dx, -height, width + dx, 0);
            } else {
                if (posX > width / 2f) {//正常范围
                    dx = -width / 2f;
                    bRectF = new RectF(dx, -height, width / 2, 0);
                } else {//超出左边界
                    float d = width / 2f - posX;
                    dx = -width / 2f + d;
                    bRectF = new RectF(dx, -height, width / 2 + d, 0);
                }
            }

            canvas.drawPath(path, arrowPaint);
            canvas.drawRoundRect(bRectF, BG_CORNER, BG_CORNER, bgPaint);
            canvas.translate(dx, -height);
        } else {//没有超过上边界
            //移动画布并绘制三角形和背景
            canvas.translate(0, -height - ARROW_HEIGHT - ARROW_OFFSET - bitmapHeight / 2f);
            path.moveTo(0, height + ARROW_HEIGHT);
            path.lineTo(ARROW_WIDTH / 2f, height - BG_CORNER);
            path.lineTo(-ARROW_WIDTH / 2f, height - BG_CORNER);
            path.lineTo(0, height + ARROW_HEIGHT);

            float dx;
            if (posX + width > chartWidth) {//超出右边界
                dx = chartWidth - (posX + width);
                bRectF = new RectF(dx, 0, width + dx, height);
            } else {
                if (posX > width / 2f) {//正常范围
                    dx = -width / 2f;
                    bRectF = new RectF(dx, 0, width / 2, height);
                } else {//超出左边界
                    float d = width / 2f - posX;
                    dx = -width / 2f + d;
                    bRectF = new RectF(dx, 0, width / 2 + d, height);
                }
            }
            canvas.drawPath(path, arrowPaint);
            canvas.drawRoundRect(bRectF, BG_CORNER, BG_CORNER, bgPaint);
            canvas.translate(dx, 0);
        }
        draw(canvas);
        canvas.restoreToCount(saveId);
    }

    private int dp2px(int dpValues) {
        return (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, dpValues,
                getResources().getDisplayMetrics());
    }
}
