package com.okla.ops.weight

import android.content.Context
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnFocusChangeListener
import android.view.inputmethod.EditorInfo
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatEditText
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R
import com.okla.ops.utils.ScanUtils

class SimpleSearchView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs), OnFocusChangeListener {

    init {
        initView()
    }

    private lateinit var etContent: AppCompatEditText
    private lateinit var ivClear: ImageView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_search_simple, this)
        ivClear = findViewById(R.id.imClear)
        ivClear.setOnClickListener {
            etContent.setText("")
            onSearchListener?.invoke("")
        }
        etContent = findViewById(R.id.etContent)
        ScanUtils.setFilter(etContent)
        etContent.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {
                if (TextUtils.isEmpty(s.toString())) {
                    ivClear.visibility = View.GONE
                } else {
                    ivClear.visibility = View.VISIBLE
                }
            }
        })
        etContent.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                etContent.clearFocus()
            }
            return@setOnEditorActionListener false
        }
        etContent.onFocusChangeListener = this
    }

    override fun onFocusChange(v: View?, hasFocus: Boolean) {
        if (!hasFocus) {
            val content = etContent.text.toString()
            onSearchListener?.invoke(content)
        }
    }

    fun setContent(content: String) {
        etContent.setText(content)
        onSearchListener?.invoke(content)
    }

    fun getContent(): String {
        return etContent.text.toString()
    }

    fun setHint(hint: String) {
        etContent.setHint(hint)
    }

    private var onSearchListener: ((String) -> Unit)? = null
    fun setOnSearchListener(listener: (String) -> Unit) {
        this.onSearchListener = listener
    }

}