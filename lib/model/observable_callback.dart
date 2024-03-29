import 'package:flutter/foundation.dart';

class ObservableCallback {
  final int requestId;
  final dynamic value;

  const ObservableCallback({
    required this.requestId,
    this.value,
  });

  factory ObservableCallback.fromJson(Map<String, dynamic> json) {
    final ObservableCallback instance;

    try {
      instance = ObservableCallback(
        requestId: json["requestId"] as int,
        value: json["value"],
      );
    } catch (e) {
      debugPrint("Error when parsing ObservableCallback from JSON. $e");
      rethrow;
    }

    return instance;
  }

  @override
  bool operator ==(other) {
    return (other is ObservableCallback) &&
        requestId == other.requestId &&
        identical(other.value, value);
  }

  @override
  int get hashCode => Object.hashAll([requestId, value]);
}
