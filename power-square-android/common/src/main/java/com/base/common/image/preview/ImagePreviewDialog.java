package com.base.common.image.preview;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.base.common.R;
import com.base.common.image.iloader.ILoaderManager;
import com.github.chrisbanes.photoview.PhotoView;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class ImagePreviewDialog extends DialogFragment {
    public List<String> imageList;
    public int pos = 0;

    public static ImagePreviewDialog getInstance(List<String> imageList, int pos) {
        ImagePreviewDialog fragment = new ImagePreviewDialog();
        Bundle bundle = new Bundle();
        bundle.putStringArrayList("imageList", (ArrayList<String>) imageList);
        bundle.putInt("pos", pos);
        fragment.setArguments(bundle);
        return fragment;
    }

    private ImagePreviewDialog() {
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NORMAL, android.R.style.Theme_Black_NoTitleBar);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        getDialog().requestWindowFeature(Window.FEATURE_NO_TITLE);
        Window win = getDialog().getWindow();
        if (win != null) {
            win.getDecorView().setPadding(0, 0, 0, 0);
            WindowManager.LayoutParams lp = win.getAttributes();
            lp.width = WindowManager.LayoutParams.MATCH_PARENT;
            lp.height = WindowManager.LayoutParams.MATCH_PARENT;
            win.setAttributes(lp);
        }
        View view = inflater.inflate(R.layout.dialog_image_preview, container);
        return view;
    }

    boolean isshow;

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ViewPager viewPager = view.findViewById(R.id.id_dia_log_vp);
        TextView textView = view.findViewById(R.id.id_image_num);
        TextView imageView = view.findViewById(R.id.id_back);
        ArrayList<String> imageLists = getArguments().getStringArrayList("imageList");
        if (imageLists != null)
            this.imageList = imageLists;
        this.pos = getArguments().getInt("pos", 0);
        if (this.imageList != null) {
            viewPager.setAdapter(new SamplePagerAdapter());
            viewPager.setCurrentItem(this.pos);
            textView.setText(String.format(Locale.US,"%d/%d", this.pos + 1, this.imageList.size()));
        }
        imageView.setOnClickListener(view12 -> {
            this.dismiss();
        });

        viewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                textView.setText(String.format(Locale.US,"%d/%d", position + 1, ImagePreviewDialog.this.imageList.size()));
                isshow = false;
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    public class SamplePagerAdapter extends PagerAdapter {

        @Override
        public int getCount() {
            return imageList.size();
        }

        @Override
        public View instantiateItem(ViewGroup container, int position) {
            PhotoView photoView = new PhotoView(container.getContext());

//            photoView.setImageResource(imageList.get(position));
            ILoaderManager.getLoader().loadNet(photoView, imageList.get(position), null);

            // Now just add PhotoView to ViewPager and return it
            container.addView(photoView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

            return photoView;
        }

        @Override
        public void destroyItem(ViewGroup container, int position, Object object) {
            container.removeView((View) object);
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            return view == object;
        }

    }
}

