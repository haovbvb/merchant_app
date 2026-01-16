package com.okla.ops.beans

data class City(
    val code: String? = "",
    val latitude: Double? = 0.0,
    val longitude: Double? = 0.0,
    val name: String? = "",
    var selected: Boolean = false,
)