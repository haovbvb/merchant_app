package com.okla.ops.custom

import android.content.Context
import android.text.Editable
import android.text.TextUtils
import android.text.TextWatcher
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.EditText
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R

/**
 * @Date: 2021/5/31 10:42
 * @Author: Craz
 * @Description:
 * @Version:
 */
class ScanOrInputView(context: Context, attrs: AttributeSet?) : ConstraintLayout(context, attrs) {
    init {
        initTypeValue(context, attrs)
        initView()
    }

    var mScanAndInputName: String? = null
    var mScanAndInputHintValue: String? = null
    var mScanAndInputValue: String? = null
    var mScanAndInputTopRight: String? = null
    var mScanAndInputTopRightImg: Int = R.mipmap.ic_scan
    var mScanAndInputBottomLineVisible: Boolean = true
    var mScanAndInputTopRightVisible: Boolean = true
    var mScanAndInputIsEnabledInput: Boolean = true
    private fun initTypeValue(context: Context, attrs: AttributeSet?) {
        val typeArray = context.obtainStyledAttributes(attrs, R.styleable.ScanOrInputView)
        mScanAndInputName = typeArray.getString(R.styleable.ScanOrInputView_ScanAndInputName)
        mScanAndInputValue = typeArray.getString(R.styleable.ScanOrInputView_ScanAndInputValue)
        mScanAndInputHintValue =
            typeArray.getString(R.styleable.ScanOrInputView_ScanAndInputHintValue)
        mScanAndInputTopRight =
            typeArray.getString(R.styleable.ScanOrInputView_ScanAndInputTopRight)
        mScanAndInputTopRightImg = typeArray.getResourceId(
            R.styleable.ScanOrInputView_ScanAndInputTopRightImg,
            R.mipmap.icon_black_scan
        )
        mScanAndInputTopRightVisible =
            typeArray.getBoolean(R.styleable.ScanOrInputView_ScanAndInputTopRightVisible, true)
        mScanAndInputBottomLineVisible =
            typeArray.getBoolean(R.styleable.ScanOrInputView_ScanAndInputBottomLineVisible, true)
        mScanAndInputIsEnabledInput =
            typeArray.getBoolean(R.styleable.ScanOrInputView_ScanAndInputIsEnabledInput, true)
        typeArray.recycle()
    }

    lateinit var tvScanAndInputName: TextView
    lateinit var etScanAndInputValue: EditText
    lateinit var tvScanAndInputTopRight: TextView
    lateinit var vLine1: View
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.custom_scan_or_input, this)
        tvScanAndInputName = findViewById(R.id.tvScanAndInputName)
        etScanAndInputValue = findViewById(R.id.etScanAndInputValue)
        tvScanAndInputTopRight = findViewById(R.id.tvScanAndInputTopRight)
        vLine1 = findViewById(R.id.vLine1)
        etScanAndInputValue.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(str: Editable?) {
                mOnClickListerner?.let { it.afterTextChanged(str.toString()) }
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }
        })
        if (mScanAndInputTopRightVisible) tvScanAndInputTopRight.visibility =
            View.VISIBLE else tvScanAndInputTopRight.visibility = View.GONE
        if (mScanAndInputBottomLineVisible) vLine1.visibility =
            View.VISIBLE else vLine1.visibility = View.GONE
        if (mScanAndInputIsEnabledInput) etScanAndInputValue.isEnabled =
            true else etScanAndInputValue.isEnabled = false

        etScanAndInputValue.setHint(mScanAndInputHintValue)
        tvScanAndInputTopRight.setOnClickListener {
            mOnClickListerner?.let { it.onClickListen() }
        }
        setData()
    }

    private fun setData() {
        tvScanAndInputName.text = mScanAndInputName
        etScanAndInputValue.setText(mScanAndInputValue)
        mScanAndInputTopRight.let { tvScanAndInputTopRight.text = it }
        if (mScanAndInputTopRightImg != R.mipmap.icon_black_scan) {
            tvScanAndInputTopRight.setCompoundDrawablesRelativeWithIntrinsicBounds(
                mScanAndInputTopRightImg,
                0,
                0,
                0
            )
        }
    }

    fun getScanOrInputValue(): String {
        return etScanAndInputValue.text.toString()
    }

    fun setScanOrInputValue(value: String) {
        if (value.length > 200) {
            return
        }
        etScanAndInputValue.setText(value)
        etScanAndInputValue.setSelection(value.length)
        etScanAndInputValue.requestFocus()
    }

    fun setScanOrInputEnableState(enable: Boolean) {
        etScanAndInputValue.isEnabled =
            enable
    }

    var mOnClickListerner: OnClickListerner? = null
    fun setListener(listerner: OnClickListerner) {
        mOnClickListerner = listerner
    }

    public interface OnClickListerner {
        fun onClickListen()
        fun afterTextChanged(str: String)
    }
}