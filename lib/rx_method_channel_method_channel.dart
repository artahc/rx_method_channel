import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:rx_method_channel/model/observable_callback.dart';
import 'package:rxdart/rxdart.dart';

import 'rx_method_channel_platform_interface.dart';

enum Action { subscribe, cancel }

enum MethodType {
  completable,
  observable,
  single,
}

/// An implementation of [RxMethodChannelPlatform] that uses method channels.
class RxMethodChannelPlatformImpl extends RxMethodChannelPlatform {
  final MethodChannel _channel;

  final StreamController<ObservableCallback> _observableCallbackController =
      StreamController.broadcast();

  RxMethodChannelPlatformImpl({required String channelName})
      : _channel = MethodChannel(channelName) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "observableCallback") {
        try {
          final args = jsonDecode(call.arguments);
          final callback = ObservableCallback.fromJson(args);
          _observableCallbackController.sink.add(callback);
        } catch (e) {
          throw Exception("Error parsing observable callback arguments");
        }
      } else {
        throw UnimplementedError(
            "Method ${call.method} is not implemented on Dart side");
      }
    });
  }

  int _generateRequestId() {
    return Random().nextInt(1000000);
  }

  void _cancelOperation(int requestId) {
    _channel.invokeMethod(
      Action.cancel.name,
      {
        "requestId": requestId,
      },
    );
  }

  @override
  CancelableOperation<void> executeCompletable({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    final requestId = _generateRequestId();
    return CancelableOperation.fromFuture(
      _channel.invokeMethod(
        Action.subscribe.name,
        {
          "requestId": requestId,
          "methodType": MethodType.completable.name,
          "methodName": methodName,
          "arguments": arguments,
        },
      ),
      onCancel: () {
        _cancelOperation(requestId);
      },
    );
  }

  @override
  CancelableOperation executeSingle({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    final requestId = _generateRequestId();
    return CancelableOperation.fromFuture(
      _channel.invokeMethod(
        Action.subscribe.name,
        {
          "requestId": requestId,
          "methodType": MethodType.single.name,
          "methodName": methodName,
          "arguments": arguments,
        },
      ),
      onCancel: () {
        _cancelOperation(requestId);
      },
    );
  }

  @override
  Stream executeObservable({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    final requestId = _generateRequestId();
    final resultStream = _observableCallbackController.stream
        .where((data) => data.requestId == requestId)
        .map((event) => event.value);

    final commandStream = _channel
        .invokeMethod(
          Action.subscribe.name,
          {
            "requestId": requestId,
            "methodName": methodName,
            "methodType": MethodType.observable.name,
            "arguments": arguments,
          },
        )
        .asStream()
        .transform(StreamTransformer.fromHandlers(
          handleData: (data, sink) => sink.close(),
          handleError: (error, stackTrace, sink) {
            sink.addError(error, stackTrace);
            sink.close();
          },
          handleDone: (sink) => sink.close(),
        ));

    return resultStream.mergeWith([commandStream]).doOnCancel(() {
      _cancelOperation(requestId);
    });
  }

  @override
  void dispose() {
    _observableCallbackController.close();
    super.dispose();
  }
}
