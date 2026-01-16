package com.base.common.custom;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.MotionEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatEditText;

public class EditTextWithDrawable extends AppCompatEditText {

    private Drawable mCompoundEndDrawables;
    private Drawable mCompoundStartDrawables;
    private Drawable mCompoundTopDrawables;
    private Drawable mCompoundBottomDrawables;
    private onDrawableEndClick mOnDrawableEndClick;
    private onDrawableStartClick mOnDrawableStartClick;
    private onDrawableTopClick mOnDrawableTopClick;
    private onDrawableBottomClick mOnDrawableBottomClick;

    public EditTextWithDrawable(@NonNull Context context) {
        super(context);
        init();
    }

    public EditTextWithDrawable(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public EditTextWithDrawable(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        Drawable[] compoundDrawablesRelative = getCompoundDrawablesRelative();
        mCompoundStartDrawables = compoundDrawablesRelative[0];
        mCompoundTopDrawables = compoundDrawablesRelative[1];
        mCompoundEndDrawables = compoundDrawablesRelative[2];
        mCompoundBottomDrawables = compoundDrawablesRelative[3];
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            if (mCompoundStartDrawables != null) {
                if (getCompoundPaddingStart() > event.getX() && event.getX() > getPaddingStart()) {
                    if (mOnDrawableStartClick != null) {
                        mOnDrawableStartClick.onClick();
                        return true;
                    }
                }
            }
            if (mCompoundTopDrawables != null) {
                if (getCompoundPaddingTop() > event.getY() && event.getY() > getPaddingTop()) {
                    if (mOnDrawableTopClick != null) {
                        mOnDrawableTopClick.onClick();
                        return true;
                    }
                }
            }
            if (mCompoundEndDrawables != null) {
                //点击范围精准至从图片左侧到图片右侧
//                if (getWidth() - getCompoundPaddingEnd() < event.getX() && getWidth() - getPaddingEnd() > event.getX()) {
                //点击范围为从图片左侧到输入框右侧
                if (getWidth() - (getCompoundPaddingEnd() + getPaddingEnd()) < event.getX() && getWidth() > event.getX()) {
                    if (mOnDrawableEndClick != null) {
                        mOnDrawableEndClick.onClick();
                        return true;
                    }
                }
            }
            if (mCompoundBottomDrawables != null) {
                if (event.getY() > getHeight() - getCompoundPaddingBottom() && getHeight() - getPaddingBottom() > event.getY()) {
                    if (mOnDrawableBottomClick != null) {
                        mOnDrawableBottomClick.onClick();
                        return true;
                    }
                }
            }
        }
        return super.onTouchEvent(event);
    }

    public interface onDrawableEndClick {
        void onClick();
    }

    public interface onDrawableStartClick {
        void onClick();
    }

    public interface onDrawableTopClick {
        void onClick();
    }

    public interface onDrawableBottomClick {
        void onClick();
    }

    public void setOnDrawableEndClick(onDrawableEndClick mOnDrawableEndClick) {
        this.mOnDrawableEndClick = mOnDrawableEndClick;
    }

    public void setOnDrawableStartClick(onDrawableStartClick mOnDrawableStartClick) {
        this.mOnDrawableStartClick = mOnDrawableStartClick;
    }

    public void setOnDrawableTopClick(onDrawableTopClick mOnDrawableTopClick) {
        this.mOnDrawableTopClick = mOnDrawableTopClick;
    }

    public void setOnDrawableBottomClick(onDrawableBottomClick mOnDrawableBottomClick) {
        this.mOnDrawableBottomClick = mOnDrawableBottomClick;
    }
}
