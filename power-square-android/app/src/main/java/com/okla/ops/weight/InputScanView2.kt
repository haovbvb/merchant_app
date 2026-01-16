package com.okla.ops.weight

import android.content.Context
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnFocusChangeListener
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import android.widget.ImageView
import androidx.constraintlayout.widget.ConstraintLayout
import com.base.common.utils.ToastUtils
import com.okla.ops.R
import com.okla.ops.utils.ScanUtils

class InputScanView2(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs), OnFocusChangeListener {

    init {
        initView()
    }

    private lateinit var etContent: EditText
    private lateinit var ivClear: ImageView
    private lateinit var ivScan: ImageView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_input_scan2, this)
        etContent = findViewById(R.id.etInput)
        ivClear = findViewById(R.id.imClear)
        ivScan = findViewById(R.id.ivScan)
        ivClear.setOnClickListener {
            etContent.setText("")
        }
        ivScan.setOnClickListener {
            onInputScanListener?.onScanClick()
        }
        ScanUtils.setFilter(etContent)
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
                    onInputScanListener?.onEditTextNotHasFocus("")
                }
            }
        })
        etContent.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                etContent.clearFocus()
                if (TextUtils.isEmpty(etContent.text.toString())) {
                    ToastUtils.showShort(getHint())
                }
            }
            return@setOnEditorActionListener false
        }
        etContent.onFocusChangeListener = this
    }

    override fun onFocusChange(v: View?, hasFocus: Boolean) {
        onHasFocusListener?.invoke(hasFocus)
        if (!hasFocus) {
            val content = etContent.text.toString()
            onInputScanListener?.onEditTextNotHasFocus(content)
        }
    }

    fun setContent(content: String) {
        etContent.setText(content)
        onInputScanListener?.onEditTextNotHasFocus(content)
    }

    fun setHint(hint: String) {
        etContent.setHint(hint)
    }

    fun getHint(): String {
        return etContent.hint.toString()
    }

    interface OnInputScanListener {
        fun onScanClick()

        fun onEditTextNotHasFocus(inputContent: String?)
    }

    private var onInputScanListener: OnInputScanListener? = null
    fun setOnInputScanListener(listener: OnInputScanListener) {
        this.onInputScanListener = listener
    }

    private var onHasFocusListener: ((Boolean) -> Unit)? = null
    fun setOnHasFocusListener(listener: (Boolean) -> Unit) {
        this.onHasFocusListener = listener
    }

}