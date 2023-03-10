#import "RxMethodChannelPlugin.h"
#if __has_include(<rx_method_channel/rx_method_channel-Swift.h>)
#import <rx_method_channel/rx_method_channel-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "rx_method_channel-Swift.h"
#endif

@implementation RxMethodChannelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRxMethodChannelPlugin registerWithRegistrar:registrar];
}
@end
