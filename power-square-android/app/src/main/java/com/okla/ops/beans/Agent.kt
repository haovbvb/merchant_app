package com.okla.ops.beans

data class Agent(
    val agentName: String,
    val agentNo: String,
    var select: Boolean = false,
    var img:String=""
)
