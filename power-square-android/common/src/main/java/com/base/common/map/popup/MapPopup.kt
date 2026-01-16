package com.base.common.map.popup

import android.annotation.SuppressLint
import android.content.Context
import androidx.databinding.DataBindingUtil
import com.base.common.R
import com.base.common.databinding.ViewMapPopLayoutBinding
import com.lxj.xpopup.core.BottomPopupView

@SuppressLint("ViewConstructor")
class MapPopup(context: Context, private val callBack: () -> Unit) :
    BottomPopupView(context) {

    override fun getImplLayoutId(): Int {
        return R.layout.view_map_pop_layout
    }

    override fun onCreate() {
        super.onCreate()
        DataBindingUtil.bind<ViewMapPopLayoutBinding>(
            bottomPopupContainer.getChildAt(
                0
            )
        )?.run {
            btnGoogleMap.setOnClickListener {
                callBack.invoke()
                dismiss()
            }
            btnCancel.setOnClickListener {
                dismiss()
            }
        }
    }

}