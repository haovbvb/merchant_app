package com.okla.ops.weight

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.ImageView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R

class SearchScanTitleView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private lateinit var topBack: ImageView
    private lateinit var searchView: InputScanView2
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_title_search_scan, this)
        topBack = findViewById(R.id.topBack)
        topBack.setOnClickListener {
            onSearchScanTitleListener?.onBack()
        }
        searchView = findViewById(R.id.inputScanView)
        searchView.setOnInputScanListener(object : InputScanView2.OnInputScanListener {
            override fun onScanClick() {
                onSearchScanTitleListener?.onScanClick()
            }

            override fun onEditTextNotHasFocus(inputContent: String?) {
                onSearchScanTitleListener?.onSearch(inputContent)
            }

        })
    }

    fun setSearchText(content: String) {
        searchView.setContent(content)
    }

    fun setSearchHint(hint: String) {
        searchView.setHint(hint)
    }

    fun getSearchHint():String {
        return searchView.getHint()
    }

    interface OnSearchScanTitleListener {

        fun onScanClick()

        fun onSearch(content: String?)

        fun onBack()
    }

    private var onSearchScanTitleListener: OnSearchScanTitleListener? = null
    fun setOnSearchScanTitleListener(listener: OnSearchScanTitleListener) {
        onSearchScanTitleListener = listener
    }

}