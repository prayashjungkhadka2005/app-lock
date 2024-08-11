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
    private var isForeground = false

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()

        createNotificationChannel()
        startForegroundService()

        window = Window(this)
        mHomeWatcher = HomeWatcher(this).apply {
            setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
                override fun onHomePressed() {
                    closeWindow()
                }

                override fun onHomeLongPressed() {
                    closeWindow()
                }
            })
        }
        mHomeWatcher.startWatch()
        startMonitoringApps()
    }

    override fun onDestroy() {
        super.onDestroy()
        timer.cancel()
        mHomeWatcher.stopWatch()
    }

    private fun startMonitoringApps() {
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                monitorForegroundApp()
            }
        }, 0, 200) // Check more frequently to catch app changes
    }

    private fun monitorForegroundApp() {
        val saveAppData: SharedPreferences = getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val lockedAppList = saveAppData.getString("app_data", "[]")!!
            .replace("[", "")
            .replace("]", "")
            .split(",")
            .map { it.trim() }

        val usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val usageEvents = usageStatsManager.queryEvents(time - 2000, time)
        val event = UsageEvents.Event()

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)

            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                if (lockedAppList.contains(event.packageName)) {
                    if (!window.isOpen() || !isForeground) {
                        isForeground = true
                        Handler(Looper.getMainLooper()).post { window.open() }
                    }
                } else if (window.isOpen()) {
                    closeWindow()
                    isForeground = false
                }
            }
        }
    }

    private fun createNotificationChannel() {
        val channelId = "AppLock-10"
        val channel = NotificationChannel(channelId, "App Lock", NotificationManager.IMPORTANCE_DEFAULT)
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
    }

    private fun startForegroundService() {
        val notification = NotificationCompat.Builder(this, "AppLock-10")
            .setContentTitle("App Lock Running")
            .setContentText("Monitoring locked apps")
            .build()
        startForeground(1, notification)
    }

    fun closeWindow() {
        if (window.isOpen()) {
            window.close()
        }
        isForeground = false
    }
}
