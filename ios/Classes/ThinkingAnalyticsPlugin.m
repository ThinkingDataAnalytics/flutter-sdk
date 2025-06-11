#import "ThinkingAnalyticsPlugin.h"
//#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import <ThinkingSDK/ThinkingSDK.h>
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
            config.mode = TDModeDebug;
        } else if ([[arguments objectForKey:@"mode"] intValue] == 2) {
            config.mode = TDModeDebugOnly;
        }
        if([arguments objectForKey:@"secretKey"]){
            NSDictionary *secretKey = (NSDictionary *)[arguments objectForKey:@"secretKey"];
            NSNumber* keyVersion = [secretKey objectForKey:@"version"];
            [config enableEncryptWithVersion:keyVersion.intValue publicKey:[secretKey objectForKey:@"publicKey"]];
        }
        config.appid = [arguments objectForKey:@"appId"];
        config.serverUrl = [arguments objectForKey:@"serverUrl"];
        NSString *version = [arguments objectForKey:@"lib_version"];
        
        [TDAnalytics startAnalyticsWithConfig:config];
        
        [TDAnalytics setCustomerLibInfoWithLibName:@"Flutter" libVersion:version];
        
        result(nil);
    } else if ([@"track" isEqualToString:call.method]) {
        [self track:arguments];
        result(nil);
    } else if ([@"trackEventModel" isEqualToString:call.method]) {
        TDEventModel *eventModel;
        NSString *extraID;
        if ([[arguments objectForKey:@"extraID"] isKindOfClass:[NSString class]]) {
            extraID = [arguments objectForKey:@"extraID"];
        }
        NSString *eventName = [arguments objectForKey:@"eventName"];
        NSString *type = [arguments objectForKey:@"eventType"];
        
        if ([type isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
            eventModel = [[TDFirstEventModel alloc] initWithEventName:eventName firstCheckID:extraID];
        } else if ([type isEqualToString:TD_EVENT_TYPE_TRACK_UPDATE]) {
            eventModel = [[TDUpdateEventModel alloc] initWithEventName:eventName eventID:extraID];
        } else if ([type isEqualToString:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
            eventModel = [[TDOverwriteEventModel alloc] initWithEventName:eventName eventID:extraID];
        }
        
        eventModel.properties = [arguments objectForKey:@"properties"];
        if ([arguments objectForKey:@"timestamp"]) {
            NSDate *time = [NSDate dateWithTimeIntervalSince1970:[[arguments objectForKey:@"timestamp"] doubleValue]/1000.];
            NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:[arguments objectForKey:@"timeZone"]];
            [eventModel configTime:time timeZone:timeZone];
        }
        [TDAnalytics trackWithEventModel:eventModel withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"identify" isEqualToString:call.method]) {
        [TDAnalytics setDistinctId:[arguments objectForKey:@"distinctId"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"login" isEqualToString:call.method]) {
        [TDAnalytics login:[arguments objectForKey:@"accountId"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"logout" isEqualToString:call.method]) {
        [TDAnalytics logoutWithAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"userSet" isEqualToString:call.method]) {
        [TDAnalytics userSet:[arguments objectForKey:@"properties"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"userSetOnce" isEqualToString:call.method]) {
        [TDAnalytics userSetOnce:[arguments objectForKey:@"properties"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"userAdd" isEqualToString:call.method]) {
        [TDAnalytics userAdd:[arguments objectForKey:@"properties"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"userAppend" isEqualToString:call.method]) {
        [TDAnalytics userAppend:[arguments objectForKey:@"properties"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    }else if ([@"userUniqAppend" isEqualToString:call.method]){
        [TDAnalytics userUniqAppend:[arguments objectForKey:@"properties"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    }else if ([@"userUnset" isEqualToString:call.method]) {
        [TDAnalytics userUnset:[arguments objectForKey:@"property"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"userDelete" isEqualToString:call.method]) {
        [TDAnalytics userDeleteWithAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"setSuperProperties" isEqualToString:call.method]) {
        [TDAnalytics setSuperProperties:[arguments objectForKey:@"properties"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"getSuperProperties" isEqualToString:call.method]) {
        NSDictionary *superProperties = [TDAnalytics getSuperPropertiesWithAppId:[arguments objectForKey:@"appId"]];
        result(superProperties);
    } else if ([@"unsetSuperProperty" isEqualToString:call.method]) {
        [TDAnalytics unsetSuperProperty:[arguments objectForKey:@"property"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"clearSuperProperties" isEqualToString:call.method]) {
        [TDAnalytics clearSuperPropertiesWithAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"getPresetProperties" isEqualToString:call.method]) {
        NSDictionary *presetProperties = [[TDAnalytics getPresetPropertiesWithAppId:[arguments objectForKey:@"appId"]] toEventPresetProperties];
        result(presetProperties);
    } else if ([@"flush" isEqualToString:call.method]) {
        [TDAnalytics flushWithAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"getDistinctId" isEqualToString:call.method]) {
        NSString *distinctId = [TDAnalytics getDistinctIdWithAppId:[arguments objectForKey:@"appId"]];
        result(distinctId);
    }else if ([@"getAccountId" isEqualToString:call.method]) {
        NSString *accountId = [TDAnalytics getAccountIdWithAppId:[arguments objectForKey:@"appId"]];
        result(accountId);
    }else if ([@"getDeviceId" isEqualToString:call.method]) {
        NSString *deviceId = [TDAnalytics getDeviceId];
        result(deviceId);
    } else if ([@"timeEvent" isEqualToString:call.method]) {
        [TDAnalytics timeEvent:[arguments objectForKey:@"eventName"] withAppId:[arguments objectForKey:@"appId"]];
        result(nil);
    } else if ([@"optOutTracking" isEqualToString:call.method]) {
        [TDAnalytics setTrackStatus:TDTrackStatusStop];
        result(nil);
    } else if ([@"optInTracking" isEqualToString:call.method]) {
        [TDAnalytics setTrackStatus:TDTrackStatusNormal];
        result(nil);
    } else if ([@"enableTracking" isEqualToString:call.method]) {
        if([arguments objectForKey:@"enabled"]){
            [TDAnalytics setTrackStatus:TDTrackStatusNormal];
        }else{
            [TDAnalytics setTrackStatus:TDTrackStatusPause];
        }
        result(nil);
    } else if ([@"createLightInstance" isEqualToString:call.method]) {
//        ThinkingAnalyticsSDK *lightInstance = [[ThinkingAnalyticsSDK sharedInstanceWithAppid:[arguments objectForKey:@"appId"]] createLightInstance];
//        NSString *uuid = [[NSUUID UUID] UUIDString];
//        if (!self.lightInstanceDic) {
//            self.lightInstanceDic = [NSMutableDictionary dictionary];
//        }
//        [self.lightInstanceDic setValue:lightInstance forKey:uuid];
        NSString *uuid = [TDAnalytics lightInstanceIdWithAppId:[arguments objectForKey:@"appId"]];
        result(uuid);
    } else if ([@"enableLog" isEqualToString:call.method]) {
        if ([arguments objectForKey:@"enable"]) {
            NSNumber *enableNumber = [arguments objectForKey:@"enable"];
            BOOL enable = NO;
            if (enableNumber) {
                enable = [enableNumber boolValue];
            }
            [TDAnalytics enableLog:enable];
        }
        result(nil);
    } else if ([@"enableAutoTrack" isEqualToString:call.method]) {
        if ([arguments objectForKey:@"types"]) {
            NSArray *autoTrackTypes = [arguments objectForKey:@"types"];
            TDAutoTrackEventType iOSAutoTrackType = TDAutoTrackEventTypeNone;
            for(int i=0; i < autoTrackTypes.count; i++) {
                NSNumber* value = autoTrackTypes[i];
                if (value.intValue == 0) {
                    iOSAutoTrackType |= TDAutoTrackEventTypeAppStart;
                } else if (value.intValue == 1) {
                    iOSAutoTrackType |= TDAutoTrackEventTypeAppEnd;
                } else if (value.intValue == 2) {
                    iOSAutoTrackType |= TDAutoTrackEventTypeAppInstall;
                } else if (value.intValue == 3) {
                    iOSAutoTrackType |= TDAutoTrackEventTypeAppViewCrash;
                }
            }
            [TDAnalytics enableAutoTrack:iOSAutoTrackType withAppId:[arguments objectForKey:@"appId"]];
        }
        result(nil);
    }else if([@"enableAutoTrackWithProperties" isEqualToString:call.method]){
        if ([arguments objectForKey:@"types"]) {
            NSInteger autoTrackTypes = [[arguments objectForKey:@"types"]intValue];
            NSDictionary* autoProperties = [arguments objectForKey:@"properties"];
            [TDAnalytics enableAutoTrack:autoTrackTypes properties:autoProperties withAppId:[arguments objectForKey:@"appId"]];
        }
    }else if([@"setAutoTrackProperties" isEqualToString:call.method]){
        NSArray *autoTrackTypes = [arguments objectForKey:@"types"];
        TDAutoTrackEventType iOSAutoTrackType = TDAutoTrackEventTypeNone;
        NSDictionary* autoProperties = [arguments objectForKey:@"properties"];
        for(int i=0; i < autoTrackTypes.count; i++) {
            NSNumber* value = autoTrackTypes[i];
            if (value.intValue == 0) {
                iOSAutoTrackType |= TDAutoTrackEventTypeAppStart;
            } else if (value.intValue == 1) {
                iOSAutoTrackType |= TDAutoTrackEventTypeAppEnd;
            } else if (value.intValue == 2) {
                iOSAutoTrackType |= TDAutoTrackEventTypeAppInstall;
            } else if (value.intValue == 3) {
                iOSAutoTrackType |= TDAutoTrackEventTypeAppViewCrash;
            }
        }
        [TDAnalytics setAutoTrackProperties:iOSAutoTrackType properties:autoProperties withAppId:[arguments objectForKey:@"appId"]];
    }else if ([@"calibrateTime" isEqualToString:call.method]) {
        [TDAnalytics calibrateTime:[[arguments objectForKey:@"timestamp"] doubleValue]];
    } else if ([@"calibrateTimeWithNtp" isEqualToString:call.method]) {
        [TDAnalytics calibrateTimeWithNtp:[arguments objectForKey:@"ntpServer"]];
    }else if ([@"setTrackStatus" isEqualToString:call.method]){
        if([arguments objectForKey:@"status"]){
            NSNumber *status = [arguments objectForKey:@"status"];
            if(status.intValue == 0){
                [TDAnalytics setTrackStatus:TDTrackStatusPause];
            }else if(status.intValue == 1){
                [TDAnalytics setTrackStatus:TDTrackStatusStop];
            }else if(status.intValue == 2){
                [TDAnalytics setTrackStatus:TDTrackStatusSaveOnly];
            }else if(status.intValue == 3){
                [TDAnalytics setTrackStatus:TDTrackStatusNormal];
            }
        }
    }else if([@"enableThirdPartySharing" isEqualToString:call.method]){
        if([arguments objectForKey:@"types"]){
            NSArray *shareTypes = [arguments objectForKey:@"types"];
            TDThirdPartyType types = TDThirdPartyTypeNone;
            for(int i = 0;i<shareTypes.count;i++){
                NSNumber* value = shareTypes[i];
                if(value.intValue == 0){
                    types |= TDThirdPartyTypeAppsFlyer;
                }else if(value.intValue == 1){
                    types |= TDThirdPartyTypeIronSource;
                }else if(value.intValue == 2){
                    types |= TDThirdPartyTypeAdjust;
                }else if(value.intValue == 3){
                    types |= TDThirdPartyTypeBranch;
                }else if(value.intValue == 4){
                    types |= TDThirdPartyTypeTopOn;
                }else if(value.intValue == 5){
                    types |= TDThirdPartyTypeTracking;
                }else if(value.intValue == 6){
                    types |= TDThirdPartyTypeTradPlus;
                }
            }
            [TDAnalytics enableThirdPartySharing:types withAppId:[arguments objectForKey:@"appId"]];
        }else if([arguments objectForKey:@"type"]){
            NSNumber* type = [arguments objectForKey:@"type"];
            NSDictionary* params = [arguments objectForKey:@"params"];
            TDThirdPartyType t = TDThirdPartyTypeNone;
            if(type.intValue == 0){
                t = TDThirdPartyTypeAppsFlyer;
            }else if(type.intValue == 1){
                t = TDThirdPartyTypeIronSource;
            }else if(type.intValue == 2){
                t = TDThirdPartyTypeAdjust;
            }else if(type.intValue == 3){
                t = TDThirdPartyTypeBranch;
            }else if(type.intValue == 4){
                t = TDThirdPartyTypeTopOn;
            }else if(type.intValue == 5){
                t = TDThirdPartyTypeTracking;
            }else if(type.intValue == 6){
                t = TDThirdPartyTypeTradPlus;
            }
            [TDAnalytics enableThirdPartySharing:t properties:params withAppId:[arguments objectForKey:@"appId"]];
        }
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)track:(NSDictionary*)arguments {
    NSTimeZone *timezone = [arguments objectForKey:@"timeZone"] ? [NSTimeZone timeZoneWithName:[arguments objectForKey:@"timeZone"]] : nil;
    if (timezone && [arguments objectForKey:@"timestamp"]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[arguments objectForKey:@"timestamp"] doubleValue] / 1000];
        [TDAnalytics track:[arguments objectForKey:@"eventName"] properties:[arguments objectForKey:@"properties"] time:date timeZone:timezone withAppId:[arguments objectForKey:@"appId"]];
    } else {
        [TDAnalytics track:[arguments objectForKey:@"eventName"] properties:[arguments objectForKey:@"properties"] withAppId:[arguments objectForKey:@"appId"]];
    }
}

//- (ThinkingAnalyticsSDK *)getThinkingAnalyticsSDK:(NSString *)appid {
//    @synchronized (self.lightInstanceDic) {
//        if ([self.lightInstanceDic objectForKey:appid]) {
//            return [self.lightInstanceDic objectForKey:appid];
//        }
//    }
//    return [ThinkingAnalyticsSDK sharedInstanceWithAppid:appid];
//}

@end
