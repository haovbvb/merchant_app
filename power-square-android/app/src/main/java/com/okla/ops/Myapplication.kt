package com.okla.ops

import com.base.common.CommonApplication
import com.clj.fastble.BleManager

class Myapplication : CommonApplication() {
    override fun onCreate() {
        super.onCreate()
        BleManager.getInstance().init(this);
    }
}