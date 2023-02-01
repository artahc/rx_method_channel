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
  final plugin = RxMethodChannel(channelName: "test_channel");
  StreamSubscription? subs;
  StreamSubscription? subs2;

  @override
  void initState() {
    super.initState();
  }

  Future<void> executeSingle() async {
    final value = await plugin.executeSingle(
      methodName: "returnmyint",
      arguments: {
        "myInt": 69,
      },
    ).valueOrCancellation(null);

    print(value);
  }

  Future<void> executeObservable() async {
    subs = plugin.executeObservable(
      methodName: "observableint",
      arguments: {
        "multiplier": 5,
      },
    ).listen(
      (event) => print("Received result in Front: $event"),
      onError: (e, st) => print("Error $e, $st"),
      onDone: () => print("Stream done"),
    );
  }

  void executePeriodicObservable() async {
    subs2 = plugin.executeObservable(methodName: "periodicObservable").listen(
          (event) => print("Received periodic: $event"),
          onError: (e, st) => print("Error: $e, $st"),
          onDone: () => print("Stream done"),
        );
  }

  void disposePeriodicObservable() {
    subs2?.cancel();
  }

  Future<void> executeCompletable() async {
    await plugin
        .executeCompletable(
          methodName: "completable",
          arguments: {},
        )
        .valueOrCancellation(null)
        .whenComplete(() {
          print("Completed");
        });
  }

  Future<void> executeErrorObservable() async {
    plugin.executeObservable(methodName: "observableerror").listen(
          (event) => print("Receive data $event"),
          onError: (e, st) => print("Error $e, $st"),
          onDone: () => print("Done"),
        );
  }

  Future<void> executeThrowingObservable() async {
    plugin.executeObservable(methodName: "throwingobservable").listen(
        (event) => print("value $event"),
        onDone: () => print("Done"),
        onError: (e, st) => print("Error $e, $st"));
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
              color: Colors.blue,
              onPressed: () {
                executeSingle();
              },
              child: const Text(
                "Execute Single",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                executeCompletable();
              },
              child: const Text(
                "Execute Completable",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                executeObservable();
              },
              child: const Text(
                "Execute Observable",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                executePeriodicObservable();
              },
              child: const Text(
                "Execute Periodic Observable",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                disposePeriodicObservable();
              },
              child: const Text(
                "Dispose Periodic Observable",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                executeErrorObservable();
              },
              child: const Text(
                "Execute observable error",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                executeThrowingObservable();
              },
              child: const Text(
                "Execute throwing observable",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
