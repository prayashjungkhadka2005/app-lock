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
import android.view.WindowManager
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
        println("MainActivity: onCreate called")

        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        setTheme(R.style.AppCompactTheme)
        saveAppData = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)

        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        println("MainActivity: GeneratedPluginRegistrant registered")

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            println("MainActivity: MethodChannel called with method: ${call.method}")
            when (call.method) {
                "addToLockedApps" -> {
                    val args = call.arguments as HashMap<*, *>
                    println("MainActivity: addToLockedApps called with args: $args")
                    val greetings = showCustomNotification(args)
                    result.success(greetings)
                }
                "setPasswordInNative" -> {
                    val args = call.arguments
                    println("MainActivity: setPasswordInNative called with args: $args")
                    val editor: SharedPreferences.Editor = saveAppData!!.edit()
                    editor.putString("password", "$args")
                    editor.apply()
                    result.success("Success")
                }
                "checkOverlayPermission" -> {
                    println("MainActivity: checkOverlayPermission called")
                    result.success(Settings.canDrawOverlays(this))
                }
                "stopForeground" -> {
                    println("MainActivity: stopForeground called")
                    stopForegroundService()
                }
                "askOverlayPermission" -> {
                    println("MainActivity: askOverlayPermission called")
                    result.success(checkOverlayPermission())
                }
                "askUsageStatsPermission" -> {
                    println("MainActivity: askUsageStatsPermission called")
                    requestUsageStatsPermission()
                }
                else -> {
                    println("MainActivity: Method not implemented")
                    result.notImplemented()
                }
            }
        }
    }

    @SuppressLint("CommitPrefEdits", "LaunchActivityFromNotification")
    private fun showCustomNotification(args: HashMap<*, *>): String {
        println("MainActivity: showCustomNotification called with args: $args")

        lockedAppList = emptyList()
        appInfo = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val arr: ArrayList<Map<String, *>> = args["app_list"] as ArrayList<Map<String, *>>

        for (element in arr) {
            run breaking@{
                for (i in appInfo!!.indices) {
                    if (appInfo!![i].packageName.toString() == element["package_name"].toString()) {
                        println("MainActivity: App found and added to lockedAppList: ${appInfo!![i].packageName}")
                        lockedAppList = lockedAppList + appInfo!![i]
                        return@breaking
                    }
                }
            }
        }

        var packageData: List<String> = emptyList()

        for (element in lockedAppList) {
            packageData = packageData + element.packageName
        }

        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.remove("app_data")
        editor.putString("app_data", "$packageData")
        editor.apply()
        println("MainActivity: Locked apps saved: $packageData")

        startForegroundService()

        return "Success"
    }

    private fun startForegroundService() {
        println("MainActivity: startForegroundService called")
        if (Settings.canDrawOverlays(this) && isAccessGranted()) {
            setIfServiceClosed("1")
            println("MainActivity: Starting ForegroundService")
            ContextCompat.startForegroundService(this, Intent(this, ForegroundService::class.java))
        } else {
            println("MainActivity: Unable to start ForegroundService due to missing permissions")
        }
    }

    private fun stopForegroundService() {
        println("MainActivity: stopForegroundService called")
        setIfServiceClosed("0")
        stopService(Intent(this, ForegroundService::class.java))
        println("MainActivity: ForegroundService stopped")
    }

    private fun setIfServiceClosed(data: String) {
        println("MainActivity: setIfServiceClosed called with data: $data")
        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.putString("is_stopped", data)
        editor.apply()
    }

    private fun checkOverlayPermission(): Boolean {
        println("MainActivity: checkOverlayPermission called")
        if (!Settings.canDrawOverlays(this)) {
            println("MainActivity: Overlay permission not granted, requesting permission")
            val myIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            startActivity(myIntent)
        }
        return Settings.canDrawOverlays(this)
    }

    private fun checkUsageStatsPermission(): Boolean {
        println("MainActivity: checkUsageStatsPermission called")
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        val granted = mode == AppOpsManager.MODE_ALLOWED
        println("MainActivity: Usage stats permission granted: $granted")
        return granted
    }

    private fun requestUsageStatsPermission() {
        println("MainActivity: requestUsageStatsPermission called")
        if (!checkUsageStatsPermission()) {
            println("MainActivity: Usage stats permission not granted, requesting permission")
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            startActivity(intent)
        }
    }

    private fun isAccessGranted(): Boolean {
        println("MainActivity: isAccessGranted called")
        return try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            val appOpsManager: AppOpsManager = getSystemService(APP_OPS_SERVICE) as AppOpsManager
            val mode = appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, applicationInfo.uid, applicationInfo.packageName)
            val granted = mode == AppOpsManager.MODE_ALLOWED
            println("MainActivity: Access granted: $granted")
            granted
        } catch (e: PackageManager.NameNotFoundException) {
            println("MainActivity: Access denied due to NameNotFoundException")
            false
        }
    }
    override fun onBackPressed() {
    super.onBackPressed()
    val foregroundService = ForegroundService()
    foregroundService.closeWindow() // Close the lock view immediately on back press
}

}
