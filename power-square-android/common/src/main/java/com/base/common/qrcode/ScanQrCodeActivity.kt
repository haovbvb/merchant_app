package com.base.common.qrcode

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.base.common.R
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.databinding.ActivityScanQrCodeBinding
import com.base.common.utils.StatusBarUtil
import com.base.library.base.mvvm.BaseViewModel
import com.journeyapps.barcodescanner.BarcodeCallback
import com.journeyapps.barcodescanner.BarcodeResult
import com.journeyapps.barcodescanner.DecoratedBarcodeView.TorchListener

class ScanQrCodeActivity : BaseNormalVActivity<BaseViewModel, ActivityScanQrCodeBinding>(),
    TorchListener {

    companion object {
        fun getIntents(context: Context) {
            val intent = Intent(context, ScanQrCodeActivity::class.java)
            context.startActivity(intent)
        }

        const val SCAN_RESULT = "scanResult"
    }


    override fun onCreateViewModel(): BaseViewModel {
        return ViewModelProvider(this)[BaseViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_scan_qr_code
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initObserver()
    }

    private fun initObserver() {

    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
        initClicks()
        mBinding.zxingBarcodeScanner.setTorchListener(this)
        mBinding.zxingBarcodeScanner.setStatusText("")
        mBinding.zxingBarcodeScanner.viewFinder.setLaserVisibility(false)
        mBinding.imgBack.setOnClickListener {
            finish()
        }
        mBinding.tvTitle.text = getString(R.string.cc_str_qr_code_title)

        mBinding.zxingBarcodeScanner.decodeContinuous(object : BarcodeCallback {
            override fun barcodeResult(result: BarcodeResult?) {
                if (result != null && result.text.isNotEmpty() && result.text != null && !TextUtils.isEmpty(
                        result.text
                    )
                ) {
                    val resultSn = result.text
                    if (!TextUtils.isEmpty(resultSn)) {
                        val intent = Intent()
                        intent.putExtra(SCAN_RESULT, resultSn)
                        setResult(RESULT_OK, intent)
                        finish()
                    }
                }
            }
        }
        );
    }


    fun initClicks() {
        mBinding.tvFlash.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {

            R.id.tvFlash -> {
                setFlashOperation()
            }
        }
    }
    private fun setFlashOperation() {
        if (isFlashOn) {
            mBinding.zxingBarcodeScanner.setTorchOff()
            mBinding.tvFlash.setCompoundDrawablesWithIntrinsicBounds(
                0,
                com.base.common.R.mipmap.img_icon_flash_on,
                0,
                0
            )

        } else {
            mBinding.zxingBarcodeScanner.setTorchOn()
            mBinding.tvFlash.setCompoundDrawablesWithIntrinsicBounds(
                0,
                com.base.common.R.mipmap.img_icon_flash_off,
                0,
                0
            )
        }
    }
    override fun onResume() {
        super.onResume()
        mBinding.zxingBarcodeScanner.resume()
    }

    override fun onPause() {
        super.onPause()
        mBinding.zxingBarcodeScanner.pause()
    }

    private var isFlashOn: Boolean = false

    // TorchListener 回调 —— 当系统手电筒被打开时调用
    override fun onTorchOn() {
        isFlashOn = true
        mBinding.tvFlash.setCompoundDrawablesWithIntrinsicBounds(
            0,
            com.base.common.R.mipmap.img_icon_flash_off,
            0,
            0
        )

    }

    // TorchListener 回调 —— 当系统手电筒被关闭时调用
    override fun onTorchOff() {
        isFlashOn = false
        mBinding.tvFlash.setCompoundDrawablesWithIntrinsicBounds(
            0,
            com.base.common.R.mipmap.img_icon_flash_on,
            0,
            0
        )
    }

}