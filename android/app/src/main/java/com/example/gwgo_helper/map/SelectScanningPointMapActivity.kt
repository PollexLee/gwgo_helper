package com.example.gwgo_helper.map

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.amap.api.maps.AMap
import com.amap.api.maps.AMapOptions
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.model.*
import com.example.gwgo_helper.R
import com.example.gwgo_helper.databinding.ActivityMapSelectLocationBinding
import com.google.gson.Gson
import kotlin.math.max
import kotlin.math.min

/**
 * 选择位置地图页面
 */
class SelectScanningPointMapActivity : AppCompatActivity() {

    companion object {
        const val RESULT_KEY = "resultKey"

        fun start(context: Activity, requestCode: Int) {
            val intent = Intent(context, SelectScanningPointMapActivity::class.java)
            context.startActivityForResult(intent, requestCode)
        }
    }

    var startPoint: LatLng? = null
    var endPoint: LatLng? = null

    lateinit var binding: ActivityMapSelectLocationBinding
    lateinit var aMap: AMap
    //    var selectLocation: LatLng? = null
    var isFocus = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_map_select_location)
        binding.map.onCreate(savedInstanceState)
        aMap = binding.map.map
        initMyLocation()

        initUiSettings()

        aMap.setOnMapClickListener {
            println("点击的高德经纬度是${it.latitude},${it.longitude}")
            showLocationMarker(it)
        }

        binding.back.setOnClickListener {
            finish()
        }

        binding.done.setOnClickListener {
            if (null == startPoint) {
                Toast.makeText(baseContext, "请选择地点", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            val minLat = min(startPoint!!.latitude, endPoint!!.latitude)
            val minLong = min(startPoint!!.longitude, endPoint!!.longitude)
            val maxLat = max(startPoint!!.latitude, endPoint!!.latitude)
            val maxLong = max(startPoint!!.longitude, endPoint!!.longitude)
            val intent = Intent()
            intent.putExtra(RESULT_KEY, "$minLat,$minLong|$maxLat,$maxLong")
            setResult(Activity.RESULT_OK, intent)
            finish()
        }
    }

    private fun initMyLocation() {
        val myLocationStyle = MyLocationStyle()
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW_NO_CENTER)
        aMap.myLocationStyle = myLocationStyle
        aMap.isMyLocationEnabled = true

        aMap.setOnMyLocationChangeListener {
            if (!isFocus && it.latitude != 0.0) {
                isFocus = true
                aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(LatLng(it.latitude, it.longitude), 17f))
            }
        }
    }

    private fun initUiSettings() {
        val uiSettings = aMap.uiSettings
        uiSettings.isRotateGesturesEnabled = false
        uiSettings.isZoomControlsEnabled = false
        uiSettings.isMyLocationButtonEnabled = true
        uiSettings.isScaleControlsEnabled = true
        uiSettings.logoPosition = AMapOptions.LOGO_POSITION_BOTTOM_RIGHT
    }

    private fun showLocationMarker(latLng: LatLng) {
        aMap.clear(true)
        startPoint = LatLng(latLng.latitude - 0.02, latLng.longitude - 0.025)
        endPoint = LatLng(latLng.latitude + 0.02, latLng.longitude + 0.025)
        aMap.addMarker(MarkerOptions().position(latLng))
        aMap.addPolygon(PolygonOptions().addAll(createRectangle(latLng, 0.05, 0.04))
                .fillColor(Color.parseColor("#55000000")).strokeColor(Color.RED).strokeWidth(1f))
    }

    private fun createRectangle(center: LatLng, halfWidth: Double, halfHeight: Double): List<LatLng> {
        val latLngs = ArrayList<LatLng>()
        latLngs.add(LatLng(center.latitude - halfHeight, center.longitude - halfWidth))
        latLngs.add(LatLng(center.latitude - halfHeight, center.longitude + halfWidth))
        latLngs.add(LatLng(center.latitude + halfHeight, center.longitude + halfWidth))
        latLngs.add(LatLng(center.latitude + halfHeight, center.longitude - halfWidth))
        return latLngs
    }


    override fun finish() {
        aMap.isMyLocationEnabled = false
        super.finish()
    }
}