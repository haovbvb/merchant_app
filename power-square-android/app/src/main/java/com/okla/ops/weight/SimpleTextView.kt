package com.okla.ops.weight

import android.content.Context
import android.view.LayoutInflater
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R

class SimpleTextView(context: Context) : ConstraintLayout(context) {

    init {
        initView()
    }

    private lateinit var tvContent: AppCompatTextView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_text_simple, this)
        tvContent = findViewById(R.id.tvContent)
    }

    fun setContent(content: String) {
        tvContent.text = content
    }

}