package com.okla.ops.utils

import android.text.SpannableString
import android.text.Spanned
import android.text.TextUtils
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan

class TextStyleUtils {

    companion object {
        fun fixTextStyleSize(content: String, indexStr: String, size: Int): CharSequence {
            if (!TextUtils.isEmpty(content)) {
                val start = content.indexOf(indexStr)
                if (start >= 0) {
                    val end = content.length
                    val spannableString = SpannableString(content)
                    val absoluteSizeSpan = AbsoluteSizeSpan(size, true)
                    spannableString.setSpan(
                        absoluteSizeSpan, start, end, Spanned.SPAN_INCLUSIVE_INCLUSIVE
                    )
                    return spannableString
                }
            }
            return content
        }

        fun fixTextStyleColor(content: String, indexStr: String, color: Int): CharSequence {
            if (!TextUtils.isEmpty(content)) {
                val start = content.indexOf(indexStr)
                if (start >= 0) {
                    val end = content.length
                    val spannableString = SpannableString(content)
                    val foregroundColorSpan = ForegroundColorSpan(color)
                    spannableString.setSpan(
                        foregroundColorSpan, start, end, Spanned.SPAN_EXCLUSIVE_INCLUSIVE
                    )
                    return spannableString
                }
            }
            return content
        }

        fun fixTextStyleColor(
            content: String, startIndex: Int, endIndex: Int, color: Int
        ): CharSequence {
            if (!TextUtils.isEmpty(content) && endIndex > startIndex && startIndex >= 0) {
                val spannableString = SpannableString(content)
                val foregroundColorSpan = ForegroundColorSpan(color)
                spannableString.setSpan(
                    foregroundColorSpan, startIndex, endIndex, Spanned.SPAN_EXCLUSIVE_INCLUSIVE
                )
                return spannableString
            }
            return content
        }
    }

}