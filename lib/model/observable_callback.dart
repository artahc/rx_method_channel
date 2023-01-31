import 'package:equatable/equatable.dart';

enum ObservableCallbackType {
  onNext,
  onError,
  onComplete;
}

class ObservableCallback extends Equatable {
  final int requestId;
  final ObservableCallbackType type;
  final dynamic value;

  const ObservableCallback({
    required this.requestId,
    required this.type,
    this.value,
  });

  factory ObservableCallback.fromJson(Map<String, dynamic> json) {
    final ObservableCallback instance;

    try {
      instance = ObservableCallback(
        requestId: json["requestId"] as int,
        type: ObservableCallbackType.values.byName(json["type"] as String),
        value: json["value"],
      );
    } catch (e) {
      print("Error when parsing ObservableCallback from JSON. $e");
      rethrow;
    }

    return instance;
  }

  @override
  List<Object?> get props => [requestId, type, value];
}
