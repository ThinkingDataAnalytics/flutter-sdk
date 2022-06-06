package cn.thinkingdata.flutter;

import android.content.Context;
import androidx.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.Iterator;

import cn.thinkingdata.android.TDConfig;
import cn.thinkingdata.android.ThinkingAnalyticsSDK;
import cn.thinkingdata.android.TDFirstEvent;
import cn.thinkingdata.android.TDUpdatableEvent;
import cn.thinkingdata.android.TDOverWritableEvent;
import cn.thinkingdata.android.encrypt.TDSecreteKey;
import cn.thinkingdata.android.thirdparty.TDThirdPartyShareType;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ThinkingAnalyticsPlugin */
public class ThinkingAnalyticsPlugin implements FlutterPlugin, MethodCallHandler {
    private Context mContext;

    private static final Map<String, Object> EMPTY_HASH_MAP = new HashMap<>();
    private static final String TAG = "ThinkingAnalyticsPlugin";

    private static final Map<String, ThinkingAnalyticsSDK> mLightInstances = new HashMap<>();

    private enum USER_OPERATIONS {USER_SET, USER_SET_ONCE, USER_ADD, USER_APPEND, USER_UNIQ_APPEND}

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        onAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
    }

    public static void registerWith(Registrar registrar) {
        final ThinkingAnalyticsPlugin thinkingAnalyticsPlugin = new ThinkingAnalyticsPlugin();
        thinkingAnalyticsPlugin.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.mContext = applicationContext;
        final MethodChannel channel = new MethodChannel(messenger, "thinkingdata.cn/ThinkingAnalytics");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String appId = call.argument("appId");
        if (TextUtils.isEmpty(appId)) {
            if (call.method.equals("enableLog")) {
                ThinkingAnalyticsSDK.enableTrackLog(true);
                result.success(null);
                return;
            }

            if (call.method.equals("calibrateTime")) {
                Long timestamp = call.argument("timestamp");
                if (null != timestamp) {
                    ThinkingAnalyticsSDK.calibrateTime(timestamp);
                }
                result.success(null);
                return;
            }

            if (call.method.equals("calibrateTimeWithNtp")) {
                String ntpServer = call.argument("ntpServer");
                ThinkingAnalyticsSDK.calibrateTimeWithNtp(ntpServer);
                result.success(null);
                return;
            }

            Log.w(TAG, "appId is required for ThinkingAnalyticsPlugin");
            result.error(TAG, "appId is required for ThinkingAnalyticsPlugin", "");
            return;
        }
        switch (call.method) {
            case "getInstance":
                getInstance(call, result, appId);
                break;
            case "login":
                login(call, result, appId);
                break;
            case "logout":
                getThinkingAnalyticsSDK(appId).logout();
                result.success(null);
                break;
            case "identify":
                identify(call, result, appId);
                break;
            case "getDistinctId":
                String distinctId = getThinkingAnalyticsSDK(appId).getDistinctId();
                result.success(distinctId);
                break;
            case "track":
                track(call, result, appId);
                break;
            case "trackEventModel":
                trackEventModel(call, result, appId);
                break;
            case "timeEvent":
                timeEvent(call, result, appId);
                break;
            case "userSet":
                userOperation(call, result, appId, USER_OPERATIONS.USER_SET);
                break;
            case "userSetOnce":
                userOperation(call, result, appId, USER_OPERATIONS.USER_SET_ONCE);
                break;
            case "userAdd":
                userOperation(call, result, appId, USER_OPERATIONS.USER_ADD);
                break;
            case "userAppend":
                userOperation(call, result, appId, USER_OPERATIONS.USER_APPEND);
                break;
            case "userUniqAppend":
                userOperation(call, result, appId, USER_OPERATIONS.USER_UNIQ_APPEND);
                break;
            case "userUnset":
                userUnset(call, result, appId);
                break;
            case "userDelete":
                getThinkingAnalyticsSDK(appId).user_delete();
                result.success(null);
                break;
            case "setSuperProperties":
                setSuperProperties(call, result, appId);
                break;
            case "getSuperProperties":
                getSuperProperties(result, appId);
                break;
            case "unsetSuperProperty":
                getThinkingAnalyticsSDK(appId).unsetSuperProperty((String)call.argument("property"));
                result.success(null);
                break;
            case "clearSuperProperties":
                getThinkingAnalyticsSDK(appId).clearSuperProperties();
                result.success(null);
                break;
            case "getPresetProperties":
                getPresetProperties(result, appId);
                break;
            case "getDeviceId":
                result.success(getThinkingAnalyticsSDK(appId).getDeviceId());
                break;
            case "flush":
                getThinkingAnalyticsSDK(appId).flush();
                result.success(null);
                break;
            case "optOutTracking":
                Boolean deleteUser = call.argument("deleteUser");
                if (deleteUser != null && deleteUser) {
                    getThinkingAnalyticsSDK(appId).optOutTrackingAndDeleteUser();
                } else {
                    getThinkingAnalyticsSDK(appId).optOutTracking();
                }
                result.success(null);
                break;
            case "optInTracking":
                getThinkingAnalyticsSDK(appId).optInTracking();
                result.success(null);
                break;
            case "enableTracking":
                Boolean enabled =  call.argument("enabled");
                if (enabled != null) {
                    getThinkingAnalyticsSDK(appId).enableTracking(enabled);
                }
                result.success(null);
                break;
            case "createLightInstance":
                createLightInstance(result, appId);
                break;
            case "enableAutoTrack":
                enableAutoTrack(call, result, appId);
                break;
            case "setAutoTrackProperties":
                setAutoTrackProperties(call, result, appId);
                break;
            case "enableThirdPartySharing":
                enableThirdPartySharing(call, result, appId);
                break;
            case "setTrackStatus":
                setTrackStatus(call, result, appId);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private ThinkingAnalyticsSDK getThinkingAnalyticsSDK(String appId) {
        synchronized (mLightInstances) {
            if (mLightInstances.containsKey(appId)) {
                return mLightInstances.get(appId);
            }
        }
        return ThinkingAnalyticsSDK.sharedInstance(mContext, appId);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    private void getInstance(MethodCall call, Result result, String appId) {
        String serverUrl = call.argument("serverUrl");

        TDConfig config = TDConfig.getInstance(mContext, appId, serverUrl);

        if (call.hasArgument("timeZone")) {
            String timeZoneId = call.argument("timeZone");
            config.setDefaultTimeZone(TimeZone.getTimeZone(timeZoneId));
        }

        if (call.hasArgument("mode")) {
            Integer mode = call.argument("mode");
            if (null != mode) {
                config.setModeInt(mode);
            }
        }

        if(call.hasArgument("lib_version")){
            String version = call.argument("lib_version");
            if(null != version){
                ThinkingAnalyticsSDK.setCustomerLibInfo("Flutter", version);
            }
        }

        if (call.hasArgument("enableEncrypt")) {
            Boolean enableEncrypt = call.argument("enableEncrypt");
            if (null != enableEncrypt) {
                config.enableEncrypt(enableEncrypt);
            }
        }

        if (call.hasArgument("secretKey")) {
            Map<String, Object> secretKey = call.argument("secretKey");
            if (secretKey != null) {
                TDSecreteKey key = new TDSecreteKey();
                key.publicKey = (String) secretKey.get("publicKey");
                Integer v = (Integer) secretKey.get("version");
                if (null != v) {
                    key.version = v;
                }
                key.symmetricEncryption = (String) secretKey.get("symmetricEncryption");
                key.asymmetricEncryption = (String) secretKey.get("asymmetricEncryption");
                config.setSecretKey(key);
            }
        }

        ThinkingAnalyticsSDK instance = ThinkingAnalyticsSDK.sharedInstance(config);
        result.success(instance.hashCode());
    }

    private void enableAutoTrack(MethodCall call, Result result, String appId) {
        if (call.hasArgument("types")) {
            List<Integer> autoTrack = call.argument("types");
            if (null != autoTrack) {
                List<ThinkingAnalyticsSDK.AutoTrackEventType> eventTypes = new ArrayList<>();
                for (int v : autoTrack) {
                    switch (v) {
                        case 0:
                            eventTypes.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_START);
                            break;
                        case 1:
                            eventTypes.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_END);
                            break;
                        case 2:
                            eventTypes.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_INSTALL);
                            break;
                        case 3:
                            eventTypes.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_CRASH);
                            break;
                    }

                }

                if (eventTypes.size() > 0) {
                    getThinkingAnalyticsSDK(appId).enableAutoTrack(eventTypes);
                }
            }
        }
        result.success(null);
    }

    private void setAutoTrackProperties(MethodCall call, Result result, String appId) {
        if (call.hasArgument("types") && call.hasArgument("properties")) {
            Map<String, Object> mapProperties = call.<HashMap<String, Object>>argument("properties");
            List<Integer> autoTrack = call.argument("types");
            if (null != autoTrack) {
                List<ThinkingAnalyticsSDK.AutoTrackEventType> eventTypes = new ArrayList<>();
                for (int v : autoTrack) {
                    switch (v) {
                        case 0:
                            eventTypes.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_START);
                            break;
                        case 1:
                            eventTypes.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_END);
                            break;
                        case 2:
                            eventTypes.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_INSTALL);
                            break;
                        case 3:
                            eventTypes.add(ThinkingAnalyticsSDK.AutoTrackEventType.APP_CRASH);
                            break;
                    }
                }
                if (eventTypes.size() > 0) {
                    JSONObject properties;
                    try {
                        properties = extractJSONObject(mapProperties == null ? EMPTY_HASH_MAP : mapProperties);
                    } catch (Exception e) {
                        result.error(e.getClass().getName(), e.toString(), "");
                        return;
                    }
                    getThinkingAnalyticsSDK(appId).setAutoTrackProperties(eventTypes, properties);
                }
            }
        }

        result.success(null);
    }

    private void enableThirdPartySharing(MethodCall call, Result result, String appId) {
        if (call.hasArgument("types")) {
            List<Integer> shareTypes = call.argument("types");
            if (null == shareTypes) return;
            int thirdTypes = 0;
            for (int v : shareTypes) {
                switch (v) {
                    case 0:
                        thirdTypes = thirdTypes | TDThirdPartyShareType.TD_APPS_FLYER;
                        break;
                    case 1:
                        thirdTypes = thirdTypes | TDThirdPartyShareType.TD_IRON_SOURCE;
                        break;
                    case 2:
                        thirdTypes = thirdTypes | TDThirdPartyShareType.TD_ADJUST;
                        break;
                    case 3:
                        thirdTypes = thirdTypes | TDThirdPartyShareType.TD_BRANCH;
                        break;
                    case 4:
                        thirdTypes = thirdTypes | TDThirdPartyShareType.TD_TOP_ON;
                        break;
                    case 5:
                        thirdTypes = thirdTypes | TDThirdPartyShareType.TD_TRACKING;
                        break;
                    case 6:
                        thirdTypes = thirdTypes | TDThirdPartyShareType.TD_TRAD_PLUS;
                        break;
                }

            }
            getThinkingAnalyticsSDK(appId).enableThirdPartySharing(thirdTypes);
        } else if (call.hasArgument("type")) {
            Integer type = call.argument("type");
            if (type == null) return;
            Map<String, Object> maps = call.argument("params");
            int thirdType = 0;
            switch (type) {
                case 0:
                    thirdType = TDThirdPartyShareType.TD_APPS_FLYER;
                    break;
                case 1:
                    thirdType = TDThirdPartyShareType.TD_IRON_SOURCE;
                    break;
                case 2:
                    thirdType = TDThirdPartyShareType.TD_ADJUST;
                    break;
                case 3:
                    thirdType = TDThirdPartyShareType.TD_BRANCH;
                    break;
                case 4:
                    thirdType = TDThirdPartyShareType.TD_TOP_ON;
                    break;
                case 5:
                    thirdType = TDThirdPartyShareType.TD_TRACKING;
                    break;
                case 6:
                    thirdType = TDThirdPartyShareType.TD_TRAD_PLUS;
                    break;
            }
            getThinkingAnalyticsSDK(appId).enableThirdPartySharing(thirdType, maps);
        }
    }

    private void setTrackStatus(MethodCall call, Result result, String appId) {
        Integer status = call.argument("status");
        if (null == status) return;
        switch (status) {
            case 0:
                getThinkingAnalyticsSDK(appId).setTrackStatus(ThinkingAnalyticsSDK.TATrackStatus.PAUSE);
                break;
            case 1:
                getThinkingAnalyticsSDK(appId).setTrackStatus(ThinkingAnalyticsSDK.TATrackStatus.STOP);
                break;
            case 2:
                getThinkingAnalyticsSDK(appId).setTrackStatus(ThinkingAnalyticsSDK.TATrackStatus.SAVE_ONLY);
                break;
            case 3:
                getThinkingAnalyticsSDK(appId).setTrackStatus(ThinkingAnalyticsSDK.TATrackStatus.NORMAL);
                break;
        }
    }

    private void track(MethodCall call, Result result, String appId) {
        String eventName = call.argument("eventName");
        Map<String, Object> mapProperties = call.<HashMap<String, Object>>argument("properties");

        JSONObject properties;

        try {
            Date date = call.hasArgument("timestamp") ? new Date((long)call.argument("timestamp")) : null;
            TimeZone timeZone = call.hasArgument("timeZone") ? TimeZone.getTimeZone((String) call.argument("timeZone")) : null;
            properties = extractJSONObject(mapProperties == null ? EMPTY_HASH_MAP : mapProperties);
            if (date != null) {
                if (timeZone != null) {
                    getThinkingAnalyticsSDK(appId).track(eventName, properties, date, timeZone);
                } else {
                    getThinkingAnalyticsSDK(appId).track(eventName, properties, date);
                }
            } else {
                getThinkingAnalyticsSDK(appId).track(eventName, properties);
            }
        } catch (Exception e) {
            Log.e(TAG, e.toString());
            result.error(e.getClass().getName(), e.toString(), "");
            return;
        }

        result.success(null);
    }

    private void trackEventModel(MethodCall call, Result result, String appId) {
        try {
            String eventName = call.argument("eventName");
            String extraID = call.argument("extraID");
            Date date = call.hasArgument("timestamp") ? new Date((long) call.argument("timestamp")) : null;
            TimeZone timeZone = call.hasArgument("timeZone") ? TimeZone.getTimeZone((String) call.argument("timeZone")) : null;

            Map<String, Object> mapProperties = call.<HashMap<String, Object>>argument("properties");
            JSONObject properties = extractJSONObject(mapProperties == null ? EMPTY_HASH_MAP : mapProperties);

            String type = call.argument("eventType");
            switch (type) {
                case "track_first": {
                    TDFirstEvent eventModel = new TDFirstEvent(eventName, properties);
                    eventModel.setFirstCheckId(extraID);
                    if (date != null) {
                        eventModel.setEventTime(date, timeZone);
                    }
                    getThinkingAnalyticsSDK(appId).track(eventModel);
                    break;
                }
                case "track_update": {
                    TDUpdatableEvent eventModel = new TDUpdatableEvent(eventName, properties, extraID);
                    if (date != null) {
                        eventModel.setEventTime(date, timeZone);
                    }
                    getThinkingAnalyticsSDK(appId).track(eventModel);
                    break;
                }
                case "track_overwrite": {
                    TDOverWritableEvent eventModel = new TDOverWritableEvent(eventName, properties, extraID);
                    if (date != null) {
                        eventModel.setEventTime(date, timeZone);
                    }
                    getThinkingAnalyticsSDK(appId).track(eventModel);
                    break;
                }
                default:
                    Log.e(TAG, "EventType is not available!!");
                    break;
            }
        } catch (Exception e) {
            Log.e(TAG, e.toString());
            result.error(e.getClass().getName(), e.toString(), "");
            return;
        }

        result.success(null);
    }

    private void userOperation(MethodCall call, Result result, String appId, USER_OPERATIONS operations) {
        Map<String, Object> mapProperties = call.<HashMap<String, Object>>argument("properties");

        JSONObject properties;
        try {
            properties = extractJSONObject(mapProperties == null ? EMPTY_HASH_MAP : mapProperties);

            ThinkingAnalyticsSDK instance = getThinkingAnalyticsSDK(appId);
            switch (operations) {
                case USER_SET:
                    instance.user_set(properties);
                    break;
                case USER_SET_ONCE:
                    instance.user_setOnce(properties);
                    break;
                case USER_APPEND:
                    instance.user_append(properties);
                    break;
                case USER_UNIQ_APPEND:
                    instance.user_uniqAppend(properties);
                    break;
                case USER_ADD:
                    instance.user_add(properties);
                    break;
            }
        } catch (Exception e) {
            result.error(e.getClass().getName(), e.toString(), "");
            return;
        }

        result.success(null);
    }

    private void userUnset(MethodCall call, Result result, String appId) {
        String property = call.argument("property");
        getThinkingAnalyticsSDK(appId).user_unset(property);
        result.success(null);
    }


    @SuppressWarnings("unchecked")
    private JSONObject extractJSONObject(Map<String, Object> properties) throws JSONException {
        JSONObject jsonObject = new JSONObject();
        if (properties != null) {
            for (String key : properties.keySet()) {
                Object value = properties.get(key);
                if (value instanceof Map<?, ?>) {
                    value = extractJSONObject((Map<String, Object>) value);
                } else if (value instanceof List) {
                    //value = new JSONArray(value);
                    value = new JSONArray((List) value);
                }
                jsonObject.put(key, value);
            }
        }
        return jsonObject;
    }

    private void identify(MethodCall call, Result result, String appId) {
        String distinctId = call.argument("distinctId");
        getThinkingAnalyticsSDK(appId).identify(distinctId);
        result.success(null);
    }

    private void login(MethodCall call, Result result, String appId) {
        String accountId = call.argument("accountId");
        getThinkingAnalyticsSDK(appId).login(accountId);
        result.success(null);
    }

    private void timeEvent(MethodCall call, Result result, String appId) {
        String eventName = call.argument("eventName");
        getThinkingAnalyticsSDK(appId).timeEvent(eventName);
        result.success(null);
    }

    private void setSuperProperties(MethodCall call, Result result, String appId) {
        Map<String, Object> mapProperties = call.<HashMap<String, Object>>argument("properties");

        JSONObject properties;
        try {
            properties = extractJSONObject(mapProperties == null ? EMPTY_HASH_MAP : mapProperties);
            getThinkingAnalyticsSDK(appId).setSuperProperties(properties);
        } catch (Exception e) {
            result.error(e.getClass().getName(), e.toString(), "");
            return;
        }

        result.success(null);
    }

    private void getSuperProperties(Result result, String appId) {
        JSONObject properties = getThinkingAnalyticsSDK(appId).getSuperProperties();
        if (properties != null) {
//            Iterator<String> keys = properties.keys();
//            Map<String, Object> mapProperties = new HashMap<>();
//            while (keys.hasNext()) {
//                String key = keys.next();
//                Object value = properties.opt(key);
//                mapProperties.put(key, value);
//            }
            result.success(jsonToMap(properties));
        } else {
            result.success(null);
        }
    }

    private Map<String, Object> jsonToMap(JSONObject properties) {
        Map<String, Object> mapProperties = new HashMap<>();
        Iterator<String> keys = properties.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            Object value = properties.opt(key);
            if (value instanceof JSONObject) {
                mapProperties.put(key, jsonToMap((JSONObject) value));
            } else if (value instanceof JSONArray) {
                mapProperties.put(key, jsonArrayToList((JSONArray) value));
            } else {
                mapProperties.put(key, value);
            }
        }
        return mapProperties;
    }

    private List<Object> jsonArrayToList(JSONArray jsonArr) {
        List<Object> lists = new ArrayList<>();
        for (int i = 0; i < jsonArr.length(); i++) {
            Object value = jsonArr.opt(i);
            if (value instanceof JSONObject) {
                lists.add(jsonToMap((JSONObject) value));
            } else if (value instanceof JSONArray) {
                lists.add(jsonArrayToList((JSONArray) value));
            } else {
                lists.add(value);
            }
        }
        return lists;
    }

    private void getPresetProperties(Result result, String appId) {
        JSONObject properties = getThinkingAnalyticsSDK(appId).getPresetProperties().toEventPresetProperties();
        if (properties != null) {
            Iterator<String> keys = properties.keys();
            Map<String, Object> mapProperties = new HashMap<>();
            while (keys.hasNext()) {
                String key = keys.next();
                Object value = properties.opt(key);
                mapProperties.put(key, value);
            }
            result.success(mapProperties);
        } else {
            result.success(null);
        }
    }

    private void createLightInstance(Result result, String appId) {
        ThinkingAnalyticsSDK lightInstance = getThinkingAnalyticsSDK(appId).createLightInstance();
        synchronized (mLightInstances) {
            mLightInstances.put(String.valueOf(lightInstance.hashCode()), lightInstance);
        }
        result.success(String.valueOf(lightInstance.hashCode()));
    }
}
