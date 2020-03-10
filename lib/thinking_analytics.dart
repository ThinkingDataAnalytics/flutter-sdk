import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Thinking Analytics instance mode.
///
/// It could be passed to [getInstance] as a parameter to set the native instance mode.
enum ThinkingAnalyticsMode {
  /// All data will be cached in device and posted to server according to certain strategies.
  NORMAL,
  /// Posts every data to server and throws exception in any unexpected condition.
  DEBUG,
  /// Similar to DEBUG, but no data will be truly saved to server.
  DEBUG_ONLY
}

/// Thinking Analytics Auto Track Type.
///
/// A List of [ThinkingAnalyticsAutoTrackType] can be passed to [enableAutoTrack] to enable auto track.
enum ThinkingAnalyticsAutoTrackType {
  /// An event named [ta_app_start] will be tracked when your App enter foreground.
  APP_START,
  /// An event named [ta_app_end] will be tracked when your App enter foreground.
  APP_END,
  /// An event named [ta_app_install] will be tracked when your App be first opened after installed.
  APP_INSTALL,
  /// An event named [ta_app_crash] will be tracked when there is an uncaught exception.
  APP_CRASH
}

/// Official Thinking Analytics API for tracking events and user properties.
///
/// Your should get the instance of ThinkingAnalyticsAPI by calling `getInstance` with your APP ID of Thinking Analytics project and URL of receiver:
///
/// ```dart
/// final ThinkingAnalyticsAPI ta = await ThinkingAnalyticsAPI.getInstance('APP_ID', 'https://SERVER_URL');
/// ```
/// The you could user the ThinkingAnalyticsAPI instance to track events:
///
/// ```dart
/// // track an simple event
/// ta.track('example_event');
/// ```
class ThinkingAnalyticsAPI {
  static const MethodChannel _channel =
  const MethodChannel('thinkingdata.cn/ThinkingAnalytics');


  // The APP ID bind to the instance.
  final String _appId;

  // The function return dynamic properties.
  Function _getDynamicSuperProperties;

  /// Gets instance of ThinkingAnalyticsAPI.
  ///
  /// The sdk in native will be initialized with [appId] and [serverUrl]. The [appId] is the APP ID of your project. The
  /// [serverUrl] is your own receiver's url. In case of using TA SaaS, the [serverUrl] is https://receiver.ta.thinkingdata.cn.
  ///
  /// By default, the event time will be serialized using device TimeZone. You can pass a named parameter [timeZone] to specify the
  /// default TimeZone in native SDK. The value of [timeZone] must be a valid time zone name like: 'UTC', 'Asia/Shanghai', etc.
  ///
  /// In addition, you can pass a [mode] to set the SDK mode. By default, the mode will be set to [ThinkingAnalyticsMode.NORMAL].
  /// NOTE:
  /// 1. DO NOT use [ThinkingAnalyticsMode.DEBUG] or [ThinkingAnalyticsMode.DEBUG_ONLY] in online App.
  /// 2. The DEBUG mode could not be enabled unless you set your device ID in TA server.
  static Future<ThinkingAnalyticsAPI> getInstance(String appId, String serverUrl, {String timeZone, ThinkingAnalyticsMode mode}) async {

    Map<String, dynamic> config = <String, dynamic>{'appId': appId, 'serverUrl': serverUrl};

    if (null != timeZone) {
      config['timeZone'] = timeZone;
    }

    if (null != mode) {
      config['mode'] = mode.index;
    }

    await _channel.invokeMethod<int>('getInstance', config);

    return ThinkingAnalyticsAPI.private(appId);
  }

  /// Enable detail logs of data tracking.
  static void enableLog() {
    _channel.invokeMethod('enableLog');
  }

  /// Enable auto track events.
  ///
  /// You can enable auto tracking by calling the method with [autoTrackTypes], which is a List of [ThinkingAnalyticsAutoTrackType].
  /// If you need to set your own distinct ID or super properties, please do that before enable auto tracking.
  void enableAutoTrack(List<ThinkingAnalyticsAutoTrackType> autoTrackTypes) {
    if (null != autoTrackTypes) {
      _channel.invokeMethod('enableAutoTrack', <String, dynamic>{
        'appId': _appId,
        'types': autoTrackTypes.map((e)=> e.index).toList(),
      });
    }
  }

  @visibleForTesting
  ThinkingAnalyticsAPI.private(this._appId);

  /// Creates a light instance.
  ///
  /// Light instance shares most configuration like APP ID and Server URL with the master instance. But the user IDs of light
  /// instance are different with its master instance.
  Future<ThinkingAnalyticsAPI> createLightInstance() async {
    String lightAppId = await _channel.invokeMethod<String>('createLightInstance', <String, dynamic> {'appId': this._appId});

    return ThinkingAnalyticsAPI.private(lightAppId);
  }

  /// Tracks an event.
  ///
  /// [eventName] is required for this function. In addition you can pass a `Map<String, dynamic>` as the event's properties.
  ///
  /// By default, the event time will be set to the device time with default time zone settings. You can pass a [dateTime] and
  /// a valid [timeZone] name to set the event time.
  void track(String eventName, {Map<String, dynamic> properties, DateTime dateTime, String timeZone}) {
    Map<String, dynamic> finalProperties = this._getDynamicSuperProperties == null ? {} : this._getDynamicSuperProperties();

    if (properties != null) {
      finalProperties.addAll(properties);
    }
    _searchDate(finalProperties);

    Map<String, dynamic> params = {
      'appId': this._appId,
      'eventName': eventName,
      'properties': finalProperties,
    };

    if (null != dateTime) {
      params['timestamp'] = dateTime.millisecondsSinceEpoch;
    }

    if (null != timeZone) {
      params['timeZone'] = timeZone;
    }

    _channel.invokeMethod<void>('track', params);
  }

  /// Sets user properties.
  ///
  /// userSet will create user properties or update the existing user properties.
  void userSet(Map<String, dynamic> properties) {
    _searchDate(properties);
    _channel.invokeMethod<void>('userSet', <String, dynamic>{'properties':properties, 'appId': this._appId});
  }

  /// Sets user properties only once.
  ///
  /// userSetOnce DO NOT update the existing user properties.
  void userSetOnce(Map<String, dynamic> properties) {
    _searchDate(properties);
    _channel.invokeMethod<void>('userSetOnce', <String, dynamic>{'properties':properties, 'appId': this._appId});
  }

  /// Updates user properties of num type by adding a value.
  ///
  /// Passing a negative value for a property is equals to subtraction.
  void userAdd(Map<String, num> properties) {
    _channel.invokeMethod<void>('userAdd', <String, dynamic>{'properties': properties, 'appId': this._appId});
  }

  /// Updates user properties of list type by appending some elements.
  void userAppend(Map<String, List> properties) {
    properties.updateAll((String k, List v) {
        return v.map((e)=> e is DateTime ? _formatDateString(e) : e).toList();
    });
    _channel.invokeMethod<void>('userAppend', <String, dynamic>{'properties':properties, 'appId': this._appId});
  }

  /// Deletes a [property] from the user properties.
  void userUnset(String property) {
    _channel.invokeMethod<void>('userUnset', <String, dynamic>{'property': property, 'appId': this._appId});
  }

  /// Deletes the user profile from TA server.
  ///
  /// This operation is irreversible. The data will be remained.
  void userDelete() {
    _channel.invokeMethod('userDelete', <String, dynamic>{'appId': this._appId});
  }

  /// Sets super properties.
  ///
  /// Super properties will be put in every event data as the event's properties. Super properties will be cached in device.
  void setSuperProperties(Map<String, dynamic> properties) {
    _searchDate(properties);
    _channel.invokeMethod<void>('setSuperProperties', <String, dynamic>{'properties': properties, 'appId': this._appId});
  }

  /// Clears super properties.
  void clearSuperProperties() {
    _channel.invokeMethod('clearSuperProperties', <String, dynamic>{'appId': this._appId});
  }

  /// Deletes a [property] from current super properties.
  void unsetSuperProperty(String property) {
    _channel.invokeMethod('unsetSuperProperty', <String, dynamic>{'property': property, 'appId': this._appId});
  }

  /// Sets the dynamic super properties.
  ///
  /// [f] is a function that retuning valid properties. It will be called in every track to get the dynamic super properties.
  void setDynamicSuperProperties(Map<String, dynamic> f()) {
    this._getDynamicSuperProperties = f;
  }

  /// Uploads the cached data immediately.
  ///
  /// All data will be cached in local device and be posted to TA server according given strategies. You can post the data to
  /// TA server immediately by calling flush.
  void flush() {
    _channel.invokeMethod('flush', <String, dynamic>{'appId': this._appId});
  }

  /// Starts the timer for the given [eventName].
  ///
  /// When you track an event with name [eventName], a property `#duration` will be put in the event properties.
  void timeEvent(String eventName) {
    _channel.invokeMethod('timeEvent', <String, dynamic>{'eventName': eventName, 'appId': this._appId});
  }

  /// Sets the account ID.
  ///
  /// `login` DO NOT upload any data to TA server.
  void login(String accountId) {
    _channel.invokeMethod<void>('login', <String, dynamic>{'accountId': accountId, 'appId': this._appId});
  }

  /// Clears the account ID.
  ///
  /// `logout` DO NOT upload any data to TA server.
  void logout() {
    _channel.invokeMethod<void>('logout', <String, dynamic>{'appId': this._appId});
  }

  /// Sets the distinct ID.
  ///
  /// By default, a random UUID will be used to identify a user. You can change the distinct ID by calling `identify`.
  /// `identify` DO NOT upload any data to TA server.
  void identify(String distinctId) {
    _channel.invokeMethod<void>('identify', <String, dynamic>{'distinctId': distinctId, 'appId': this._appId});
  }

  /// Gets the current distinct ID.
  Future<String> getDistinctId() async {
    return await _channel.invokeMethod<String>('getDistinctId', <String, dynamic>{'appId': this._appId});
  }

  /// Gets the device ID.
  Future<String> getDeviceId() async {
    return await _channel.invokeMethod('getDeviceId', <String, dynamic>{'appId': this._appId});
  }

  /// Stops the SDK function.
  ///
  /// The SDK will be disabled and all local data will be cleared. If [deleteUser] is set to be true, SDK will try to upload
  /// an user delete data to TA server before stopping SDK functions.
  void optOutTracking([bool deleteUser = false]) {
    _getDynamicSuperProperties = null;
    _channel.invokeMethod('optOutTracking', <String, dynamic>{'deleteUser': deleteUser, 'appId': this._appId});
  }

  /// Opts in the SDK being opt outed.
  void optInTracking() {
    _channel.invokeMethod('optInTracking', <String, dynamic>{'appId': this._appId});
  }

  /// Pause/resume SDK functions.
  ///
  /// The cached data and local settings such as user IDs and super properties will not be deleted.
  void enableTracking(bool enabled) {
    _channel.invokeMethod('enableTracking', <String, dynamic>{'enabled': enabled, 'appId': this._appId});
  }

  // Formats all DateTime value in properties.
  void _searchDate(Map<String, dynamic> properties) {
    if (properties == null) return;

    properties.updateAll((String k, dynamic v) {
      if (v is DateTime) {
        return _formatDateString(v);
      } else if (v is List) {
        return v.map((e)=> e is DateTime ? _formatDateString(e) : e).toList();
      } else {
        return v;
      }
    });
  }

  String _formatDateString(DateTime dateTime) {
    final sb = StringBuffer();

    sb.write(_digits(dateTime.year, 4));
    sb.write('-');
    sb.write(_digits(dateTime.month, 2));
    sb.write('-');
    sb.write(_digits(dateTime.day, 2));
    sb.write(' ');
    sb.write(_digits(dateTime.hour, 2));
    sb.write(':');
    sb.write(_digits(dateTime.minute, 2));
    sb.write(':');
    sb.write(_digits(dateTime.second, 2));
    sb.write('.');
    sb.write(_digits(dateTime.millisecond, 3));

    return sb.toString();
  }

  String _digits(int value, int length) {
    String ret = '$value';
    if (ret.length < length) {
      ret = '0' * (length - ret.length) + ret;
    }
    return ret;
  }
}