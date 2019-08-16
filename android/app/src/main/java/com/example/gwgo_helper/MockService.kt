package com.example.gwgo_helper

import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Criteria
import android.location.Location
import android.location.LocationManager
import android.location.LocationProvider
import android.os.*
import android.util.Log
import android.widget.Toast
import com.example.gwgo_helper.widget.RockerView
import java.util.*

/**
 * 用户模拟位置的服务
 */
class MockService : Service() {

    companion object {
        var TELEPORT: String = "com.zhishiqi.TELEPORT"
    }

    private var locationManager: LocationManager? = null

    private var handler: Handler? = null
    var lat: Double = Double.MIN_VALUE
    var lon: Double = Double.MIN_VALUE
    // 是否启动了模拟位置
    var isStart = false
    var floatWindowHelper: FloatWindowHelper? = null
    var isStartMove = false

    override fun onCreate() {
        Log.d("native", "onCreate")
        super.onCreate()
        handler = Handler {
            when (it.what) {
                1 -> {
                    notifyLocation(lon, lat)
                    handler?.sendEmptyMessageDelayed(1, 1000)!!
                }

                else -> {
                    handler?.sendEmptyMessageDelayed(1, 1000)!!
                }
            }
        }
        if (locationManager == null) {
            locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        }
    }

    /**
     * 收到服务启动的消息
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("native", "onStartCommand")
        // 启动悬浮窗 （从经纬度参数位置起飞）
        if (null != intent) {
            if (intent.hasExtra("lat")) {
                lat = intent.getDoubleExtra("lat", 0.0)
                lon = intent.getDoubleExtra("lon", 0.0)
                if (intent.hasExtra("start")) {
                    val start = intent.getBooleanExtra("start", true)
                    if (start) {
                        startMockLocation()
                    } else {
                        stopMockLocation()
                    }
                }
            } else if (intent.hasExtra("float")) {
                if (floatWindowHelper == null) {
                    floatWindowHelper = FloatWindowHelper()
                }
                var isOpenFloatingWindow = intent.getBooleanExtra("float", false)
                if (isOpenFloatingWindow) {
                    floatWindowHelper!!.showFloatingWindow(this)
                    floatWindowHelper!!.rockerView!!.setCallBackMode(RockerView.CallBackMode.CALL_BACK_MODE_MOVE)

                    floatWindowHelper!!.rockerView!!.setOnAngleChangeListener(object : RockerView.OnAngleChangeListener {
                        override fun onStart() {
                            isStartMove = true
                        }

                        override fun angle(angle: Double, lenXY: Float, lenX: Float, lenY: Float) {
                            Log.d("pollex", "lenX = $lenX, lenY = $lenY")
                            if (isStartMove) {
                                // 手机屏幕上的座标距离
                                val x: Double
                                val y: Double
                                val bigLen = 150
                                if (lenXY <= bigLen) {
                                    x = lenX.toDouble()
                                    y = lenY.toDouble()
                                } else {
                                    when (angle) {
                                        in 0.toDouble()..90.toDouble() -> {
                                            y = Math.sin(Math.toRadians(angle)) * bigLen
                                            x = Math.cos(Math.toRadians(angle)) * bigLen
                                        }
                                        in 90.toDouble()..180.toDouble() -> {
                                            y = Math.sin(Math.toRadians(180 - angle)) * bigLen
                                            x = -Math.cos(Math.toRadians(180 - angle)) * bigLen
                                        }
                                        in 180.toDouble()..270.toDouble() -> {
                                            y = -Math.sin(Math.toRadians(angle - 180)) * bigLen
                                            x = -Math.cos(Math.toRadians(angle - 180)) * bigLen
                                        }
                                        in 270.toDouble()..360.toDouble() -> {
                                            y = -Math.sin(Math.toRadians(360 - angle)) * bigLen
                                            x = Math.cos(Math.toRadians(360 * angle)) * bigLen
                                        }
                                        else -> {
                                            y = 0.0
                                            x = 0.0
                                        }
                                    }
                                }
                                lat -= y / 18000000
                                lon += x / 18000000
                            }
                        }

                        override fun onFinish() {
                            isStartMove = false
                        }
                    })
                } else {
                    floatWindowHelper!!.dismissFloatingWindow()
                }
            } else if (intent.hasExtra(NotificationHelper.HIDE_FLOAT_FLAG)) {
                val isHide = intent.getBooleanExtra(NotificationHelper.HIDE_FLOAT_FLAG, false)
                if (isHide) {
                    if(floatWindowHelper!!.isShow){
                        floatWindowHelper!!.dismissFloatingWindow()
                    } else {
                        floatWindowHelper!!.showFloatingWindow(this)

                    }
                }
            }

        }

        return super.onStartCommand(intent, flags, startId)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return MockBinder(this)
    }

    /**
     * 启动模拟位置
     */
    private fun startMockLocation() {
        if (!isStart) {
            // 启动
            if (isOpenMockLocation()) {
                // 开启了模拟位置
                handler!!.sendEmptyMessage(1)
                isStart = true
                Toast.makeText(this, "起飞成功", Toast.LENGTH_LONG).show()
                NotificationHelper.instance.init(this)
                startForeground(NotificationHelper.NOTIFICATION_FLAG, NotificationHelper.instance.showDemon(this))
            } else {
                // 没有开启模拟位置
                stopForeground(true)
                Toast.makeText(this, "请确认是否授予了获取位置权限和选中了模拟位置应用", Toast.LENGTH_LONG).show();
            }

        }
    }

    /**
     * 关闭模拟位置
     */
    private fun stopMockLocation() {
        isStart = false
        handler!!.removeCallbacksAndMessages(null)
        Toast.makeText(this, "降落成功", Toast.LENGTH_LONG).show()
        stopForeground(true)
    }


    /**
     * 判断是否获得了模拟位置权限
     */
    private fun isOpenMockLocation(): Boolean {
        try {
            val provider = locationManager?.getProvider(LocationManager.GPS_PROVIDER)
            if (null != provider) {
                locationManager?.addTestProvider(
                        provider.name
                        , provider.requiresNetwork()
                        , provider.requiresSatellite()
                        , provider.requiresCell()
                        , provider.hasMonetaryCost()
                        , provider.supportsAltitude()
                        , provider.supportsSpeed()
                        , provider.supportsBearing()
                        , provider.powerRequirement
                        , provider.accuracy
                )
            } else {
                locationManager?.addTestProvider(
                        LocationManager.GPS_PROVIDER
                        , true, true, false, false, true, true, true
                        , Criteria.POWER_HIGH, Criteria.ACCURACY_FINE
                )
            }
            locationManager?.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)
            locationManager?.setTestProviderStatus(
                    LocationManager.GPS_PROVIDER,
                    LocationProvider.AVAILABLE,
                    null,
                    System.currentTimeMillis()
            );

            // 模拟位置可用
            return true
        } catch (exception: Exception) {
            Log.d("模拟位置异常", exception.localizedMessage)
            return false
        }
    }

    private fun notifyLocation(lon: Double, lat: Double) {
        Log.d("native", "更新位置 lon = $lon , lat = $lat")
        try {
            // 模拟位置（addTestProvider成功的前提下）
            val providerStr = LocationManager.GPS_PROVIDER
            val mockLocation = Location(providerStr) //39.881289,116.407013
            // 经纬度随机加一点
            mockLocation.setLatitude(lat + rand(100, 100000).toDouble() / 10000000000000000)   // 维度（度）
            mockLocation.setLongitude(lon + rand(100, 100000).toDouble() / 10000000000000000)  // 经度（度）
            // 随机高度
            val altitude = rand(99, 99999).toDouble() / 10000
            mockLocation.setAltitude(altitude)    // 高程（米）
            // 方向
            val bearing = rand(0, 360).toFloat()
            mockLocation.setBearing(bearing)   // 方向（度）
            // 速度
            val speed = rand(1, 10).toFloat() / 10
            mockLocation.setSpeed(speed)    //速度（米/秒）
            // 精度
            val accuracy = rand(1, 3).toFloat() / 10
            mockLocation.setAccuracy(accuracy)   // 精度（米）

            mockLocation.setTime(Date().getTime())   // 本地时间
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                mockLocation.setElapsedRealtimeNanos(SystemClock.elapsedRealtimeNanos())
            }
            locationManager?.setTestProviderLocation(providerStr, mockLocation)
        } catch (e: Exception) {
            isStart = false
            handler!!.removeCallbacksAndMessages(null)
            Toast.makeText(this, "模拟位置异常", Toast.LENGTH_LONG).show()
            Log.d("native", "模拟位置异常")
            stopSelf()
            // 防止用户在软件运行过程中关闭模拟位置或选择其他应用
//                        stopMockLocation()
        }
    }

    fun rand(from: Int, to: Int): Int {
        return Random().nextInt(to - from) + from
    }
}

class MockBinder(service: MockService) : Binder() {
    var service: MockService? = service
}