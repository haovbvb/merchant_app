package com.okla.ops.views.mine

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.ImageView
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.MessageItem
import com.okla.ops.databinding.ActivityNotificationBinding

class NotificationActivity :
    BaseNormalVActivity<NotificationViewModel, ActivityNotificationBinding>() {
    companion object {
        fun startNotificationActivity(context: Context) {
            val intent = Intent(context, NotificationActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): NotificationViewModel {
        return ViewModelProvider(this)[NotificationViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_notification
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        addObserver()
        initAdapter()
        mBinding.swipRefresh.apply {
            setEnableRefresh(true)
            setEnableLoadMore(true)
            setOnRefreshListener {
                pageIndex = 1
                refreshData()
            }
            setOnLoadMoreListener {
                pageIndex++
                refreshData()
            }
        }
        pageIndex = 1
        refreshData()
    }

    override fun title(): Int {
        return R.string.title_message
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<MessageItem>
    private fun initAdapter() {
        mAdapter = object : SingleDataBindingNoPUseAdapter<MessageItem>(R.layout.item_message) {
            override fun convert(
                helper: BaseViewHolder,
                item: MessageItem
            ) {
                super.convert(helper, item)
                helper.setText(R.id.tvMsgContent, item?.content)
                helper.setText(R.id.tvMsgTitle, item?.title)
                helper.setText(
                    R.id.tvMsgDate,
                    DateTimeUtils.getTimeString(
                        DateTimeUtils.defaultFormat,
                        item.createTime ?: 0,
                        LanguageUtils.LanguageUtil.getLocalByLanguage()
                    )
                )
                val img = helper.getView<ImageView>(R.id.ivMsgType)
                Glide.with(mContext).load(item.iconUrl ?: "").into(img)
            }
        }
        mAdapter.setOnItemClickListener { adapter, view, position ->
            val item = mAdapter.getItem(position)
            item?.msgId?.let { getViewModel().setMsgRead(1, it) }
//            BaseWebViewActivity.startBaseWebViewActivity(mContext,item?.url?:"")
        }
        mBinding.rvSwapHistory.adapter = mAdapter
    }


    private fun addObserver() {
        getViewModel().msgListLiveData.observe(this, {
            updateList(it)
        })

        getViewModel().setMsgReadLiveData.observe(this, {

        })
    }

    private fun updateList(list: List<MessageItem>?) {
        if (pageIndex == 1) {
            mBinding.swipRefresh.finishRefresh()
        } else {
            mBinding.swipRefresh.finishLoadMore()
        }

        if (list.isNullOrEmpty()) {
            if (pageIndex == 1) {
                mBinding.emptyLayout.dataErrorView.visibility = View.VISIBLE
                mBinding.swipRefresh.setEnableLoadMore(false)
                mBinding.swipRefresh.visibility = View.GONE
            } else {
                mBinding.swipRefresh.finishLoadMoreWithNoMoreData()
            }
            return
        }

        mBinding.emptyLayout.dataErrorView.visibility = View.GONE
        mBinding.swipRefresh.visibility = View.VISIBLE
        mBinding.swipRefresh.setEnableLoadMore(true)

        if (pageIndex == 1) {
            mAdapter.setNewData(list)
        } else {
            mAdapter.addData(list)
        }

        if (list.size < pageSize) {
            mBinding.swipRefresh.finishLoadMoreWithNoMoreData()
        }

        pageIndex++
    }


    private fun refreshData() {
        getViewModel().getMsgList(pageIndex, pageSize)
    }

    private var pageIndex = 1
    private var pageSize = 10

}