package com.okla.ops.views.monitor

import android.content.Context
import android.view.View
import androidx.databinding.DataBindingUtil
import com.okla.ops.R
import com.okla.ops.databinding.PopMapSwitchBinding
import com.lxj.xpopup.core.AttachPopupView

class MapSwitchPopup(
    context: Context,
    private var curPos: Int,
    private val callBack: (pos: Int) -> Unit
) :
    AttachPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.pop_map_switch
    }

    override fun onCreate() {
        super.onCreate()
        DataBindingUtil.bind<PopMapSwitchBinding>(attachPopupContainer.getChildAt(0))?.run {
            updateUiByCurPos(imgAll,imgNoMaintenance,imgMaintenance)
            tvAll.setOnClickListener {
                curPos=0
                updateUiByCurPos(imgAll,imgNoMaintenance,imgMaintenance)
                tvAll.postDelayed(kotlinx.coroutines.Runnable {
                    dismiss()
                },800)
                callBack.invoke(0)
            }
            tvNoMaintenance.setOnClickListener {
                curPos=1
                updateUiByCurPos(imgAll,imgNoMaintenance,imgMaintenance)
                tvNoMaintenance.postDelayed(kotlinx.coroutines.Runnable {
                    dismiss()
                },800)
                callBack.invoke(1)
            }
            tvmaintenance.setOnClickListener {
                curPos=2
                updateUiByCurPos(imgAll,imgNoMaintenance,imgMaintenance)
                tvmaintenance.postDelayed(kotlinx.coroutines.Runnable {
                    dismiss()
                },800)
                callBack.invoke(2)
            }
        }
    }

    private fun updateUiByCurPos(imgAll: View,imgNoMaintenance:View,imgMaintenance:View){
        when (curPos) {
            0 -> {
                imgAll.visibility = View.VISIBLE
                imgNoMaintenance.visibility = View.GONE
                imgMaintenance.visibility = View.GONE
            }

            1 -> {
                imgAll.visibility = View.GONE
                imgNoMaintenance.visibility = View.VISIBLE
                imgMaintenance.visibility = View.GONE
            }

            2 -> {
                imgAll.visibility = View.GONE
                imgNoMaintenance.visibility = View.GONE
                imgMaintenance.visibility = View.VISIBLE
            }
        }
    }
}