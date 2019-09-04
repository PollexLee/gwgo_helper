package com.example.gwgo_helper.map

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.amap.api.maps.AMap
import com.amap.api.maps.AMapOptions
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.MyLocationStyle
import com.example.gwgo_helper.R
import com.example.gwgo_helper.entity.LeitaiEntity
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.ArrayList


class LeitaiMapActivity : AppCompatActivity() {

    companion object {

        fun start(context: Activity, json: String) {
            val intent = Intent(context, LeitaiMapActivity::class.java)
            intent.putExtra("json", json)
            context.startActivity(intent)
        }
    }

    lateinit var binding: com.example.gwgo_helper.databinding.ActivityMapLeitaiBinding
    lateinit var aMap: AMap

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_map_leitai)


        binding.map.onCreate(savedInstanceState)
        aMap = binding.map.map

        val json: String? = intent.getStringExtra("json")
        val leitaiData = parseJson(json)
        drawLeitais(leitaiData)

        aMap.setOnMarkerClickListener {

            //            it.setMarkerOptions(it.options.title("便便变"))
            it.showInfoWindow()
            true
        }

        initMyLocation()

        initUiSettings()
    }

    private fun parseJson(json: String?): List<LeitaiEntity> {
        return Gson().fromJson(json!!, object : TypeToken<List<LeitaiEntity>>() {}.type)
    }

    /**
     * 绘制所有擂台
     */
    private fun drawLeitais(leitaiList: List<LeitaiEntity>) {
        // 开启线程，绘制图标
        Thread(Runnable {
            // 设置地图集中焦点
            val points: List<MarkerOptions> = leitaiList.map {

                MarkerOptions().position(LatLng(it.latitude.toDouble() / 1000000, it.longtitude.toDouble() / 1000000))
                        .title("呢称：" + it.winner_name)
                        .snippet(it.getSpritesInfo())

            }
            aMap.addMarkers(points as ArrayList<MarkerOptions>?, true)
        }).start()
    }

    private fun initMyLocation() {
        val myLocationStyle = MyLocationStyle()
        myLocationStyle.interval(2000)
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW_NO_CENTER)
        aMap.myLocationStyle = myLocationStyle
        aMap.isMyLocationEnabled = true
    }

    private fun initUiSettings() {
        val uiSettings = aMap.uiSettings
        uiSettings.isRotateGesturesEnabled = false
        uiSettings.isZoomControlsEnabled = false
        uiSettings.isMyLocationButtonEnabled = true
        uiSettings.isScaleControlsEnabled = true
        uiSettings.logoPosition = AMapOptions.LOGO_POSITION_BOTTOM_RIGHT
    }

    override fun finish() {
        aMap.isMyLocationEnabled = false
        super.finish()
    }
}