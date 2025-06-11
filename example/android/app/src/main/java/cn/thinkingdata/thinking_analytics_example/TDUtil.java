package cn.thinkingdata.thinking_analytics_example;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import androidx.annotation.RequiresApi;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;
import java.util.TimeZone;
import java.util.UUID;

class TDUtil {

    public static Context mContext;

    private static List<String> methodList = Arrays.asList("TDAnalytics.getAccountId", "TDUtil.tdRemoteConfigChainGet");
    private static List<String> methodParamList = Arrays.asList("TDAnalytics.calibrateTimeWithNtp", "TDAnalytics.userUnset");

    public static JSONObject content;
    public static JSONObject statusMap;
    public static JSONArray methodGetList = new JSONArray();
    public static boolean isStartTimeCollect = false;

    public static void setContent(JSONObject jsonObject) {
        content = jsonObject;
    }

    public static JSONObject getContent() {
        return content != null ? content : new JSONObject();
    }

    public static JSONObject getStatusMap() {
        return statusMap != null ? statusMap : new JSONObject();
    }

    public static void throwCrash() {
        Log.i("hh", "调用crash");
        throw new RuntimeException("crash");
    }

    public static void throwCrash(Throwable e) {
        if (e != null && (e.getLocalizedMessage() != null && e.getLocalizedMessage().equals("crash")) || (e.getCause() != null && e.getCause().getLocalizedMessage().equals("crash"))) {
            throw new RuntimeException("crash");
        }
    }

    //   public static void throwCrash(Throwable e)
    public static SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA);

    //   public static void throwCrash(Throwable e)
//   {
//      if(e!=null && e.getLocalizedMessage()!= null && e.getLocalizedMessage().equals("crash"))
//      {
//         TDUtil.throwCrash();
//      }
//   }
    @RequiresApi(api = Build.VERSION_CODES.N)
    public static boolean clearDisk(Context context) {
        String path = context.getDataDir().getAbsolutePath();
        deleteDirectory(path+"/databases");
        deleteDirectory(path+"/shared_prefs");
        return true;
    }

    public static JSONArray getTriggerRecord(Context context, String appId, String uid, String taskId, long triggerTime) {
        TDSqlite sqlite = new TDSqlite(context, TDSqlite.DB_ST);
        return sqlite.getTriggerRecord(appId, uid, taskId, triggerTime);
    }

    public static boolean insertTask(Context context, String appId, String clientUid, String taskId, String rawData, long taskVersion) {
        TDSqlite sqlite = new TDSqlite(context, TDSqlite.DB_ST);
        return sqlite.insertTask(appId, clientUid, taskId, rawData, taskVersion);
    }

    public static JSONArray getTasks(Context context, String appId, String client_user_id) {
        TDSqlite sqlite = new TDSqlite(context, TDSqlite.DB_ST);
        return sqlite.getTasks(appId, client_user_id);
    }

    public static int getTaskCount(Context context, String appId, String client_user_id) {
        TDSqlite sqlite = new TDSqlite(context, TDSqlite.DB_ST);
        if (client_user_id == null)
            return sqlite.getCount(TDSqlite.TABLE_TASK, null, null);
        else
            return sqlite.getCount(TDSqlite.TABLE_TASK, TDSqlite.KEY_CLIENT_UID, client_user_id);
    }

    public static int getCount(Context context, String db_name, String table_name, String filter_key, String filter_value) {
        TDSqlite sqlite = new TDSqlite(context, db_name);
        return sqlite.getCount(table_name, filter_key, filter_value);
    }

    public static int getCount(Context context, String db_name, String table_name, JSONObject filters) {
//        filters = (Map<String,String>)filters;
        TDSqlite sqlite = new TDSqlite(context, db_name);
        return sqlite.getCount(table_name, filters);
    }

    public static int getEventTriggerCount(Context context, String appId, String task_id) {
        TDSqlite sqlite = new TDSqlite(context, TDSqlite.DB_ST);
        if (task_id == null)
            return sqlite.getCount(TDSqlite.TABLE_EVENT_RIGGER, null, null);
        else
            return sqlite.getCount(TDSqlite.TABLE_EVENT_RIGGER, TDSqlite.KEY_TASK_ID, task_id);
    }

    public static int getTaskTriggerCount(Context context, String appId, String task_id) {
        TDSqlite sqlite = new TDSqlite(context, TDSqlite.DB_ST);
        if (task_id == null)
            return sqlite.getCount(TDSqlite.TABLE_TASK_TRIGGER, null, null);
        else
            return sqlite.getCount(TDSqlite.TABLE_TASK_TRIGGER, TDSqlite.KEY_TASK_ID, task_id);
    }

    public static int getChannelTriggerCount(Context context, String appId, String channel_id) {
        TDSqlite sqlite = new TDSqlite(context, TDSqlite.DB_ST);
        if (channel_id == null)
            return sqlite.getCount(TDSqlite.TABLE_CHANNEL_TRIGGER, null, null);
        else
            return sqlite.getCount(TDSqlite.TABLE_CHANNEL_TRIGGER, TDSqlite.KEY_CHANNEL_ID, channel_id);
    }

    public static JSONArray getAllUsers(Context context, String appid) {
        TDSqlite sqlite = new TDSqlite(context);
        return sqlite.getAllUsers(appid);
    }

    public static int getUserCount(Context context, String appid) {
        TDSqlite sqlite = new TDSqlite(context);
        JSONArray array = sqlite.getAllUsers(appid);
//      Log.i("hh","length:"+array.length());
        return array.length();
    }

    public static JSONArray getUserIDs(Context context, String appid) {
        TDSqlite sqlite = new TDSqlite(context);
        return sqlite.getUserIDByFilter(appid, null, null);
    }

    public static JSONArray getUserByAccountId(Context context, String appid, String account_id) {
        TDSqlite sqlite = new TDSqlite(context);
        return sqlite.getUserByFilter(appid, TDSqlite.KEY_ACCOUNT_ID, account_id);
    }

    public static JSONArray getUserByDistinctId(Context context, String appid, String distinct_id) {
        TDSqlite sqlite = new TDSqlite(context);
        return sqlite.getUserByFilter(appid, TDSqlite.KEY_DISTINCT_ID, distinct_id);
    }

    public static JSONArray getUserIDByDistinctId(Context context, String appid, String distinct_id) {
        TDSqlite sqlite = new TDSqlite(context);
        return sqlite.getUserIDByFilter(appid, TDSqlite.KEY_DISTINCT_ID, distinct_id);
    }

    public static JSONArray getUserIDByAccountId(Context context, String appid, String account_id) {
        TDSqlite sqlite = new TDSqlite(context);
        return sqlite.getUserIDByFilter(appid, TDSqlite.KEY_ACCOUNT_ID, account_id);
    }

    /**
     * 删除单个文件
     *
     * @param filePath 被删除文件的文件名
     * @return 文件删除成功返回true，否则返回false
     */
    public static boolean deleteFile(String filePath) {
        File file = new File(filePath);
        if (file.isFile() && file.exists()) {
            return file.delete();
        }
        return false;
    }

    /**
     * 删除文件夹以及目录下的文件
     *
     * @param filePath 被删除目录的文件路径
     * @return 目录删除成功返回true，否则返回false
     */
    public static boolean deleteDirectory(String filePath) {
        boolean flag = false;
        //如果filePath不以文件分隔符结尾，自动添加文件分隔符
        if (!filePath.endsWith(File.separator)) {
            filePath = filePath + File.separator;
        }
        File dirFile = new File(filePath);
        if (!dirFile.exists() || !dirFile.isDirectory()) {
            return false;
        }
        flag = true;
        File[] files = dirFile.listFiles();
        if (files != null && files.length == 0) return true;
        //遍历删除文件夹下的所有文件(包括子目录)
        for (int i = 0; i < files.length; i++) {
            if (files[i].isFile()) {
                //删除子文件
                flag = deleteFile(files[i].getAbsolutePath());
                if (!flag) break;
            } else {
                //删除子目录
                flag = deleteDirectory(files[i].getAbsolutePath());
                if (!flag) break;
            }
        }
        if (!flag) return false;
        //删除当前空目录
        if (filePath.equals("/data/user/0/cn.thinkingdata.thinking_analytics_example/")) {
            return true;
        } else {
            return dirFile.delete();
        }
    }


    /**
     * 根据路径删除指定的目录或文件，无论存在与否
     *
     * @param filePath 要删除的目录或文件
     * @return 删除成功返回 true，否则返回 false。
     */
    public static boolean DeleteFolder(String filePath) {
        File file = new File(filePath);
        if (!file.exists()) {
            return false;
        } else {
            if (file.isFile()) {
                // 为文件时调用删除文件方法
                return deleteFile(filePath);
            } else {
                // 为目录时调用删除目录方法
                return deleteDirectory(filePath);
            }
        }
    }

    private static Object isReturnNull(String method) {
        if (methodList.contains(method)) {
            return "null";
        }
        return true;
    }

    public static String objectToString(Object object) {
        if (object instanceof String) {
            return ( String ) (object);
        } else if (object instanceof JSONObject) {
            return (( JSONObject ) (object)).toString();
        }
        return "";
    }

    public static boolean isEmpty(String str) {
        return str == null || str.length() == 0;
    }

    public static Map<String, String> JSONObjectToMap(JSONObject object) {
        Map<String, String> map = new HashMap<>();
        if (object != null) {
            Iterator<String> keys = object.keys();
            while (keys.hasNext()) {
                String k = keys.next();
                Object v = null;
                try {
                    v = object.get(k);
                    map.put(k, v.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
        return map;
    }

    static boolean isEmpty(JSONArray array) {
        return array == null || array.length() == 0;
    }

    public static boolean jsonArrayContainsValue(JSONArray jsonArray, String searchValue) {
        for (int i = 0; i < jsonArray.length(); i++) {
            try {
                if (jsonArray.getString(i).equals(searchValue)) {
                    return true;
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    public static String getRandomString(String str) {
        if (str == null) return "";
        if (str.contains("random_uuid")) {
            String prefix = str.substring(0, str.lastIndexOf("random"));
            return prefix + UUID.randomUUID().toString();
        } else if (str.contains("random_index")) {
            return str;
        } else if (str.contains("random_")) {
            String prefix = str.substring(0, str.lastIndexOf("random"));
            String n = str.substring(str.lastIndexOf("_") + 1);
            try {
                int number = Integer.parseInt(n);
                Random random = new Random();
                StringBuilder strBuilder = new StringBuilder();
                strBuilder.append(prefix);
                for (int i = 0; i < number; i++) {
                    int r = random.nextInt(10);
                    strBuilder.append(r);
                }
                return strBuilder.toString();
            } catch (Exception e) {
                return prefix;
            }
        } else {
            return str;
        }
    }

    public static Object getDateFormat(String str) {
        try {
            return simpleDateFormat.parse(str);
        } catch (Exception ignore) {
        }
        return str;
    }

    public static JSONObject getDataJson(JSONObject json) {
        if (json == null) return null;
        JSONObject newJson = new JSONObject();
        try {
            Iterator<String> iterator = json.keys();
            while (iterator.hasNext()) {
                String key = iterator.next();
                Object value = json.opt(key);
                if (value instanceof String) {
                    newJson.put(key, getDateFormat(( String ) value));
                } else if (value instanceof JSONObject) {
                    newJson.put(key, getDataJson(( JSONObject ) value));
                } else if (value instanceof JSONArray) {
                    newJson.put(key, getDataJsonArray(( JSONArray ) value));
                } else {
                    newJson.put(key, value);
                }
            }
        } catch (Exception ignore) {
        }
        return newJson;
    }

    public static JSONArray getDataJsonArray(JSONArray array) {
        if (array == null) return null;
        JSONArray newArray = new JSONArray();
        for (int i = 0; i < array.length(); i++) {
            Object value = array.opt(i);
            if (value instanceof String) {
                newArray.put(getDateFormat(( String ) value));
            } else if (value instanceof JSONObject) {
                newArray.put(getDataJson(( JSONObject ) value));
            } else if (value instanceof JSONArray) {
                newArray.put(getDataJsonArray(( JSONArray ) value));
            } else {
                newArray.put(value);
            }
        }
        return newArray;
    }


    public static JSONArray isChangeParamType(String method) {
        if (methodParamList.contains(method)) {
            JSONArray jsonArray = new JSONArray();
            jsonArray.put("String[]");
            return jsonArray;
        } else if (TextUtils.equals(method, "TDAnalytics.calibrateTime")) {
            JSONArray jsonArray = new JSONArray();
            jsonArray.put("long");
            return jsonArray;
        }
        return null;
    }

    public static Object[] changeParamsValues(Object[] ps) {
        String[] strings = new String[ps.length];
        for (int i = 0; i < ps.length; i++) {
            strings[i] = ps[i].toString();
        }
        return new Object[]{strings};
    }

    public static TimeZone getTimeZone(double timeZoneOffset) {
        int hour = ( int ) timeZoneOffset;
        int minute = ( int ) ((timeZoneOffset - hour) * 60);
        if (hour >= 0) {
            return TimeZone.getTimeZone(String.format(Locale.ROOT, "GMT+%02d:%02d", hour, minute));
        } else {
            return TimeZone.getTimeZone(String.format(Locale.ROOT, "GMT%02d:%02d", hour, minute));
        }
    }

    public static String getPerformanceInfo() {
        return "";
    }

    public static Object tdRemoteConfigChainGet(JSONArray a1, JSONObject obj, JSONArray a2, String type) {
        return "";
    }

    public static int queryEventCount() {
        TDSqlite sqlite = new TDSqlite(mContext, TDSqlite.DB_TA);
        return sqlite.getCount("events", null, null);
    }

    public static int queryEventCountByEventName(String eventName) {
        TDSqlite sqlite = new TDSqlite(mContext, TDSqlite.DB_TA);
        return sqlite.getCount("events", "clickdata", eventName);
    }

    private static List<View> getAllViews(View root) {
        List<View> allViews = new ArrayList<>();
        if (!(root instanceof ViewGroup)) {
            allViews.add(root);
            return allViews;
        }

        ViewGroup viewGroup = ( ViewGroup ) root;
        for (int i = 0; i < viewGroup.getChildCount(); i++) {
            View child = viewGroup.getChildAt(i);
            allViews.addAll(getAllViews(child));
        }
        return allViews;
    }


    public static void addGetMethod(String methodName, long duration) {
        if (!isStartTimeCollect) return;
        try {
            JSONObject jsonItem = new JSONObject();
            jsonItem.put("methodName", methodName);
            jsonItem.put("duration", duration);
            methodGetList.put(jsonItem);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static void startMethodTimeCollect() {
        isStartTimeCollect = true;
    }

    public static JSONArray getMethodTimeCollect() {
        JSONArray str = methodGetList;
        methodGetList = new JSONArray();
        isStartTimeCollect = false;
        return str;
    }

}
