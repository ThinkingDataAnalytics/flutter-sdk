package cn.thinkingdata.flutter;

import android.content.Context;
import androidx.annotation.NonNull;
import android.text.TextUtils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import cn.thinkingdata.android.TDConfig;
import cn.thinkingdata.android.ThinkingAnalyticsSDK;
import cn.thinkingdata.android.utils.TDLog;
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
    private static final String TAG = "ThinkingAnalytics.ThinkingAnalyticsPlugin";

    private static final Map<String, ThinkingAnalyticsSDK> mLightInstances = new HashMap<>();

    private enum USER_OPERATIONS {USER_SET, USER_SET_ONCE, USER_ADD, USER_APPEND}

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

            TDLog.w(TAG, "appId is required for ThinkingAnalyticsPlugin");
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
            case "unsetSuperProperty":
                getThinkingAnalyticsSDK(appId).unsetSuperProperty((String)call.argument("property"));
                result.success(null);
                break;
            case "clearSuperProperties":
                getThinkingAnalyticsSDK(appId).clearSuperProperties();
                result.success(null);
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
            TDLog.e(TAG, e.toString());
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

    private void createLightInstance(Result result, String appId) {
        ThinkingAnalyticsSDK lightInstance = getThinkingAnalyticsSDK(appId).createLightInstance();
        synchronized (mLightInstances) {
            mLightInstances.put(String.valueOf(lightInstance.hashCode()), lightInstance);
        }
        result.success(String.valueOf(lightInstance.hashCode()));
    }
}
