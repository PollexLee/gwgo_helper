package com.example.gwgo_helper

import android.annotation.SuppressLint
import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.Context.WINDOW_SERVICE
import android.content.DialogInterface
import android.content.Intent
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.*
import android.widget.EditText
import android.widget.ImageView
import android.widget.Toast
import androidx.core.app.ActivityCompat.startActivityForResult
import com.example.gwgo_helper.widget.RockerView


/**
 * 悬浮窗辅助类
 */
class FloatWindowHelper {

    companion object {
        val REQUEST_CODE = 0x001
    }

    var windowManager: WindowManager? = null
    var floatView: View? = null
    var rockerView: RockerView? = null
    var ivMove: ImageView? = null
    var ivBack: ImageView? = null
    var ivStart: ImageView? = null
    var onAngleChangeListener: RockerView.OnAngleChangeListener? = null
    var isMove = false
    var x = 0
    var y = 0
    var layoutParams: WindowManager.LayoutParams? = null
    var isShow = false

    init {

    }

    /**
     * 申请悬浮窗动态权限
     */
    fun requestPermission(activity: Activity): Boolean {
        if (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    !Settings.canDrawOverlays(activity)
                } else {
                    return true
                }) {
            activity.startActivityForResult(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + activity.packageName)), REQUEST_CODE)
            return false
        } else {
            return true
        }
    }

    /**
     * 显示摇杆
     */
    @SuppressLint("ClickableViewAccessibility")
    fun showFloatingWindow(context: Context) {
        // 设置LayoutParam
        layoutParams = WindowManager.LayoutParams()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            layoutParams!!.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            layoutParams!!.type = WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
        }
        layoutParams!!.format = PixelFormat.RGBA_8888
        layoutParams!!.width = WindowManager.LayoutParams.WRAP_CONTENT
        layoutParams!!.height = WindowManager.LayoutParams.WRAP_CONTENT
        layoutParams!!.x = 800
        layoutParams!!.y = 800
        layoutParams!!.gravity = Gravity.TOP or Gravity.LEFT
        layoutParams!!.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE

        if (null == windowManager || null == floatView) {
            // 获取WindowManager服务
            windowManager = context.getSystemService(WINDOW_SERVICE) as WindowManager
            // 新建悬浮窗控件
            floatView = LayoutInflater.from(context).inflate(R.layout.float_window_layout, null)
            rockerView = floatView!!.findViewById(R.id.rocker_view)
            ivMove = floatView!!.findViewById(R.id.ivMove)
            ivBack = floatView!!.findViewById(R.id.ivBack)
            ivStart = floatView!!.findViewById(R.id.ivCollection)
            rockerView!!.setCallBackMode(RockerView.CallBackMode.CALL_BACK_MODE_MOVE)

            floatView!!.setOnTouchListener { _, event ->
                Log.d("pollex", "event = ${event.action}")
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        isMove = true
                        x = event.rawX.toInt()
                        y = event.rawY.toInt()
                    }
                    MotionEvent.ACTION_UP -> {
                        isMove = false
                    }
                    MotionEvent.ACTION_MOVE -> {
                        if (isMove) {
                            val nowX = event.rawX.toInt()
                            val nowY = event.rawY.toInt()
                            val movedX = nowX - x
                            val movedY = nowY - y
                            x = nowX
                            y = nowY
                            layoutParams!!.x = layoutParams!!.x + movedX
                            layoutParams!!.y = layoutParams!!.y + movedY
                            Log.d("pollex", "movedX = $movedX, movedY = $movedY")
                            windowManager!!.updateViewLayout(floatView, layoutParams)
                        }
                    }
                }
                false
            }

            ivBack!!.setOnClickListener {
                val intent = context.packageManager.getLaunchIntentForPackage("com.tencent.gwgohelper")
                if (intent == null) {
                    Toast.makeText(context, "未安装指示器", Toast.LENGTH_LONG).show()
                } else {
                    context.startActivity(intent)
                }
            }

            ivStart!!.setOnClickListener {
                val inputView = LayoutInflater.from(context).inflate(R.layout.start_dialog_layout, null)
                val name = inputView.findViewById<EditText>(R.id.name)
                val location = inputView.findViewById<EditText>(R.id.location)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    val dialog = AlertDialog.Builder(context).setTitle("收藏位置")
                            .setIcon(R.drawable.ic_star_black_24dp)
                            .setPositiveButton("取消") { dialog, _ ->
                                dialog.dismiss()
                            }.setNegativeButton("确定") { dialog, _ ->
                                val nameText = name.text
                                val locationText = location.text



                                dialog.dismiss()
                            }
                            .setView(inputView).create()

                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                        dialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_PANEL)
                    } else {
                        dialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
                    }
                    dialog.show()
                }
            }
        }
        // 将悬浮窗控件添加到WindowManager
        windowManager!!.addView(floatView, layoutParams)
        isShow = true
    }

    /**
     * 隐藏摇杆
     */
    fun dismissFloatingWindow() {
        if (null != windowManager && null != floatView) {
            windowManager!!.removeView(floatView)
            isShow = false
        }
    }

    fun isShowFloatingWindow(): Boolean {
        return isShow
    }


}