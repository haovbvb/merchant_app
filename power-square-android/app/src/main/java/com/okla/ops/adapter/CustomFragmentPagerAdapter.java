package com.okla.ops.adapter;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;

public class CustomFragmentPagerAdapter extends FragmentStatePagerAdapter {
    private static final String TAG = "CustomFragmentPagerAdapter";
    private OnFragmentChangeListener mFragmentChangeListener = null;
    private int mCount = 0;
    public CustomFragmentPagerAdapter(FragmentManager fm, OnFragmentChangeListener l) {
        super(fm);
        this.mFragmentChangeListener = l;
    }

    /**
     * 设置count
     *
     * @param count
     */
    public void setCount(int count) {
        this.mCount = count;
    }

    @Override
    public int getCount() {
        return mCount;
    }

    @Override
    public Fragment getItem(int arg0) {
        if (null == mFragmentChangeListener) {
            return null;
        }
        return mFragmentChangeListener.getFragment(arg0);
    }

    public interface OnFragmentChangeListener {
        Fragment getFragment(int position);
    }
}
