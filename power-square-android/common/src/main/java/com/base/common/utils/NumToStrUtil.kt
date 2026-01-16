package com.base.common.utils

import java.text.DecimalFormat

object NumToStrUtil {
    fun IntToStrWith1(num: Int): String {
        return DecimalFormat("####0.0").format(num)
    }

    fun IntToStrWith2(num: Int): String {
        return DecimalFormat("####0.00").format(num)
    }

    fun DoubleToStrWith1(num: Double): String {
        return DecimalFormat("####0.0").format(num)
    }

    fun DoubleToStrWith2(num: Double): String {
        return DecimalFormat("####0.00").format(num)
    }

    fun DoubleToStrWith2AndThousand(num: Double): String {
        return DecimalFormat("##,##0.00").format(num)
    }

    fun FloatToStrWith0(num: Double): String {
        return DecimalFormat("####0").format(num)
    }

    fun FloatToStrWith2(num: Double): String {
        return DecimalFormat("####0.00").format(num)
    }
}