import Flutter
import UIKit

public class SwiftRxMethodChannelPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftRxMethodChannelPlugin()
        let channel = FlutterMethodChannel(name: "rx_method_channel", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
}
