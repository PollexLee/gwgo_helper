package com.example.gwgo_helper.map

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.amap.api.maps.AMap
import com.amap.api.maps.AMapOptions
import com.amap.api.maps.CameraUpdate
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.MyLocationStyle
import com.example.gwgo_helper.R
import com.example.gwgo_helper.databinding.ActivityMapBinding
import com.example.gwgo_helper.databinding.ActivityMapSelectLocationBinding
import com.google.gson.Gson

/**
 * 选择位置地图页面
 */
class SelectLocationMapActivity : AppCompatActivity() {

    companion object {
        const val RESULT_KEY = "resultKey"

        fun start(context: Activity, requestCode: Int) {
            val intent = Intent(context, SelectLocationMapActivity::class.java)
            context.startActivityForResult(intent, requestCode)
        }
    }

    lateinit var binding: ActivityMapSelectLocationBinding
    lateinit var aMap: AMap
    var selectLocation: LatLng? = null
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
            if (null == selectLocation) {
                Toast.makeText(this, "请选择起飞位置", Toast.LENGTH_LONG).show()
                return@setOnClickListener
            }
            val intent = Intent()
            intent.putExtra(RESULT_KEY, Gson().toJson(selectLocation))
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
        selectLocation = latLng
        aMap.addMarker(MarkerOptions().position(latLng))
    }

    override fun finish() {
        aMap.isMyLocationEnabled = false
        super.finish()
    }
}