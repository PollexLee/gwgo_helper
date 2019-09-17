package com.example.gwgo_helper.map

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.amap.api.maps.AMap
import com.amap.api.maps.model.*
import com.example.gwgo_helper.R
import kotlin.math.max
import kotlin.math.min

class SelectAreaMapActivity : AppCompatActivity() {

    lateinit var aMap: AMap
    lateinit var binding: com.example.gwgo_helper.databinding.ActivityMapSelectAreaBinding

    var startPoint: LatLng? = null
    var endPoint: LatLng? = null
    var polyline: Polyline? = null

    companion object {
        const val RESULT_KEY = "resultKey"

        fun start(context: Activity, requestCode: Int) {
            val intent = Intent(context, SelectAreaMapActivity::class.java)
            context.startActivityForResult(intent, requestCode)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_map_select_area)
        binding.mapView.onCreate(savedInstanceState)
        aMap = binding.mapView.map

        Toast.makeText(this, "请选择起点", Toast.LENGTH_SHORT).show()

        aMap.setOnMapClickListener {
            processClick(it)
        }

        aMap.setOnMarkerDragListener(object : AMap.OnMarkerDragListener {
            override fun onMarkerDragEnd(p0: Marker?) {
                if (p0!!.title.contains("起点")) {
                    startPoint = p0.position
                } else if (p0.title.contains("终点")) {
                    endPoint = p0.position
                }
                drawRect()
            }

            override fun onMarkerDragStart(p0: Marker?) {
                TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
            }

            override fun onMarkerDrag(p0: Marker?) {
                if (p0!!.title.contains("起点")) {
                    startPoint = p0.position
                } else if (p0.title.contains("终点")) {
                    endPoint = p0.position
                }
                drawRect()
            }
        })

        binding.back.setOnClickListener {
            finish()
        }

        binding.done.setOnClickListener {
            if (null == startPoint) {
                Toast.makeText(baseContext, "请选择起点", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            } else if (null == endPoint) {
                Toast.makeText(baseContext, "请选择终点", Toast.LENGTH_SHORT).show()
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

    /**
     * 处理地图点击时间
     */
    private fun processClick(latLng: LatLng) {
        if (null == startPoint) {
            startPoint = latLng
            // 绘制起始图标
            aMap.addMarker(MarkerOptions().position(latLng).draggable(true)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.start))
                    .title("起点，长按拖动"))
            Toast.makeText(this, "请选择终点", Toast.LENGTH_SHORT).show()

        } else if (null == endPoint) {
            endPoint = latLng
            // 绘制结束图标
            aMap.addMarker(MarkerOptions().position(latLng).draggable(true)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.end))
                    .title("终点，长按拖动"))
            // 绘制矩形
            drawRect()
        }
    }

    private fun drawRect() {
        if (null != polyline) {
            polyline!!.remove()
        }
        polyline = aMap.addPolyline(PolylineOptions().addAll(createRectangle(startPoint!!, endPoint!!))
                .color(Color.RED)
                .width(10F)
        )
    }

    private fun createRectangle(start: LatLng, end: LatLng): List<LatLng> {
        val latLngs = ArrayList<LatLng>()
        latLngs.add(start)
        latLngs.add(LatLng(start.latitude, end.longitude))
        latLngs.add(end)
        latLngs.add(LatLng(end.latitude, start.longitude))
        latLngs.add(start)
        return latLngs
    }

}