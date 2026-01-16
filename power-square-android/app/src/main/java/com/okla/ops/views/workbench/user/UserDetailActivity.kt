package com.okla.ops.views.workbench.user

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.okla.ops.R
import com.okla.ops.databinding.ActivityUserDetailBinding

class UserDetailActivity : BaseNormalVActivity<UserViewModel, ActivityUserDetailBinding>() {

    companion object {
        fun startUserDetailActivity(context: Context, cardNum: String) {
            val intent = Intent(context, UserDetailActivity::class.java)
            intent.putExtra("cardNum", cardNum)
            context.startActivity(intent)
        }
    }

    override fun title(): Int {
        return R.string.title_user_detail
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_user_detail
    }

    private var mCardNum: String = ""
    override fun getIntentExtras(intent: Intent?) {
        super.getIntentExtras(intent)
        mCardNum = intent?.getStringExtra("cardNum") ?: ""
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initObserver()
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        initData()
    }

    private fun initObserver() {
        getViewModel().userDetailLiveData.observe(this) {
            if (it != null) {
                mBinding.emptyView.visibility = View.GONE
                supportFragmentManager.beginTransaction()
                    .replace(R.id.flContent, UserDetailFragment.getInstance(it)).commit()
            } else {
                mBinding.emptyView.visibility = View.VISIBLE
            }
        }
    }

    private fun initData() {
        getViewModel().getUserDetail(mCardNum)
    }

}