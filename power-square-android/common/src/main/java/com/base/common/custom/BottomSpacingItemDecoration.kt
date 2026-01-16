package com.base.common.custom

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

class BottomSpacingItemDecoration(private val bottomSpacing: Int) : RecyclerView.ItemDecoration() {
    override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
        val position = parent.getChildAdapterPosition(view) // 获取当前项的位置
        if (position != RecyclerView.NO_POSITION) {
            outRect.bottom = bottomSpacing // 设置下间距
        }
    }
}
