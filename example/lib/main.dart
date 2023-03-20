import 'package:flutter/material.dart';
import 'dart:async';

import 'package:rx_method_channel/rx_method_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final channel = RxMethodChannel(channelName: "test_channel");

  StreamSubscription? subs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MaterialButton(
              onPressed: () async {
                final value =
                    await channel.executeSingle(methodName: "mySingle").value;
                debugPrint(value);
              },
              child: const Center(
                child: Text("Execute Single"),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                await channel
                    .executeCompletable(methodName: "myCompletable")
                    .value
                    .whenComplete(() => debugPrint("Completed"));
              },
              child: const Center(
                child: Text("Execute Completable"),
              ),
            ),
            MaterialButton(
              onPressed: () {
                subs?.cancel();
                subs = channel
                    .executeObservable(methodName: "myObservable")
                    .timeout(const Duration(seconds: 5))
                    .listen((event) {
                  debugPrint(event);
                });
              },
              child: const Center(
                child: Text("Execute Observable"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
