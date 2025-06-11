import 'package:flutter/services.dart';
import 'package:thinking_analytics/td_analytics.dart';

typedef LogCallback = void Function(String event);

class TDUtil {
  static const MethodChannel _channel =
      const MethodChannel('thinkingdata.cn/demo');

  static const EventChannel _eventChannel =
      const EventChannel('thinkingdata.cn/demo/event');

  static bool isStartTimeCollect = false;

  static List<Map<String, dynamic>> methodGetList = [];

  static Future<bool?> clearDisk() async {
    return await _channel.invokeMethod<bool>("clearDisk");
  }

  static void setLogListener(LogCallback callback) {
    _channel.invokeMethod("setLogListener");
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is String) {
        callback(event);
      }
    });
  }

  static void searchDate(dynamic data) {
    if (data is Map<String, dynamic>) {
      data.updateAll((String k, dynamic v) {
        if (v is String) {
          return _formatDateString(v);
        } else if (v is List) {
          return _processList(v);
        } else if (v is Map<String, dynamic>) {
          searchDate(v);
          return v;
        }
        return v;
      });
    } else if (data is List) {
      _processList(data);
    }
  }

  static List<dynamic> _processList(List<dynamic> list) {
    for (int i = 0; i < list.length; i++) {
      if (list[i] is String) {
        list[i] = _formatDateString(list[i]);
      } else if (list[i] is List) {
        list[i] = _processList(list[i]);
      } else if (list[i] is Map<String, dynamic>) {
        searchDate(list[i]);
      }
    }
    return list;
  }

  static dynamic _formatDateString(String value) {
    try {
      // 尝试将字符串转换为 DateTime 类型
      return DateTime.parse(value);
    } catch (e) {
      // 如果转换失败，返回原始字符串
      return value;
    }
  }

  static void testSetDynamicSuperProperties(Map<String, dynamic> p) {
    TDAnalytics.setDynamicSuperProperties(() {
      return p;
    });
  }

  static void addGetMethod(String methodName, int duration) {
    if (!isStartTimeCollect) return;
    Map<String, dynamic> map = Map();
    map['methodName'] = methodName;
    map['duration'] = duration;
    methodGetList.add(map);
  }

  static void startMethodTimeCollect() {
    isStartTimeCollect = true;
  }

  static List<Map<String, dynamic>> getMethodTimeCollect() {
    isStartTimeCollect = false;
    var list = methodGetList;
    methodGetList = [];
    return list;
  }
}
