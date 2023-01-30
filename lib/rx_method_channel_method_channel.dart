import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rx_method_channel_platform_interface.dart';

/// An implementation of [RxMethodChannelPlatform] that uses method channels.
class MethodChannelRxMethodChannel extends RxMethodChannelPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rx_method_channel');

  @override
  CancelableOperation<void> executeCompletable({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }

  @override
  CancelableOperation<T> executeSingle<T>({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<T> executeObservable<T>({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }
}
