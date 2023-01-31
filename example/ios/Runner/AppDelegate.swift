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
        
        channel.registerSingle("returnmyint") { (args: Argument) in
            let value = args["myInt"] as! Int
            
            return Single.just(value)
        }
        
        channel.registerCompletable("completable") { (args: Argument) in
            return Completable.create { (observer : @escaping Completable.CompletableObserver) in
                print("Print something")
                return Disposables.create {}
            }
        }
        
        channel.registerObservable("observableint") { (args: Argument) in
            let multiplier = args["multiplier"] as! Int
            return Observable<Int>.concat([Observable.just(1), Observable.just(2), Observable.just(3)])
                .map { $0 * multiplier }
        }
        
        channel.registerObservable("periodicObservable") { (args: Argument) in
            return Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance).map { $0 }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
