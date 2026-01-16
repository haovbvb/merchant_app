package com.okla.ops.utils

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Color
import android.text.Editable
import android.text.InputFilter
import android.text.InputType
import android.text.SpannableString
import android.text.Spanned
import android.text.TextUtils
import android.text.TextWatcher
import android.text.style.ForegroundColorSpan
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import java.util.regex.Pattern

interface TextUtil : TextWatcher {

    fun textAddStart(str: String): SpannableString? {
        if (str.isEmpty()) return null
        val newStr = "$str*"
        val spannableString = SpannableString(newStr);
        val color = Color.parseColor("#FF0000")
        spannableString.setSpan(
            ForegroundColorSpan(color),
            spannableString.length - 1,
            spannableString.length,
            Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
        )
        return spannableString
    }

    fun textFilterEmoji(editView: EditText) {
        editView.filters = arrayOf(InputFilter { source, _, _, _, _, _ ->
            source.filter {
                Character.getType(it) != Character.SURROGATE.toInt() && Character.getType(
                    it
                ) != Character.OTHER_SYMBOL.toInt()
            }
        })
    }

    fun textFilterBlank(editView: EditText) {
        editView.filters = arrayOf(InputFilter { source, _, _, _, _, _ ->
            source.filter {
                it != ' '
            }
        })
    }

    fun textFilterChinese(editView: EditText) {
        editView.filters = arrayOf(InputFilter { source, _, _, _, _, _ ->
            source.filter {
                val p = Pattern.compile("[\u4e00-\u9fa5]")
                val matcher = p.matcher(it.toString())
                !matcher.matches()
            }
        })
    }

    fun textIsEmpty(text: String?): String {
        return if (TextUtils.isEmpty(text)) "-" else text ?: ""
    }

    /**
     * 米换算千米
     */
    fun m2km(m: Double): String {
        if (m < 1000) {
            return m.toInt().toString() + "m "
        }
        val v = m / 1000.0
        val result = String.format("%.1f", v)
        return result + "km "
    }

    fun TextView.copyTextToClipboard(context: Context, tips: String) {
        // 获取剪贴板管理器
        val clipboardManager =
            context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

        // 获取当前 TextView 的文本
        val textToCopy = this.text.toString()

        // 创建剪贴板内容
        val clipData = ClipData.newPlainText("Copied Text", textToCopy)

        // 设置到剪贴板
        clipboardManager.setPrimaryClip(clipData)

        // 提示用户
        Toast.makeText(context, tips, Toast.LENGTH_SHORT).show()
    }

    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

    }

    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
        onTextChange(s)
    }

    override fun afterTextChanged(s: Editable?) {
    }

    fun onTextChange(s: CharSequence?) {}

    //限制输入数字和小数点，小数点后最多2位。
    // 在任意地方定义这个扩展方法，调用 editText.setDecimalLimit() 即可
    fun setDecimalLimit(editView: EditText) {
        // 只允许输入数字和小数点
        editView.inputType = InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL

        // 自定义过滤器：总长度 ≤ 9；不能以 . 开头；小数点后最多 2 位；只允许一个小数点
        val decimalFilter = InputFilter { source, start, end, dest, dstart, dend ->
            // 拼接新文本
            val newText = StringBuilder()
                .append(dest.substring(0, dstart))
                .append(source.subSequence(start, end))
                .append(dest.substring(dend))
                .toString()

            // 允许删除等行为
            if (source.isEmpty()) {
                return@InputFilter null
            }
            // 总长度校验（包括小数点）
            if (newText.length > 9) {
                return@InputFilter ""
            }
            // 不能以 . 开头
            if (newText.startsWith(".")) {
                return@InputFilter ""
            }
            // 格式校验：必须是数字，或者数字 + 一个小数点 + 最多两位小数
            // 这里用负向先行断言，确保首字符不是点；也可以用上面 startsWith 检查
            val pattern = Regex("^(?!\\.)\\d*(\\.\\d{0,2})?$")
            if (!pattern.matches(newText)) {
                return@InputFilter ""
            }
            // 校验通过
            null
        }

        // 应用过滤器
        editView.filters = arrayOf(decimalFilter)
    }


}