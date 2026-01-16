package com.okla.ops.views.workbench.qm.roadassistance

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.databinding.ViewDataBinding
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.RecyclerView
import com.base.common.base.mvvm.BaseNormalListVActivity
import com.base.common.beans.RxEvent.RoadSideNotPayEvent
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.DensityUtil
import com.base.common.utils.LanguageUtils.LanguageUtil.getLocalByLanguage
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.material.tabs.TabLayout
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.RoadSideInfo
import com.okla.ops.databinding.ActivityRoadsideAssistanceBinding
import com.okla.ops.utils.ViewClickUtils
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class RoadSideAssistantActivity :
    BaseNormalListVActivity<RoadSideViewModel, ActivityRoadsideAssistanceBinding>() {
    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<RoadSideInfo?>

    companion object {
        fun getIntents(context: Context) {
            context.startActivity(Intent(context, RoadSideAssistantActivity::class.java))
        }
    }

    //    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<Any>
    override fun onCreateViewModel(): RoadSideViewModel {
        return ViewModelProvider(this)[RoadSideViewModel::class.java]
    }

    override fun title(): Int {
        return R.string.title_roadside_assistant
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_roadside_assistance
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        getStatusView().setEnableLoadMore(true)
        getStatusView().setEnableRefresh(true)
        initIndicator()
        initObserver()
        onRefresh()
    }

    private fun initObserver() {
        getViewModel().roadSideListLiveData.observe(this, {
            mBinding.swipRefresh.finishRefresh()
            mBinding.swipRefresh.finishLoadMore()
            updateListItems(it?.list)
        })
    }

    override fun createAdapter(): RecyclerView.Adapter<*> {
        mAdapter =
            object :
                SingleDataBindingNoPUseAdapter<RoadSideInfo?>(R.layout.item_roadside_assistant) {
                override fun convert(
                    helper: BaseViewHolder?,
                    item: RoadSideInfo?,
                    viewDataBinding: ViewDataBinding?
                ) {
                    super.convert(helper, item, viewDataBinding)
                    helper?.setText(R.id.tv_work_id, "NO." + item?.recordNo)
                    helper?.setText(
                        R.id.tv_time,
                        DateTimeUtils.getTimeString(
                            DateTimeUtils.dateFormat3,
                            item?.createTime,
                            getLocalByLanguage()
                        )
                    )
                    val tvStatus = helper?.getView<TextView>(R.id.tv_status)
                    val tvResult = helper?.getView<TextView>(R.id.tv_result)
                    val tvTitleCompleteTime = helper?.getView<TextView>(R.id.tv_title_completetime)
                    val tvCompleteTime = helper?.getView<TextView>(R.id.tv_completetime)
                    when (item?.status) {
                        0 -> {
                            tvStatus?.text = mContext.getString(R.string.str_waiting_for_rescue)
                            tvStatus?.setTextColor(getColor(R.color.color_ffa4332))
                            tvStatus?.setBackgroundResource(R.drawable.bg_fff3f2_r6)
                            helper?.setGone(R.id.layout_result, false)
                            tvCompleteTime?.visibility= View.GONE
                            tvTitleCompleteTime?.visibility= View.GONE
                        }

                        1 -> {
                            tvStatus?.text = mContext.getString(R.string.str_in_progress)
                            tvStatus?.setTextColor(getColor(R.color.color_ed942f))
                            tvStatus?.setBackgroundResource(R.drawable.bg_fef7ea_r6)
                            helper?.setGone(R.id.layout_result, true)
                            helper?.setGone(R.id.tv_title_completetime, false)
                            helper?.setGone(R.id.tv_completetime, false)
                            tvResult?.compoundDrawablePadding= DensityUtil.dp2px(3f)
                            if(item.result==1){
                                tvResult?.text = mContext.getString(R.string.str_return_to_factory)
                                tvResult?.setCompoundDrawablesWithIntrinsicBounds(
                                    ContextCompat.getDrawable(
                                        mContext,
                                        R.drawable.bg_oval_ed942f
                                    ), null, null, null
                                )
                            }else if(item.result==2){
                                tvResult?.text = mContext.getString(R.string.str_completed)
                                tvResult?.setCompoundDrawablesWithIntrinsicBounds(
                                    ContextCompat.getDrawable(
                                        mContext,
                                        R.drawable.bg_oval_56b337
                                    ), null, null, null
                                )
                            }
                            tvCompleteTime?.visibility= View.GONE
                            tvTitleCompleteTime?.visibility= View.GONE
                        }

                        2 -> {
                            tvStatus?.text = mContext.getString(R.string.str_completed)
                            tvStatus?.setTextColor(getColor(R.color.main_color))
                            tvStatus?.setBackgroundResource(R.drawable.bg_ffeef7e9_r6)
                            helper?.setGone(R.id.layout_result, true)
                            tvCompleteTime?.visibility= View.VISIBLE
                            tvTitleCompleteTime?.visibility= View.VISIBLE
                            if(null!=item.processTime){
                                tvCompleteTime?.text =  DateTimeUtils.getTimeString(
                                    DateTimeUtils.dateFormat3,
                                    item?.processTime,
                                    getLocalByLanguage()
                                )
                            }else{
                                tvCompleteTime?.text="-"
                            }
                            if(item.result==1){
                                tvResult?.text = mContext.getString(R.string.str_return_to_factory)
                                tvResult?.setCompoundDrawablesWithIntrinsicBounds(
                                    ContextCompat.getDrawable(
                                        mContext,
                                        R.drawable.bg_oval_ed942f
                                    ), null, null, null
                                )
                            }else if(item.result==2){
                                tvResult?.text = mContext.getString(R.string.str_completed)
                                tvResult?.setCompoundDrawablesWithIntrinsicBounds(
                                    ContextCompat.getDrawable(
                                        mContext,
                                        R.drawable.bg_oval_56b337
                                    ), null, null, null
                                )
                            }
                        }
                    }
                    val imgDevice = helper?.getView<ImageView>(R.id.img_device)
                    imgDevice?.let { Glide.with(mContext).load(item?.img).into(it) }
                    helper?.setText(R.id.tv_device_sn, "SN:" + item?.deviceSn)
                    helper?.setText(R.id.tv_remark, item?.description)
                }
            }
        mAdapter.setOnItemClickListener { adapter: BaseQuickAdapter<*, *>?, view: View?, position: Int ->
            if (ViewClickUtils.isFastClick()) {
                return@setOnItemClickListener
            }
            val roadSideInfo = mAdapter.data[position] as RoadSideInfo
            startActivity(
                RoadSideOrderDetailActivity.getIntents(
                    this,
                    roadSideInfo.recordNo,
                    true
                )
            )
        }
        return mAdapter
    }


    override fun getRecyclerView(): RecyclerView {
        return mBinding.recyclerView
    }

    private val mTitleDataList = ArrayList<String>()
    override fun initPageData() {
        getViewModel().getRoadSideList(mStatus, pageIndex, pageSize);
    }

    private var mStatus: Int? = null
    private fun initIndicator() {
        //初始化标题列表（可根据需要清空再填充）
        mTitleDataList.clear()
        mTitleDataList.add(resources.getString(R.string.str_all))
        mTitleDataList.add(resources.getString(R.string.str_waiting_for_rescue))
        mTitleDataList.add(resources.getString(R.string.str_in_progress))
        mTitleDataList.add(resources.getString(R.string.str_completed))
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
                mStatus = when (position) {
                    0 -> null
                    1 -> 0
                    2 -> 1
                    3 -> 2
                    else -> mStatus
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
    override fun isBindEventBusHere(): Boolean {
        return true
    }
    //不支付
    @Subscribe(threadMode = ThreadMode.MAIN)
    fun notPay(event: RoadSideNotPayEvent?) {
       onRefresh()
    }
}