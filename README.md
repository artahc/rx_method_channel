# rx_method_channel

Reactive (Rx) wrapper for method channel in Flutter.

## How to Use?
- Add this dependency to pubspec.yaml
- Make method channel using `RxMethodChannel`

```
import 'package:rx_method_channel/rx_method_channel.dart';

void main() async {
  final channel = RxMethodChannel(channelName: "channelName");

  // Observable
  final observableSubsciption = channel.executeObservable(
    methodName: "methodName",
    arguments: {},
  ).listen((event) { 

  });
  observableSubsciption.cancel();

  // Completable
  final completableOperation =
      channel.executeCompletable(methodName: "methodName");
  await completableOperation.valueOrCancellation().whenComplete(() {
    print("Completed");
  });


  // Single
  final singleOperation = channel.executeSingle(
    methodName: "methodName",
    arguments: {
      "arg": "someArg",
    },
  );

  final value = await singleOperation.valueOrCancellation();
  print(value);
}

```
