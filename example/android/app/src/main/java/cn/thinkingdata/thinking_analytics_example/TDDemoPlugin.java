/*
 * Copyright (C) 2025 ThinkingData
 */
package cn.thinkingdata.thinking_analytics_example;

import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import cn.thinkingdata.core.utils.LogUtil;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 *
 * @author liulongbing
 * @since 2025/4/14
 */
public class TDDemoPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    private EventChannel.EventSink eventSink;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        TDUtil.mContext = binding.getApplicationContext();
        MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), "thinkingdata.cn/demo");
        channel.setMethodCallHandler(this);
        EventChannel eventChannel = new EventChannel(binding.getBinaryMessenger(), "thinkingdata.cn/demo/event");
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if(TextUtils.equals(call.method,"clearDisk")){
            boolean isSuccess = TDUtil.clearDisk(TDUtil.mContext);
            result.success(isSuccess);
        }else if(TextUtils.equals(call.method,"setLogListener")){
            LogUtil.setLogPrintListener(new LogUtil.OnLogPrintListener() {
                @Override
                public void onLogPrint(String s, String s1) {
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if(eventSink != null){
                                eventSink.success(s1);
                            }
                        }
                    });
                }
            });
        }
    }
}
