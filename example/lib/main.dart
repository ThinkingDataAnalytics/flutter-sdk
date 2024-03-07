import 'package:flutter/material.dart';
import 'dart:async';

import 'package:thinking_analytics/thinking_analytics.dart';
import 'package:thinking_analytics/td_analytics.dart';
import 'package:ta_flutter_plugin_example/multi.dart';

void main() => runApp(new MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initThinkingDataSDK();
  }

  Future<void> initThinkingDataSDK() async {
    if (!mounted) return;
    TDAnalytics.enableLog(true);
    TDConfig config = TDConfig();
    config.appId = "40eddce753cd4bef9883a01e168c3df0";
    config.serverUrl = "https://receiver-ta-preview.thinkingdata.cn";
    config.setMode(TDMode.NORMAL);
    config.enableEncrypt(1,
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAti6FnWGv7Lggzg\\/R8hQa\\n4GEtd2ucfntqo6Xkf1sPwCIfndr2u6KGPhWQ24bFUKgtNLDuKnUAg1C\\/OEEL8uON\\nJBdbX9XpckO67tRPSPrY3ufNIxsCJ9td557XxUsnebkOZ+oC1Duk8\\/ENx1pRvU6S\\n4c+UYd6PH8wxw1agD61oJ0ju3CW0aZNZ2xKcWBcIU9KgYTeUtawrmGU5flod88Cq\\nZc8VKB1+nY0tav023jvxwkM3zgQ6vBWIU9\\/aViGECB98YEzJfZjcOTD6zvqsZc\\/W\\nRnUNhBHFPGEwc8ueMvzZNI+FP0pUFLVRwVoYbj\\/tffKbxGExaRFIcgP73BIW6\\/6n\\nQwIDAQAB");
    TDAnalytics.initWithConfig(config);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '自动采集',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => enableAutoTrack())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '自动采集+参数',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => enableAutoTrackAndProperties())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '时间校准',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => calibratedTime())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '测试事件',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => trackTestEvent())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '首次事件',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => trackFirstEvent())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '可更新事件',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => trackUpdateEvent())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '可重写事件',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => trackOverwriteEvent())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '事件计时',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => timeEvent())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'userSet',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => userSet())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'userSetOnce',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => userSetOnce())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'userUnset',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => userUnset())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'userAdd',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => userAdd())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'userAppend',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => userAppend())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'userUniqAppend',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => userUniqAppend())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'userDelete',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => userDelete())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '静态公共属性',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => setSuperProperties())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '动态公共属性',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => setDynamicProperties())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '清除一个属性',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => clearOneProperties())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '清除所有公共属性',
                      style: TextStyle(fontSize: 8),
                    ),
                    onPressed: () => clearAllSuperProperties())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '获取公共属性',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => getSuperProperties())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '获取预置属性',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => getPresetProperties())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '登录',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => login())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '登出',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => logout())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '设置访客',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => setDistinctId())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '获取访客',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => getDistinctId())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '获取设备号',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => getDeviceId())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'flush',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => flush1())),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'normal',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => setTrackStatus1(TDTrackStatus.NORMAL))),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'pause',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => setTrackStatus1(TDTrackStatus.PAUSE))),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'stop',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => setTrackStatus1(TDTrackStatus.STOP))),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      'saveOnly',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => setTrackStatus1(TDTrackStatus.SAVE_ONLY))),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '三方数据',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => enableThirdParty())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '多实例',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MultiInstancePage();
                      }));
                    })),
          ],
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '创建轻实例',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => lightInstance())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '轻实例发送事件',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => trackLightEvent())),
            Expanded(
                child: OutlinedButton(
                    child: Text(
                      '轻实例用户属性',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () {
                      trackLightUserSet();
                    })),
          ],
        ),
      )
    ];

    return MaterialApp(
      theme: ThemeData(
          //buttonTheme: ButtonThemeData(minWidth: double.infinity),
          ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('单实例测试'),
        ),
        body: Container(
            child: new CustomScrollView(shrinkWrap: true, slivers: <Widget>[
          new SliverPadding(
            padding: const EdgeInsets.all(2.0),
            sliver: new SliverList(
              delegate: new SliverChildListDelegate(
                buttons,
              ),
            ),
          ),
        ])),
      ),
    );
  }

  /// 自动采集
  void enableAutoTrack() {
    TDAnalytics.enableAutoTrack(TDAutoTrackEventType.APP_START |
        TDAutoTrackEventType.APP_END |
        TDAutoTrackEventType.APP_INSTALL |
        TDAutoTrackEventType.APP_CRASH);
  }

  ///自动采集+参数
  void enableAutoTrackAndProperties() {
    TDAnalytics.enableAutoTrack(
        TDAutoTrackEventType.APP_START | TDAutoTrackEventType.APP_END,
        autoTrackEventProperties: {"auto_name": "jack", "auto_age": 19});
  }

  ///时间校准
  void calibratedTime() {
    TDAnalytics.calibrateTime(1688019937000);
  }

  ///发送测试事件
  void trackTestEvent() {
    TDAnalytics.track("test_event_111", properties: {
      'PROP_INT': 5678,
      'PROP_DOUBLE': 12.3,
      'PROP_DATE': DateTime.now().toUtc(),
      'PROP_LIST': ['apple', 'ball', 1234],
      'PROP_BOOL': false,
      'PROP_STRING': 'flutter test',
    });
    // TDAnalytics.track("test_event_111",
    //     properties: {
    //       'PROP_INT': 5678,
    //       'PROP_DOUBLE': 12.3,
    //       'PROP_DATE': DateTime.now().toUtc(),
    //       'PROP_LIST': ['apple', 'ball', 1234],
    //       'PROP_BOOL': false,
    //       'PROP_STRING': 'flutter test',
    //     },
    //     dateTime: DateTime.fromMillisecondsSinceEpoch(1688019937000),
    //     timeZone: "GMT+00:00");
  }

  ///发送首次事件
  void trackFirstEvent() {
    var properties = {
      'PROP_INT': 5678,
      'PROP_DOUBLE': 12.3,
      'PROP_DATE': DateTime.now().toUtc(),
      'PROP_LIST': ['apple', 'ball', 1234],
      'PROP_BOOL': false,
      'PROP_STRING': 'flutter test',
    };
    TDFirstEventModel model =
        TDFirstEventModel("fist_event", "f_1233", properties);
    TDAnalytics.trackEventModel(model);
  }

  ///发送可更新事件
  void trackUpdateEvent() {
    var properties = {
      'PROP_INT': 5678,
      'PROP_DOUBLE': 12.3,
      'PROP_DATE': DateTime.now().toUtc(),
      'PROP_LIST': ['apple', 'ball', 1234],
      'PROP_BOOL': false,
      'PROP_STRING': 'flutter test',
    };
    TDUpdatableEventModel model =
        TDUpdatableEventModel("update_event", "event_id_123", properties);
    TDAnalytics.trackEventModel(model);
  }

  ///发送可重写事件
  void trackOverwriteEvent() {
    var properties = {
      'PROP_INT': 5678,
      'PROP_DOUBLE': 12.3,
      'PROP_DATE': DateTime.now().toUtc(),
      'PROP_LIST': ['apple', 'ball', 1234],
      'PROP_BOOL': false,
      'PROP_STRING': 'flutter test',
      'PROP_EDIT_KEY': 'PROP_EDIT_VALUE_UPDATE',
      'PROP_EDIT_KEY2': 'PROP_EDIT_VALUE_UPDATE2',
    };
    TDOverWritableEventModel model =
        TDOverWritableEventModel("overwrite_event", "event_id_110", properties);
    TDAnalytics.trackEventModel(model);
  }

  ///事件计时
  void timeEvent() {
    TDAnalytics.timeEvent("test_event_111");
  }

  void userSet() {
    TDAnalytics.userSet({'user_name': 'TA'});
  }

  void userSetOnce() {
    TDAnalytics.userSetOnce({'first_payment_time': '2018-01-01 01:23:45.678'});
  }

  void userUnset() {
    TDAnalytics.userUnset("USER_INT");
  }

  void userAdd() {
    TDAnalytics.userAdd({'total_revenue': 30});
  }

  void userAppend() {
    TDAnalytics.userAppend({
      'USER_LIST': ['apple', 'ball'],
    });
  }

  void userUniqAppend() {
    TDAnalytics.userUniqAppend({
      'user_list': ['apple', 'ball']
    });
  }

  void userDelete() {
    TDAnalytics.userDelete();
  }

  void setSuperProperties() {
    TDAnalytics.setSuperProperties({'vip_level': 21, "super_level": 991});
  }

  void setDynamicProperties() {
    TDAnalytics.setDynamicSuperProperties(() {
      return {
        'DYNAMIC_DATE': DateTime.now().toUtc(),
      };
    });
  }

  void clearOneProperties() {
    TDAnalytics.unsetSuperProperty("vip_level");
  }

  void clearAllSuperProperties() {
    TDAnalytics.clearSuperProperties();
  }

  void getSuperProperties() async {
    var map = await TDAnalytics.getSuperProperties();
    print("ThinkingAnalytics: " + map.toString());
  }

  void getPresetProperties() async {
    var map = await TDAnalytics.getPresetProperties();
    print("ThinkingAnalytics: " + map.toString());
  }

  void login() {
    TDAnalytics.login("llb_1234");
    TDAnalytics.track("sign_up");
  }

  void logout() {
    TDAnalytics.logout();
    TDAnalytics.track("sign_out");
  }

  void setDistinctId() {
    TDAnalytics.setDistinctId("identify_123");
    TDAnalytics.track("sign_in");
  }

  void getDistinctId() async {
    String? distinctId = await TDAnalytics.getDistinctId();
    print("ThinkingAnalytics: " + distinctId.toString());
  }

  void getDeviceId() async {
    String? deviceId = await TDAnalytics.getDeviceId();
    print("ThinkingAnalytics: " + deviceId.toString());
  }

  void flush1() {
    TDAnalytics.flush();
  }

  void setTrackStatus1(TDTrackStatus status) {
    TDAnalytics.setTrackStatus(status);
  }

  void enableThirdParty() {
    TDAnalytics.enableThirdPartySharing(TDThirdPartyType.APPS_FLYER |
        TDThirdPartyType.ADJUST |
        TDThirdPartyType.BRANCH |
        TDThirdPartyType.IRON_SOURCE |
        TDThirdPartyType.TOP_ON |
        TDThirdPartyType.TRACKING |
        TDThirdPartyType.TRAD_PLUS |
        TDThirdPartyType.APPLOVIN_IMPRESSION);
  }

  String? lightAppId;
  void lightInstance() async {
    lightAppId = await TDAnalytics.lightInstance();
  }

  void trackLightEvent() {
    TDAnalytics.track("light_event", appId: lightAppId);
  }

  void trackLightUserSet() {
    TDAnalytics.userSet({"light_name": "mace"}, appId: lightAppId);
  }
}
