package com.okla.ops.views.workbench

data class ModuleItem(
    val module: Module,
    val onClick: () -> Unit // 点击回调闭包
)