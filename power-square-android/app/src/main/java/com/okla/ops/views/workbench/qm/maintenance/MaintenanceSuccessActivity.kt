package com.okla.ops.views.workbench.qm.maintenance

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.okla.ops.R
import com.okla.ops.databinding.FragmentShipSuccessBinding
import com.okla.ops.utils.ViewClickUtils

class MaintenanceSuccessActivity :
    BaseNormalVActivity<MaintenanceBookViewModel, FragmentShipSuccessBinding>() {

    companion object {
        fun getIntents(context: Context) {
            context.startActivity(Intent(context, MaintenanceSuccessActivity::class.java))
        }
    }

    override fun onCreateViewModel(): MaintenanceBookViewModel {
        return ViewModelProvider(this)[MaintenanceBookViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_ship_success
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        mBinding.includeTitle.topTitle.text = mContext.getString(R.string.str_maintenance_succ)
        mBinding.tvResult.text = mContext.getString(R.string.str_maintenance_succ).plus("!")
        mBinding.includeTitle.topBack.setOnClickListener {
            MaintenanceBookActivity.Companion.getIntents(mContext)
            finish()
        }
        mBinding.btnReturn.setOnClickListener {
            if(ViewClickUtils.isFastClick()){
                return@setOnClickListener
            }
            finish()
        }
    }
}