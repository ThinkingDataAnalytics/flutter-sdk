#import "TDDemoPlugin.h"
#import <ThinkingSDK/ThinkingSDK.h>
#import <ThinkingDataCore/ThinkingDataCore.h>

@interface TestLogConsumer : NSObject<TDLogChannleProtocol>
@property (nonatomic, copy) FlutterEventSink eventSink;
@end

@implementation TestLogConsumer

- (void)printMessage:(NSString *)message type:(TDLogType)type {
    if (self.eventSink) {
        self.eventSink(message);
    }
}
@end



@interface TDDemoPlugin() <FlutterStreamHandler>
//@property (nonatomic, strong) FlutterEventSink eventSink;
@end

@implementation TDDemoPlugin


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"thinkingdata.cn/demo"
                                     binaryMessenger:[registrar messenger]];
    TDDemoPlugin* instance = [[TDDemoPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* eventChannel = [FlutterEventChannel
                                             eventChannelWithName:@"thinkingdata.cn/demo/event"
                                             binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary* arguments = (NSDictionary *)call.arguments;
    if ([@"clearDisk" isEqualToString:call.method]) {
        BOOL result1 = YES;

        NSError *error = nil;
        
        // 清空 user default
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [userDefaults dictionaryRepresentation];
        for (id key in dic) {
            [userDefaults removeObjectForKey:key];
        }
        
        // 删除 Documents 里所有文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSArray *documentItems = [fileManager contentsOfDirectoryAtPath:documentPath error:&error];
        if (error) {
            NSLog(@"获取 documentPath 目录内容出错：%@", error.description);
            result1 = NO;
        }
        for (NSString *itemPath in documentItems) {
            if ([itemPath hasPrefix:@"."]) {
                // 过滤隐藏文件
                continue;
            }
            [fileManager removeItemAtPath:[NSString pathWithComponents:@[documentPath, itemPath]] error:&error];
            if (error) {
                NSLog(@"删除 documentPath 目录中的内容出错：%@", error.description);
                result1 = NO;
            }
        }
        
        // 删除 Library 里所有文件
        NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        NSArray *libraryItems = [fileManager contentsOfDirectoryAtPath:libraryPath error:&error];
        if (error) {
            NSLog(@"获取 libraryPath 目录内容出错：%@", error.description);
            result1 = NO;
        }
        for (NSString *itemPath in libraryItems) {
            // HTTPStorages 被删除，有可能会影响到 WSocket 的连接
            if ([itemPath hasPrefix:@"."] || [itemPath isEqualToString:@"HTTPStorages"] || [itemPath isEqualToString:@"Caches"] || [itemPath isEqualToString:@"Preferences"]) {
                // 过滤隐藏文件
                continue;
            }
            [fileManager removeItemAtPath:[NSString pathWithComponents:@[libraryPath, itemPath]] error:&error];
            if (error) {
                NSLog(@"删除 libraryPath 目录中的内容出错：%@", error.description);
                result1 = NO;
            }
        }
        
        result(@(result1));

    }else if ([@"setLogListener" isEqualToString:call.method]) {
        NSLog(@"=======1234");
    }
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events {
//    self.eventSink = events;
    TestLogConsumer *consumer = [[TestLogConsumer alloc] init];
    consumer.eventSink = events;
    [TDOSLog addLogConsumer:consumer];
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
//    self.eventSink = nil;
    return nil;
}

@end


