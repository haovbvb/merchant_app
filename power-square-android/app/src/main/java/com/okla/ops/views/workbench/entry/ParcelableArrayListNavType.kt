package com.okla.ops.views.workbench.entry

import android.os.Bundle
import android.os.Parcelable
import androidx.navigation.NavType
import com.okla.ops.beans.Battery
import com.okla.ops.beans.Car

// 定义支持 ArrayList<Car> 的 NavType
class ParcelableArrayListNavType<T : Parcelable>(private val clazz: Class<T>) :
    NavType<ArrayList<T>>(isNullableAllowed = false) {

    override fun get(bundle: Bundle, key: String): ArrayList<T>? {
        return bundle.getParcelableArrayList(key)
    }

    override fun parseValue(value: String): ArrayList<T> {
        throw UnsupportedOperationException("ArrayList 不支持字符串解析")
    }

    override fun put(bundle: Bundle, key: String, value: ArrayList<T>) {
        bundle.putParcelableArrayList(key, value)
    }

    companion object {
        // 注册 Car 类型的实例
        fun createCarListType(): ParcelableArrayListNavType<Car> {
            return ParcelableArrayListNavType(Car::class.java)
        }
        fun createBatteryListType(): ParcelableArrayListNavType<Battery> {
            return ParcelableArrayListNavType(Battery::class.java)
        }
    }
}