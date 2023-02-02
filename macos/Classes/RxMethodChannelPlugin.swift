import Cocoa
import FlutterMacOS

public class RxMethodChannelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {

    print("ANJING BAT")

    let channel = FlutterMethodChannel(name: "rx_method_channel", binaryMessenger: registrar.messenger)
    let instance = RxMethodChannelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
