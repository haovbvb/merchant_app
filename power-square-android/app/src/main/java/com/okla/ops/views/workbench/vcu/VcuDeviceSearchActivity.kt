package com.okla.ops.views.workbench.vcu

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.view.View
import android.widget.TextView
import androidx.lifecycle.ViewModelProvider
import com.base.common.Preferences
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.utils.ToastUtils
import com.base.common.utils.WindowInsetsHelper
import com.base.library.utils.GsonUtils
import com.google.gson.reflect.TypeToken
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.beans.SearchHistory
import com.okla.ops.custom.SearchHistoryView
import com.okla.ops.custom.SearchTitleView
import com.okla.ops.databinding.ActivityVcuDeviceSearchBinding
import com.okla.ops.views.workbench.QRCodeActivity

class VcuDeviceSearchActivity :
    BaseNormalVActivity<VcuViewModel, ActivityVcuDeviceSearchBinding>() {

    companion object {
        fun startVcuDeviceSearchActivity(context: Context) {
            val intent = Intent(context, VcuDeviceSearchActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): VcuViewModel? {
        return ViewModelProvider(this)[VcuViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_vcu_device_search
    }

    /*override fun getToolbar(): View? {
        return mBinding.searchScanTitleView
    }*/

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initObserver()
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        initListener()
        WindowInsetsHelper.applyForToolbar(this, mBinding.searchScanTitleView.getId())
        mBinding.searchScanTitleView.editHint = getString(R.string.hint_enter_device_or_scan_qr_code)
        switchViewDefault()
        initData()
        Handler(Looper.getMainLooper()).postDelayed({
            mBinding.searchScanTitleView.showInputKeyword()
        }, 500)
    }

    private fun initData() {
        val historyJson = readHistoryData()
        if (historyJson.isNotEmpty()) {
            val type = object : TypeToken<MutableList<SearchHistory>>() {}.type
            mBinding.searchHistoryView.setHistoryData(GsonUtils.fromGson(historyJson, type))
        }
        mBinding.emptyView.findViewById<TextView>(R.id.tvNoData).text =
            mContext.getString(R.string.str_empty_search_tip)
    }

    private fun readHistoryData(): String {
        return Preferences.getInstance().getVcuHistory(Preferences.getInstance().name)
    }

    private fun clearHistory() {
        Preferences.getInstance().removeVcuHistory(Preferences.getInstance().name)
    }

    private fun addHistory(content: String) {
        if (TextUtils.isEmpty(content)) return
        if (!mBinding.searchHistoryView.isExistHistoryData(content)) {
            var historyJson = readHistoryData()
            if (historyJson.isNotEmpty()) {
                val type = object : TypeToken<MutableList<SearchHistory>>() {}.type
                val historyList = GsonUtils.fromGson<MutableList<SearchHistory>>(historyJson, type)
                if (historyList.size > 4) {
                    historyList.removeAt(0)
                }
                historyList.add(0, SearchHistory(content, content))
                mBinding.searchHistoryView.setHistoryData(historyList)
                historyJson = GsonUtils.toGson(historyList)
            } else {
                val list: MutableList<SearchHistory> = mutableListOf()
                list.add(SearchHistory(content, content))
                mBinding.searchHistoryView.setHistoryData(list)
                historyJson = GsonUtils.toGson(list)
            }
            Preferences.getInstance().setVcuHistory(Preferences.getInstance().name,historyJson)
        }
    }

    private fun initObserver() {
        getViewModel().mEquipmentDeviceSearchBeanData.observe(this) { deviceInfo ->
            if (deviceInfo != null) {
                if (deviceInfo.type == 4) {
                    val ctrlId = deviceInfo.deviceInfo.ctrlId
                    if (!TextUtils.isEmpty(ctrlId)) {
                        addHistory(mDeviceSn)
                        VcuControlActivity.startVcuControlActivity(
                            this@VcuDeviceSearchActivity,
                            deviceInfo.deviceInfo
                        )
                    } else {
                        ToastUtils.showShort(getString(R.string.tips_vcu_not_found))
                    }
                } else {
                    switchViewBySearchResult()
                }
            } else {
                switchViewBySearchResult()
            }
        }
    }

    private fun initListener() {
        mBinding.searchScanTitleView.setOnSearchTitleListener(object :
            SearchTitleView.OnSearchTitleListener {

            override fun onSearchContent(content: String?) {
                if (!TextUtils.isEmpty(content)) {
                    searchDevice(content!!)
                } else {
                    switchViewDefault()
                }
            }

            override fun onContentUpdate(content: String?) {

            }

            override fun onContentCLear() {

            }

            override fun onBack() {
                finish()
            }

            override fun onScan() {
                initializeScan(QRCodeActivity.NORMAL)
            }

        })
        mBinding.searchHistoryView.setListener(object : SearchHistoryView.OnClickListener {
            override fun onSelectedName(id: String) {
                searchDevice(id)
            }

            override fun onClearSearchName() {
                clearHistory()
            }
        })
    }

    private fun switchViewBySearchResult() {
        mBinding.searchHistoryView.visibility = View.GONE
        mBinding.emptyView.visibility = View.VISIBLE
    }

    private fun switchViewDefault() {
        mBinding.emptyView.visibility = View.GONE
        mBinding.searchHistoryView.visibility = View.VISIBLE
    }

    private var mDeviceSn: String = ""
    private fun searchDevice(sn: String) {
        mDeviceSn = sn
        getViewModel().searchDeviceBySn(sn)
    }

    private fun initializeScan(type: Int) {
        IntentIntegrator(this)
            .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
            .setOrientationLocked(false)
            .setCaptureActivity(QRCodeActivity::class.java)
            .initiateScan() //  初始化扫描
    }

    /**
     * Event for receiving the activity result.
     *
     * @param requestCode Request code.
     * @param resultCode Result code.
     * @param data        Result.
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode != RESULT_OK || data == null) {
            return
        }
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            val mScanResult = intentResult?.contents ?: ""
            mScanResult?.run {
                var deviceSn = this
                if (contains("sn=")) {
                    //正常扫描换电
                    val index = indexOf("sn=")
                    if (index > -1) {
                        deviceSn = substring(index + 3)
                    }
                }
                if (!TextUtils.isEmpty(deviceSn)) {
                    mBinding.searchScanTitleView.setEditContent(deviceSn)
                    searchDevice(deviceSn)
                }
            }
        }
    }

}