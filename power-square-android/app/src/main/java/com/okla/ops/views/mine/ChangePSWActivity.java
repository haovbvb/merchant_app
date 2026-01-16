package com.okla.ops.views.mine;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.view.View;

import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProvider;

import com.base.common.Preferences;
import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.common.utils.MD5Util;
import com.base.common.utils.ToastUtils;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityChangePswBinding;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ChangePSWActivity extends BaseNormalVActivity<ChangePSWViewModel, ActivityChangePswBinding> {

    public static void startChangePSWActivity(Context context, String mPersonalId) {
        Intent intent = new Intent(context, ChangePSWActivity.class);
        intent.putExtra("mPersonalId", mPersonalId);
        context.startActivity(intent);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_change_psw;
    }

    @Override
    protected ChangePSWViewModel onCreateViewModel() {
        return new ViewModelProvider(this).get(ChangePSWViewModel.class);
    }

    @Override
    public int title() {
        return R.string.title_change_psw;
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        String mPersonalId = getIntent().getStringExtra("mPersonalId");
        if (!TextUtils.isEmpty(mPersonalId)) {
            if (mPersonalId.contains("@"))
                mPersonalId = mPersonalId.substring(0, mPersonalId.indexOf("@"));
            mBinding.tvUserId.setText(getString(R.string.text_ids, mPersonalId));
        }
        regex = "^(?![0-9]+$)(?![a-zA-Z`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]+$)[0-9A-Za-z`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]{8,36}$";
        initObserver();
        initClicks();
    }

    private void initObserver() {
        mBinding.etOldPwd.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String content = s.toString();
                if (content.isEmpty()) {
                    mBinding.ivClearOldPwd.setVisibility(View.GONE);
                } else {
                    mBinding.ivClearOldPwd.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        mBinding.etOldPwd.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String content = s.toString();
                if (content.isEmpty()) {
                    mBinding.ivClearNewPwd.setVisibility(View.GONE);
                } else {
                    mBinding.ivClearNewPwd.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        mBinding.etNewPwdConfirm.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String content = s.toString();
                if (content.isEmpty()) {
                    mBinding.ivClearNewConfirm.setVisibility(View.GONE);
                } else {
                    mBinding.ivClearNewConfirm.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
    }

    private String regex;

    private void initClicks() {
        mBinding.ivEyeOld.setOnClickListener(v -> {
            if (mBinding.ivEyeOld.isSelected()) {
                mBinding.ivEyeOld.setSelected(false);
                mBinding.ivEyeOld.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.icon_eye_close));
                mBinding.etOldPwd.setTransformationMethod(PasswordTransformationMethod.getInstance());
            } else {
                mBinding.ivEyeOld.setSelected(true);
                mBinding.ivEyeOld.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.icon_eye_open));
                mBinding.etOldPwd.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
            }
            String s = mBinding.etOldPwd.getText().toString();
            if (!TextUtils.isEmpty(s))
                mBinding.etOldPwd.setSelection(s.length());
        });
        mBinding.ivClearOldPwd.setOnClickListener(v -> mBinding.etOldPwd.setText(""));
        mBinding.ivEyeNew.setOnClickListener(v -> {
            if (mBinding.ivEyeNew.isSelected()) {
                mBinding.ivEyeNew.setSelected(false);
                mBinding.ivEyeNew.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.icon_eye_close));
                mBinding.etNewPwd.setTransformationMethod(PasswordTransformationMethod.getInstance());
            } else {
                mBinding.ivEyeNew.setSelected(true);
                mBinding.ivEyeNew.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.icon_eye_open));
                mBinding.etNewPwd.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
            }
            String s = mBinding.etNewPwd.getText().toString();
            if (!TextUtils.isEmpty(s))
                mBinding.etNewPwd.setSelection(s.length());
        });
        mBinding.ivClearNewPwd.setOnClickListener(v -> mBinding.etNewPwd.setText(""));
        mBinding.ivEyeNewConfirm.setOnClickListener(v -> {
            if (mBinding.ivEyeNewConfirm.isSelected()) {
                mBinding.ivEyeNewConfirm.setSelected(false);
                mBinding.ivEyeNewConfirm.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.icon_eye_close));
                mBinding.etNewPwdConfirm.setTransformationMethod(PasswordTransformationMethod.getInstance());
            } else {
                mBinding.ivEyeNewConfirm.setSelected(true);
                mBinding.ivEyeNewConfirm.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.icon_eye_open));
                mBinding.etNewPwdConfirm.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
            }
            String s = mBinding.etNewPwdConfirm.getText().toString();
            if (!TextUtils.isEmpty(s))
                mBinding.etNewPwdConfirm.setSelection(s.length());
        });
        mBinding.ivClearNewConfirm.setOnClickListener(v -> mBinding.etNewPwdConfirm.setText(""));
        mBinding.btnConfirm.setOnClickListener(v -> {
            hideSoftInput();
            String oldPwd = mBinding.etOldPwd.getText().toString();
            if (TextUtils.isEmpty(oldPwd)) {
                ToastUtils.showShort(getString(R.string.tips_enter_current_psw));
                return;
            }
            String newPwd = mBinding.etNewPwd.getText().toString();
            if (TextUtils.isEmpty(newPwd)) {
                ToastUtils.showShort(getString(R.string.tips_enter_new_psw));
                return;
            }
            String newPwdConfirm = mBinding.etNewPwdConfirm.getText().toString();
            if (TextUtils.isEmpty(newPwdConfirm)) {
                ToastUtils.showShort(getString(R.string.tips_enter_new_psw_confirm));
                return;
            }
            if (!TextUtils.equals(newPwd, newPwdConfirm)) {
                ToastUtils.showShort(getString(R.string.tips_enter_psw_not_match));
                return;
            }
            Pattern pattern = Pattern.compile(regex);
            Matcher matcher = pattern.matcher(mBinding.etNewPwd.getText().toString());
            if (matcher.matches()) {
                getLoading().onStart();
                getViewModel().changePwd(MD5Util.encrypt(oldPwd), MD5Util.encrypt(newPwd), MD5Util.encrypt(newPwdConfirm)).observe(this, o -> {
                    Preferences.getInstance().setUserPSW(mBinding.etNewPwd.getText().toString());
                    getLoading().onFinish();
                    if (o != null) {
                        ToastUtils.showShort(getString(R.string.tips_psw_update));
                        finish();
                    }
                });
            } else {
                ToastUtils.showShort(getString(R.string.tips_enter_new_psw_error));
            }
        });
    }
}