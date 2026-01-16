package com.okla.ops.views.workbench.qm.aftersalebind

import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.utils.StatusBarUtil
import com.okla.ops.R
import com.okla.ops.databinding.FragmentPaymentSuccessBinding

class AfterSaleBindSucFragment :
    BaseNormalVFragment<AfterSaleBindViewModel, FragmentPaymentSuccessBinding>() {

    override fun getLayoutId(): Int {
        return R.layout.fragment_payment_success
    }

    override fun title(): Int {
        return R.string.title_aftersale
    }

    override fun onCreateViewModel(): AfterSaleBindViewModel {
        return ViewModelProvider(this)[AfterSaleBindViewModel::class.java]
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this.activity)
        StatusBarUtil.StatusBarLightMode(this.activity)
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        mBinding.btnReturn.setOnClickListener(this)
        mBinding.ivBack.setOnClickListener(this)
        mBinding.tvResult.text = getString(R.string.text_aftersale_bind_success)
    }


    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.btnReturn -> {
                activity?.finish()
            }

            R.id.ivBack -> {
                findNavController().previousBackStackEntry
                    ?.savedStateHandle
                    ?.set("fromAfterSaleBindSuccessFragment", true)
                findNavController().popBackStack()
            }
        }
    }

}