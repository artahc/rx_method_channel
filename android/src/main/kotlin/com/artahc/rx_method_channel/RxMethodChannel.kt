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
import java.util.logging.Level
import java.util.logging.Logger

typealias SingleContainer = (Argument) -> Single<*>

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
    private val registeredObservable = mutableMapOf<String, (Argument) -> Observable<*>>()
    private val registeredCompletable = mutableMapOf<String, (Argument) -> Completable>()

    private val subscriptions = mutableMapOf<Int, Disposable>()

    fun <T> registerSingle(methodName: String, call: (Argument) -> Single<T>) {
        logger.log(Level.INFO, "Registered single: $methodName")
        registeredSingle[methodName] = call
    }

    fun registerCompletable(methodName: String, call: (Argument) -> Completable) {
        logger.log(Level.INFO, "Registered completable $methodName")
        registeredCompletable[methodName] = call
    }

    fun <T> registerObservable(methodName: String, call: (Argument) -> Observable<T>) {
        logger.log(Level.INFO, "Registered observable $methodName")
        registeredObservable[methodName] = call
    }

    private fun removeSubscription(requestId: Int) {
        logger.log(Level.INFO, "Disposed subscription with requestId: ${subscriptions[requestId]}")
        subscriptions[requestId]?.dispose()
        subscriptions.remove(requestId)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        logger.log(Level.INFO, "Invoking ${call.method} ${call.arguments}")

        val args = call.arguments as HashMap<String, Any>
        val requestId = args["requestId"] as Int

        when (call.method) {
            "cancel" -> {
                removeSubscription(requestId)
                result.success(null)
            }
            "subscribe" -> {
                val methodName = args["methodName"] as String
                val methodType = args["methodType"] as String
                val methodArgument = args["arguments"] as HashMap<String, Any>

                when (methodType) {
                    "single" -> {
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
                            .subscribeOn(AndroidSchedulers.mainThread())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe({
                                result.success(it)
                            }, { error ->
                                result.error(OPERATION_ERROR, error.localizedMessage, error)
                            })
                    }
                    "completable" -> {
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
                            .subscribeOn(AndroidSchedulers.mainThread())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe({
                                logger.log(Level.INFO, "Success: $methodName")
                                result.success(null)
                            }, { error ->
                                logger.log(Level.INFO, "Error: $methodName")
                                result.error(OPERATION_ERROR, null, error)
                            })
                    }
                    "observable" -> {
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
                            .doOnTerminate {
                                result.success(null)
                            }
                            .doOnComplete {
                                channel.invokeMethod(
                                    "observableCallback",
                                    ObservableCallback(
                                        requestId,
                                        ObservableCallbackType.OnComplete,
                                        null
                                    ).toJson()
                                )
                            }
                            .subscribeOn(AndroidSchedulers.mainThread())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe({
                                logger.log(Level.INFO, "Emitting item $it")
                                channel.invokeMethod(
                                    "observableCallback",
                                    ObservableCallback(
                                        requestId,
                                        ObservableCallbackType.OnNext,
                                        it
                                    ).toJson()
                                )
                            }, {
                                channel.invokeMethod(
                                    "observableCallback",
                                    ObservableCallback(
                                        requestId,
                                        ObservableCallbackType.OnError,
                                        null
                                    ).toJson()
                                )
                            })
                    }
                    else -> throw Exception("Invalid methodType: $methodType")
                }
            }
            else -> {
                throw Exception("Unable to find method ${call.method}")
            }
        }
    }
}