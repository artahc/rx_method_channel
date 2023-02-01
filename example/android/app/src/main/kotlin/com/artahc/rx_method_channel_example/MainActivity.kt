package com.artahc.rx_method_channel_example

import android.os.Bundle
import android.util.Log
import com.artahc.rx_method_channel.RxMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.reactivex.Completable
import io.reactivex.Observable
import io.reactivex.Single
import java.util.concurrent.TimeUnit
import java.util.logging.Level
import java.util.logging.Logger

class MainActivity : FlutterActivity() {
    private val tag = "MainActivity"
    private val logger = Logger.getLogger(tag)
    private lateinit var channel: RxMethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        logger.log(Level.CONFIG, "Initializing MainActivity")

        channel = RxMethodChannel("test_channel", this.flutterEngine!!.dartExecutor.binaryMessenger)
        channel.registerSingle<Int>("returnmyint") { args ->
            val myInt = args["myInt"] as Int
            Completable.timer(2, TimeUnit.SECONDS).andThen(
                Single.just(myInt)
            )
        }
        channel.registerCompletable("completable") { args ->
            Completable.fromCallable {
                logger.log(Level.INFO, "Print something")
            }
        }

        channel.registerObservable<Int>("observableint") { args ->
            val multiplier = args["multiplier"] as Int
            Observable.fromArray(1, 2, 3).map { it * multiplier }
        }

        channel.registerObservable<Int>("periodicObservable") { args ->
            Observable.interval(2L, TimeUnit.SECONDS).map { it.toInt() }
        }

        channel.registerObservable<Int>("observableerror") { args ->
           Observable.concatArray(
               Observable.just(1),
               Observable.just(2),
               Observable.error(Exception("Test Error")),
           )
        }

        channel.registerObservable<Int>("throwingobservable") { args ->
            Observable.create { emitter ->
                throw Exception("Throwing observable")
            }
        }
    }
}
