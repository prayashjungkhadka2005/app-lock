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
import android.util.Log
import android.view.WindowManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val channel = "flutter.native/helper"
    private var appInfo: List<ApplicationInfo>? = null
    private var lockedAppList: MutableList<ApplicationInfo> = mutableListOf()
    private var saveAppData: SharedPreferences? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "onCreate called")

        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        setTheme(R.style.AppCompactTheme)
        saveAppData = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)

        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        Log.d("MainActivity", "GeneratedPluginRegistrant registered")

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            Log.d("MainActivity", "MethodChannel called with method: ${call.method}")
            when (call.method) {
                "updateLockedApps" -> {
                    val args = call.arguments as HashMap<*, *>
                    Log.d("MainActivity", "updateLockedApps called with args: $args")
                    val response = updateLockedApps(args)
                    result.success(response)
                }
                "checkOverlayPermission" -> {
                    Log.d("MainActivity", "checkOverlayPermission called")
                    result.success(Settings.canDrawOverlays(this))
                }
                "stopForeground" -> {
                    Log.d("MainActivity", "stopForeground called")
                    stopForegroundService()
                }
                "askOverlayPermission" -> {
                    Log.d("MainActivity", "askOverlayPermission called")
                    result.success(checkOverlayPermission())
                }
                "askUsageStatsPermission" -> {
                    Log.d("MainActivity", "askUsageStatsPermission called")
                    requestUsageStatsPermission()
                }
                else -> {
                    Log.d("MainActivity", "Method not implemented")
                    result.notImplemented()
                }
            }
        }
    }

    @SuppressLint("CommitPrefEdits", "LaunchActivityFromNotification")
    private fun updateLockedApps(args: HashMap<*, *>): String {
        Log.d("MainActivity", "updateLockedApps called with args: $args")

        lockedAppList.clear()
        appInfo = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val arr: ArrayList<Map<String, *>> = args["app_list"] as ArrayList<Map<String, *>>

        for (element in arr) {
            for (app in appInfo!!) {
                if (app.packageName == element["package_name"].toString()) {
                    Log.d("MainActivity", "App found and added to lockedAppList: ${app.packageName}")
                    lockedAppList.add(app)
                    break
                }
            }
        }

        val packageData: List<String> = lockedAppList.map { it.packageName }

        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.putString("app_data", packageData.joinToString(","))
        editor.apply()
        Log.d("MainActivity", "Locked apps updated: $packageData")

        startForegroundService()

        return "Success"
    }

    private fun startForegroundService() {
        Log.d("MainActivity", "startForegroundService called")
        if (Settings.canDrawOverlays(this) && isAccessGranted()) {
            setIfServiceClosed("1")
            Log.d("MainActivity", "Starting ForegroundService")
            ContextCompat.startForegroundService(this, Intent(this, ForegroundService::class.java))
        } else {
            Log.d("MainActivity", "Unable to start ForegroundService due to missing permissions")
        }
    }

    private fun stopForegroundService() {
        Log.d("MainActivity", "stopForegroundService called")
        setIfServiceClosed("0")
        stopService(Intent(this, ForegroundService::class.java))
        Log.d("MainActivity", "ForegroundService stopped")
    }

    private fun setIfServiceClosed(data: String) {
        Log.d("MainActivity", "setIfServiceClosed called with data: $data")
        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.putString("is_stopped", data)
        editor.apply()
    }

    private fun checkOverlayPermission(): Boolean {
        Log.d("MainActivity", "checkOverlayPermission called")
        if (!Settings.canDrawOverlays(this)) {
            Log.d("MainActivity", "Overlay permission not granted, requesting permission")
            val myIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            startActivity(myIntent)
        }
        return Settings.canDrawOverlays(this)
    }

    private fun checkUsageStatsPermission(): Boolean {
        Log.d("MainActivity", "checkUsageStatsPermission called")
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
        val granted = mode == AppOpsManager.MODE_ALLOWED
        Log.d("MainActivity", "Usage stats permission granted: $granted")
        return granted
    }

    private fun requestUsageStatsPermission() {
        Log.d("MainActivity", "requestUsageStatsPermission called")
        if (!checkUsageStatsPermission()) {
            Log.d("MainActivity", "Usage stats permission not granted, requesting permission")
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            startActivity(intent)
        }
    }

    private fun isAccessGranted(): Boolean {
        Log.d("MainActivity", "isAccessGranted called")
        return try {
            val appOpsManager: AppOpsManager = getSystemService(APP_OPS_SERVICE) as AppOpsManager
            val mode = appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), packageName)
            val granted = mode == AppOpsManager.MODE_ALLOWED
            Log.d("MainActivity", "Access granted: $granted")
            granted
        } catch (e: PackageManager.NameNotFoundException) {
            Log.e("MainActivity", "Access denied due to NameNotFoundException", e)
            false
        }
    }

    override fun onBackPressed() {
        super.onBackPressed()
        val foregroundService = ForegroundService()
        foregroundService.closeWindow() // Close the lock view immediately on back press
    }
}
