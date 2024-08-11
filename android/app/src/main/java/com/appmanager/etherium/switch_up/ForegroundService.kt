package com.example.gobbl

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import java.util.*

class ForegroundService : Service() {
    private var timer: Timer = Timer()
    private lateinit var mHomeWatcher: HomeWatcher
    private lateinit var window: Window

    override fun onBind(intent: Intent): IBinder? {
        println("ForegroundService: onBind called")
        return null
    }

    override fun onCreate() {
        super.onCreate()
        println("ForegroundService: onCreate called")

        val channelId = "AppLock-10"
        val channel = NotificationChannel(
            channelId,
            "Channel human readable title",
            NotificationManager.IMPORTANCE_DEFAULT
        )
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("")
            .setContentText("").build()
        startForeground(1, notification)

        window = Window(this)
        mHomeWatcher = HomeWatcher(this)
        mHomeWatcher.setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
            override fun onHomePressed() {
                println("ForegroundService: Home button pressed")
                closeWindow()
            }

            override fun onHomeLongPressed() {
                println("ForegroundService: Recent apps button pressed")
                closeWindow()
            }
        })
        mHomeWatcher.startWatch()
        startMonitoringApps()
    }

    override fun onDestroy() {
        println("ForegroundService: onDestroy called")
        timer.cancel()
        mHomeWatcher.stopWatch()
        super.onDestroy()
    }

    private fun startMonitoringApps() {
        println("ForegroundService: Starting to monitor apps")
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                monitorForegroundApp()
            }
        }, 0, 500)
    }

   private fun monitorForegroundApp() {
    val saveAppData: SharedPreferences = getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
    val lockedAppList = saveAppData.getString("app_data", "AppList")!!
        .replace("[", "")
        .replace("]", "")
        .split(",")
        .map { it.trim() }

    val usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
    val time = System.currentTimeMillis()
    val usageEvents = usageStatsManager.queryEvents(time - 5000, time)
    val event = UsageEvents.Event()

    while (usageEvents.hasNextEvent()) {
        usageEvents.getNextEvent(event)

        if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
            if (lockedAppList.contains(event.packageName)) {
                println("ForegroundService: Locked app opened - ${event.packageName}")
                if (!window.isOpen()) {
                    Handler(Looper.getMainLooper()).post {
                        window.open()
                    }
                }
            } else if (window.isOpen()) {
                println("ForegroundService: Unlocked app detected, closing lock screen")
                closeWindow()
            }
        }
    }
}


   public fun closeWindow() {
    if (window.isOpen()) {
        window.close()
    }
}
}