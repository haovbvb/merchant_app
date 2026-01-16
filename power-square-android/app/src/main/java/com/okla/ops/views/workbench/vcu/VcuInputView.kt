package com.okla.ops.views.workbench.vcu

import android.content.Context
import android.text.Editable
import android.text.InputFilter
import android.text.InputType
import android.text.TextUtils
import android.text.TextWatcher
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatEditText
import androidx.appcompat.widget.AppCompatTextView
import com.okla.ops.R

class VcuInputView(context: Context) :
    VcuCustomView(context) {
    init {
        initView()
    }

    private lateinit var tvUnit: AppCompatTextView
    private lateinit var etInput: AppCompatEditText
    private lateinit var ivClear: ImageView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.view_vcu_input, this)
        etInput = findViewById(R.id.etInput)
        tvUnit = findViewById(R.id.tvUnit)
        ivClear = findViewById(R.id.imClear)
        ivClear.setOnClickListener {
            etInput.setText("")
        }
        etInput.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val content = s.toString()
                if (TextUtils.isEmpty(content) || !etInput.isEnabled) {
                    ivClear.visibility = View.GONE
                } else {
                    ivClear.visibility = View.VISIBLE
                }
            }

            override fun afterTextChanged(s: Editable?) {
            }
        })
    }

    fun showUnit() {
        tvUnit.visibility = View.VISIBLE
    }

    fun setInputNumberType() {
        etInput.inputType = InputType.TYPE_CLASS_NUMBER
        etInput.filters = arrayOf(InputFilter { source, start, end, dest, dstart, dend ->
            try {
                val newValue = (dest.substring(0, dstart) +
                        source.substring(start, end) +
                        dest.substring(dend))

                if (newValue.isNotEmpty()) {
                    val num = newValue.toInt()
                    if (num > 65535 || num <= 0) return@InputFilter ""
                }
            } catch (_: NumberFormatException) {
                return@InputFilter ""
            }
            null
        })
    }

    fun setHintText(textRes: Int) {
        etInput.hint = context.getString(textRes)
    }

    private var function: ((String) -> String)? = null
    fun setFunction(func: (String) -> String) {
        function = func
    }

    override fun newData(): VcuData {
        val inputData = etInput.text.toString()
        val result = if (TextUtils.isEmpty(inputData)) "" else function?.invoke(inputData) ?: ""
        return VcuData(
            "",
            result,
            select = false,
            net = false
        )
    }

}