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
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.subjects.PublishSubject
import java.util.concurrent.TimeUnit

class InputScanView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs), OnFocusChangeListener {
    private lateinit var inputSubject:PublishSubject<String>
    init {
        initView()
    }

    private lateinit var etContent: EditText
    private lateinit var ivClear: ImageView
    private lateinit var ivScan: ImageView
    private var inputDispose: Disposable? = null
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_input_scan, this)
        etContent = findViewById(R.id.etInput)
        ivClear = findViewById(R.id.imClear)
        ivScan = findViewById(R.id.ivScan)
        ivClear.setOnClickListener {
            etContent.setText("")
        }
        ivScan.setOnClickListener {
            onInputScanListener?.onScanClick()
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
//                if (!TextUtils.isEmpty(s.toString())) {
//                    // 将输入变化推送给 PublishSubject
//                    inputSubject.onNext(s.toString())
//                }
            }
        })
        etContent.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                etContent.clearFocus()
            }
            return@setOnEditorActionListener false
        }
        etContent.onFocusChangeListener = this
        // 设置订阅，防抖处理
        inputSubject = PublishSubject.create<String>()
        inputDispose = inputSubject
            .debounce(1500, TimeUnit.MILLISECONDS)
            .observeOn(AndroidSchedulers.mainThread())
            .debounce(300, TimeUnit.MILLISECONDS) // 防止快速输入频繁触发
            .distinctUntilChanged() // 去重
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe { inputText -> // 处理输入框数据
                if (onInputScanListener != null) {
                    onInputScanListener?.onEditTextNotHasFocus(inputText.toString())
                }
            }

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
        etContent.requestFocus()
        etContent.clearFocus()
    }


    fun setHint(hint: String) {
        etContent.setHint(hint)
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