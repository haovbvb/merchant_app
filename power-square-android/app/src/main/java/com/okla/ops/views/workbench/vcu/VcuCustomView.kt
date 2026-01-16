package com.okla.ops.views.workbench.vcu

import android.content.Context
import androidx.constraintlayout.widget.ConstraintLayout

abstract class VcuCustomView(context: Context) :
    ConstraintLayout(context) {

    fun getData(): VcuData {
        return newData()
    }

    abstract fun newData(): VcuData

}