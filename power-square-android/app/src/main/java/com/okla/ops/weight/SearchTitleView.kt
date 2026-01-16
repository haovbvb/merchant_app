package com.okla.ops.weight

import android.content.Context
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.widget.ImageView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R

class SearchTitleView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private lateinit var topBack: ImageView
    private lateinit var searchView: SimpleSearchView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_title_search_old, this)
        topBack = findViewById(R.id.topBack)
        topBack.setOnClickListener {
            Log.d("xxxxxxxxx","setOnClickListener")
            onSearchTitleListener?.onBack()
        }
        searchView = findViewById(R.id.searchView)
        searchView.setOnSearchListener {
            onSearchTitleListener?.onSearch(it)
        }
    }

    fun setSearchText(content: String) {
        searchView.setContent(content)
    }

    fun getSearchText():String {
        return searchView.getContent()
    }

    fun setSearchHint(hint: String) {
        searchView.setHint(hint)
    }

    interface OnSearchTitleListener {
        fun onSearch(content: String)

        fun onBack()
    }

    private var onSearchTitleListener: OnSearchTitleListener? = null
    fun setOnSearchTitleListener(listener: OnSearchTitleListener) {
        onSearchTitleListener = listener
    }

}