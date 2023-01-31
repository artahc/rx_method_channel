package com.artahc.rx_method_channel

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

enum class ObservableCallbackType {
    @SerializedName("onNext")
    OnNext,
    @SerializedName("onError")
    OnError,
    @SerializedName("onComplete")
    OnComplete;
}

data class ObservableCallback(
    val requestId: Int,
    val type: ObservableCallbackType,
    val value: Any? = null
) {
    fun toJson(): String {
        return Gson().toJson(this).toString()
    }
}
