import 'package:async/async.dart';
import 'package:rx_method_channel/rx_method_channel_method_channel.dart';

import 'rx_method_channel_platform_interface.dart';
export 'package:async/async.dart';

class RxMethodChannel {
  final String channelName;

  RxMethodChannel({required this.channelName}) {
    final methodChannelImpl =
        RxMethodChannelPlatformImpl(channelName: channelName);
    RxMethodChannelPlatform.instance = methodChannelImpl;
  }

  CancelableOperation<void> executeCompletable({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    return RxMethodChannelPlatform.instance.executeCompletable(
      methodName: methodName,
      arguments: arguments,
    );
  }

  CancelableOperation executeSingle({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    return RxMethodChannelPlatform.instance.executeSingle(
      methodName: methodName,
      arguments: arguments,
    );
  }

  Stream executeObservable({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    return RxMethodChannelPlatform.instance.executeObservable(
      methodName: methodName,
      arguments: arguments,
    );
  }
}
