import 'dart:convert';

import 'package:ta_flutter_plugin_example/config.dart';
import 'package:ta_flutter_plugin_example/utils.dart';
import 'package:thinking_analytics/td_analytics.dart';
import 'package:web_socket_channel/io.dart';

import 'analytic_clone.dart';

class TDMessageHandler {
  static late IOWebSocketChannel channel;
  static var methodMap = <String, Function>{
    'TDAnalytics.init': TDAnalyticsClone.init,
    'TDAnalytics.track': TDAnalyticsClone.track,
    'TDAnalytics.enableLog': TDAnalytics.enableLog,
    'TDUtil.clearDisk': TDUtil.clearDisk,
    'TDAnalytics.getDistinctId': TDAnalytics.getDistinctId,
    'TDAnalytics.setSuperProperties': TDAnalytics.setSuperProperties,
    'TDAnalytics.login': TDAnalytics.login,
    'TDAnalytics.userSet': TDAnalytics.userSet,
    'TDAnalytics.logout': TDAnalytics.logout,
    'TDAnalytics.getDeviceId': TDAnalytics.getDeviceId,
    'TDAnalytics.setDistinctId': TDAnalytics.setDistinctId,
    'TDAnalytics.clearSuperProperties': TDAnalytics.clearSuperProperties,
    'TDAnalytics.flush': TDAnalytics.flush,
    'TDAnalytics.getAccountId': TDAnalytics.getAccountId,
    'TDAnalytics.userAdd': TDAnalytics.userAdd,
    'TDAnalytics.userSetOnce': TDAnalytics.userSetOnce,
    'TDAnalytics.userUnset': TDAnalytics.userUnset,
    'TDAnalytics.userDelete': TDAnalytics.userDelete,
    'TDAnalytics.userAppend': TDAnalytics.userAppend,
    'TDAnalytics.userUniqAppend': TDAnalytics.userUniqAppend,
    'TDAnalytics.trackEventModel': TDAnalytics.trackEventModel,
    'TDAnalytics.timeEvent': TDAnalytics.timeEvent,
    'TDAnalytics.unsetSuperProperties': TDAnalytics.unsetSuperProperty,
    'TDAnalytics.getSuperProperties': TDAnalytics.getSuperProperties,
    'TDUtil.testSetDynamicSuperProperties':
        TDUtil.testSetDynamicSuperProperties,
    'TDAnalytics.calibrateTime': TDAnalytics.calibrateTime,
    'TDAnalytics.calibrateTimeWithNtp': TDAnalytics.calibrateTimeWithNtp,
    'TDAnalytics.setTrackStatus': TDAnalytics.setTrackStatus,
    'TDAnalytics.getPresetProperties': TDAnalytics.getPresetProperties,
    'TDAnalytics.enableAutoTrack': TDAnalytics.enableAutoTrack,
    'TDUtil.startMethodTimeCollect': TDUtil.startMethodTimeCollect,
    'TDUtil.getMethodTimeCollect': TDUtil.getMethodTimeCollect,
  };

  static late WebSocketResponse response;

  static void initWebsocket() {
    TDUtil.setLogListener((event) {
      if (event.contains("[ThinkingData]") && event.contains(":")) {
        int start = event.indexOf(":");
        String msg = event.substring(start + 2);
        int logSize = response.returnLogs.length <= 5 ? 3000 : 50;
        if (msg.length > logSize) {
          msg = msg.substring(0, logSize);
        }
        response.returnLogs.add(msg);
      }
    });
    channel = IOWebSocketChannel.connect(Config.URL + Config.FROM_ID);
    channel.stream.listen((message) {
      print('收到消息: $message');
      Map<String, dynamic> jsonMap = jsonDecode(message);
      handlerMessage(jsonMap);
    }, onError: (error) {
      print('接收消息时出错: $error');
    }, onDone: () {
      print('消息流已关闭');
    });
  }

  static void handlerMessage(Map<String, dynamic> params) async {
    List<Map<String, dynamic>> tasks = convertParams(params);
    if (tasks.length == 1) {
      //单任务
      var task = tasks[0];
      final methodName = task["methodName"];
      final function = methodMap[methodName];
      int duration = 100;
      int count = 1;
      if (task['runMode'] != null) {
        duration = task['runMode']['log_duration'] == null
            ? 100
            : task['runMode']['log_duration'];
        count = task['runMode']['repeat_count'] == null
            ? 1
            : task['runMode']['repeat_count'];
      }
      startMethod(methodName, duration, false);
      if (function != null) {
        try {
          for (var i = 0; i < count; i++) {
            int start = DateTime.now().millisecond;
            var result = await Function.apply(function, task["params"]);
            int duration = DateTime.now().millisecond - start;
            TDUtil.addGetMethod(methodName, duration);
            updateResponseResult(result, duration);
          }
        } catch (e) {}
      } else {
        print('未找到方法: $methodName');
      }
    } else {
      startMethod("", 300, false);
      for (var value in tasks) {
        final methodName = value["methodName"];
        final function = methodMap[methodName];
        if (function != null) {
          try {
            int start = DateTime.now().millisecond;
            await Function.apply(function, value["params"]);
            TDUtil.addGetMethod(methodName, DateTime.now().millisecond - start);
          } catch (e) {}
        } else {
          print('未找到方法: $methodName');
        }
      }
      updateResponseResult(true, 0);
    }
  }

  static void startMethod(String methodName, int delay, bool isMultiTask) {
    response = new WebSocketResponse();
    response.methodName = methodName;
    if (isMultiTask) return;
    Future.delayed(Duration(milliseconds: delay), () {
      sendMessage();
    });
  }

  static void updateResponseResult(Object? result, int spendTime) {
    response.returnValue =
        result == null ? isReturnNull(response.methodName) : result;
    response.spendTime = spendTime;
  }

  static dynamic isReturnNull(String methodName) {
    if (methodName == 'TDAnalytics.getAccountId') {
      return "null";
    }
    return true;
  }

  static void addResponseLog(String log) {
    response.returnLogs.add(log);
  }

  static void sendMessage() {
    var params = {
      "from_id": Config.FROM_ID,
      "to_id": Config.TO_ID,
      "msg": {
        "return_value": response.returnValue,
        "spend_time": response.spendTime,
        "return_logs": response.returnLogs
      }
    };
    var formattedParams = JsonEncoder.withIndent('  ').convert(params);
    print("发送消息:$formattedParams");
    channel.sink.add(jsonEncode(params));
  }

  static List<Map<String, dynamic>> convertParams(Map<String, dynamic> params) {
    var tasks = <Map<String, dynamic>>[];
    var msg = params['msg'];
    if (msg is Map) {
      tasks.add(Map<String, dynamic>.from(msg));
    } else if (msg is List) {
      for (var item in msg) {
        if (item is Map) {
          tasks.add(Map<String, dynamic>.from(item));
        }
      }
    }
    if (tasks.isEmpty) return [];
    var convertTasks = <Map<String, dynamic>>[];
    for (var value in tasks) {
      var methodName = value['class_name'] + "." + value['method_name'];
      var params = value["params"] == null ? [] : value["params"];
      var paramTypes = value["params_type"] == null ? [] : value["params_type"];
      var paramList = <dynamic>[];
      if (methodName == "TDAnalytics.init") {
        TDConfig config = new TDConfig();
        if (params.length == 1) {
          var p1 = params[0];
          config.appId = p1["AppId"];
          config.serverUrl = p1["ServerUrl"];
          config.timeZone =
              convertTimezoneNumberToFormat(p1["DefaultTimeZone"]);
          int mode = p1["Mode"] == null ? 0 : p1["Mode"];
          if (mode == 1) {
            config.setMode(TDMode.DEBUG);
          } else if (mode == 2) {
            config.setMode(TDMode.DEBUG_ONLY);
          }
          if (p1['PublicKey'] != null &&
              (p1['PublicKey'] as String).isNotEmpty) {
            config.enableEncrypt(p1['Version'], p1['PublicKey']);
          }
        } else if (params.length == 3) {
          config.appId = params[1];
          config.serverUrl = params[2];
        }
        paramList.add(config);
      } else if (methodName == "TDAnalytics.track") {
        if (paramTypes is List && paramTypes.contains("TDFirstEvent")) {
          methodName = value['class_name'] + "." + "trackEventModel";
          if (params.length == 1) {
            var eventObj = params[0];
            if (eventObj is Map) {
              var eventModel = TDFirstEventModel(
                  eventObj['EventName'] == null ? "" : eventObj['EventName'],
                  eventObj['ExtraId'] == null ? "" : eventObj['ExtraId'],
                  eventObj['Properties'] == null
                      ? new Map<String, dynamic>()
                      : eventObj['Properties']);
              paramList.add(eventModel);
            }
          }
        } else if (paramTypes is List &&
            paramTypes.contains("TDUpdatableEvent")) {
          methodName = value['class_name'] + "." + "trackEventModel";
          if (params.length == 1) {
            var eventObj = params[0];
            if (eventObj is Map) {
              var eventModel = TDUpdatableEventModel(
                  eventObj['EventName'] == null ? "" : eventObj['EventName'],
                  eventObj['ExtraId'] == null ? "" : eventObj['ExtraId'],
                  eventObj['Properties'] == null
                      ? new Map<String, dynamic>()
                      : eventObj['Properties']);
              paramList.add(eventModel);
            }
          }
        } else if (paramTypes is List &&
            paramTypes.contains("TDOverWritableEvent")) {
          methodName = value['class_name'] + "." + "trackEventModel";
          if (params.length == 1) {
            var eventObj = params[0];
            if (eventObj is Map) {
              var eventModel = TDOverWritableEventModel(
                  eventObj['EventName'] == null ? "" : eventObj['EventName'],
                  eventObj['ExtraId'] == null ? "" : eventObj['ExtraId'],
                  eventObj['Properties'] == null
                      ? new Map<String, dynamic>()
                      : eventObj['Properties']);
              paramList.add(eventModel);
            }
          }
        } else {
          //普通事件
          if (params.length == 1) {
            paramList.add(params[0]);
            paramList.add(new Map<String, dynamic>());
          } else {
            for (var i = 0; i < params.length; i++) {
              paramList.add(params[i]);
            }
          }
        }
      } else if (methodName == "TDAnalytics.userAdd") {
        if (params.length == 1) {
          if (params[0] is Map) {
            final Map<String, dynamic> dynamicMap =
                params[0] as Map<String, dynamic>;
            Map<String, num> numMap = {};
            dynamicMap.forEach((key, value) {
              if (value is num) {
                numMap[key] = value;
              } else if (value is String) {
                try {
                  numMap[key] = num.parse(value);
                } catch (e) {}
              }
            });
            if (numMap.isNotEmpty) {
              paramList.add(numMap);
            }
          }
        }
      } else if (methodName == "TDAnalytics.userAppend" ||
          methodName == "TDAnalytics.userUniqAppend") {
        if (params.length == 1) {
          if (params[0] is Map) {
            final Map<String, dynamic> dynamicMap =
                params[0] as Map<String, dynamic>;
            Map<String, List> numMap = {};
            dynamicMap.forEach((key, value) {
              if (value is List) {
                numMap[key] = value;
              }
            });
            if (numMap.isNotEmpty) {
              paramList.add(numMap);
            }
          }
        }
      } else if (methodName == "TDAnalytics.setTrackStatus") {
        if (params.length == 1) {
          if (params[0] == 1) {
            paramList.add(TDTrackStatus.STOP);
          } else if (params[0] == 0) {
            paramList.add(TDTrackStatus.PAUSE);
          } else if (params[0] == 2) {
            paramList.add(TDTrackStatus.SAVE_ONLY);
          } else {
            paramList.add(TDTrackStatus.NORMAL);
          }
        }
      } else {
        for (var i = 0; i < params.length; i++) {
          if (params[i] == 'ignore_param') {
          } else if (params[i] == 'nullptr') {
            paramList.add(null);
          } else {
            paramList.add(params[i]);
          }
        }
      }
      if (methodName != "TDAnalytics.userAdd" &&
          methodName != "TDAnalytics.userAppend" &&
          methodName != "TDAnalytics.userUniqAppend") {
        for (var item in paramList) {
          if (item is Map<String, dynamic>) {
            TDUtil.searchDate(item);
          }
        }
      }
      convertTasks.add({
        "methodName": methodName,
        "className": value['class_name'],
        "params": paramList,
        "runMode": value["run_mode"],
      });
    }
    return convertTasks;
  }

  static String convertTimezoneNumberToFormat(num offset) {
    int sign = offset >= 0 ? 1 : -1;
    num absOffset = offset.abs();
    int hours = absOffset.floor();
    int minutes = ((absOffset - hours) * 60).round();

    String signStr = sign == 1 ? "+" : "-";
    String hourStr = hours.toString().padLeft(2, '0');
    String minuteStr = minutes.toString().padLeft(2, '0');

    return 'GMT$signStr$hourStr:$minuteStr';
  }
}

class WebSocketResponse {
  late String methodName;
  late Object returnValue = true;
  late int spendTime = 0;
  List<String> returnLogs = [];
}
