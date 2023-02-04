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
    }
}

enum TestError: Error {
    case testError
}
