package com.artahc.rx_method_channel

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

data class ObservableCallback(
    val requestId: Int,
    val value: Any?
) {
    fun toJson(): String {
        return Gson().toJson(this).toString()
    }
}
