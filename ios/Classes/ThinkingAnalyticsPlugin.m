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
        if([arguments objectForKey:@"enableEncrypt"]){
            NSNumber* enableEncrypt = [arguments objectForKey:@"enableEncrypt"];
            config.enableEncrypt = enableEncrypt.boolValue;
        }
        if([arguments objectForKey:@"secretKey"]){
            NSDictionary *secretKey = (NSDictionary *)[arguments objectForKey:@"secretKey"];
            NSNumber* keyVersion = [secretKey objectForKey:@"version"];
            config.secretKey = [[TDSecretKey alloc] initWithVersion:keyVersion.intValue publicKey:[secretKey objectForKey:@"publicKey"] asymmetricEncryption:[secretKey objectForKey:@"asymmetricEncryption"] symmetricEncryption:[secretKey objectForKey:@"symmetricEncryption"]];
        }
        NSString *appId = [arguments objectForKey:@"appId"];
        NSString *serverUrl = [arguments objectForKey:@"serverUrl"];
        NSString *version = [arguments objectForKey:@"lib_version"];
        [ThinkingAnalyticsSDK startWithAppId:appId
                                     withUrl:serverUrl
                                  withConfig:config];
        
        [ThinkingAnalyticsSDK setCustomerLibInfoWithLibName:@"Flutter" libVersion:version];
        
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
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] trackWithEventModel:eventModel];
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
    }else if ([@"userUniqAppend" isEqualToString:call.method]){
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_uniqAppend:[arguments objectForKey:@"properties"]];
        result(nil);
    }else if ([@"userUnset" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_unset:[arguments objectForKey:@"property"]];
        result(nil);
    } else if ([@"userDelete" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] user_delete];
        result(nil);
    } else if ([@"setSuperProperties" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] setSuperProperties:[arguments objectForKey:@"properties"]];
        result(nil);
    } else if ([@"getSuperProperties" isEqualToString:call.method]) {
        NSDictionary *superProperties = [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] currentSuperProperties];
        result(superProperties);
    } else if ([@"unsetSuperProperty" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] unsetSuperProperty:[arguments objectForKey:@"property"]];
        result(nil);
    } else if ([@"clearSuperProperties" isEqualToString:call.method]) {
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] clearSuperProperties];
        result(nil);
    } else if ([@"getPresetProperties" isEqualToString:call.method]) {
        NSDictionary *presetProperties = [[[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] getPresetProperties] toEventPresetProperties];
        result(presetProperties);
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
    }else if([@"setAutoTrackProperties" isEqualToString:call.method]){
        NSArray *autoTrackTypes = [arguments objectForKey:@"types"];
        ThinkingAnalyticsAutoTrackEventType iOSAutoTrackType = ThinkingAnalyticsEventTypeNone;
        NSDictionary* autoProperties = [arguments objectForKey:@"properties"];
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
        [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] setAutoTrackProperties:iOSAutoTrackType properties:autoProperties];
    }else if ([@"calibrateTime" isEqualToString:call.method]) {
        [ThinkingAnalyticsSDK calibrateTime:[[arguments objectForKey:@"timestamp"] doubleValue]];
    } else if ([@"calibrateTimeWithNtp" isEqualToString:call.method]) {
        [ThinkingAnalyticsSDK calibrateTimeWithNtp:[arguments objectForKey:@"ntpServer"]];
    }else if ([@"setTrackStatus" isEqualToString:call.method]){
        if([arguments objectForKey:@"status"]){
            NSNumber *status = [arguments objectForKey:@"status"];
            if(status.intValue == 0){
                [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] setTrackStatus: TATrackStatusPause];
            }else if(status.intValue == 1){
                [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] setTrackStatus: TATrackStatusStop];
            }else if(status.intValue == 2){
                [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] setTrackStatus: TATrackStatusSaveOnly];
            }else if(status.intValue == 3){
                [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] setTrackStatus: TATrackStatusNormal];
            }
        }
    }else if([@"enableThirdPartySharing" isEqualToString:call.method]){
        if([arguments objectForKey:@"types"]){
            NSArray *shareTypes = [arguments objectForKey:@"types"];
            TAThirdPartyShareType types = TDThirdPartyShareTypeNONE;
            for(int i = 0;i<shareTypes.count;i++){
                NSNumber* value = shareTypes[i];
                if(value.intValue == 0){
                    types |= TDThirdPartyShareTypeAPPSFLYER;
                }else if(value.intValue == 1){
                    types |= TDThirdPartyShareTypeIRONSOURCE;
                }else if(value.intValue == 2){
                    types |= TDThirdPartyShareTypeADJUST;
                }else if(value.intValue == 3){
                    types |= TDThirdPartyShareTypeBRANCH;
                }else if(value.intValue == 4){
                    types |= TDThirdPartyShareTypeTOPON;
                }else if(value.intValue == 5){
                    types |= TDThirdPartyShareTypeTRACKING;
                }else if(value.intValue == 6){
                    types |= TDThirdPartyShareTypeTRADPLUS;
                }
            }
            [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] enableThirdPartySharing:types];
        }else if([arguments objectForKey:@"type"]){
            NSNumber* type = [arguments objectForKey:@"type"];
            NSDictionary* params = [arguments objectForKey:@"params"];
            TAThirdPartyShareType t = TDThirdPartyShareTypeNONE;
            if(type.intValue == 0){
                t = TDThirdPartyShareTypeAPPSFLYER;
            }else if(type.intValue == 1){
                t = TDThirdPartyShareTypeIRONSOURCE;
            }else if(type.intValue == 2){
                t = TDThirdPartyShareTypeADJUST;
            }else if(type.intValue == 3){
                t = TDThirdPartyShareTypeBRANCH;
            }else if(type.intValue == 4){
                t = TDThirdPartyShareTypeTOPON;
            }else if(type.intValue == 5){
                t = TDThirdPartyShareTypeTRACKING;
            }else if(type.intValue == 6){
                t = TDThirdPartyShareTypeTRADPLUS;
            }
            [[self getThinkingAnalyticsSDK:[arguments objectForKey:@"appId"]] enableThirdPartySharing:t customMap:params];
        }
    }else {
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
