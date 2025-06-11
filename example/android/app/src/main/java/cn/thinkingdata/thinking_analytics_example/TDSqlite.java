package cn.thinkingdata.thinking_analytics_example;

import android.annotation.SuppressLint;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import androidx.annotation.Nullable;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

class TDSqlite extends SQLiteOpenHelper {
   public static final String DB_RC = "td_remote_config.db";
   public static final String DB_ST = "td_strategy.db";
   public static final String DB_TA = "thinkingdata";
   private static String TABLE_RC ="t_users";
   public static String TABLE_TASK ="t_task";
   public static String TABLE_CHANNEL_TRIGGER ="t_channel_trigger";
   public static String TABLE_EVENT_RIGGER="t_event";
   public static String TABLE_TASK_TRIGGER="t_task_trigger";

   public static final String KEY_APP_ID = "app_id";
   private static final int DB_VERSION = 1;
   public static final String KEY_ACCOUNT_ID = "account_id";
   public static final String KEY_DISTINCT_ID = "distinct_id";
   public static final String KEY_CLIENT_USER_ID = "client_uid";

   public static final  String KEY_CLIENT_UID = "client_uid";
   public static final  String KEY_TASK_ID = "task_id";
   public static final  String KEY_CHANNEL_ID = "channel_id";
   public static final  String KEY_TRIGGER_TIME = "trigger_time";

   public static final String KEY_TASK_VERSION = "task_version";
   public static final String KEY_RAW_DATA="raw_data";


   Context context;

   public TDSqlite(@Nullable Context context) {
      super(context, DB_RC, null, DB_VERSION);
      this.context  = context;
   }
   public TDSqlite(@Nullable Context context,String dbName) {
      super(context, dbName, null, DB_VERSION);
      this.context  = context;
   }

   @Override
   public void onCreate(SQLiteDatabase sqLiteDatabase) {

   }

   @Override
   public void onUpgrade(SQLiteDatabase sqLiteDatabase, int i, int i1) {

   }
   /**
    * IDMapping 关系查询
    */
   public JSONArray getAllUsers(String appid)
   {
     return getUserByFilter(appid,null,null);
   }
   @SuppressLint("Range")
   public JSONArray getUserByFilter(String appid,String filter_key,String filter_value)
   {
      Cursor cursor = null;
      JSONArray array = new JSONArray();
//      if(!isDatabaseExists(DB_NAME) && !isTableExists(TABLE_NAME))
//      {
//         return  array;
//      }
      try {
         SQLiteDatabase db = getReadableDatabase();
         if(filter_key != null && filter_key.length() >= 0)
         {
            cursor = db.query(TABLE_RC, null, KEY_APP_ID + "=? AND "+filter_key + "=?", new String[]{appid,filter_value}, null, null, null);
         }else
         {
            cursor = db.query(TABLE_RC, null, KEY_APP_ID + "=?", new String[]{appid}, null, null, null);
         }

         if (cursor.moveToFirst()) {
            do {
               JSONObject object = new JSONObject();
               object.put(KEY_APP_ID,cursor.getString(cursor.getColumnIndex(KEY_APP_ID)));
               object.put(KEY_ACCOUNT_ID,cursor.getString(cursor.getColumnIndex(KEY_ACCOUNT_ID)));
               object.put(KEY_DISTINCT_ID,cursor.getString(cursor.getColumnIndex(KEY_DISTINCT_ID)));
               object.put(KEY_CLIENT_USER_ID,cursor.getString(cursor.getColumnIndex(KEY_CLIENT_USER_ID)));
               array.put(object);
            } while (cursor.moveToNext());
         }
         cursor.close();
         db.close();
      } catch (Exception e) {
         array.put(e.toString());
      } finally {
         if (null != cursor) {
            cursor.close();
         }
      }
      return  array;
   }
   @SuppressLint("Range")
   public JSONArray getUserIDByFilter(String appid,String filter_key,String filter_value)
   {
      Cursor cursor = null;
      JSONArray array = new JSONArray();
      try {
         SQLiteDatabase db = getReadableDatabase();
         if(filter_key != null && filter_key.length() >= 0)
         {
            if(filter_value != null)
            {
               cursor = db.query(TABLE_RC,new String[]{KEY_CLIENT_USER_ID}, KEY_APP_ID + "=? AND "+filter_key + "=?", new String[]{appid,filter_value}, null, null, null);
            }else
            {
               cursor = db.query(TABLE_RC,new String[]{KEY_CLIENT_USER_ID}, KEY_APP_ID + "=? AND "+filter_key + " IS NULL", new String[]{appid}, null, null, null);
            }

         }else
         {
            cursor = db.query(TABLE_RC, new String[]{KEY_CLIENT_USER_ID}, KEY_APP_ID + "=?", new String[]{appid}, null, null, null);
         }

         if (cursor.moveToFirst()) {
            do {
               String client_user_id = cursor.getString(cursor.getColumnIndex(KEY_CLIENT_USER_ID));
               array.put(cursor.getString(cursor.getColumnIndex(KEY_CLIENT_USER_ID)));
//               if(!TDUtil.jsonArrayContainsValue(array,client_user_id))
//               {
//                  array.put(cursor.getString(cursor.getColumnIndex(KEY_CLIENT_USER_ID)));
//               }
//               JSONObject object = new JSONObject();
//               object.put(KEY_CLIENT_USER_ID,cursor.getString(cursor.getColumnIndex(KEY_CLIENT_USER_ID)));
//               array.put(object);
            } while (cursor.moveToNext());
         }
         cursor.close();
         db.close();
      } catch (Exception e) {
         array.put(e.toString());
      } finally {
//         if(array.length() == 0 )
//         {
//            array.put("查询数据为空，filter不匹配");
//         }
         if (null != cursor) {
            cursor.close();
         }
      }
      return  array;
   }

   /**
    * 客户端触发记录查询
    */
   @SuppressLint("Range")
   public JSONArray getTriggerRecord(String appId,String uid,String taskId,long triggerTime)
   {
      Cursor cursor = null;
      JSONArray array = new JSONArray();
      try {
         SQLiteDatabase db = getReadableDatabase();
         cursor = db.query(TABLE_TASK_TRIGGER, null, KEY_APP_ID + "=? AND "+ KEY_CLIENT_UID+"=? AND "+KEY_TASK_ID+"=? AND "+KEY_TRIGGER_TIME+">?", new String[]{appId,uid,taskId,triggerTime+""}, null, null, null);
         if (cursor.moveToFirst()) {
            do {
               JSONObject object = new JSONObject();
               object.put(KEY_APP_ID,cursor.getString(cursor.getColumnIndex(KEY_APP_ID)));
               object.put(KEY_TASK_ID,cursor.getString(cursor.getColumnIndex(KEY_TASK_ID)));
               object.put(KEY_CLIENT_UID,cursor.getString(cursor.getColumnIndex(KEY_CLIENT_UID)));
               object.put(KEY_TRIGGER_TIME,cursor.getLong(cursor.getColumnIndex(KEY_TRIGGER_TIME)));
               array.put(object);
            } while (cursor.moveToNext());
         }
         cursor.close();
         db.close();
      } catch (Exception e) {
         array.put(e.toString());
      } finally {
         if (null != cursor) {
            cursor.close();
         }
      }
      return  array;
   }
   public boolean insertTask(String appId,String clientUid,String taskId,String rawData,long taskVersion)
   {
      SQLiteDatabase db = getWritableDatabase();
      ContentValues values = new ContentValues();
      values.put(KEY_APP_ID, appId);
      values.put(KEY_CLIENT_UID, clientUid);
      values.put(KEY_TASK_ID, taskId);
      values.put(KEY_RAW_DATA,rawData);
      values.put(KEY_TASK_VERSION, taskVersion);
      long count = db.insert(TABLE_TASK, null, values);
      try {
         db.insert(TABLE_TASK, null, values);
      }catch (Exception e)
      {
         return false;
      }
      return true;
   }
   @SuppressLint("Range")
   public JSONArray getTasks(String appId,String client_uid)
   {
      Cursor cursor = null;
      JSONArray array = new JSONArray();
      try {
         SQLiteDatabase db = getReadableDatabase();
         if(client_uid != null)
         {
            cursor = db.query(TABLE_TASK, null,KEY_APP_ID + "=? AND "+ KEY_CLIENT_UID+"=?", new String[]{appId,client_uid}, null, null, null);
         }else
         {
            cursor = db.query(TABLE_TASK, null,KEY_APP_ID + "=?", new String[]{appId}, null, null, null);
         }
         if (cursor.moveToFirst()) {
            do {
               JSONObject object = new JSONObject();
               object.put(KEY_APP_ID,cursor.getString(cursor.getColumnIndex(KEY_APP_ID)));
               object.put(KEY_TASK_ID,cursor.getString(cursor.getColumnIndex(KEY_TASK_ID)));
               object.put(KEY_CLIENT_UID,cursor.getString(cursor.getColumnIndex(KEY_CLIENT_UID)));
               object.put(KEY_TASK_VERSION,cursor.getLong(cursor.getColumnIndex(KEY_TASK_VERSION)));
               array.put(object);
            } while (cursor.moveToNext());
         }
         cursor.close();
         db.close();
      } catch (Exception e) {
         array.put(e.toString());
      } finally {
         if (null != cursor) {
            cursor.close();
         }
      }

//      SQLiteDatabase db = getWritableDatabase();
//      ContentValues values = new ContentValues();
//      values.put(KEY_APP_ID, appId);
//      values.put(KEY_CLIENT_UID, clientUid);
//      values.put(KEY_TASK_ID, taskId);
//      values.put(KEY_RAW_DATA,rawData);
//      values.put(KEY_TASK_VERSION, taskVersion);
//      long count = db.insert(TABLE_TASK, null, values);
      return array;
   }
   public int getCount(String table,String filterKey,String filterValue)
   {
      SQLiteDatabase db = getReadableDatabase();
      Cursor cursor;
      if(filterKey != null && filterValue!= null)
      {
         cursor = db.rawQuery("SELECT COUNT(*) FROM "+table+" where "+ filterKey +"=?",new String[]{filterValue});
      }else
      {
         cursor = db.rawQuery("SELECT COUNT(*) FROM "+table, null);
      }
      int count = 0;
      if (cursor.moveToFirst()) {
         count = cursor.getInt(0);
      }
      cursor.close();
      return  count;
   }

   public int getLikeCount(String table,String filterKey,String filterValue)
   {
      SQLiteDatabase db = getReadableDatabase();
      Cursor cursor;
      if(filterKey != null && filterValue!= null)
      {
         cursor = db.rawQuery("SELECT COUNT(*) FROM "+table+" where "+ filterKey +"LIKE ?",new String[]{"%" + filterValue + "%"});
      }else
      {
         cursor = db.rawQuery("SELECT COUNT(*) FROM "+table, null);
      }
      int count = 0;
      if (cursor.moveToFirst()) {
         count = cursor.getInt(0);
      }
      cursor.close();
      return  count;
   }

   public int getCount(String table, JSONObject filters)
   {
      SQLiteDatabase db = getReadableDatabase();
      Cursor cursor;
      if(filters != null && filters.length()>=0)
      {
         String[] filterValues = new String[filters.length()];
         String sql = "SELECT COUNT(*) FROM "+table+" where ";
         int index = 0;
         Iterator<String> keys = filters.keys();
         while (keys.hasNext())
         {
            String key = keys.next();
            if(index !=0)
            {
               sql=sql +" AND "+key+"=?";
            }else
            {
               sql=sql + key+"=?";
            }
            String filterValue = "";
            Object value = filters.opt(key);
            if(value.getClass().equals(Long.class)
                    || value.getClass().equals(Integer.class)
                    || value.getClass().equals(Double.class))
               filterValue +=value;
            else
               filterValue = (String) value;
            filterValues[index++]=filterValue;
         }
         cursor = db.rawQuery(sql,filterValues);
//         cursor = db.rawQuery(sql,filterValues);
////         cursor = db.rawQuery("SELECT COUNT(*) FROM t_task where app_id='381f8bbad66c41a18923089321a1ba6f'",null);
      }else
      {
         cursor = db.rawQuery("SELECT COUNT(*) FROM "+table, null);
      }
      int count = 0;
      if (cursor.moveToFirst()) {
         count = cursor.getInt(0);
      }
      cursor.close();
      return  count;
   }
   public boolean isDatabaseExists(String dbName)
   {
      File dbFile = context.getDatabasePath(dbName);
      return  dbFile.exists();
   }
   public boolean isTableExists(String tableName) {
      SQLiteDatabase db = this.getReadableDatabase();
      Cursor cursor = db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "'", null);
      boolean exists = (cursor.getCount() > 0);
      cursor.close();
      return exists;
   }
}
