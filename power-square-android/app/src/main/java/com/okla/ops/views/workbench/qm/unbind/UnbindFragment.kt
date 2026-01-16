package com.okla.ops.views.workbench.qm.unbind//package com.okla.ops.views.home.workbench.bindorunbind
//
//import android.os.Bundle
//import android.view.View
//import androidx.lifecycle.ViewModelProvider
//import androidx.navigation.findNavController
//import com.base.common.base.mvvm.BaseNormalVFragment
//import com.okla.ops.R
//import com.okla.ops.databinding.FragmentUnbindBinding
//
///**
// * @Date: 2021/8/16 9:33
// * @Author: Craz
// * @Description:
// * @Version:
// */
//class UnbindFragment : BaseNormalVFragment<UnbindViewModel, FragmentUnbindBinding>(),View.OnClickListener {
//
//    override fun getLayoutId(): Int {
//        return R.layout.fragment_unbind;
//    }
//
//    override fun onCreateViewModel(): UnbindViewModel {
//        return ViewModelProvider(this).get(UnbindViewModel::class.java);
//    }
//
//    override fun initViews(view: View?, savedInstanceState: Bundle?) {
//        super.initViews(view, savedInstanceState)
//        initObserver();
//        initClicks();
//        mBinding.includeTitle.topTitle.setText(R.string.workbench_device_unbind)
//    }
//
//    fun initClicks() {
//        mBinding.includeTitle.topBack.setOnClickListener(this)
//        mBinding.tvBatteryUnbind.setOnClickListener(this)
//        mBinding.tvCenterControlUnbind.setOnClickListener(this)
//    }
//
//    fun initObserver() {
//
//    }
//
//    override fun onClick(v: View) {
//        when(v.id){
//            R.id.topBack->{requireActivity().finish()}
//            R.id.tvBatteryUnbind->{
//                mBinding.tvBatteryUnbind.findNavController().navigate(R.id.fragmentBatteryUnbind)
//            }
//            R.id.tvCenterControlUnbind->{
//                mBinding.tvCenterControlUnbind.findNavController().navigate(R.id.fragmentCenterControlUnbind)
//            }
//        }
//    }
//
//}
