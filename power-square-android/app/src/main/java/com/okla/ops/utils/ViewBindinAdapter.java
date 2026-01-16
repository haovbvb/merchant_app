package com.okla.ops.utils;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.databinding.BindingAdapter;

import com.bumptech.glide.Glide;
import com.okla.ops.R;
import com.okla.ops.custom.deviceinfo.InformationView;


public class ViewBindinAdapter {


    @BindingAdapter("setVisibility")
    public static void setVisibility(View view, boolean isGone) {
        view.setVisibility(isGone ? View.GONE : View.VISIBLE);
    }

    @BindingAdapter("setImg")
    public static void setImg(ImageView imageView, int img) {
        imageView.setImageResource(img);
    }

    @BindingAdapter("setInfoTitle")
    public static void setInfoTitle(InformationView informationView, String data) {
        informationView.setValue(data);
    }

    @BindingAdapter("setInfoValue")
    public static void setInfoValue(InformationView informationView, String data) {
        informationView.setValue(data);
    }

}
