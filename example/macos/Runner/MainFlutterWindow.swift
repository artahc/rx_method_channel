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
        _ = RxMethodChannel(channelName: "test_channel", binaryMessenger: binaryMessenger)
    }
}
