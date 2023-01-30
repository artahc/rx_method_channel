import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_method_channel/rx_method_channel_method_channel.dart';

void main() {
  MethodChannelRxMethodChannel platform = MethodChannelRxMethodChannel();
  const MethodChannel channel = MethodChannel('rx_method_channel');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
