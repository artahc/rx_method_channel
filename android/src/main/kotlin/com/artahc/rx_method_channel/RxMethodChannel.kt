package com.artahc.rx_method_channel

import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Completable
import io.reactivex.Observable
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import java.util.logging.Level
import java.util.logging.Logger

typealias SingleContainer = (Argument) -> Single<Any>
typealias CompletableContainer = (Argument) -> Completable
typealias ObservableContainer = (Argument) -> Observable<Any>

enum class Action(val value: String) {

    Cancel("cancel"), Subscribe("subscribe");

    companion object {
        private val map = Action.values().associateBy(Action::value)
        operator fun get(value: String) = map[value]
    }
}

enum class MethodType(val value: String) {
    Single("single"), Completable("completable"), Observable("observable");

    companion object {
        private val map = MethodType.values().associateBy(MethodType::value)
        operator fun get(value: String) = map[value]
    }
}

class RxMethodChannel(channelName: String, binaryMessenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {
    private val tag = "RxMethodChannelPlugin"
    private val logger = Logger.getLogger(tag)
    private val channel: MethodChannel

    init {
        channel = MethodChannel(binaryMessenger, channelName)
        channel.setMethodCallHandler(this)
    }

    private val registeredSingle = mutableMapOf<String, SingleContainer>()
    private val registeredObservable = mutableMapOf<String, ObservableContainer>()
    private val registeredCompletable = mutableMapOf<String, CompletableContainer>()

    private val subscriptions = mutableMapOf<Int, Disposable>()

    fun <T> registerSingle(methodName: String, call: SingleContainer) {
        logger.log(Level.INFO, "Registered single: $methodName")
        registeredSingle[methodName] = call
    }

    fun registerCompletable(methodName: String, call: CompletableContainer) {
        logger.log(Level.INFO, "Registered completable $methodName")
        registeredCompletable[methodName] = call
    }

    fun <T> registerObservable(methodName: String, call: ObservableContainer) {
        logger.log(Level.INFO, "Registered observable $methodName")
        registeredObservable[methodName] = call
    }

    private fun removeSubscription(requestId: Int) {
        logger.log(
            Level.INFO,
            "Disposed subscription with requestId: $requestId -> ${subscriptions[requestId]}"
        )
        subscriptions[requestId]?.dispose()
        subscriptions.remove(requestId)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        logger.log(Level.INFO, "Invoking ${call.method} ${call.arguments}")

        val args = call.arguments as HashMap<String, Any>
        val requestId = args["requestId"] as Int

        when (Action[call.method]) {
            Action.Cancel -> {
                removeSubscription(requestId)
                result.success(null)
            }
            Action.Subscribe -> {
                val methodName = args["methodName"] as String
                val methodArgument = args["arguments"] as HashMap<String, Any>
                val rawMethodType = args["methodType"] as String

                when (MethodType[rawMethodType]) {
                    MethodType.Single -> {
                        if (!registeredSingle.containsKey(methodName)) {
                            result.error(
                                METHOD_NOT_FOUND,
                                "Method $methodName is not registered.",
                                null
                            )
                            return
                        }

                        val source = registeredSingle[methodName]
                        subscriptions[requestId] = source!!.invoke(methodArgument)
                            .doOnTerminate {
                                removeSubscription(requestId)
                            }
                            .subscribe({
                                result.success(it)
                            }, { error ->
                                result.error(OPERATION_ERROR, error.localizedMessage, error)
                            })
                    }
                    MethodType.Completable -> {
                        if (!registeredCompletable.containsKey(methodName)) {
                            result.error(
                                METHOD_NOT_FOUND,
                                "Method $methodName is not registered.",
                                null
                            )
                            return
                        }

                        val source = registeredCompletable[methodName]
                        subscriptions[requestId] = source!!.invoke(methodArgument)
                            .doOnTerminate {
                                removeSubscription(requestId)
                            }
                            .subscribe({
                                result.success(null)
                            }, { error ->
                                result.error(OPERATION_ERROR, error.localizedMessage, error)
                            })
                    }
                    MethodType.Observable -> {
                        if (!registeredObservable.containsKey(methodName)) {
                            result.error(
                                METHOD_NOT_FOUND,
                                "Method $methodName is not registered.",
                                null
                            )
                            return
                        }

                        val source = registeredObservable[methodName]
                        subscriptions[requestId] = source!!.invoke(methodArgument)
                            .observeOn(AndroidSchedulers.mainThread())
                            .doOnComplete {
                                result.success(null)
                                removeSubscription(requestId)
                            }
                            .subscribe({
                                channel.invokeMethod(
                                    "observableCallback",
                                    ObservableCallback(requestId, it).toJson()
                                )
                            }, { error ->
                                result.error(OPERATION_ERROR, error.localizedMessage, null)
                                removeSubscription(requestId)
                            })
                    }
                    null -> result.error(
                        INVALID_OPERATION,
                        "Invalid method type: $rawMethodType",
                        null
                    )
                }
            }
            null -> result.error(INVALID_OPERATION, "Invalid operation: ${call.method}", null)
        }
    }
}