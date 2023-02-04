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
        channel.registerSingle<Int>("mySingle") {
            Single.just(100)
        }

        channel.registerCompletable("myCompletable") {
            Completable.fromCallable {
                logger.log(Level.INFO, "myCompletable completed.")
            }
        }

        channel.registerObservable<Int>("myObservable") {
            Observable.just(1, 2, 3, 4, 5)
        }
    }
}
