import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { TDAnalytics, TDConfig, TDMode } from '@thinkingdata/analytics';
import { common } from '@kit.AbilityKit';
import { TDFlutterUtils } from "./TDFlutterUtils";

export default class ThinkingAnalyticsPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private context: Context | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "ThinkingAnalyticsFlutterPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "thinkingdata.cn/ThinkingAnalytics");
    this.channel.setMethodCallHandler(this)
    this.context = getContext(this) as common.UIAbilityContext ?? binding.getApplicationContext();
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "enableLog") {
      let enable: boolean = call.argument("enable")
      TDAnalytics.enableLog(enable)
      result.success(null)
    } else if (call.method == "getInstance") {
      let config: TDConfig = new TDConfig()
      config.appId = call.argument("appId")
      config.serverUrl = call.argument("serverUrl")
      let mode: number = call.argument("mode")
      if (mode == 1) {
        config.mode = TDMode.DEBUG
      } else if (mode == 2) {
        config.mode = TDMode.DEBUG_ONLY
      }
      if (call.hasArgument("lib_version")) {
        TDAnalytics.setCustomerLibInfo("Flutter", call.argument("lib_version"))
      }
      if (call.hasArgument("secretKey")) {
        let secretKey: object = call.argument("secretKey")
        config.enableEncrypt(secretKey["version"], secretKey["publicKey"])
      }
      TDAnalytics.initWithConfig(this.context, config)
      result.success(null)
    } else if (call.method == "calibrateTime") {
      TDAnalytics.calibrateTime(call.argument("timestamp"))
      result.success(null)
    } else if (call.method == "calibrateTimeWithNtp") {
      result.success(null)
    } else if (call.method == "track") {
      let eventName: string = call.argument("eventName")
      let properties: object = call.argument("properties")
      TDAnalytics.track({
        eventName: eventName,
        properties: TDFlutterUtils.convertMapToJsonObject(properties),
      }, call.argument("appId"))
      result.success(null)
    } else if (call.method == "trackEventModel") {
      let eventType: string = call.argument("eventType")
      let appId: string = call.argument("appId")
      let eventName: string = call.argument("eventName")
      let properties = TDFlutterUtils.convertMapToJsonObject(call.argument("properties"))
      let extraID: string = call.argument("extraID")
      if (eventType == "track_first") {
        TDAnalytics.trackFirst({
          eventName: eventName,
          properties: properties,
          firstCheckId: extraID
        }, appId)
      } else if (eventType == "track_update") {
        TDAnalytics.trackUpdate({
          eventName: eventName,
          properties: properties,
          eventId: extraID
        }, appId)
      } else if (eventType == "track_overwrite") {
        TDAnalytics.trackOverwrite({
          eventName: eventName,
          properties: properties,
          eventId: extraID
        }, appId)
      }
      result.success(null)
    } else if (call.method == "timeEvent") {
      TDAnalytics.timeEvent(call.argument("eventName"), call.argument("appId"))
      result.success(null)
    } else if (call.method == "userSet") {
      let properties: object = call.argument("properties")
      TDAnalytics.userSet({
        properties: TDFlutterUtils.convertMapToJsonObject(properties)
      }, call.argument("appId"))
      result.success(null)
    } else if (call.method == "userSetOnce") {
      let properties: object = call.argument("properties")
      TDAnalytics.userSetOnce({
        properties: TDFlutterUtils.convertMapToJsonObject(properties)
      }, call.argument("appId"))
      result.success(null)
    } else if (call.method == "userAdd") {
      let properties: object = call.argument("properties")
      TDAnalytics.userAdd({
        properties: TDFlutterUtils.convertMapToJsonObject(properties)
      }, call.argument("appId"))
      result.success(null)
    } else if (call.method == "userAppend") {
      let properties: object = call.argument("properties")
      TDAnalytics.userAppend({
        properties: TDFlutterUtils.convertMapToJsonObject(properties)
      }, call.argument("appId"))
      result.success(null)
    } else if (call.method == "userUniqAppend") {
      let properties:object = call.argument("properties")
      TDAnalytics.userUniqAppend({
        properties: TDFlutterUtils.convertMapToJsonObject(properties)
      }, call.argument("appId"))
      result.success(null)
    } else if (call.method == "userUnset") {
      let property: string = call.argument("property")
      TDAnalytics.userUnset({
        property: property
      }, call.argument("appId"))
      result.success(null)
    } else if (call.method == "userDelete") {
      TDAnalytics.userDelete(call.argument("appId"))
      result.success(null)
    } else if (call.method == "setSuperProperties") {
      let properties:object = call.argument("properties")
      TDAnalytics.setSuperProperties(TDFlutterUtils.convertMapToJsonObject(properties), call.argument("appId"))
      result.success(null)
    } else if (call.method == "getSuperProperties") {
      let str: string = TDAnalytics.getSuperProperties(call.argument("appId"))
      result.success(JSON.parse(str));
    } else if (call.method == "clearSuperProperties") {
      TDAnalytics.clearSuperProperties(call.argument("appId"))
      result.success(null)
    } else if (call.method == "unsetSuperProperty") {
      let property: string = call.argument("property")
      TDAnalytics.unsetSuperProperty(property, call.argument("appId"))
      result.success(null)
    } else if (call.method == "getPresetProperties") {
      let str:string = TDAnalytics.getPresetProperties(call.argument("appId"))
      result.success(JSON.parse(str))
    } else if (call.method == "flush") {
      TDAnalytics.flush(call.argument("appId"))
      result.success(null)
    } else if (call.method == "login") {
      let accountId: string = call.argument("accountId")
      TDAnalytics.login(accountId, call.argument("appId"))
      result.success(null)
    } else if (call.method == "logout") {
      TDAnalytics.logout(call.argument("appId"))
      result.success(null)
    } else if (call.method == "identify") {
      let distinctId: string = call.argument("distinctId")
      TDAnalytics.setDistinctId(distinctId, call.argument("appId"))
      result.success(null)
    } else if (call.method == "getDistinctId") {
      result.success(TDAnalytics.getDistinctId(call.argument("appId")))
    } else if (call.method == "getAccountId") {
      result.success(TDAnalytics.getAccountId(call.argument("appId")))
    } else if (call.method == "getDeviceId") {
      result.success(TDAnalytics.getDeviceId(call.argument("appId")))
    } else if (call.method == "enableAutoTrack") {
      let types: number = call.argument("types")
      TDAnalytics.enableAutoTrack(this.context, types, null, call.argument("appId"))
      result.success(null)
    } else if (call.method == "enableAutoTrackWithProperties") {
      let types: number = call.argument("types")
      let properties:object = call.argument("properties")
      if(properties){
        TDAnalytics.enableAutoTrackProperties(this.context, types, TDFlutterUtils.convertMapToJsonObject(properties), null,
            call.argument("appId"))
      }else{
        TDAnalytics.enableAutoTrack(this.context,types)
      }
      result.success(null)
    } else {
      result.notImplemented()
    }
  }
}