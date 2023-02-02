import Cocoa
import FlutterMacOS

public class RxMethodChannelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let instance = RxMethodChannelPlugin()
      let channel = FlutterMethodChannel(name: "rx_method_channel", binaryMessenger: registrar.messenger)
      registrar.addMethodCallDelegate(instance, channel: channel)
  }
}
