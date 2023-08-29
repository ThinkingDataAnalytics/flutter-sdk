import 'package:flutter/material.dart';
import 'package:thinking_analytics/td_analytics.dart';

class MultiInstancePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MultiInstancePage> {
  static const String APP_ID = "1b1c1fef65e3482bad5c9d0e6a823356";

  @override
  void initState() {
    super.initState();
    initThinkingDataSDK();
  }

  Future<void> initThinkingDataSDK() async {
    if (!mounted) return;
    TDAnalytics.init(APP_ID, "https://receiver.ta.thinkingdata.cn");
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
                      '三方数据',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () => enableThirdParty())),
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
          ],
        ),
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("多实例测试"),
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
    );
  }

  /// 自动采集
  void enableAutoTrack() {
    TDAnalytics.enableAutoTrack(
        TDAutoTrackEventType.APP_START |
            TDAutoTrackEventType.APP_END |
            TDAutoTrackEventType.APP_INSTALL |
            TDAutoTrackEventType.APP_CRASH,
        appId: APP_ID);
  }

  ///自动采集+参数
  void enableAutoTrackAndProperties() {
    TDAnalytics.enableAutoTrack(TDAutoTrackEventType.APP_START,
        autoTrackEventProperties: {"auto_name": "jack", "auto_age": 19},
        appId: APP_ID);
  }

  ///发送测试事件
  void trackTestEvent() {
    TDAnalytics.track("test_event_111",
        properties: {
          'PROP_INT': 5678,
          'PROP_DOUBLE': 12.3,
          'PROP_DATE': DateTime.now().toUtc(),
          'PROP_LIST': ['apple', 'ball', 1234],
          'PROP_BOOL': false,
          'PROP_STRING': 'flutter test',
        },
        appId: APP_ID);
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
    TDAnalytics.trackEventModel(model, appId: APP_ID);
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
    TDAnalytics.trackEventModel(model, appId: APP_ID);
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
    TDAnalytics.trackEventModel(model, appId: APP_ID);
  }

  ///事件计时
  void timeEvent() {
    TDAnalytics.timeEvent("test_event_111", appId: APP_ID);
  }

  void userSet() {
    TDAnalytics.userSet({'user_name': 'TA'}, appId: APP_ID);
  }

  void userSetOnce() {
    TDAnalytics.userSetOnce({'first_payment_time': '2018-01-01 01:23:45.678'},
        appId: APP_ID);
  }

  void userUnset() {
    TDAnalytics.userUnset("USER_INT", appId: APP_ID);
  }

  void userAdd() {
    TDAnalytics.userAdd({'total_revenue': 30}, appId: APP_ID);
  }

  void userAppend() {
    TDAnalytics.userAppend({
      'USER_LIST': ['apple', 'ball'],
    }, appId: APP_ID);
  }

  void userUniqAppend() {
    TDAnalytics.userUniqAppend({
      'user_list': ['apple', 'ball']
    }, appId: APP_ID);
  }

  void userDelete() {
    TDAnalytics.userDelete(appId: APP_ID);
  }

  void setSuperProperties() {
    TDAnalytics.setSuperProperties({'vip_level': 2, "super_leve": 99},
        appId: APP_ID);
  }

  void setDynamicProperties() {
    TDAnalytics.setDynamicSuperProperties(() {
      return {
        'DYNAMIC_DATE': DateTime.now().toUtc(),
      };
    }, appId: APP_ID);
  }

  void clearOneProperties() {
    TDAnalytics.unsetSuperProperty("vip_level", appId: APP_ID);
  }

  void clearAllSuperProperties() {
    TDAnalytics.clearSuperProperties(appId: APP_ID);
  }

  void getSuperProperties() async {
    var map = await TDAnalytics.getSuperProperties(appId: APP_ID);
    print("ThinkingAnalytics: " + map.toString());
  }

  void getPresetProperties() async {
    var map = await TDAnalytics.getPresetProperties(appId: APP_ID);
    print("ThinkingAnalytics: " + map.toString());
  }

  void login() {
    TDAnalytics.login("llb_123", appId: APP_ID);
    TDAnalytics.track("sign_up", appId: APP_ID);
  }

  void logout() {
    TDAnalytics.logout(appId: APP_ID);
    TDAnalytics.track("sign_out", appId: APP_ID);
  }

  void setDistinctId() {
    TDAnalytics.setDistinctId("identify_123", appId: APP_ID);
    TDAnalytics.track("sign_in", appId: APP_ID);
  }

  void getDistinctId() async {
    String? distinctId = await TDAnalytics.getDistinctId(appId: APP_ID);
    print("ThinkingAnalytics: " + distinctId.toString());
  }

  void getDeviceId() async {
    String? deviceId = await TDAnalytics.getDeviceId(appId: APP_ID);
    print("ThinkingAnalytics: " + deviceId.toString());
  }

  void flush1() {
    TDAnalytics.flush(appId: APP_ID);
  }

  void setTrackStatus1(TDTrackStatus status) {
    TDAnalytics.setTrackStatus(status, appId: APP_ID);
  }

  void enableThirdParty() {
    TDAnalytics.enableThirdPartySharing(
        TDThirdPartyType.APPS_FLYER |
            TDThirdPartyType.ADJUST |
            TDThirdPartyType.BRANCH |
            TDThirdPartyType.IRON_SOURCE |
            TDThirdPartyType.TOP_ON |
            TDThirdPartyType.TRACKING |
            TDThirdPartyType.TRAD_PLUS,
        appId: APP_ID);
  }
}
