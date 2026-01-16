package com.okla.ops.utils

import java.util.Locale

class StringUtils {
    companion object {
        fun strToList(input: String?): ArrayList<String> {
            if (input?.trim()?.isNullOrBlank() == true) {
                return ArrayList<String>()
            }
            return input
                ?.split(',')                          // 用逗号拆分
                ?.map { it.trim() }                   // 去掉前后空白
                ?.filter { it.isNotEmpty() }          // 过滤空串（可选）
                ?.toCollection(ArrayList())
                ?: ArrayList<String>()            // 转成 ArrayList<String>
        }

        fun listToStr(list: List<String>): String {
            return if (list.isEmpty()) {
                ""
            } else {
                list.joinToString(separator = ",")
            }
        }

        fun formatLatLng(coordinate: Double): String {
            // 保留6位小数，不四舍五入
            return String.format(Locale.US, "%.6f", coordinate)
        }
    }
}