package com.example.gwgo_helper

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.drawable.Icon
import android.os.Build


/**
 * 通知栏图标
 */
class NotificationHelper private constructor() {

    var notificationManager: NotificationManager? = null
    var isShow = false
    var listener: OnNotificationClickListener? = null

    companion object {
        const val NOTIFICATION_FLAG = 0X12
        const val CHANNEL_ID = "飞行指示器"
        const val HIDE_FLOAT_FLAG = "hide_float"

        val instance = FloatingDemonHelper.holder
    }

    private object FloatingDemonHelper {
        val holder = NotificationHelper()

    }

    fun init(cont: Context) {
        notificationManager = cont.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = CHANNEL_ID
            val descriptionText = CHANNEL_ID
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val mChannel = NotificationChannel(CHANNEL_ID, name, importance)
            mChannel.description = descriptionText
            notificationManager!!.createNotificationChannel(mChannel)
        }

    }


    /**
     * 显示妖灵布局
     */
    fun showDemon(context: Context): Notification {
        val builder = Notification.Builder(context.applicationContext)
        val intent = Intent(context, MockService::class.java)
        intent.putExtra(HIDE_FLOAT_FLAG, true)
        val actionIntent = PendingIntent.getService(context, 1, intent, PendingIntent.FLAG_CANCEL_CURRENT)
        builder.setLargeIcon(BitmapFactory.decodeResource(context.resources, R.mipmap.indicator_icon))
                .setContentText("飞行指示器持续为您导航")
                .setContentTitle("正在飞行中...")
                .setSmallIcon(R.mipmap.indicator_icon)
                .setWhen(System.currentTimeMillis())
                .setPriority(Notification.PRIORITY_HIGH)
                .setTicker("飞行指示器持续为您导航")
                .setDefaults(Notification.DEFAULT_LIGHTS)
                .addAction(Notification.Action.Builder(Icon.createWithResource(context, R.mipmap.indicator_icon), "显示/隐藏摇杆", actionIntent).build())

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder.setChannelId(CHANNEL_ID)
        }

        val notification = builder.build()
        notification.flags = notification.flags or Notification.FLAG_ONGOING_EVENT or Notification.FLAG_NO_CLEAR
        notificationManager!!.notify(NOTIFICATION_FLAG, notification)
        isShow = true
        if (null != listener) {
            if (isShow) {
                listener!!.show()
            } else {
//                listener!!.show()
            }
        }
        return notification
    }

    /**
     * 隐藏妖灵布局
     */
    fun dismissDemon() {
    }


}

interface OnNotificationClickListener {
    fun hide()
    fun show()
}