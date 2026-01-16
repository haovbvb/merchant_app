package com.okla.ops.adapter;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;

public class ViewPager2FragmentAdapter extends FragmentStateAdapter {
    private int mCount;
    private OnCreateFragmentListener mOnCreateFragmentListener;

    public interface OnCreateFragmentListener {
        Fragment onCreateFragment(int position);
    }

    public ViewPager2FragmentAdapter(@NonNull FragmentActivity fragmentActivity, int count, OnCreateFragmentListener onCreateFragmentListener) {
        super(fragmentActivity);
        this.mCount = count;
        this.mOnCreateFragmentListener = onCreateFragmentListener;
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        if (mOnCreateFragmentListener != null) {
            return mOnCreateFragmentListener.onCreateFragment(position);
        }
        return null;
    }

    @Override
    public int getItemCount() {
        return mCount;
    }
}
