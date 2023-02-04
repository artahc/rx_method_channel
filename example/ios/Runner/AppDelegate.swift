import UIKit
import rx_method_channel
import RxSwift
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = RxMethodChannel(channelName: "test_channel", binaryMessenger: controller.binaryMessenger)
        
        channel.registerSingle("mySingle") { (args: Argument) in
            return Single.just(100)
        }
        
        channel.registerCompletable("myCompletable") { (args: Argument) in
            return Completable.create { (observer : @escaping Completable.CompletableObserver) in
                print("myCompletable completed.")
                observer(.completed)
                return Disposables.create {}
            }
        }
        
        channel.registerObservable("myObservable") { (args: Argument) in
            return Observable.concat([
                Observable.just(1),
                Observable.just(2),
                Observable.just(3),
                Observable.just(4),
                Observable.just(5)
            ])
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

enum TestError: Error {
    case testError
}
