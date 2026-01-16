package com.base.common.custom

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

class GridSpacingItemDecoration(
    private val spanCount: Int, // 网格的列数
    private val spacing: Int, // 间隔的大小
    private val includeEdge: Boolean // 是否包含边缘的间隔
) : RecyclerView.ItemDecoration() {

    override fun getItemOffsets(
        outRect: Rect,
        view: View,
        parent: RecyclerView,
        state: RecyclerView.State
    ) {
        val position = parent.getChildAdapterPosition(view) // 当前项的位置
        val column = position % spanCount // 当前项在列中的位置（从0开始）

        if (includeEdge) {
            // 包含边缘的间隔
            outRect.left = spacing - column * spacing / spanCount
            outRect.right = (column + 1) * spacing / spanCount

            if (position < spanCount) {
                outRect.top = spacing // 顶部间隔
            }
            outRect.bottom = spacing // 底部间隔
        } else {
            // 不包含边缘的间隔
            outRect.left = column * spacing / spanCount
            outRect.right = spacing - (column + 1) * spacing / spanCount

            if (position >= spanCount) {
                outRect.top = spacing // 顶部间隔
            }
        }
    }
}
