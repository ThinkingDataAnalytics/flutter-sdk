import 'package:flutter/material.dart';
import 'dart:async';

import 'package:thinking_analytics/thinking_analytics.dart';

void main() => runApp(new MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum USER_OPERATIONS {
  USER_SET,
  USER_SET_ONCE,
  USER_ADD,
  USER_DEL,
  USER_UNSET,
  USER_APPEND,
  USER_UNIQ_APPEND,
}

enum SUPER_PROPERTY_OPERATIONS { SET, CLEAR, UNSET, GET }

enum INSTANCE_OPERATIONS {
  TRACK,
  TRACK_MODEL,
  LOGIN,
  LOGOUT,
  FLUSH,
  INFO,
}

class _MyAppState extends State<MyApp> {
  late ThinkingAnalyticsAPI _ta;
  late ThinkingAnalyticsAPI _ta2;
  late ThinkingAnalyticsAPI _light;

  @override
  void initState() {
    super.initState();
    initThinkingDataState();
  }

  Future<void> initThinkingDataState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});

    ThinkingAnalyticsAPI.enableLog();

    var sKey = TASecretKey();
    sKey.publicKey =
        "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCzAKEGsq67Yd03/RF77VKJ/cQ3zfSboK1wzlQfH2E1fr504WCJHHL/UVgjfUGUjMLIN15FNEelp7TXLToqtYlqqMbEXCfSc14ulRatKQioYnJ8EzgUhG0HcRlulni6vxGJHR9iq4weDNyJFRaZuwIQSrUzIaiVq/3hYijxxhhFqQIDAQAB";
    sKey.version = 1;
    sKey.symmetricEncryption = "AES";
    sKey.asymmetricEncryption = "RSA";

    _ta = await ThinkingAnalyticsAPI.getInstance(
        '1b1c1fef65e3482bad5c9d0e6a823356',
        'https://receiver.ta.thinkingdata.cn',
        enableEncrypt: true,
        secretKey: sKey);

    _ta.setDynamicSuperProperties(() {
      return <String, dynamic>{
        'DYNAMIC_DATE': DateTime.now().toUtc(),
        'PROP_INT': 8888
      };
    });

    _ta.setSuperProperties(
        <String, dynamic>{'SUPER_START_TIME': DateTime.now()});

    _ta.enableAutoTrack([
      ThinkingAnalyticsAutoTrackType.APP_START,
      ThinkingAnalyticsAutoTrackType.APP_END,
      ThinkingAnalyticsAutoTrackType.APP_INSTALL,
      ThinkingAnalyticsAutoTrackType.APP_CRASH,
    ]);

    _ta.setAutoTrackProperties([
      ThinkingAnalyticsAutoTrackType.APP_START,
    ], {
      'auto_test': 'stu',
      'auto_arr': [1, 2, 3],
      'auto_obj': {'obj_test': 'xxx'}
    });

    _light = await _ta.createLightInstance();
    _light.identify('light_d_id');

    _ta2 = await ThinkingAnalyticsAPI.getInstance(
      '7a055a4bd7ec423fa5294b4a2c1eff28',
      'https://receiver-ta-dev.thinkingdata.cn',
      timeZone: 'UTC',
      mode: ThinkingAnalyticsMode.DEBUG,
    );
    _ta2.identify('ta2_d_id');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      ElevatedButton(
          child: Text('TRACK AN EVENT'), onPressed: () => trackEvent()),
      ElevatedButton(
          child: Text('TRACK DEFAULT_FIRST_CHECK_ID'),
          onPressed: () => trackDefaultFirstCheckID()),
      ElevatedButton(
          child: Text('TRACK FIRST_CHECK_ID'),
          onPressed: () => trackFirstCheckID()),
      ElevatedButton(
          child: Text('TRACK_UPDATE'), onPressed: () => trackUpdate()),
      ElevatedButton(
          child: Text('TRACK_OVERWRITE'), onPressed: () => trackOverwrite()),
      ElevatedButton(
          child: Text('TIME EVENT'),
          onPressed: () => _ta.timeEvent('TEST_EVENT')),
      ElevatedButton(
          child: Text('LOGIN'), onPressed: () => _ta.login('FLUTTER_A_ID')),
      ElevatedButton(child: Text('LOGOUT'), onPressed: () => _ta.logout()),
      ElevatedButton(
          child: Text('SUPER PROPERTIES'),
          onPressed: () => superPropertiesOperations()),
      ElevatedButton(
          child: Text('PRESET PROPERTIES'),
          onPressed: () => presetPropertiesOperations()),
      ElevatedButton(
          child: Text('USER PROPERTIES'), onPressed: () => userOperations()),
      ElevatedButton(
          child: Text('Three-party data access'),
          onPressed: () => enableThirdShare()),
      ElevatedButton(
          child: Text('Stop data tracking'),
          onPressed: () => setTrackStatus(TATrackStatus.PAUSE)),
      ElevatedButton(
          child: Text('Stop data tracing to clear the cache'),
          onPressed: () => setTrackStatus(TATrackStatus.STOP)),
      ElevatedButton(
          child: Text('Stopping Data Reporting'),
          onPressed: () => setTrackStatus(TATrackStatus.SAVE_ONLY)),
      ElevatedButton(
          child: Text('Restore the data reporting status'),
          onPressed: () => setTrackStatus(TATrackStatus.NORMAL)),
      ElevatedButton(child: Text('FLUSH'), onPressed: () => flush()),
      ElevatedButton(
          child: Text('SHOW SDK INFO'), onPressed: () => getSDKInfo(_ta)),
      ElevatedButton(
          child: Text('LIGHT INSTANCE'),
          onPressed: () => instanceOperations(_light, 'light')),
      ElevatedButton(
          child: Text('ANOTHER INSTANCE'),
          onPressed: () => instanceOperations(_ta2, 'another')),
    ];

    return MaterialApp(
      theme: ThemeData(
          //buttonTheme: ButtonThemeData(minWidth: double.infinity),
          ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: new CustomScrollView(shrinkWrap: true, slivers: <Widget>[
          new SliverPadding(
            padding: const EdgeInsets.all(20.0),
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

  Future<void> getSDKInfo(ThinkingAnalyticsAPI instance) async {
    String? distinctId = await instance.getDistinctId();
    String? deviceId = await instance.getDeviceId();

    showDialog(
        context: context,
        builder: (context) {
          return new SimpleDialog(
            title: new Text("SDK Info"),
            children: <Widget>[
              new SimpleDialogOption(
                child: new Text("Distinct ID: " + distinctId!),
              ),
              new SimpleDialogOption(
                child: new Text("Device ID: " + deviceId!),
              ),
            ],
          );
        });
  }

  Future<void> userOperations() async {
    switch (await showDialog<USER_OPERATIONS>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select assignment'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, USER_OPERATIONS.USER_SET);
                },
                child: const Text('USER SET'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, USER_OPERATIONS.USER_SET_ONCE);
                },
                child: const Text('USER SET ONCE'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, USER_OPERATIONS.USER_APPEND);
                },
                child: const Text('USER APPEND'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, USER_OPERATIONS.USER_UNIQ_APPEND);
                },
                child: const Text('USER UNIQ APPEND'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, USER_OPERATIONS.USER_ADD);
                },
                child: const Text('USER ADD'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, USER_OPERATIONS.USER_UNSET);
                },
                child: const Text('USER UNSET'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, USER_OPERATIONS.USER_DEL);
                },
                child: const Text('USER DEL'),
              ),
            ],
          );
        })) {
      case USER_OPERATIONS.USER_SET:
        _ta.userSet(<String, dynamic>{
          'USER_INT': 1,
          'USER_DOUBLE': 50.12,
          'USER_LIST': ['apple', 'ball', 'cat', 1, DateTime.now().toUtc()],
          'USER_BOOL': true,
          'USER_STRING': 'a user value',
          'USER_DATE': DateTime.now(),
        });
        break;
      case USER_OPERATIONS.USER_SET_ONCE:
        _ta.userSetOnce(<String, dynamic>{
          'USER_INT': 2,
          'USER_DOUBLE': 10.12,
        });
        break;
      case USER_OPERATIONS.USER_APPEND:
        _ta.userAppend(<String, List>{
          'USER_LIST': [DateTime.now()],
        });
        break;
      case USER_OPERATIONS.USER_UNIQ_APPEND:
        _ta.userUniqAppend(<String, List>{
          'USER_LIST1': [DateTime.now()],
        });
        break;
      case USER_OPERATIONS.USER_ADD:
        _ta.userAdd(<String, num>{
          'USER_INT': 2,
          'USER_DOUBLE': 10.1,
        });
        break;
      case USER_OPERATIONS.USER_UNSET:
        _ta.userUnset('USER_INT');
        break;
      case USER_OPERATIONS.USER_DEL:
        _ta.userDelete();
        break;
      default:
        break;
    }
  }

  Future<void> superPropertiesOperations() async {
    switch (await showDialog<SUPER_PROPERTY_OPERATIONS>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('SUPER PROPERTIES'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, SUPER_PROPERTY_OPERATIONS.SET);
                },
                child: const Text('SET SUPER PROPERTIES'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, SUPER_PROPERTY_OPERATIONS.CLEAR);
                },
                child: const Text('CLEAR SUPER PROPERTIES'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, SUPER_PROPERTY_OPERATIONS.UNSET);
                },
                child: const Text('UNSET A SUPER PROPERTY'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, SUPER_PROPERTY_OPERATIONS.GET);
                },
                child: const Text('GET SUPER PROPERTIES'),
              ),
            ],
          );
        })) {
      case SUPER_PROPERTY_OPERATIONS.SET:
        Map<String, dynamic> superProperties = {
          'SUPER_STRING': 'super string value',
          'SUPER_INT': 1234,
          'SUPER_DOUBLE': 66.88,
          'SUPER_DATE': DateTime.now(),
          'SUPER_BOOL': true,
          'SUPER_LIST': [1234, 'hello', DateTime.now().toUtc()]
        };

        _ta.setSuperProperties(superProperties);
        break;
      case SUPER_PROPERTY_OPERATIONS.CLEAR:
        _ta.clearSuperProperties();
        break;
      case SUPER_PROPERTY_OPERATIONS.UNSET:
        _ta.unsetSuperProperty('SUPER_LIST');
        break;
      case SUPER_PROPERTY_OPERATIONS.GET:
        var superProperties = await _ta.getSuperProperties();
        print("super properties: " + superProperties.toString());
        break;
      default:
        break;
    }
  }

  Future<void> presetPropertiesOperations() async {
    TDPresetProperties presetProperties = await _ta.getPresetProperties();
    String deviceId = presetProperties.deviceId!;
    print("preset properties: device_id = " + deviceId);
    Map<String, dynamic>? eventPresetProperties =
        presetProperties.toEventPresetProperties();
    print("preset properties: " + eventPresetProperties.toString());
  }

  void trackEvent() {
    _ta.track('TEST_EVENT', properties: <String, dynamic>{
      'PROP_INT': 5678,
      'PROP_DOUBLE': 12.3,
      'PROP_DATE': DateTime.now().toUtc(),
      'PROP_LIST': ['apple', 'ball', 1234],
      'PROP_BOOL': false,
      'PROP_STRING': 'flutter test',
    });
  }

  void trackDefaultFirstCheckID() {
    var properties = {
      'PROP_INT': 5678,
      'PROP_DOUBLE': 12.3,
      'PROP_DATE': DateTime.now().toUtc(),
      'PROP_LIST': ['apple', 'ball', 1234],
      'PROP_BOOL': false,
      'PROP_STRING': 'flutter test',
    };
    var firstModel =
        TrackFirstEventModel('EventName_Flutter_FirstCheckID', '', properties);
    firstModel.dateTime = DateTime.now().toUtc();
    firstModel.timeZone = 'UTC';
    _ta.trackEventModel(firstModel);
  }

  void trackFirstCheckID() {
    var properties = {
      'PROP_INT': 5678,
      'PROP_DOUBLE': 12.3,
      'PROP_DATE': DateTime.now().toUtc(),
      'PROP_LIST': ['apple', 'ball', 1234],
      'PROP_BOOL': false,
      'PROP_STRING': 'flutter test',
    };
    var firstModel = TrackFirstEventModel(
        'EventName_Flutter_FirstCheckID', 'FlutterFirstCheckID', properties);
    firstModel.dateTime = DateTime.now().toUtc();
    firstModel.timeZone = 'UTC';
    _ta.trackEventModel(firstModel);
  }

  void trackUpdate() {
    var properties = {
      'PROP_INT': 5678,
      'PROP_DOUBLE': 12.3,
      'PROP_DATE': DateTime.now().toUtc(),
      'PROP_LIST': ['apple', 'ball', 1234],
      'PROP_BOOL': false,
      'PROP_STRING': 'flutter test',
    };
    var updateModel = TrackUpdateEventModel(
        'EventName_Flutter_FirstCheckID', 'FlutterEditEventID', properties);
    updateModel.dateTime = DateTime.now().toUtc();
    updateModel.timeZone = 'UTC';
    _ta.trackEventModel(updateModel);
  }

  void trackOverwrite() {
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
    var overwriteModel = TrackOverwriteEventModel(
        'EventName_Flutter_FirstCheckID', 'FlutterEditEventID', properties);
    overwriteModel.dateTime = DateTime.now().toUtc();
    overwriteModel.timeZone = 'UTC';
    _ta.trackEventModel(overwriteModel);
  }

  void enableThirdShare() {
    _ta.enableThirdPartySharing([
      TAThirdPartyShareType.TA_APPS_FLYER,
      TAThirdPartyShareType.TA_ADJUST,
      TAThirdPartyShareType.TA_BRANCH,
      TAThirdPartyShareType.TA_IRON_SOURCE,
      TAThirdPartyShareType.TA_TOP_ON,
      TAThirdPartyShareType.TA_TRACKING,
      TAThirdPartyShareType.TA_TRAD_PLUS
    ]);
    // _ta.enableThirdPartySharing(
    //     TAThirdPartyShareType.TA_TRAD_PLUS, {'name': 'jack'});
  }

  void setTrackStatus(TATrackStatus status) {
    _ta.setTrackStatus(status);
  }

  void flush() {
    _ta.flush();
  }

  Future<void> instanceOperations(
      ThinkingAnalyticsAPI instance, String prefix) async {
    switch (await showDialog<INSTANCE_OPERATIONS>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('INSTANCE: ' + prefix),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, INSTANCE_OPERATIONS.TRACK);
                },
                child: const Text('TRACK AN EVENT'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, INSTANCE_OPERATIONS.TRACK_MODEL);
                },
                child: const Text('TRACK AN EVENT WITH MODEL'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, INSTANCE_OPERATIONS.LOGIN);
                },
                child: const Text('LOGIN'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, INSTANCE_OPERATIONS.LOGOUT);
                },
                child: const Text('LOGOUT'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, INSTANCE_OPERATIONS.FLUSH);
                },
                child: const Text('FLUSH'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, INSTANCE_OPERATIONS.INFO);
                },
                child: const Text('SHOW SDK INFO'),
              ),
            ],
          );
        })) {
      case INSTANCE_OPERATIONS.TRACK:
        instance.track(prefix + '_TEST');
        break;
      case INSTANCE_OPERATIONS.LOGIN:
        instance.login(prefix + '_aid');
        break;
      case INSTANCE_OPERATIONS.LOGOUT:
        instance.logout();
        break;
      case INSTANCE_OPERATIONS.FLUSH:
        instance.flush();
        break;
      case INSTANCE_OPERATIONS.INFO:
        getSDKInfo(instance);
        break;
      default:
        break;
    }
  }
}
