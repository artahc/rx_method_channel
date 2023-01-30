import 'package:async/async.dart';

class RxMethodChannel {
  CancelableOperation<void> executeCompletable({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }

  CancelableOperation<T> executeSingle<T>({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }

  Stream<T> executeObservable<T>({
    required String methodName,
    Map<String, dynamic> arguments = const {},
  }) {
    throw UnimplementedError();
  }
}
