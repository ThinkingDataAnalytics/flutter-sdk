import 'dart:collection';
import 'package:thinking_analytics/thinking_analytics.dart';
import 'dart:math';
import 'dart:convert';

///Running mode. The default mode is NORMAL.
enum TDMode {
  ///In normal mode, data is cached and reported according to certain cache policies
  NORMAL,

  ///Debug mode: Data is reported one by one. When a problem occurs, the user is alerted in the form of logs and exceptions
  DEBUG,

  ///Debug Only mode: verifies data and does not store data in the database
  DEBUG_ONLY
}

///SDK config.
class TDConfig {
  ///APP ID
  late String appId;

  ///server url
  late String serverUrl;

  ///Running mode. The default mode is NORMAL.
  TDMode _mode = TDMode.NORMAL;

  ///Encrypt related configuration information
  TASecretKey? _secretKey;

  ///default time zone
  String? timeZone;

  ///encryption switch
  bool _mEnableEncrypt = false;

  ///Set Running mode
  ///
  ///[mode] Running mode
  void setMode(TDMode mode) {
    this._mode = mode;
  }

  ///Enable encryption
  ///
  ///[version] public key version
  ///
  ///[publicKey] public key
  void enableEncrypt(int version, String publicKey,
      {String asymmetricEncryption = "RSA",
      String symmetricEncryption = "AES"}) {
    this._mEnableEncrypt = true;
    if (null == _secretKey) {
      _secretKey = new TASecretKey();
      _secretKey?.version = version;
      _secretKey?.publicKey = publicKey;
      _secretKey?.asymmetricEncryption = asymmetricEncryption;
      _secretKey?.symmetricEncryption = symmetricEncryption;
    }
  }
}

/// TDUniqueEvent Used to describe the first event.
/// The server uses the event name and #first_check_id to determine if the event was first fired
/// If the event already exists in the system, the current data is ignored.
/// By default, the device ID is used as #first_check_id.
class TDFirstEventModel extends TrackFirstEventModel {
  TDFirstEventModel(
      String eventName, String firstCheckID, Map<String, dynamic> properties)
      : super(eventName, firstCheckID, properties);
}

///  Events that can be updated. Corresponds to the track_update operation.
///  In some scenarios, attributes in the event table need to be updated. You can create a TDUpdatableEvent and pass in an eventId identifying this data point.
///  Upon receiving such a request, the server uses the current attribute to override the previous attribute of the same name in the corresponding data of the eventId.
class TDUpdatableEventModel extends TrackUpdateEventModel {
  TDUpdatableEventModel(
      String eventName, String eventID, Map<String, dynamic> properties)
      : super(eventName, eventID, properties);
}

/// Overridden event that corresponds to the ta_overwrite operation.
/// Create the TDOverWritableEvent object to override the previous event data.
/// Passing eventId specifies the event that needs to be overridden.
class TDOverWritableEventModel extends TrackOverwriteEventModel {
  TDOverWritableEventModel(
      String eventName, String eventID, Map<String, dynamic> properties)
      : super(eventName, eventID, properties);
}

/// Automatic collection of event types
class TDAutoTrackEventType {
  /// Start event: including opening the APP and opening the APP from the background
  static const int APP_START = 1;

  /// Including closing the APP and the App entering the background, and collecting the duration of the startup
  static const int APP_END = 1 << 1;

  /// Record crash information when APP crashes
  static const int APP_CRASH = 1 << 4;

  /// Record the behavior of APP being installed
  static const int APP_INSTALL = 1 << 5;
}

/// Data sending status
enum TDTrackStatus {
  /// Stop SDK data tracking
  PAUSE,

  /// Stop SDK data tracking to clear the cache
  STOP,

  /// Stop SDK data reporting
  SAVE_ONLY,

  /// Restore all states
  NORMAL,
}

/// Three-party data platform
class TDThirdPartyType {
  /// Appsflyer
  static const int APPS_FLYER = 1;

  /// IronSource
  static const int IRON_SOURCE = 1 << 1;

  /// Adjust
  static const int ADJUST = 1 << 2;

  /// Branch
  static const int BRANCH = 1 << 3;

  /// Top on
  static const int TOP_ON = 1 << 4;

  /// re yun
  static const int TRACKING = 1 << 5;

  /// Trad plus
  static const int TRAD_PLUS = 1 << 6;

  /// AppLovinSdk Impression
  static const int APPLOVIN_IMPRESSION = 1 << 8;
}

/// The packaging class of ThinkingAnalyticsSDK provides static methods, which is more convenient for customers to use
class TDAnalytics {
  static Map<String, ThinkingAnalyticsAPI> _sInstances = LinkedHashMap();

  ///enable debug logging
  ///
  /// [enableLog] log switch
  static void enableLog(bool enableLog) {
    if (enableLog) {
      ThinkingAnalyticsAPI.enableLog();
    }
  }

  ///time calibration with timestamp
  ///
  /// [timestamp] timestamp
  static void calibrateTime(int timestamp) {
    ThinkingAnalyticsAPI.calibrateTime(timestamp);
  }

  ///time calibration with ntp
  ///
  ///[ntpServer] ntp server url
  static void calibrateTimeWithNtp(String ntpServer) {
    ThinkingAnalyticsAPI.calibrateTimeWithNtp(ntpServer);
  }

  ///Initialize the SDK. The track function is not available until this interface is invoked.
  ///
  /// [appId] the APP ID of your project.
  ///
  /// [serverUrl] your own receiver's url. In case of using TA SaaS, the serverUrl is https://receiver.ta.thinkingdata.cn.
  static Future<void> init(String appId, String serverUrl) async {
    ThinkingAnalyticsAPI instance =
        await ThinkingAnalyticsAPI.getInstance(appId, serverUrl);
    if (!_sInstances.containsKey(appId)) {
      _sInstances[appId] = instance;
    }
  }

  ///Initialize the SDK. The track function is not available until this interface is invoked.
  ///
  /// [config] SDK init config
  static Future<void> initWithConfig(TDConfig config) async {
    ThinkingAnalyticsMode? mode;
    switch (config._mode) {
      case TDMode.NORMAL:
        mode = ThinkingAnalyticsMode.NORMAL;
        break;
      case TDMode.DEBUG:
        mode = ThinkingAnalyticsMode.DEBUG;
        break;
      case TDMode.DEBUG_ONLY:
        mode = ThinkingAnalyticsMode.DEBUG_ONLY;
        break;
    }
    ThinkingAnalyticsAPI instance = await ThinkingAnalyticsAPI.getInstance(
        config.appId, config.serverUrl,
        timeZone: config.timeZone,
        mode: mode,
        enableEncrypt: config._mEnableEncrypt,
        secretKey: config._secretKey);
    if (!_sInstances.containsKey(config.appId)) {
      _sInstances[config.appId] = instance;
    }
  }

  /// Create lightweight SDK instances. Lightweight SDK instances do not support
  /// caching of local account ids, guest ids, public properties, etc.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static Future<String> lightInstance({String? appId}) async {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    ThinkingAnalyticsAPI? lightInstance = await instance?.createLightInstance();
    var random = Random();
    String uuid = List.generate(16, (i) => random.nextInt(256)).join('');
    if (!_sInstances.containsKey(uuid) && null != lightInstance) {
      _sInstances[uuid] = lightInstance;
    }
    return uuid;
  }

  /// Upload a single event, containing only preset properties and set public properties.
  ///
  /// [eventName] is required for this function. In addition you can pass a `Map<String, dynamic>` as the event's properties.
  ///
  /// [properties] event properties
  ///
  /// [dateTime] event time
  ///
  /// [timeZone] event timeZone
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void track(String eventName,
      {Map<String, dynamic>? properties,
      DateTime? dateTime,
      String? timeZone,
      String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.track(eventName,
        properties: properties, dateTime: dateTime, timeZone: timeZone);
  }

  /// Upload a special type of event.
  ///
  /// [eventModel] Event Object TDFirstEventModel / TDOverWritableEventModel / TDUpdatableEventModel
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void trackEventModel(TrackEventModel eventModel, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.trackEventModel(eventModel);
  }

  /// Enable the auto tracking function with properties
  ///
  /// [autoTrackEventType] Indicates the type of the automatic collection event to be enabled
  ///
  /// [autoTrackEventProperties] auto track event properties
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void enableAutoTrack(int autoTrackEventType,
      {Map<String, dynamic>? autoTrackEventProperties, String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.enableAutoTrackWithProperties(
        autoTrackEventType, autoTrackEventProperties);
  }

  /// Record the event duration, call this method to start the timing, stop the timing when the target event is uploaded, and add the attribute #duration to the event properties, in seconds.
  ///
  /// [eventName] target event name
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void timeEvent(String eventName, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.timeEvent(eventName);
  }

  /// Sets the user property, replacing the original value with the new value if the property already exists.
  ///
  /// [properties] user property
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void userSet(Map<String, dynamic> properties, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.userSet(properties);
  }

  /// Sets a single user attribute, ignoring the new attribute value if the attribute already exists.
  ///
  /// [properties] user property
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void userSetOnce(Map<String, dynamic> properties, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.userSetOnce(properties);
  }

  /// Reset user properties.
  ///
  /// [property] user property
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void userUnset(String property, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.userUnset(property);
  }

  /// Only one attribute is set when the user attributes of a numeric type are added.
  ///
  /// [properties] user property
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void userAdd(Map<String, num> properties, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.userAdd(properties);
  }

  /// Append a user attribute of the List type.
  ///
  /// [properties] user property
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void userAppend(Map<String, List> properties, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.userAppend(properties);
  }

  /// The element appended to the library needs to be done to remove the processing, remove the support, and then import.
  ///
  /// [properties] user property
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void userUniqAppend(Map<String, List> properties, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.userUniqAppend(properties);
  }

  /// Delete the user attributes, but retain the uploaded event data. This operation is not reversible and should be performed with caution.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void userDelete({String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.userDelete();
  }

  /// Set the public event attribute, which will be included in every event uploaded after that. The public event properties are saved without setting them each time.
  ///
  /// [properties] super properties
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void setSuperProperties(Map<String, dynamic> properties,
      {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.setSuperProperties(properties);
  }

  /// Set dynamic public properties. Each event uploaded after that will contain a public event attribute.
  ///
  /// [f] is a function that retuning valid properties. It will be called in every track to get the dynamic super properties.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void setDynamicSuperProperties(Map<String, dynamic> f(),
      {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.setDynamicSuperProperties(f);
  }

  /// Clears a public event attribute.
  ///
  /// [property] Public event attribute key to clear,Deletes a property from current super properties.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void unsetSuperProperty(String property, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.unsetSuperProperty(property);
  }

  /// Clear all public event attributes.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void clearSuperProperties({String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.clearSuperProperties();
  }

  /// Gets the public event properties that have been set.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static Future<Map<String, dynamic>?> getSuperProperties(
      {String? appId}) async {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    return await instance?.getSuperProperties();
  }

  /// Gets prefabricated properties for all events.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static Future<Map<String, dynamic>?> getPresetProperties(
      {String? appId}) async {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    TDPresetProperties? presetProperties =
        await instance?.getPresetProperties();
    return presetProperties?.toEventPresetProperties();
  }

  /// Set the account ID. Each setting overrides the previous value. Login events will not be uploaded.
  ///
  /// [loginId] account id
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static Future<void> login(String loginId, {String? appId}) async {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    await instance?.login(loginId);
  }

  /// Clearing the account ID will not upload user logout events.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static Future<void> logout({String? appId}) async {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    await instance?.logout();
  }

  /// Set the distinct ID to replace the default UUID distinct ID.
  ///
  /// [identity] distinct id
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void setDistinctId(String identity, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.identify(identity);
  }

  /// Get a visitor ID: The #distinct_id value in the reported data.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static Future<String?> getDistinctId({String? appId}) async {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    return await instance?.getDistinctId();
  }

  /// Obtain the device ID.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static Future<String?> getDeviceId({String? appId}) async {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    return await instance?.getDeviceId();
  }

  /// Empty the cache queue. When this function is called, the data in the current cache queue will attempt to be reported.
  /// If the report succeeds, local cache data will be deleted.
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void flush({String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    instance?.flush();
  }

  /// The switch reporting status is suspended and restored.
  ///
  /// [status] reporting status
  ///
  /// [appId] It is used in multi-instance scenarios. If there is only one instance, it is recommended not to pass
  static void setTrackStatus(TDTrackStatus status, {String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    TATrackStatus trackStatus = TATrackStatus.NORMAL;
    switch (status) {
      case TDTrackStatus.STOP:
        trackStatus = TATrackStatus.STOP;
        break;
      case TDTrackStatus.PAUSE:
        trackStatus = TATrackStatus.PAUSE;
        break;
      case TDTrackStatus.SAVE_ONLY:
        trackStatus = TATrackStatus.SAVE_ONLY;
        break;
      case TDTrackStatus.NORMAL:
        break;
    }
    instance?.setTrackStatus(trackStatus);
  }

  /// Enable three-party data synchronization.
  ///
  /// [type] Three-party data platform
  ///
  /// [extras] extras
  static void enableThirdPartySharing(int type,
      {Map<String, dynamic>? extras, String? appId}) {
    ThinkingAnalyticsAPI? instance = _getInstanceByAppId(appId);
    List<TAThirdPartyShareType> thirdTypes = [];
    if (type & TDThirdPartyType.APPS_FLYER > 0) {
      thirdTypes.add(TAThirdPartyShareType.TA_APPS_FLYER);
    }
    if (type & TDThirdPartyType.IRON_SOURCE > 0) {
      thirdTypes.add(TAThirdPartyShareType.TA_IRON_SOURCE);
    }
    if (type & TDThirdPartyType.ADJUST > 0) {
      thirdTypes.add(TAThirdPartyShareType.TA_ADJUST);
    }
    if (type & TDThirdPartyType.BRANCH > 0) {
      thirdTypes.add(TAThirdPartyShareType.TA_BRANCH);
    }
    if (type & TDThirdPartyType.TOP_ON > 0) {
      thirdTypes.add(TAThirdPartyShareType.TA_TOP_ON);
    }
    if (type & TDThirdPartyType.TRACKING > 0) {
      thirdTypes.add(TAThirdPartyShareType.TA_TRACKING);
    }
    if (type & TDThirdPartyType.TRAD_PLUS > 0) {
      thirdTypes.add(TAThirdPartyShareType.TA_TRAD_PLUS);
    }
    if (type & TDThirdPartyType.APPLOVIN_IMPRESSION > 0) {
      thirdTypes.add(TAThirdPartyShareType.TA_APPLOVIN_IMPRESSION);
    }
    instance?.enableThirdPartySharing(thirdTypes, extras);
  }

  static ThinkingAnalyticsAPI? _getInstanceByAppId(String? appId) {
    if (null == appId && _sInstances.length > 0) {
      return _sInstances.values.first;
    }
    if (null == _sInstances[appId]) {
      return _sInstances.values.first;
    }
    return _sInstances[appId];
  }

  static const String TDEventTypeTrack = "track";
  static const String TDEventTypeTrackFirst = "track_first";
  static const String TDEventTypeTrackUpdate = "track_update";
  static const String TDEventTypeTrackOverwrite = "track_overwrite";
  static const String TDEventTypeUserDel = "user_del";
  static const String TDEventTypeUserAdd = "user_add";
  static const String TDEventTypeUserSet = "user_set";
  static const String TDEventTypeUserSetOnce = "user_setOnce";
  static const String TDEventTypeUserUnset = "user_unset";
  static const String TDEventTypeUserAppend = "user_append";
  static const String TDEventTypeUserUniqAppend = "user_uniq_append";

  static void h5ClickHandler(String eventData) {
    if (eventData.isNotEmpty) {
      final Map<String, dynamic> eventMap = json.decode(eventData);
      final dataArr = eventMap['data'] as List?;
      if (dataArr == null || dataArr.isEmpty) {
        return;
      }

      final dataInfo = dataArr.first as Map<String, dynamic>?;
      if (dataInfo == null) {
        return;
      }

      var type = dataInfo['#type'] as String?;
      final eventName = dataInfo['#event_name'] as String?;
      final time = dataInfo['#time'] as String?;
      var properties = dataInfo['properties'] as Map<String, dynamic>;

      String? extraID;
      if (type == TDEventTypeTrack) {
        extraID = dataInfo['#first_check_id'] as String?;
        if (extraID != null) {
          type = "track_first";
        }
      } else {
        extraID = dataInfo['#event_id'] as String?;
      }

      properties.remove('#account_id');
      properties.remove('#distinct_id');
      properties.remove('#device_id');
      properties.remove('#lib');
      properties.remove('#lib_version');
      properties.remove('#screen_height');
      properties.remove('#screen_width');
      h5track(eventName, extraID, properties, type, time);
    }
  }

  static void h5track(String? eventName, String? extraID, Map<String, dynamic>? properties, String? type, String? time) {
    if (isTrackEvent(type)) {
      if (type == TDEventTypeTrack) {
        var dateTime = DateTime.parse(time!);
        String? timeZone;
        if (properties!.containsKey('#zone_offset')) {
          final zoneOffset = properties['#zone_offset'];
          final diffHours = dateTime.timeZoneOffset.inMinutes / 60 - zoneOffset;
          final hours = diffHours.toInt();
          final minutes = ((diffHours - hours) * 60).toInt();
          final duration = Duration(hours: hours, minutes: minutes);
          dateTime = dateTime.add(duration);
          timeZone = formatTimeZone(zoneOffset.toDouble());
        }
        track(eventName!, properties: properties, dateTime: dateTime, timeZone: timeZone.toString());
        return;
      }

      TrackEventModel eventModel;
      switch (type) {
        case TDEventTypeTrackFirst:
          eventModel = TrackFirstEventModel(eventName!, extraID ?? "", properties!);
          break;
        case TDEventTypeTrackUpdate:
          eventModel = TrackUpdateEventModel(eventName!, extraID!, properties!);
          break;
        case TDEventTypeTrackOverwrite:
          eventModel = TrackOverwriteEventModel(eventName!, extraID!, properties!);
          break;
        default:
          throw ArgumentError("Invalid event type: $type");
      }
      trackEventModel(eventModel);
    } else {
      switch (type) {
        case TDEventTypeUserDel:
          userDelete();
          break;
        case TDEventTypeUserAdd:
          userAdd(convertToNumMap(properties!));
          break;
        case TDEventTypeUserSet:
          userSet(properties!);
          break;
        case TDEventTypeUserSetOnce:
          userSetOnce(properties!);
          break;
        case TDEventTypeUserUnset:
          userUnset(properties!.keys.first);
          break;
        case TDEventTypeUserAppend:
          userAppend(convertToMapOfLists(properties!));
          break;
        case TDEventTypeUserUniqAppend:
          userUniqAppend(convertToMapOfLists(properties!));
          break;
      }
    }
  }

  static Map<String, num> convertToNumMap(Map<String, dynamic> map) {
  return Map.fromEntries(map.entries.map((entry) {
    if (entry.value is int || entry.value is double) {
      return MapEntry(entry.key, entry.value);
    } else if (entry.value is String && num.tryParse(entry.value) != null) {
      return MapEntry(entry.key, num.parse(entry.value));
    } else {
      throw Exception('Value for key ${entry.key} is not a number');
    }
    }));
  }

  static Map<String, List<dynamic>> convertToMapOfLists(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is List) {
        return MapEntry(key, value);
      } else {
        throw Exception('Value for key ${key} is not a List');
      }
    });
  }

  static String formatTimeZone(double hours) {
    final sign = hours >= 0 ? '+' : '-';
    final hourAbs = hours.abs();
    final minutes = (hourAbs - hourAbs.floor()) * 60;
    final hourPart = '${hourAbs.floor().toString().padLeft(2, '0')}';
    final minutePart = '${minutes.round().toString().padLeft(2, '0')}';

    return 'GMT${sign}${hourPart}:${minutePart}';
  }

  static bool isTrackEvent(String? eventType) {
    return eventType == TDEventTypeTrack ||
          eventType == TDEventTypeTrackFirst ||
          eventType == TDEventTypeTrackUpdate ||
          eventType == TDEventTypeTrackOverwrite;
  }
}