package com.okla.ops.custom

import android.content.Context
import android.text.Editable
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
class ScanOrInputComplexNewView(context: Context, attrs: AttributeSet?) :
    ConstraintLayout(context, attrs) {
    init {
        initTypeValue(context, attrs)
        initView()
    }

    var mScanAndInputName: String? = null
    var mScanAndInputHintValue: String? = null
    var mScanAndInputValue: String? = null
    var mScanAndInputTopRight: String? = null
    var mScanAndInputTopRightImg: Int = R.mipmap.ic_scan
    var mScanAndInputTopRightVisible: Boolean = true
    var mScanAndInputTopRightTwoVisible: Boolean = true
    var mScanAndInputBottomVisible: Boolean = true
    var mScanAndInputBottomLineVisible: Boolean = true
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
            R.mipmap.ic_scan
        )
        mScanAndInputTopRightVisible =
            typeArray.getBoolean(R.styleable.ScanOrInputView_ScanAndInputTopRightVisible, true)
        mScanAndInputTopRightTwoVisible =
            typeArray.getBoolean(R.styleable.ScanOrInputView_ScanAndInputTopRightTwoVisible, true)
        mScanAndInputBottomVisible =
            typeArray.getBoolean(R.styleable.ScanOrInputView_ScanAndInputBottomVisible, true)
        mScanAndInputBottomLineVisible =
            typeArray.getBoolean(R.styleable.ScanOrInputView_ScanAndInputBottomLineVisible, true)
        mScanAndInputIsEnabledInput =
            typeArray.getBoolean(R.styleable.ScanOrInputView_ScanAndInputIsEnabledInput, true)

        typeArray.recycle()
    }

    lateinit var tvScanAndInputName: TextView
    lateinit var etScanAndInputValue: EditText
    lateinit var tvScanAndInputTopRight: TextView
    lateinit var tvScanAndInputTopRightTwo: TextView
    lateinit var btnAdd: ConstraintLayout
    lateinit var vLine1: View
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.custom_scan_or_input_complex_new, this)
        tvScanAndInputName = findViewById(R.id.tvScanAndInputName)
        etScanAndInputValue = findViewById(R.id.etScanAndInputValue)
        tvScanAndInputTopRight = findViewById(R.id.tvScanAndInputTopRight)
        tvScanAndInputTopRightTwo = findViewById(R.id.tvScanAndInputTopRightTwo)
        btnAdd = findViewById(R.id.btnAdd)
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
        tvScanAndInputTopRightTwo.setOnClickListener {
            mOnClickListerner?.onTextViewClickListern(1)
        }
        btnAdd.setOnClickListener {
            mOnClickListerner?.onTextViewClickListern(0)
        }
        if (mScanAndInputTopRightVisible) {
            tvScanAndInputTopRight.visibility = View.VISIBLE
        } else {
            tvScanAndInputTopRight.visibility = View.GONE
        }
        if (mScanAndInputTopRightTwoVisible) {
            tvScanAndInputTopRightTwo.visibility = View.VISIBLE
        } else {
            tvScanAndInputTopRightTwo.visibility = View.GONE
        }
        if (mScanAndInputBottomVisible) {
            btnAdd.visibility = View.VISIBLE
        } else {
            btnAdd.visibility = View.GONE
        }
        if (mScanAndInputIsEnabledInput) {
            etScanAndInputValue.isEnabled = true
        } else {
            etScanAndInputValue.isEnabled = false
        }

        if (mScanAndInputBottomLineVisible) vLine1.visibility =
            View.VISIBLE else vLine1.visibility = View.GONE
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
        if (mScanAndInputTopRightImg != R.mipmap.ic_scan) {
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
        etScanAndInputValue.setText(value)
        etScanAndInputValue.setSelection(value.length)
        etScanAndInputValue.requestFocus()
    }

    fun setTopRightTwoVisible(visible: Boolean) {
        tvScanAndInputTopRightTwo.visibility = if (visible) View.VISIBLE else View.GONE
    }

    fun setBottomVisible(visible: Boolean) {
        btnAdd.visibility = if (visible) View.VISIBLE else View.GONE
    }

    var mOnClickListerner: OnClickListerner? = null
    fun setListener(listerner: OnClickListerner) {
        mOnClickListerner = listerner
    }

    public interface OnClickListerner {
        fun onClickListen()
        fun afterTextChanged(str: String)

        //position: 0:底部textview，增加电池；1:右上角textview减少电池
        fun onTextViewClickListern(position: Int)
    }
}