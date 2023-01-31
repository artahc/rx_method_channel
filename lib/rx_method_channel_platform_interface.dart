import 'package:async/async.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rx_method_channel_method_channel.dart';

abstract class RxMethodChannelPlatform extends PlatformInterface {
  /// Constructs a RxMethodChannelPlatform.
  RxMethodChannelPlatform() : super(token: _token);

  static final Object _token = Object();

  static RxMethodChannelPlatform _instance = RxMethodChannelPlatformImpl(channelName: "");

  /// The default instance of [RxMethodChannelPlatform] to use.
  ///
  /// Defaults to [RxMethodChannelPlatformImpl].
  static RxMethodChannelPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RxMethodChannelPlatform] when
  /// they register themselves.
  static set instance(RxMethodChannelPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  CancelableOperation<void> executeCompletable({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }

  CancelableOperation executeSingle({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }

  Stream executeObservable({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }

  void dispose() {
    throw UnimplementedError();
  }
}
