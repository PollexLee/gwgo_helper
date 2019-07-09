package com.example.gwgo_helper;

import android.Manifest;
import android.app.Activity;
import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Looper;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

class GwgoIntentHelper implements MethodChannel.MethodCallHandler {

    public static String CHANNEL = "com.pollex.gwgo/plugin";

    static MethodChannel channel;

    private Activity activity;
    private LocationListener locationListener;
    private MethodChannel.Result result;
    private LocationManager locationManager;

    private GwgoIntentHelper(Activity activity) {
        this.activity = activity;
        createLocationListener();
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL);
        GwgoIntentHelper instance = new GwgoIntentHelper(registrar.activity());
        // setMethodCallHandler在此通道上接收方法调用的回调
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        // 通过MethodCall可以获取参数和方法名，然后再寻找对应的平台业务，本案例做了2个跳转的业务

        Log.d("Pollex", "onMethodCall");
        // 接收来自flutter的指令oneAct
        if (methodCall.method.equals("teleport")) {
            double lat = methodCall.argument("lat");
            double lon = methodCall.argument("lon");

            PackageManager packageManager = activity.getPackageManager();
            Intent xiaozhuboIntent = packageManager.getLaunchIntentForPackage("com.tencent.xiaozhubo");
            if (xiaozhuboIntent == null) {
                return;
            }
            Intent intent = new Intent("com.xiaozhubo.TELEPORT");
            intent.putExtra("lat", (float) lat);
            intent.putExtra("lng", (float) lon);
            intent.putExtra("alt", 1.666f);
            intent.setPackage("com.tencent.xiaozhubo");
            try {
                ComponentName componentName = activity.startService(intent);

                Toast.makeText(activity, "飞行中...", Toast.LENGTH_SHORT).show();

                Intent intent2 = packageManager.getLaunchIntentForPackage("com.tencent.gwgo");
                if (intent2 == null) {
                    Toast.makeText(activity, "未安装", Toast.LENGTH_LONG).show();
                } else {
                    activity.startActivity(intent2);
                }
            } catch (Exception e) {
                Log.e("GwgoInterHelper", e.getLocalizedMessage());
            }

            // 返回给flutter的参数
            result.success("success");
        } else if (methodCall.method.equals("getLocation")) {
            LocationManager locationManager = (LocationManager) activity.getSystemService(Service.LOCATION_SERVICE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && activity.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(activity, "请授予指示器定位权限", Toast.LENGTH_SHORT).show();
                    result.success(null);
                    return;
                }
            }
            locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 500, 0, locationListener, Looper.myLooper());
            this.result = result;
        } else if (methodCall.method.equals("getImei")) {
            TelephonyManager telephonyManager = (TelephonyManager) activity.getSystemService(Context.TELEPHONY_SERVICE);
            List<String> imeiList = new ArrayList<>();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                for (int slot = 0; slot < telephonyManager.getPhoneCount(); slot++) {
                    String imei = telephonyManager.getDeviceId(slot);
                    imeiList.add(imei);
                }
            } else {
                String imei = telephonyManager.getDeviceId();
                imeiList.add(imei);
            }
            Map<String, List<String>> params = new HashMap<>();
            params.put("imei", imeiList);
            result.success(params);
        } else if (methodCall.method.equals("toast")){
            String content = (String) methodCall.arguments;
            Toast.makeText(activity, content, Toast.LENGTH_SHORT).show();
            result.success("success");
        }
    }

    private void createLocationListener() {
        locationListener = new LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                if (locationManager != null) {
                    locationManager.removeUpdates(locationListener);
                }
                Map<String, Double> params = new HashMap<>();
                params.put("latitude", location.getLatitude());
                params.put("longitude", location.getLongitude());
                if (null != result) {
                    result.success(params);
                    result = null;
                }
            }

            @Override
            public void onStatusChanged(String provider, int status, Bundle extras) {

            }

            @Override
            public void onProviderEnabled(String provider) {

            }

            @Override
            public void onProviderDisabled(String provider) {

            }
        };
    }
}