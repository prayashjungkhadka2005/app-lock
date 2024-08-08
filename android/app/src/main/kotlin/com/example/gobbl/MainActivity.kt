package com.example.gobbl

import android.annotation.SuppressLint
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {
    private val channel = "flutter.native/helper"
    private var appInfo: List<ApplicationInfo>? = null
    private var lockedAppList: List<ApplicationInfo> = emptyList()
    private var saveAppData: SharedPreferences? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        saveAppData = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "addToLockedApps" -> {
                    val args = call.arguments as HashMap<*, *>
                    println("MainActivity: $args ----- ARGS")
                    val greetings = showCustomNotification(args)
                    result.success(greetings)
                }
                "setPasswordInNative" -> {
                    val args = call.arguments
                    val editor: SharedPreferences.Editor = saveAppData!!.edit()
                    editor.putString("password", "$args")
                    editor.apply()
                    println("MainActivity: Password set: $args")
                    result.success("Success")
                }
                "checkOverlayPermission" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "stopForeground" -> {
                    stopForegroundService()
                }
                "askOverlayPermission" -> {
                    result.success(checkOverlayPermission())
                }
                "askUsageStatsPermission" -> {
                    requestUsageStatsPermission()
                }
            }
        }
    }

    @SuppressLint("CommitPrefEdits", "LaunchActivityFromNotification")
    private fun showCustomNotification(args: HashMap<*, *>): String {
        lockedAppList = emptyList()
        println("MainActivity: showCustomNotification called with args: $args")
        appInfo = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val arr: ArrayList<Map<String, *>> = args["app_list"] as ArrayList<Map<String, *>>

        for (element in arr) {
            run breaking@{
                for (i in appInfo!!.indices) {
                    if (appInfo!![i].packageName.toString() == element["package_name"].toString()) {
                        val ogList = lockedAppList
                        lockedAppList = ogList + appInfo!![i]
                        println("MainActivity: Locked app added: ${appInfo!![i].packageName}")
                        return@breaking
                    }
                }
            }
        }

        var packageData: List<String> = emptyList()

        for (element in lockedAppList) {
            val ogList = packageData
            packageData = ogList + element.packageName
        }

        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.remove("app_data")
        editor.putString("app_data", "$packageData")
        editor.apply()
        println("MainActivity: Locked apps saved: $packageData")

        startForegroundService()

        return "Success"
    }

    private fun setIfServiceClosed(data: String) {
        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.putString("is_stopped", data)
        editor.apply()
        println("MainActivity: Service state updated: $data")
    }

    private fun startForegroundService() {
        if (Settings.canDrawOverlays(this) && isAccessGranted()) {
            setIfServiceClosed("1")
            println("MainActivity: Starting foreground service")
            ContextCompat.startForegroundService(this, Intent(this, ForegroundService::class.java))
        } else {
            println("MainActivity: Overlay or usage stats permission missing")
        }
    }

    private fun stopForegroundService() {
        setIfServiceClosed("0")
        println("MainActivity: Stopping foreground service")
        stopService(Intent(this, ForegroundService::class.java))
    }

    private fun checkOverlayPermission(): Boolean {
        if (!Settings.canDrawOverlays(this)) {
            val myIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            startActivity(myIntent)
        }
        return Settings.canDrawOverlays(this)
    }

    private fun checkUsageStatsPermission(): Boolean {
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        if (!checkUsageStatsPermission()) {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            startActivity(intent)
        }
    }

    private fun isAccessGranted(): Boolean {
        return try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            val appOpsManager: AppOpsManager = getSystemService(APP_OPS_SERVICE) as AppOpsManager
            val mode = appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, applicationInfo.uid, applicationInfo.packageName)
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}
