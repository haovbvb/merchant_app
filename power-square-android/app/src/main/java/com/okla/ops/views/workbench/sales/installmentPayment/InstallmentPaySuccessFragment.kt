package com.okla.ops.views.workbench.sales.installmentPayment

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.base.common.base.mvvm.BaseNormalVFragment
import com.okla.ops.R
import com.okla.ops.databinding.FragmentInstallpaymentSuccessBinding
import com.okla.ops.utils.TextUtil
import com.okla.ops.utils.ViewClickUtils

class InstallmentPaySuccessFragment :
    BaseNormalVFragment<InstallmentViewModel, FragmentInstallpaymentSuccessBinding>(), TextUtil {
    override fun getLayoutId(): Int {
        return R.layout.fragment_installpayment_success
    }

    override fun onCreateViewModel(): InstallmentViewModel {
        return ViewModelProvider(this).get(InstallmentViewModel::class.java);
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        mBinding.btnReturn.setOnClickListener(this)
        mBinding.ivBack.setOnClickListener(this)
        mBinding.tvNumber.setOnClickListener(this)
        val args: InstallmentPaySuccessFragmentArgs by navArgs()
        val orderId = args.orderId
        mBinding.tvNumber.text = orderId
    }


    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.btnReturn -> {
                activity?.finish()
            }

            R.id.ivBack -> {
               handleBackPressed()
            }

            R.id.tvNumber -> {
                if(ViewClickUtils.isFastClick()){
                    return
                }
                context?.let {
                    mBinding.tvNumber.copyTextToClipboard(
                        it,
                        getString(R.string.tips_copid_to_clipboard)
                    )
                }
            }
        }
    }
//    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
//        super.onViewCreated(view, savedInstanceState)
//        // 监听系统返回键
//        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner,object :
//            OnBackPressedCallback(true){
//            override fun handleOnBackPressed() {
//                handleBackPressed()
//            }
//        })
//
//    }

    private fun handleBackPressed(){
        findNavController().previousBackStackEntry
            ?.savedStateHandle
            ?.set("fromInstallmentSuccessFragment", true)

        findNavController().popBackStack()
    }
}