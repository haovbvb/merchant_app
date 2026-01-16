package com.okla.ops.weight

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import androidx.appcompat.widget.AppCompatEditText
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.utils.TextUtil

class SelectView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs), TextUtil {

    init {
        initView()
    }

    private lateinit var flHead: FrameLayout
    private lateinit var tvTitle: AppCompatTextView
    private lateinit var tvContent: AppCompatEditText
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_select, this)
        flHead = findViewById(R.id.flHead)
        tvTitle = findViewById(R.id.tvTitle)
        tvContent = findViewById(R.id.tvContent)
        tvContent.setOnClickListener {
            onSelectListener?.invoke()
        }
    }

    fun setTitle(title: String) {
        tvTitle.text = title
    }

    fun addStart(addStart: Boolean? = false) {
        if (addStart == true) {
            tvTitle.text = textAddStart(tvTitle.text.toString())
        }
    }

    fun setContent(name: String) {
        tvContent.setText(name)
    }

    fun setHint(hind: String) {
        tvContent.setHint(hind)
    }

    fun setHead(view: View) {
        flHead.visibility = View.VISIBLE
        flHead.removeAllViews()
        flHead.addView(view)
    }

    private var onSelectListener: (() -> Unit)? = null
    fun setOnSelectListener(listener: () -> Unit) {
        this.onSelectListener = listener
    }

}