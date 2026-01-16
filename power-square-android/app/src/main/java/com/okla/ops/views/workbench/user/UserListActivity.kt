package com.okla.ops.views.workbench.user

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.custom.BottomSpacingItemDecoration
import com.base.common.utils.NumToStrUtil
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.material.tabs.TabLayout
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.UserInfo
import com.okla.ops.databinding.ActivityUserListBinding
import com.okla.ops.utils.TextUtil
import com.okla.ops.utils.ViewClickUtils

class UserListActivity : BaseNormalListVActivity<UserViewModel, ActivityUserListBinding>(),
    TextUtil {

    companion object {
        fun startUserListActivity(context: Context) {
            val intent = Intent(context, UserListActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): UserViewModel {
        return ViewModelProvider(this)[UserViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_user_list
    }

    override fun title(): Int {
        return R.string.title_user
    }

    override fun onRightImage() {
        super.onRightImage()
        if (ViewClickUtils.isFastClick()) {
            return
        }
        UserSearchActivity.startUserSearchActivity(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initObserver()
    }

    override fun onResume() {
        super.onResume()
        onRefresh()
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        getStatusView().enableRefresh = true
        getStatusView().enableLoadMore = true
        mBinding.includeTitle.topRightImage.visibility = View.VISIBLE
        mBinding.includeTitle.topRightImage.setImageResource(R.mipmap.search)
        initTabLayout()
    }

    private fun initObserver() {
        getViewModel().userListLiveData.observe(this) {
            updateListItems(it?.list)
        }
    }

    private val mTitleDataList = mutableListOf<String>()
    private fun initTabLayout() {
        //初始化标题列表（可根据需要清空再填充）
        mTitleDataList.clear()
        mTitleDataList.add(getString(R.string.transport_all))
        mTitleDataList.add(getString(R.string.str_normal))
        mTitleDataList.add(getString(R.string.text_overdue))
        mTitleDataList.add(getString(R.string.text_dishonest))
        mTitleDataList.add(getString(R.string.str_ended))
        mTitleDataList.forEach { title ->
            val tab = mBinding.tabLayout.newTab()
            val customView = LayoutInflater.from(this).inflate(R.layout.layout_custom_tab, null)
            customView.findViewById<TextView>(R.id.tabText).text = title
            tab.customView = customView
            mBinding.tabLayout.addTab(tab)
        }
        mBinding.tabLayout.setSelectedTabIndicator(null)
        mBinding.tabLayout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = true
                val position = tab?.position ?: 0
                mType = when (position) {
                    0 -> null
                    1 -> 1
                    2 -> 2
                    3 -> 3
                    4 -> 4
                    else -> mType
                }
                onRefresh()
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = false

            }

            override fun onTabReselected(tab: TabLayout.Tab?) {
                tab?.customView?.isSelected = true

            }
        })

    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<UserInfo>
    override fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<UserInfo>(R.layout.item_user) {
            override fun convert(helper: BaseViewHolder, item: UserInfo) {
                super.convert(helper, item)
                helper.setText(R.id.tvOrderValue, item.order?.toString() ?: "-")
                helper.setText(R.id.tv_assets_value, item.asset?.toString() ?: "-")
                if (item.orderAmount != null) {
                    helper.setText(
                        R.id.tv_consumption_value,
                        "$".plus(NumToStrUtil.DoubleToStrWith2(item.orderAmount) ?: "-")

                    )
                }
                helper.setText(R.id.tvId, "ID:".plus(item.cardNum))
                Glide.with(this@UserListActivity).load(item.avatar)
                    .placeholder(R.drawable.icon_def_avator)
                    .error(R.drawable.icon_def_avator)
                    .into(helper.getView(R.id.ivAvatar))
                val tvName = helper.getView<AppCompatTextView>(R.id.tvName)
                tvName.text = String.format("${item.firstName} ${item.lastName}")
                val tvStatus = helper.getView<AppCompatTextView>(R.id.tvStatus)
                val tvTip = helper.getView<TextView>(R.id.tv_tip)
                val status = item.type
                //type 1正常 2逾期 3失信 4已结束
                when (status) {
                    1 -> {
                        //正常
                        tvStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_f49300
                            )
                        )
                        tvStatus.text = mContext.getString(R.string.str_normal)
                        tvStatus.background =
                            ContextCompat.getDrawable(mContext, R.drawable.bg_line_f49300_r4)
                        tvTip.text = mContext.getString(R.string.user_status_all_normal)
                    }

                    2 -> {
                        //逾期
                        tvStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_ffa4332
                            )
                        )
                        tvStatus.text = mContext.getString(R.string.text_overdue)
                        tvTip.text = mContext.getString(R.string.user_status_has_overdue)
                        tvStatus.background =
                            ContextCompat.getDrawable(mContext,R.drawable.bg_fff3f2_r4)
                    }

                    3 -> {
                        //失信
                        tvStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_ffa4332
                            )
                        )
                        tvStatus.text = mContext.getString(R.string.text_dishonest)
                        tvStatus.background =
                            ContextCompat.getDrawable(mContext,R.drawable.bg_fff3f2_r4)
                        tvTip.text = mContext.getString(R.string.user_status_has_defaulted)
                    }


                    4 -> {
                        //已结束
                        tvStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.main_color
                            )
                        )
                        tvStatus.text = mContext.getString(R.string.str_ended)
                        tvStatus.background =
                            ContextCompat.getDrawable(mContext, R.drawable.bg_line_maincolor_r4)
                        tvTip.text = mContext.getString(R.string.user_status_all_completed)
                    }

                    else -> {
                        tvStatus.text = "-"
                        tvStatus.setTextColor(
                            ContextCompat.getColor(
                                mContext,
                                R.color.color_99000000
                            )
                        )
                        tvStatus.setBackgroundResource(R.drawable.bg_line_26000000_r4)
                        tvTip.text = "-"
                        helper.setText(
                            R.id.tv_consumption_value, "-"
                        )
                    }
                }
            }

        }
        mAdapter.setOnItemClickListener { adapter, _, position ->
            val userInfo = adapter.data[position] as UserInfo
            UserDetailActivity.startUserDetailActivity(
                this@UserListActivity,
                userInfo.cardNum
            )
        }
        return mAdapter
    }

    override fun getRecyclerView(): RecyclerView {
        mBinding.rvUser.addItemDecoration(BottomSpacingItemDecoration(6))
        return mBinding.rvUser
    }

    private var mType: Int? = null
    override fun initPageData() {
        getViewModel().getUserList(
            mType,
            null,
            pageIndex,
            pageSize
        )
    }

}