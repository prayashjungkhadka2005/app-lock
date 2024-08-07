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
    override fun onBind(intent: Intent): IBinder? {
        throw UnsupportedOperationException("")
    }

    var timer: Timer = Timer()
    var isTimerStarted = false
    var timerReload: Long = 500
    var currentAppActivityList = arrayListOf<String>()
    private var mHomeWatcher = HomeWatcher(this)

    override fun onCreate() {
        super.onCreate()
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
        startMyOwnForeground()
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        println("onStartCommand called with intent: $intent\n\n\n\n\n\n\n\n\n")
        return super.onStartCommand(intent, flags, startId)
    }

    private fun startMyOwnForeground() {
        println("Starting foreground service\n\n\n\n\n\n\n\n\n")

        mHomeWatcher.setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
            override fun onHomePressed() {
                println("onHomePressed\n\n\n\n\n\n\n\n\n")
                currentAppActivityList.clear()
            }

            override fun onHomeLongPressed() {
                println("onHomeLongPressed\n\n\n\n\n\n\n\n\n")
                currentAppActivityList.clear()
            }
        })
        mHomeWatcher.startWatch()
        timerRun()
    }

    override fun onDestroy() {
        println("onDestroy called\n\n\n\n\n\n\n\n\n")
        timer.cancel()
        mHomeWatcher.stopWatch()
        super.onDestroy()
    }

    private fun timerRun() {
        println("Starting timer\n\n\n\n\n\n\n\n\n")
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                isTimerStarted = true
                isServiceRunning()
            }
        }, 0, timerReload)
    }

    private fun isServiceRunning() {
        println("Checking if service is running\n\n\n\n\n\n\n\n\n")
        
        val saveAppData: SharedPreferences = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val lockedAppList: List<String> = saveAppData.getString("app_data", "AppList")!!
            .replace("[", "")
            .replace("]", "")
            .split(",")

               val mUsageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val usageEvents = mUsageStatsManager.queryEvents(time - timerReload, time)
        val event = UsageEvents.Event()

        run breaking@{
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                val currentPackageName = event.packageName.toString().trim() // Capture current package name

                for (element in lockedAppList) {
                    if (currentPackageName == element.trim()) {
                        if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED && currentAppActivityList.isEmpty()) {
                            currentAppActivityList.add(event.className)
                            println("$currentAppActivityList-----List--added\n\n\n\n\n\n\n\n\n")
                            launchDartAuthScreen(currentPackageName) // Pass the current package name
                            return@breaking
                        } else if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                            if (!currentAppActivityList.contains(event.className)) {
                                currentAppActivityList.add(event.className)
                                println("$currentAppActivityList-----List--added\n\n\n\n\n\n\n\n\n")
                            }
                        } else if (event.eventType == UsageEvents.Event.ACTIVITY_STOPPED) {
                            if (currentAppActivityList.contains(event.className)) {
                                currentAppActivityList.remove(event.className)
                                println("$currentAppActivityList-----List--remained\n\n\n\n\n\n\n\n\n")
                            }
                        }
                    }
                }
            }
        }
    }

    private fun launchDartAuthScreen(packageName: String) {
        val intent = Intent(this, MainActivity::class.java) // Ensure MainActivity exists and is properly imported
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        intent.putExtra("screenToShow", "auth")
        intent.putExtra("packageName", packageName) // Use the correct package name
        startActivity(intent)
    }
}


