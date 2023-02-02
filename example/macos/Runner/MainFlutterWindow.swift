import Cocoa
import FlutterMacOS
import RxSwift
import rx_method_channel

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        self.initializeMethodChannel(flutterViewController.engine.binaryMessenger)
        RegisterGeneratedPlugins(registry: flutterViewController)
        super.awakeFromNib()
    }
    
    private func initializeMethodChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        let channel = RxMethodChannel(channelName: "test_channel", binaryMessenger: binaryMessenger)

        channel.registerSingle("returnmyint") { (args: Argument) in
            let value = args["myInt"] as! Int
            
            return Single.just(value)
        }
        
        channel.registerCompletable("completable") { (args: Argument) in
            return Completable.create { (observer : @escaping Completable.CompletableObserver) in
                print("Print something")
                observer(.completed)
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
        
        channel.registerObservable("observableerror") { (args: Argument) in
            return Observable.concat([Observable.just(1), Observable.just(2), Observable.error(TestError.testError)])
        }
        
        channel.registerObservable("throwingobservable") { (args: Argument) in
            return Observable.create { (observer: AnyObserver) in
                observer.onError(TestError.testError)
                return Disposables.create{}
            }
        }
    }
}

enum TestError: Error {
    case testError
}
