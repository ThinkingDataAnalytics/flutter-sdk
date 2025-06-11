//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"
#import "TDDemoPlugin.h"
#if __has_include(<thinking_analytics/ThinkingAnalyticsPlugin.h>)
#import <thinking_analytics/ThinkingAnalyticsPlugin.h>
#else
@import thinking_analytics;
#endif

#if __has_include(<webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h>)
#import <webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h>
#else
@import webview_flutter_wkwebview;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [ThinkingAnalyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"ThinkingAnalyticsPlugin"]];
  [FLTWebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTWebViewFlutterPlugin"]];
   [TDDemoPlugin registerWithRegistrar:[registry registrarForPlugin:@"TDDemoPlugin"]];
}

@end
