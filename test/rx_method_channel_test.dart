import 'package:flutter_test/flutter_test.dart';
import 'package:rx_method_channel/rx_method_channel.dart';
import 'package:rx_method_channel/rx_method_channel_platform_interface.dart';
import 'package:rx_method_channel/rx_method_channel_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRxMethodChannelPlatform
    with MockPlatformInterfaceMixin
    implements RxMethodChannelPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RxMethodChannelPlatform initialPlatform = RxMethodChannelPlatform.instance;

  test('$MethodChannelRxMethodChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRxMethodChannel>());
  });

  test('getPlatformVersion', () async {
    RxMethodChannel rxMethodChannelPlugin = RxMethodChannel();
    MockRxMethodChannelPlatform fakePlatform = MockRxMethodChannelPlatform();
    RxMethodChannelPlatform.instance = fakePlatform;

    expect(await rxMethodChannelPlugin.getPlatformVersion(), '42');
  });
}
