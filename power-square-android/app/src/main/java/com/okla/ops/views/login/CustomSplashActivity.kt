package com.okla.ops.views.login

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.StatusBarUtil
import com.okla.ops.R
import com.okla.ops.databinding.ActivitySplashBinding
import com.okla.ops.views.MainActivity

class CustomSplashActivity : BaseNormalVActivity<LoginViewModel, ActivitySplashBinding>() {

    companion object {
        fun startSplashActivity(context: Context) {
            val intent = Intent(context, CustomSplashActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): LoginViewModel {
        return ViewModelProvider(this)[LoginViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_splash
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
        if (TextUtils.isEmpty(DataStoreUtils.readStringData(DataStoreKeyUtils.ACCESSTOKEN, ""))) {
            LoginActivity.startLoginActivity(this)
            finish()
        } else {
            initObserver()
            initData()
        }
    }

    private fun initData() {
        getViewModel().refreshToken()
    }

    private fun initObserver() {
        getViewModel().tokenLiveData.observe(this) {
            if (it == null) {
                LoginActivity.startLoginActivity(this)
            } else {
                MainActivity.startMainActivity(this)
            }
            finish()
        }
    }

}