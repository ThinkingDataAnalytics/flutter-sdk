#import "ThinkingAnalyticsPlugin.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@interface ThinkingAnalyticsPlugin ()

@property (nonatomic, strong) NSMutableDictionary *lightInstanceDic;

@end

@implementation ThinkingAnalyticsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"thinkingdata.cn/ThinkingAnalytics"
            binaryMessenger:[registrar messenger]];
  ThinkingAnalyticsPlugin* instance = [[ThinkingAnalyticsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = (NSDictionary *)call.arguments;
    
    if ([@"getInstance" isEqualToString:call.method]) {
        TDConfig *config = [[TDConfig alloc] init];
        if ([arguments objectForKey:@"timeZone"]) {
            config.defaultTimeZone = [NSTimeZone timeZoneWithName:[arguments objectForKey:@"timeZone"]];
        }
        if ([[arguments objectForKey:@"mode"] intValue] == 1) {
            config.debugMode = ThinkingAnalyticsDebug;
        } else if ([[arguments objectForKey:@"mode"] intValue] == 2) {
            config.debugMode = ThinkingAnalyticsDebugOnly;
        }
        [ThinkingAnalyticsSDK startWithAppId:[arguments objectForKey:@"appId"] withUrl:[arguments objectForKey:@"serverUrl"] withConfig:config];
        result(nil);
    } else if ([@"track" isEqualToString:call.method]) {
        [self track:arguments];
        result(nil);
    } else if ([@"identify" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] identify:[arguments objectForKey:@"distinctId"]];
        result(nil);
    } else if ([@"login" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] login:[arguments objectForKey:@"accountId"]];
        result(nil);
    } else if ([@"logout" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] logout];
        result(nil);
    } else if ([@"userSet" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_set:[arguments objectForKey:@"properties"]];
        result(nil);
    } else if ([@"userSetOnce" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_setOnce:[arguments objectForKey:@"properties"]];
        result(nil);
    } else if ([@"userAdd" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_add:[arguments objectForKey:@"properties"]];
        result(nil);
    } else if ([@"userAppend" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_append:[arguments objectForKey:@"properties"]];
        result(nil);
    } else if ([@"userUnset" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_unset:[arguments objectForKey:@"property"]];
        result(nil);
    } else if ([@"userDelete" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_delete];
        result(nil);
    } else if ([@"setSuperProperties" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] setSuperProperties:[arguments objectForKey:@"properties"]];
        result(nil);
    } else if ([@"unsetSuperProperty" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] unsetSuperProperty:[arguments objectForKey:@"property"]];
        result(nil);
    } else if ([@"clearSuperProperties" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] clearSuperProperties];
        result(nil);
    } else if ([@"flush" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] flush];
        result(nil);
    } else if ([@"getDistinctId" isEqualToString:call.method]) {
        NSString *distinctId = [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] getDistinctId];
        result(distinctId);
    } else if ([@"getDeviceId" isEqualToString:call.method]) {
        NSString *deviceId = [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] getDeviceId];
        result(deviceId);
    } else if ([@"timeEvent" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] timeEvent:[arguments objectForKey:@"eventName"]];
        result(nil);
    } else if ([@"optOutTracking" isEqualToString:call.method]) {
        if ([arguments objectForKey:@"deleteUser"]) {
            [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] optOutTrackingAndDeleteUser];
        } else {
            [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] optOutTracking];
        }
        result(nil);
    } else if ([@"optInTracking" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] optInTracking];
        result(nil);
    } else if ([@"enableTracking" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] enableTracking:[arguments objectForKey:@"enabled"]];
        result(nil);
    } else if ([@"createLightInstance" isEqualToString:call.method]) {
        ThinkingAnalyticsSDK *lightInstance = [[ThinkingAnalyticsSDK sharedInstanceWithAppid:[arguments objectForKey:@"appId"]] createLightInstance];
        NSString *uuid = [[NSUUID UUID] UUIDString];
        if (!self.lightInstanceDic) {
            self.lightInstanceDic = [NSMutableDictionary dictionary];
        }
        [self.lightInstanceDic setValue:lightInstance forKey:uuid];
        result(uuid);
    } else if ([@"enableLog" isEqualToString:call.method]) {
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
        result(nil);
    } else if ([@"enableAutoTrack" isEqualToString:call.method]) {
        if ([arguments objectForKey:@"types"]) {
              NSArray *autoTrackTypes = [arguments objectForKey:@"types"];
              ThinkingAnalyticsAutoTrackEventType iOSAutoTrackType = ThinkingAnalyticsEventTypeNone;
              for(int i=0; i < autoTrackTypes.count; i++) {
                  NSNumber* value = autoTrackTypes[i];
                  if (value.intValue == 0) {
                      iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppStart;
                  } else if (value.intValue == 1) {
                       iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppEnd;
                  } else if (value.intValue == 2) {
                      iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppInstall;
                  } else if (value.intValue == 3) {
                      iOSAutoTrackType |= ThinkingAnalyticsEventTypeAppViewCrash;
                  }
              }
              [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] enableAutoTrack:iOSAutoTrackType];
        }
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)track:(NSDictionary*)arguments {
    NSTimeZone *timezone = [arguments objectForKey:@"timeZone"] ? [NSTimeZone timeZoneWithName:[arguments objectForKey:@"timeZone"]] : nil;
    if ([arguments objectForKey:@"timestamp"]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[arguments objectForKey:@"timestamp"] doubleValue] / 1000];
        if (timezone) {
            [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] track:[arguments objectForKey:@"eventName"] properties:[arguments objectForKey:@"properties"] time:date timeZone:timezone];
        } else {
            [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] track:[arguments objectForKey:@"eventName"] properties:[arguments objectForKey:@"properties"] time:date];
        }
    } else {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] track:[arguments objectForKey:@"eventName"] properties:[arguments objectForKey:@"properties"]];
    }
}

- (ThinkingAnalyticsSDK *)getThinkingAnalyticsSDK:(NSString *)appid {
    @synchronized (self.lightInstanceDic) {
        if ([self.lightInstanceDic objectForKey:appid]) {
            return [self.lightInstanceDic objectForKey:appid];
        }
    }
    return [ThinkingAnalyticsSDK sharedInstanceWithAppid:appid];
}

@end
