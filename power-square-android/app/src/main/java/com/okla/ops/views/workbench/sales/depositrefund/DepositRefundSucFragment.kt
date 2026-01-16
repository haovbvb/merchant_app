package com.okla.ops.views.workbench.sales.depositrefund

import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.utils.StatusBarUtil
import com.okla.ops.R
import com.okla.ops.databinding.FragmentDepositRefundSuccessBinding
import com.okla.ops.utils.TextUtil

class DepositRefundSucFragment :
    BaseNormalVFragment<DepositRefundViewModel, FragmentDepositRefundSuccessBinding>(),
    TextUtil {

    companion object {
        fun getInstance(): DepositRefundSucFragment {
            return DepositRefundSucFragment()
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_deposit_refund_success
    }

    override fun onBack() {
        super.onBack()
        handleBackPressed()
    }

    override fun title(): Int {
        return R.string.text_deposit_refund
    }

    override fun onCreateViewModel(): DepositRefundViewModel {
        return ViewModelProvider(this)[DepositRefundViewModel::class.java]
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        StatusBarUtil.opacityBar(mActivity)
        StatusBarUtil.StatusBarLightMode(mActivity)
        StatusBarUtil.setStatusBar(mActivity)
        mBinding.btnReturn.setOnClickListener(this)
        mBinding.includeTitle.topBack.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.btnReturn -> {
                activity?.finish()
            }

            R.id.topBack -> {
                handleBackPressed()
            }
        }
    }


//    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
//        super.onViewCreated(view, savedInstanceState)
//        // 监听系统返回键
//        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner,
//            object : OnBackPressedCallback(true) {
//                override fun handleOnBackPressed() {
//                    handleBackPressed()
//                }
//            })
//
//    }

    private fun handleBackPressed() {
        findNavController().previousBackStackEntry
            ?.savedStateHandle
            ?.set("fromRefundSuccessFragment", true)

        findNavController().popBackStack()

    }
}