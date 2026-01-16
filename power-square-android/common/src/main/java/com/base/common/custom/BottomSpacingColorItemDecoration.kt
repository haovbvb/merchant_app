package com.base.common.custom

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

class BottomSpacingColorItemDecoration(
    private val bottomSpacing: Int,
    private val backgroundColor: Int,
    private val margin: Int,
) :
    RecyclerView.ItemDecoration() {

    // 绘制背景颜色
    override fun onDrawOver(c: Canvas, parent: RecyclerView, state: RecyclerView.State) {
        super.onDrawOver(c, parent, state)

        val childCount = parent.childCount
        for (i in 0 until childCount) {
            val childView = parent.getChildAt(i)
            // 绘制背景
            drawBackground(c, childView)
        }
    }

    private fun drawBackground(c: Canvas, view: View) {
        val paint = Paint()
        paint.color = backgroundColor // 设置背景颜色
        val rect = Rect(margin, view.bottom, view.width - margin, view.bottom + bottomSpacing)
        c.drawRect(rect, paint)
    }
}
