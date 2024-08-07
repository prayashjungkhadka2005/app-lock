package com.example.gobbl

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.IBinder
import androidx.core.app.NotificationCompat
import java.util.*

class ForegroundService : Service() {

    private var timer: Timer = Timer()
    private var isTimerStarted = false
    private var timerReload: Long = 500
    private var currentAppActivityList = arrayListOf<String>()
    private var mHomeWatcher = HomeWatcher(this)

    override fun onBind(intent: Intent): IBinder? {
        throw UnsupportedOperationException("")
    }

    override fun onCreate() {
        super.onCreate()
        println("ForegroundService: Service onCreate")
        val channelId = "AppLock-10"
        val channel = NotificationChannel(
            channelId,
            "Channel human readable title",
            NotificationManager.IMPORTANCE_DEFAULT
        )
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Foreground Service")
            .setContentText("Service is running").build()
        startForeground(1, notification)
        startMyOwnForeground()
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        println("ForegroundService: Service onStartCommand")
        return super.onStartCommand(intent, flags, startId)
    }

    private fun startMyOwnForeground() {
        println("ForegroundService: Starting my own foreground service")
        mHomeWatcher.setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
            override fun onHomePressed() {
                println("ForegroundService: Home button pressed")
                currentAppActivityList.clear()
                println("ForegroundService: Cleared currentAppActivityList")
            }

            override fun onHomeLongPressed() {
                println("ForegroundService: Home button long pressed")
                currentAppActivityList.clear()
                println("ForegroundService: Cleared currentAppActivityList")
            }
        })
        mHomeWatcher.startWatch()
        timerRun()
    }

    override fun onDestroy() {
        println("ForegroundService: Service onDestroy")
        timer.cancel()
        mHomeWatcher.stopWatch()
        super.onDestroy()
    }

    private fun timerRun() {
        println("ForegroundService: Starting timer")
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                isTimerStarted = true
                isServiceRunning()
            }
        }, 0, timerReload)
    }

    private fun isServiceRunning() {
        println("ForegroundService: Checking if service is running")
        val saveAppData: SharedPreferences = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val lockedAppList: List<String> = saveAppData.getString("app_data", "AppList")!!
            .replace("[", "")
            .replace("]", "")
            .split(",")

        println("ForegroundService: Locked apps list: $lockedAppList")

        val mUsageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()

        println("ForegroundService: Querying usage events")
        val usageEvents = mUsageStatsManager.queryEvents(time - timerReload, time)
        val event = UsageEvents.Event()

        println("ForegroundService: Checking if usageEvents has next event")
        if (usageEvents.hasNextEvent()) {
            println("ForegroundService: UsageEvents has next event")
        } else {
            println("ForegroundService: UsageEvents does not have next event")
        }

        run breaking@{
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                println("ForegroundService: Event detected: ${event.packageName}, ${event.eventType}")
                for (element in lockedAppList) {
                    if (event.packageName.toString().trim() == element.toString().trim()) {
                        println("ForegroundService: Locked app detected: ${event.packageName}")
                        if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED && currentAppActivityList.isEmpty()) {
                            currentAppActivityList.add(event.className)
                            println("ForegroundService: Activity resumed: ${event.className}")
                            launchDartAuthScreen()
                            return@breaking
                        } else if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                            if (!currentAppActivityList.contains(event.className)) {
                                currentAppActivityList.add(event.className)
                                println("ForegroundService: Activity resumed: ${event.className}")
                            }
                        } else if (event.eventType == UsageEvents.Event.ACTIVITY_STOPPED) {
                            if (currentAppActivityList.contains(event.className)) {
                                currentAppActivityList.remove(event.className)
                                println("ForegroundService: Activity stopped: ${event.className}")
                            }
                        } else if (event.eventType == UsageEvents.Event.MOVE_TO_BACKGROUND) {
                            println("ForegroundService: Locked app moved to background: ${event.packageName}")
                        }
                    }
                }
            }
        }
    }

    private fun launchDartAuthScreen() {
        println("ForegroundService: Launching authentication screen")
        val intent = Intent(this, AuthActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        startActivity(intent)
    }
}
