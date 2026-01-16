package com.okla.ops.weight

import android.content.Context
import android.text.Editable
import android.text.InputFilter
import android.text.InputType
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnFocusChangeListener
import android.view.inputmethod.EditorInfo
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatEditText
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R
import com.okla.ops.utils.TextUtil

class InputTextView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs), OnFocusChangeListener, TextUtil {

    init {
        initView()
    }

    private lateinit var tvTitle: AppCompatTextView
    private lateinit var etContent: AppCompatEditText
    private lateinit var ivClear: ImageView
    private lateinit var vLine: View
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_input_text, this)
        tvTitle = findViewById(R.id.tvTitle)
        etContent = findViewById(R.id.etContent)
        ivClear = findViewById(R.id.imClear)
        ivClear.setOnClickListener {
            etContent.setText("")
        }
        etContent.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val content = s.toString()
                if (TextUtils.isEmpty(content) || !etContent.isEnabled) {
                    ivClear.visibility = View.GONE
                } else {
                    ivClear.visibility = View.VISIBLE
                }
            }

            override fun afterTextChanged(s: Editable?) {
                onInputTextListener?.invoke(s.toString())
            }
        })
        etContent.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                etContent.clearFocus()
            }
            return@setOnEditorActionListener false
        }
        etContent.onFocusChangeListener = this
        vLine = findViewById(R.id.vLine)
    }

    override fun onFocusChange(v: View?, hasFocus: Boolean) {
        if (!hasFocus) {
            val content = etContent.text.toString()
            onInputTextListener?.invoke(content)
        }
    }

    fun setTitle(title: String, addStart: Boolean? = false) {
        tvTitle.text = title
        if (addStart == true) {
            tvTitle.text = textAddStart(tvTitle.text.toString())
        }
    }

    fun setEditEnable(enable: Boolean) {
        etContent.isEnabled = enable
    }

    fun setContent(content: String) {
        etContent.setText(content)
    }

    fun getContent(): String {
        return etContent.text.toString()
    }

    fun setHint(hint: String) {
        etContent.hint = hint
    }

    fun hideLine(hide: Boolean) {
        if (hide) vLine.visibility = View.INVISIBLE else vLine.visibility = View.VISIBLE
    }

    fun setContentMaxLength(maxLength: Int) {
        etContent.filters = arrayOf(InputFilter.LengthFilter(maxLength))
    }

    fun setOnlyNumber() {
        etContent.inputType = InputType.TYPE_CLASS_NUMBER
    }

    fun switchFunctionToClick() {
        etContent.isFocusable = false
        etContent.isClickable = true
        etContent.isCursorVisible = false
        etContent.inputType = InputType.TYPE_NULL
        etContent.setOnClickListener {
            onInputTextClickListener?.invoke()
        }
    }

    private var onInputTextListener: ((String) -> Unit)? = null
    fun setOnInputTextListener(listener: (String) -> Unit) {
        this.onInputTextListener = listener
    }

    private var onInputTextClickListener: (() -> Unit)? = null
    fun setOnInputTextClickListener(listener: () -> Unit) {
        this.onInputTextClickListener = listener
    }

}