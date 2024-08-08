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

    private val tag = "ForegroundService"
    private var timer: Timer = Timer()
    private var timerReload: Long = 1000 // 1 second
    private var currentAppActivityList = arrayListOf<String>()
    private var mHomeWatcher = HomeWatcher(this)

    private var lastAuthLaunchTime: Long = 0
    private val authLaunchDebounceTime = 3000 // 3 seconds debounce time

    override fun onBind(intent: Intent): IBinder? {
        throw UnsupportedOperationException("Not implemented")
    }

    override fun onCreate() {
        super.onCreate()
        println("$tag: Service onCreate")
        startForegroundService()
        startMyOwnForeground()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        println("$tag: Service onStartCommand")
        return START_STICKY
    }

    private fun startForegroundService() {
        val channelId = "AppLock-10"
        val channel = NotificationChannel(
            channelId,
            "App Lock Service",
            NotificationManager.IMPORTANCE_DEFAULT
        )
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Foreground Service")
            .setContentText("Service is running")
            .build()

        startForeground(1, notification)
    }

    private fun startMyOwnForeground() {
        println("$tag: Starting my own foreground service")
        mHomeWatcher.setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
            override fun onHomePressed() {
                println("$tag: Home button pressed")
                currentAppActivityList.clear()
                println("$tag: Cleared currentAppActivityList")
            }

            override fun onHomeLongPressed() {
                println("$tag: Home button long pressed")
                currentAppActivityList.clear()
                println("$tag: Cleared currentAppActivityList")
            }
        })
        mHomeWatcher.startWatch()
        timerRun()
    }

    override fun onDestroy() {
        println("$tag: Service onDestroy")
        timer.cancel()
        mHomeWatcher.stopWatch()
        super.onDestroy()
    }

    private fun timerRun() {
        println("$tag: Starting timer")
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                isServiceRunning()
            }
        }, 0, timerReload)
    }

    private fun isServiceRunning() {
        val saveAppData: SharedPreferences = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val lockedAppList: List<String> = saveAppData.getString("app_data", "[]")
            ?.replace("[", "")
            ?.replace("]", "")
            ?.split(",") ?: emptyList()

        val mUsageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()

        val usageEvents = mUsageStatsManager.queryEvents(time - 60000, time) // 60 seconds time range
        val event = UsageEvents.Event()

        val runningApps = mutableListOf<String>()

        run breaking@{
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                runningApps.add(event.packageName)

                when (event.eventType) {
                    UsageEvents.Event.ACTIVITY_RESUMED -> {
                        if (lockedAppList.contains(event.packageName.trim())) {
                            println("$tag: Locked app resumed: ${event.packageName}")
                            if (currentAppActivityList.isEmpty()) {
                                currentAppActivityList.add(event.className)
                                println("$tag: Activity resumed: ${event.className}")
                                showAuthScreenDebounced()
                                return@breaking
                            } else if (!currentAppActivityList.contains(event.className)) {
                                currentAppActivityList.add(event.className)
                                println("$tag: Activity resumed: ${event.className}")
                            }
                        }
                    }
                    UsageEvents.Event.ACTIVITY_STOPPED -> {
                        if (currentAppActivityList.contains(event.className)) {
                            currentAppActivityList.remove(event.className)
                            println("$tag: Activity stopped: ${event.className}")
                        }
                    }
                    else -> { /* Handle other event types if needed */ }
                }
            }
        }

        // Print running apps only if there are significant changes
        if (runningApps.isNotEmpty()) {
            println("$tag: Running apps in background: $runningApps")
        }
    }

    private fun showAuthScreenDebounced() {
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastAuthLaunchTime > authLaunchDebounceTime) {
            showAuthScreen()
            lastAuthLaunchTime = currentTime
        } else {
            println("$tag: Auth screen launch debounced")
        }
    }

    private fun showAuthScreen() {
        println("$tag: Launching authentication screen")
        val intent = Intent(this, AuthActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(intent)
    }
}
