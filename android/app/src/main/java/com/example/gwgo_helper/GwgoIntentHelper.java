package com.example.gwgo_helper;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Looper;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.example.gwgo_helper.map.LeitaiMapActivity;
import com.example.gwgo_helper.map.SelectAreaMapActivity;
import com.example.gwgo_helper.map.SelectLocationMapActivity;
import com.example.gwgo_helper.map.SelectScanningPointMapActivity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import static android.content.Context.TELEPHONY_SERVICE;

class GwgoIntentHelper implements MethodChannel.MethodCallHandler {

    public static String CHANNEL = "com.pollex.gwgo/plugin";

    static MethodChannel channel;

    /**
     * 跳转地图选择位置的code
     */
    private final int REQUEST_CODE_LOCATION = 0x002;
    private final int REQUEST_CODE_PERMISSION = 0x001;
    private final int REQUEST_CODE_SELECT_AREA = 0x003;

    private MockService mockService;
    private boolean isReceive = false;
    private boolean isStart = false;

    private Activity activity;
    private LocationListener locationListener;
    private MethodChannel.Result result;
    private LocationManager locationManager;

    private MethodChannel.Result resultTemp;

    private GwgoIntentHelper(Activity activity) {
        this.activity = activity;
        createLocationListener();
    }

    public static GwgoIntentHelper registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL);
        GwgoIntentHelper instance = new GwgoIntentHelper(registrar.activity());
        // setMethodCallHandler在此通道上接收方法调用的回调
        channel.setMethodCallHandler(instance);
        return instance;
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            switch (requestCode) {
                case REQUEST_CODE_LOCATION:
                    String locationJson = data.getStringExtra(SelectLocationMapActivity.RESULT_KEY);
                    channel.invokeMethod("setMockLocation", locationJson);
                    break;
                case REQUEST_CODE_PERMISSION:
                    processDeviceId(resultTemp, false);
                    break;
                case REQUEST_CODE_SELECT_AREA:
                    String result = data.getStringExtra(SelectAreaMapActivity.RESULT_KEY);
                    channel.invokeMethod("setArea", result);
                default:
                    break;

            }

        }
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        // 通过MethodCall可以获取参数和方法名，然后再寻找对应的平台业务，本案例做了2个跳转的业务

        Log.d("native", "onMethodCall");
        // 接收来自flutter的指令oneAct
        if (methodCall.method.equals("teleport")) {
            double lat = methodCall.argument("lat");
            double lon = methodCall.argument("lon");
            boolean isStartGame = methodCall.argument("startGame");
            String plain = methodCall.argument("plain");
            if (TextUtils.isEmpty(plain)) {
                plain = "自带飞行器";
            }
            Intent intent = new Intent();
            switch (plain) {
                case "自带飞行器":
                    intent.setComponent(new ComponentName(activity, MockService.class));
                    intent.putExtra("lat", lat);
                    intent.putExtra("lon", lon);
                    intent.setAction(MockService.Companion.getTELEPORT());
                    activity.startService(intent);
                    break;
                case "咬她的飞行器":
                    intent.setAction("com.yaota.TELEPORT");
                    intent.putExtra("lat", (float) lat);
                    intent.putExtra("lng", (float) lon);
                    intent.putExtra("alt", 1.666f);
                    intent.setPackage("com.tencent.yaota");
                    break;
                case "小主播的飞行器":
                    intent.setAction("com.xiaozhubo.TELEPORT");
                    intent.putExtra("lat", (float) lat);
                    intent.putExtra("lng", (float) lon);
                    intent.putExtra("alt", 1.666f);
                    intent.setPackage("com.tencent.xiaozhubo");
                    break;
                case "小莫哥的飞行器":
                    intent.setAction("com.xiaomoge.TELEPORT");
                    intent.putExtra("lat", (float) lat);
                    intent.putExtra("lng", (float) lon);
                    intent.putExtra("alt", 1.666f);
                    intent.setPackage("com.tencent.xiaomoge");
                    break;
                default:
                    break;
            }
            activity.startService(intent);

            // 是否启动游戏
            PackageManager packageManager = activity.getPackageManager();
            if (isStartGame) {
                Intent intent2 = packageManager.getLaunchIntentForPackage("com.tencent.gwgo");
                if (intent2 == null) {
                    Toast.makeText(activity, "未安装", Toast.LENGTH_LONG).show();
                } else {
                    activity.startActivity(intent2);
                }
            }
            // 返回给flutter的参数
            result.success("success");
        } else if (methodCall.method.equals("getLocation")) {
            LocationManager locationManager = (LocationManager) activity.getSystemService(Service.LOCATION_SERVICE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (activity.checkSelfPermission(
                        Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                        && activity.checkSelfPermission(
                        Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(activity, "请授予指示器定位权限", Toast.LENGTH_SHORT).show();
                    result.success(null);
                    return;
                }
            }

            // Criteria criteria = new Criteria();
            // criteria.setAccuracy(Criteria.ACCURACY_FINE);
            // criteria.setSpeedRequired(true);
            locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 1000, locationListener,
                    Looper.myLooper());
            this.result = result;
        } else if (methodCall.method.equals("getImei")) {

            processDeviceId(result, true);

        } else if (methodCall.method.equals("toast")) {
            String content = (String) methodCall.arguments;
            Toast.makeText(activity, content, Toast.LENGTH_SHORT).show();
            result.success("success");

        } else if (methodCall.method.equals("openAir")) {
            Log.d("native", "openAir");
            double lat = methodCall.argument("lat");
            double lon = methodCall.argument("lon");
            boolean start = methodCall.argument("start");
            if (start) {
                Log.d("native", "打开模拟位置");
            } else {
                Log.d("native", "关闭模拟位置");
            }
            Intent intent = new Intent(activity, MockService.class);
            intent.putExtra("lat", lat);
            intent.putExtra("lon", lon);
            intent.putExtra("start", start);
            intent.setAction(MockService.Companion.getTELEPORT());
            activity.startService(intent);
            result.success("success");
        } else if (methodCall.method.equals("float")) {
            Log.d("native", "操作悬浮窗");
            if (new FloatWindowHelper().requestPermission(activity)) {
                boolean showFloat = methodCall.argument("float");
                Intent intent = new Intent(activity, MockService.class);
                intent.putExtra("float", showFloat);
                intent.setAction(MockService.Companion.getTELEPORT());
                activity.startService(intent);
                result.success("success");
            } else {
                result.success("failed");
            }

        } else if (methodCall.method.equals("closePlain")) {
            Log.d("native", "关闭飞机");
        } else if (methodCall.method.equals("getAirStatus")) {
            Log.d("native", "获取飞行器状态");

            ServiceConnection conn = new ServiceConnection() {

                @Override
                public void onServiceDisconnected(ComponentName name) {

                }

                @Override
                public void onServiceConnected(ComponentName name, IBinder iBinder) {
                    // 返回一个MsgService对象
                    mockService = ((MockBinder) iBinder).getService();
                    isReceive = true;
                    if (null != mockService) {
                        isStart = mockService.isStart();
                    }
                }
            };

            Intent intent = new Intent(activity, MockService.class);
            intent.setAction(MockService.Companion.getTELEPORT());
            activity.bindService(intent, conn, Context.BIND_AUTO_CREATE);

            while (!isReceive) {
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            result.success(isStart);
        } else if (methodCall.method.equals("leitaiMap")) {
            String json = (String) methodCall.arguments;
            Log.d("pollex", "json = " + json);
            LeitaiMapActivity.Companion.start(activity, json);
            result.success("ok");
        } else if (methodCall.method.equals("mockLocation")) {
            // String json = (String) methodCall.arguments;
            // Log.d("pollex", "json = " + json);
            SelectLocationMapActivity.Companion.start(activity, REQUEST_CODE_LOCATION);
            result.success("ok");
        } else if (methodCall.method.equals("openSelectAreaPage")) {
            // 选择扫描区域
            SelectScanningPointMapActivity.Companion.start(activity, REQUEST_CODE_SELECT_AREA);
//            SelectAreaMapActivity.Companion.start(activity, REQUEST_CODE_SELECT_AREA);
            result.success("ok");
        } else if (methodCall.method.equals("openQQ")) {
            String qq = (String) methodCall.arguments;
            String url = "mqqwpa://im/chat?chat_type=wpa&uin=" + qq;//uin是发送过去的qq号码
            activity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
        }
    }

    private void processDeviceId(MethodChannel.Result result, boolean isFirst) {
        // Android6.0需要动态获取权限
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && activity.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            // 无权限
            if (isFirst) {
                resultTemp = result;
                activity.requestPermissions(new String[]{Manifest.permission.READ_PHONE_STATE,
                                Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION},
                        REQUEST_CODE_PERMISSION);
            } else {
                result.success(null);
                resultTemp = null;
            }
        } else {
            // 有权限 或者小于M
            TelephonyManager telephonyManager = (TelephonyManager) activity.getSystemService(TELEPHONY_SERVICE);
            List<String> imeiList = new ArrayList<>();
            if (telephonyManager == null) {
                result.success(null);
                return;
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                String deviceId = Settings.System.getString(activity.getContentResolver(), Settings.Secure.ANDROID_ID);
                imeiList.add(deviceId);
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                for (int slot = 0; slot < telephonyManager.getPhoneCount(); slot++) {
                    @SuppressLint("HardwareIds") String imei = telephonyManager.getDeviceId(slot);
                    imeiList.add(imei);
                }
            } else {
                @SuppressLint("HardwareIds") String imei = telephonyManager.getDeviceId();
                imeiList.add(imei);
            }
            Map<String, List<String>> params = new HashMap<>();
            params.put("imei", imeiList);
            result.success(params);
            resultTemp = null;
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