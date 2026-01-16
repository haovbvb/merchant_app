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
import android.widget.EditText
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R
import com.okla.ops.weight.InputScanView.OnInputScanListener

class TitleInputScanView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs), OnFocusChangeListener {

    init {
        initView()
    }

    private lateinit var tvTitle: AppCompatTextView
    private lateinit var etContent: EditText
    private lateinit var ivClear: ImageView
    private lateinit var ivScan: ImageView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_input_text_title, this)
        tvTitle = findViewById(R.id.tvTitle)
        etContent = findViewById(R.id.etInput)
        ivClear = findViewById(R.id.imClear)
        ivScan = findViewById(R.id.ivScan)
        ivClear.setOnClickListener {
            etContent.setText("")
        }
        ivScan.setOnClickListener {
            onOnTitleInputScanListener?.onScanClick()
        }
        etContent.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val content = s.toString()
                if (TextUtils.isEmpty(content)) {
                    ivClear.visibility = View.GONE
                } else {
                    ivClear.visibility = View.VISIBLE
                }
            }

            override fun afterTextChanged(s: Editable?) {
                if (TextUtils.isEmpty(s.toString())) {
                    onOnTitleInputScanListener?.onEditTextNotHasFocus("")
                }
            }
        })
        etContent.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                etContent.clearFocus()
            }
            return@setOnEditorActionListener false
        }
        etContent.onFocusChangeListener = this
    }

    override fun onFocusChange(v: View?, hasFocus: Boolean) {
        onHasFocusListener?.invoke(hasFocus)
        if (!hasFocus) {
            val content = etContent.text.toString()
            onOnTitleInputScanListener?.onEditTextNotHasFocus(content)
        }
    }

    fun setTitle(title: String) {
        tvTitle.text = title
    }

    fun setContent(content: String) {
        etContent.setText(content)
        onOnTitleInputScanListener?.onEditTextNotHasFocus(content)
    }

    fun clearContent() {
        etContent.setText("")
    }

    fun setHint(hint: String) {
        etContent.setHint(hint)
    }

    fun clearContentFocus() {
        etContent.clearFocus()
    }

    interface OnTitleInputScanListener {
        fun onScanClick()

        fun onEditTextNotHasFocus(inputContent: String?)
    }

    private var onOnTitleInputScanListener: OnTitleInputScanListener? = null
    fun setOnOnTitleInputScanListener(listener: OnTitleInputScanListener) {
        this.onOnTitleInputScanListener = listener
    }

    private var onHasFocusListener: ((Boolean) -> Unit)? = null
    fun setOnHasFocusListener(listener: (Boolean) -> Unit) {
        this.onHasFocusListener = listener
    }

}