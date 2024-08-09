package com.example.gobbl

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import com.example.gobbl.HomeWatcher
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import java.util.*

class ForegroundService : Service() {
    private var timer: Timer = Timer()
    private var currentAppActivityList = arrayListOf<String>()
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

        println("ForegroundService: Notification channel created and service started in foreground")

        window = Window(this)
        mHomeWatcher = HomeWatcher(this)
        mHomeWatcher.setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
            override fun onHomePressed() {
                println("ForegroundService: Home button pressed")
                currentAppActivityList.clear()
                if (window.isOpen()) {
                    println("ForegroundService: Closing window due to home button press")
                    window.close()
                }
            }

            override fun onHomeLongPressed() {
                println("ForegroundService: Recent apps button pressed")
                currentAppActivityList.clear()
                if (window.isOpen()) {
                    println("ForegroundService: Closing window due to recent apps button press")
                    window.close()
                }
            }
        })
        mHomeWatcher.startWatch()
        println("ForegroundService: HomeWatcher started")
        startMonitoringApps()
    }

    override fun onDestroy() {
        println("ForegroundService: onDestroy called")
        timer.cancel()
        mHomeWatcher.stopWatch()
        println("ForegroundService: Timer canceled and HomeWatcher stopped")
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
    println("ForegroundService: Monitoring foreground apps")
    
    val saveAppData: SharedPreferences = getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
    val lockedAppList = saveAppData.getString("app_data", "AppList")!!
        .replace("[", "")
        .replace("]", "")
        .split(",")
        .map { it.trim() }
    
    val usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
    val time = System.currentTimeMillis()
    val usageEvents = usageStatsManager.queryEvents(time - 10000, time) // Extended time window to 10 seconds
    val event = UsageEvents.Event()

    val runningForegroundApps = mutableListOf<String>()

    println("ForegroundService: Checking locked apps: $lockedAppList")

    while (usageEvents.hasNextEvent()) {
        usageEvents.getNextEvent(event)

        // Debugging: Log all events
        println("Event: Package ${event.packageName}, EventType: ${event.eventType}, ClassName: ${event.className}")

        // Check for resumed apps
        if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
            runningForegroundApps.add(event.packageName)

            if (lockedAppList.contains(event.packageName)) {
                println("ForegroundService: Locked app in foreground detected - ${event.packageName}")
                if (!window.isOpen()) {
                    Handler(Looper.getMainLooper()).post {
                        println("ForegroundService: Attempting to open the lock screen for ${event.packageName}")
                        window.open()
                    }
                }
            }
        }
    }

    println("ForegroundService: Currently running foreground apps: $runningForegroundApps")
}

}
