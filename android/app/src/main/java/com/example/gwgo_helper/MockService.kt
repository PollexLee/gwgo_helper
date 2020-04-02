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
import kotlin.math.cos
import kotlin.math.sin

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
                    handler?.sendEmptyMessageDelayed(1, 500)!!
                }

                else -> {
                    handler?.sendEmptyMessageDelayed(1, 500)!!
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
                                            y = -sin(Math.toRadians(angle - 180)) * bigLen
                                            x = -cos(Math.toRadians(angle - 180)) * bigLen
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
                                lon += x / 14400000
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
                    if (floatWindowHelper!!.isShow) {
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
//            if (addMockProvider()) {
            addMockProvider()
            handler!!.sendEmptyMessage(1)
            isStart = true
            Toast.makeText(this, "起飞成功", Toast.LENGTH_LONG).show()
            NotificationHelper.instance.init(this)
            startForeground(NotificationHelper.NOTIFICATION_FLAG, NotificationHelper.instance.showDemon(this))
//            } else {
//                // 没有开启模拟位置
//                stopForeground(true)
//                Toast.makeText(this, "请确认是否授予了获取位置权限和选中了模拟位置应用", Toast.LENGTH_LONG).show();
//            }

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
    private fun addMockProvider(): Boolean {
//        return true
        try {
            val provider = locationManager?.getProvider(LocationManager.NETWORK_PROVIDER)
//            val provider1 = locationManager?.getProvider(LocationManager.PASSIVE_PROVIDER)
            val provider2 = locationManager?.getProvider("fused")
            val provider3 = locationManager?.getProvider(LocationManager.GPS_PROVIDER)

            if (null != provider) {
                addProvider(provider)
            }
//            if (null != provider1) {
//                addProvider(provider1)
//            }
            if (null != provider2) {
                addProvider(provider2)
            }
            if (null != provider3) {
                addProvider(provider3)
            }
            // 模拟位置可用
            return true
        } catch (exception: Exception) {
            Log.d("模拟位置异常", exception.localizedMessage)
            return true
        }
    }

    /**
     * 给LocationManager添加TestProvider
     */
    private fun addProvider(provider: LocationProvider) {
        try {
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
            locationManager?.setTestProviderEnabled(provider.name, true)
        } catch (e: Exception) {
            print(e.toString())
        }
    }

    private fun notifyLocation(lon: Double, lat: Double) {
        Log.d("native", "更新位置 lon = $lon , lat = $lat")
        try {
            // 模拟位置（addTestProvider成功的前提下）
            locationManager?.setTestProviderLocation(LocationManager.NETWORK_PROVIDER, generateLocation(LocationManager.NETWORK_PROVIDER, lat, lon))
//            locationManager?.setTestProviderLocation(LocationManager.PASSIVE_PROVIDER, generateLocation(LocationManager.PASSIVE_PROVIDER, lat, lon))
            locationManager?.setTestProviderLocation("fused", generateLocation("fused", lat, lon))
            locationManager?.setTestProviderLocation(LocationManager.GPS_PROVIDER, generateLocation(LocationManager.GPS_PROVIDER, lat, lon))
        } catch (e: Exception) {
            isStart = false
            handler!!.removeCallbacksAndMessages(null)
//            Toast.makeText(this, "模拟位置异常", Toast.LENGTH_LONG).show()
            Log.d("native", "模拟位置异常: ${e.localizedMessage}")
//            stopSelf()
            // 防止用户在软件运行过程中关闭模拟位置或选择其他应用
//                        stopMockLocation()
        }
    }

    private fun generateLocation(provider: String, lat: Double, lon: Double): Location {
        val mockLocation = Location(provider) //39.881289,116.407013
        // 经纬度随机加一点
        mockLocation.latitude = lat + rand(1000, 100000).toDouble() / 10000000000000000   // 维度（度）
        mockLocation.longitude = lon + rand(1000, 100000).toDouble() / 10000000000000000  // 经度（度）
        // 随机高度
        val altitude = rand(99, 99999).toDouble() / 10000
        mockLocation.altitude = altitude    // 高程（米）
        // 方向
        val bearing = rand(0, 360).toFloat()
        mockLocation.bearing = bearing   // 方向（度）
        // 速度
        val speed = rand(1, 10).toFloat() / 10
        mockLocation.speed = speed    //速度（米/秒）
        // 精度
        val accuracy = rand(1, 10).toFloat() / 10
        mockLocation.accuracy = accuracy   // 精度（米）

        mockLocation.time = Date().time   // 本地时间
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            mockLocation.elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
        }
        return mockLocation
    }

    fun rand(from: Int, to: Int): Int {
        return Random().nextInt(to - from) + from
    }
}

class MockBinder(service: MockService) : Binder() {
    var service: MockService? = service
}