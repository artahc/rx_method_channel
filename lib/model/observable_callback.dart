import 'package:equatable/equatable.dart';

class ObservableCallback extends Equatable {
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
      print("Error when parsing ObservableCallback from JSON. $e");
      rethrow;
    }

    return instance;
  }

  @override
  List<Object?> get props => [requestId, value];
}
