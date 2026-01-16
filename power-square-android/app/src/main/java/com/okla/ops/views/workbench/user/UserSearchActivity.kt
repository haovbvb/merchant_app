package com.okla.ops.views.workbench.user

import android.Manifest
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.appcompat.widget.AppCompatTextView
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.custom.BottomSpacingColorItemDecoration
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.DensityUtil
import com.base.library.utils.GsonUtils
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.google.gson.reflect.TypeToken
import com.google.zxing.integration.android.IntentIntegrator
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.SearchHistory
import com.okla.ops.beans.UserInfo
import com.okla.ops.databinding.ActivityUserSearchBinding
import com.okla.ops.utils.ScanUtils
import com.okla.ops.views.workbench.QRCodeActivity
import com.okla.ops.weight.SearchHistoryView
import com.okla.ops.weight.SearchScanTitleView
import com.luck.picture.lib.utils.SdkVersionUtils

class UserSearchActivity : BaseNormalListVActivity<UserViewModel, ActivityUserSearchBinding>() {

    companion object {
        fun startUserSearchActivity(context: Context) {
            val intent = Intent(context, UserSearchActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_user_search
    }

    private lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
        initObserver()
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        getStatusView().enableRefresh = true
        getStatusView().enableLoadMore = true
        initListener()
        initData()
    }

    private fun initObserver() {
        getViewModel().userSearchListLiveData.observe(this) {
            updateListItems(it.list)
            if (it.total == 0) {
                mBinding.searchEmptyView.visibility = View.VISIBLE
                mBinding.swipRefresh.visibility = View.GONE
            } else {
                mBinding.searchEmptyView.visibility = View.GONE
                mBinding.swipRefresh.visibility = View.VISIBLE
            }
            if (!it.list.isNullOrEmpty()) {
                addHistory(mKeyword ?: "")
            }
        }
    }

    private fun initListener() {
        mBinding.searchScanTitleView.setOnSearchScanTitleListener(object :
            SearchScanTitleView.OnSearchScanTitleListener {
            override fun onScanClick() {
                askPermission()
            }

            override fun onSearch(content: String?) {
                switchView(content ?: "")
                if (!TextUtils.isEmpty(content)) {
                    mKeyword = content
                    onRefresh()
                }
            }

            override fun onBack() {
                finish()
            }
        })
        mBinding.searchHistoryView.setListener(object : SearchHistoryView.OnClickListener {
            override fun onSelectedName(id: String) {
                mBinding.searchScanTitleView.setSearchText(id)
            }

            override fun onClearSearchName() {
                val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
                DataStoreUtils.saveSyncStringData(
                    DataStoreKeyUtils.HISTORY_USER_NAME.plus(account),
                    ""
                )
            }

        })
    }

    private fun initData() {
        val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
        val historyJson =
            DataStoreUtils.readStringData(DataStoreKeyUtils.HISTORY_USER_NAME.plus(account))
        if (historyJson.isNotEmpty()) {
            val type = object : TypeToken<MutableList<SearchHistory>>() {}.type
            mBinding.searchHistoryView.setHistoryData(GsonUtils.fromGson(historyJson, type))
        }
        mBinding.searchScanTitleView.setSearchHint(getString(R.string.hint_enter_user_id_or_phone))
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<UserInfo>
    override fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<UserInfo>(R.layout.item_user1) {
            override fun convert(helper: BaseViewHolder, item: UserInfo) {
                super.convert(helper, item)
                Glide.with(this@UserSearchActivity).load(item.avatar)
                    .placeholder(R.drawable.icon_def_avator)
                    .error(R.drawable.icon_def_avator)
                    .into(helper.getView(R.id.ivAvatar))
                val tvName = helper.getView<AppCompatTextView>(R.id.tvName)
                tvName.text = String.format("${item.firstName} ${item.lastName}")
                val tvId = helper.getView<AppCompatTextView>(R.id.tvId)
                tvId.text = getString(R.string.text_ids, item.username)
            }
        }
        mAdapter.setOnItemClickListener { adapter, _, position ->
            val userInfo = adapter.data[position] as UserInfo
            UserDetailActivity.startUserDetailActivity(
                this@UserSearchActivity,
                userInfo.cardNum
            )
        }
        return mAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        val backgroundColor = Color.parseColor("#FFE6E6E6")  // 背景颜色
        val itemDecoration =
            BottomSpacingColorItemDecoration(1, backgroundColor, DensityUtil.dp2px(12f))
        mBinding.rvUser.addItemDecoration(itemDecoration)
        return mBinding.rvUser
    }

    private var mKeyword: String? = null
    override fun initPageData() {
        getViewModel().getUserSearchList(
            mKeyword,
            pageIndex,
            pageSize
        )
    }

    private fun switchView(content: String) {
        if (TextUtils.isEmpty(content)) {
            mBinding.searchHistoryView.visibility = View.VISIBLE
            mBinding.swipRefresh.visibility = View.GONE
            mBinding.searchEmptyView.visibility = View.GONE
        } else {
            mBinding.searchHistoryView.visibility = View.GONE
        }
    }

    private fun addHistory(content: String) {
        if (TextUtils.isEmpty(content)) return
        if (!mBinding.searchHistoryView.isExistHistoryData(content)) {
            val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
            var historyJson =
                DataStoreUtils.readStringData(DataStoreKeyUtils.HISTORY_USER_NAME.plus(account))
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
            DataStoreUtils.saveSyncStringData(
                DataStoreKeyUtils.HISTORY_USER_NAME.plus(account),
                historyJson
            )
        }
    }

    private fun askPermission() {
        val permissions = mutableListOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.CAMERA,
        )
        if (SdkVersionUtils.isTIRAMISU()) {
            permissions.remove(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
        permissionManager.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
//                QrCodeUtils.startScanQrCode(this@UserSearchActivity)
                initializeScan(QRCodeActivity.NORMAL)

            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(this@UserSearchActivity, "")
            }
        }, *permissions.toTypedArray())
    }

    private fun initializeScan(type: Int) {
        IntentIntegrator(this)
            .setOrientationLocked(false)
            .addExtra(QRCodeActivity.QR_TYPE_TARGET, type)
            .setCaptureActivity(QRCodeActivity::class.java)
            .initiateScan() //  初始化扫描

    }

    private var mScanResult: String = ""

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
            mScanResult = intentResult?.contents ?: ""
//            val obj= data.getParcelableExtra(QRCodeActivity.SCAN_RESULT)
//            mScanResult = obj?.showResult ?: ""
            if (!TextUtils.isEmpty(mScanResult)) {
                mScanResult = ScanUtils.getUserCarNum(mContext, mScanResult)
                mBinding.searchScanTitleView.setSearchText(mScanResult)
            }
        }
    }
}