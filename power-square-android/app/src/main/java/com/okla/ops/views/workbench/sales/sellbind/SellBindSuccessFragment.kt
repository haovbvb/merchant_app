package com.okla.ops.views.workbench.sales.sellbind

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.utils.StatusBarUtil
import com.okla.ops.R
import com.okla.ops.beans.PayTypeObject
import com.okla.ops.databinding.FragmentSalebindSuccessBinding
import com.okla.ops.utils.TextStyleUtils
import com.okla.ops.utils.TextUtil

class SellBindSuccessFragment :
    BaseNormalVFragment<SellBindViewModel, FragmentSalebindSuccessBinding>(), TextUtil {


    override fun getLayoutId(): Int {
        return R.layout.fragment_salebind_success
    }

    override fun title(): Int {
        return R.string.title_salebind
    }

    override fun onCreateViewModel(): SellBindViewModel {
        return ViewModelProvider(this)[SellBindViewModel::class.java]
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        backCallback = object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    // 这里一定能拦截到系统返回键
                    handleBackPressed()
                }
            }
        requireActivity().onBackPressedDispatcher.addCallback(backCallback as OnBackPressedCallback)
        StatusBarUtil.transparencyBar(this.activity)
        StatusBarUtil.StatusBarLightMode(this.activity)
    }

    private var backCallback: OnBackPressedCallback?=null
    private var titleStr = ""
    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        mBinding.btnReturn.setOnClickListener(this)
        mBinding.ivBack.setOnClickListener(this)
        mBinding.tvNumber.setOnClickListener(this)
        val args: SellBindSuccessFragmentArgs by navArgs()
        val orderId = args.orderId
        val paySource = args.paySource
        titleStr = args.title
        mBinding.tvTitle.text = titleStr
        mBinding.tvNumber.text = orderId
        if (paySource == PayTypeObject.TYPE_ONLINE) {
            mBinding.tvDes.text = context?.getString(R.string.str_tip_paysuccess_online)
        } else {
            mBinding.tvDes.text = context?.getString(R.string.str_tip_paysuccess_cash)
        }
        context?.let {
            mBinding.tvDes.text = TextStyleUtils.fixTextStyleColor(
                mBinding.tvDes.text.toString(),
                "2",
                it.getColor(R.color.color_fff78c00)
            )
        }
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
                context?.let {
                    mBinding.tvNumber.copyTextToClipboard(
                        it,
                        getString(R.string.tips_copid_to_clipboard)
                    )
                }
            }
        }
    }



    private fun handleBackPressed() {
        findNavController().previousBackStackEntry
            ?.savedStateHandle
            ?.set("fromSellBindSuccessFragment", true)

        findNavController().popBackStack()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        backCallback?.remove()
    }
}