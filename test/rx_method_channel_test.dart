import 'package:flutter/foundation.dart';
import 'package:rx_method_channel/rx_method_channel.dart';

void main() async {
  final channel = RxMethodChannel(channelName: "channelName");

  // Observable
  final observableSubsciption = channel.executeObservable(
    methodName: "methodName",
    arguments: {},
  ).listen((event) {});
  observableSubsciption.cancel();

  // Completable
  final completableOperation =
      channel.executeCompletable(methodName: "methodName");
  await completableOperation.valueOrCancellation().whenComplete(() {
    debugPrint("Completed");
  });

  // Single
  final singleOperation = channel.executeSingle(
    methodName: "methodName",
    arguments: {
      "arg": "someArg",
    },
  );

  final value = await singleOperation.valueOrCancellation();
  debugPrint(value);
}
