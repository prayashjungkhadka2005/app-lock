package com.example.gobbl

import android.annotation.SuppressLint
import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.*

class MainActivity : FlutterActivity() {
    private val channel = "flutter.native/helper"
    private var appInfo: List<ApplicationInfo>? = null
    private var lockedAppList: List<ApplicationInfo> = emptyList()
    private var saveAppData: SharedPreferences? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        saveAppData = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))

        handleIntent(intent) // Handle intent on creation

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "addToLockedApps" -> {
                    val args = call.arguments as HashMap<*, *>
                    println("Received 'addToLockedApps' call with arguments: $args\n\n\n\n\n\n\n\n\n")
                    val greetings = showCustomNotification(args)
                    result.success(greetings)
                }
                "setPasswordInNative" -> {
                    val args = call.arguments
                    println("Received 'setPasswordInNative' call with arguments: $args\n\n\n\n\n\n\n\n\n")
                    val editor: SharedPreferences.Editor = saveAppData!!.edit()
                    editor.putString("password", "$args")
                    editor.apply()
                    result.success("Success")
                }
                "checkOverlayPermission" -> {
                    val hasPermission = Settings.canDrawOverlays(this)
                    println("Received 'checkOverlayPermission' call. Permission status: $hasPermission\n\n\n\n\n\n\n\n\n")
                    result.success(hasPermission)
                }
                "stopForeground" -> {
                    println("Received 'stopForeground' call\n\n\n\n\n\n\n\n\n")
                    stopForegroundService()
                }
                "askOverlayPermission" -> {
                    val hasPermission = checkOverlayPermission()
                    println("Received 'askOverlayPermission' call. Permission status: $hasPermission\n\n\n\n\n\n\n\n\n")
                    result.success(hasPermission)
                }
                "askUsageStatsPermission" -> {
                    println("Received 'askUsageStatsPermission' call\n\n\n\n\n\n\n\n\n")
                    if (!isAccessGranted()) {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        startActivity(intent)
                    }
                }
                "showAuthScreen" -> {
                    val packageName = call.arguments as String
                    println("Received 'showAuthScreen' call with packageName: $packageName\n\n\n\n\n\n\n\n\n")
                    showAuthenticationScreen(packageName)
                }
                "openApp" -> {
                    val packageName = call.arguments as String
                    println("Received 'openApp' call with packageName: $packageName\n\n\n\n\n\n\n\n\n")
                    openApp(packageName)
                }
            }
        }
    }

    // Handle intent when activity is started or restarted
    override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    println("New intent received: $intent\n\n\n\n\n\n\n\n\n")
    handleIntent(intent)
}


    private fun handleIntent(intent: Intent) {
    val screenToShow = intent.getStringExtra("screenToShow")
    val packageName = intent.getStringExtra("packageName") // Get the locked app's package name
    println("Handling intent. screenToShow: $screenToShow, packageName: $packageName\n\n\n\n\n\n\n\n\n")
    if (screenToShow != null && screenToShow == "auth" && packageName != null) {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel)
            .invokeMethod("showAuthScreen", packageName)
    } else {
        println("Intent data missing or invalid\n\n\n\n\n\n\n\n\n")
    }
}


    private fun showAuthenticationScreen(packageName: String) {
        println("Showing authentication screen for packageName: $packageName\n\n\n\n\n\n\n\n\n")
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel)
            .invokeMethod("showAuthScreen", packageName)
    }

    private fun openApp(packageName: String) {
        println("Opening app with packageName: $packageName\n\n\n\n\n\n\n\n\n")
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        if (launchIntent != null) {
            startActivity(launchIntent)
        } else {
            println("App not found. Redirecting to Play Store.\n\n\n\n\n\n\n\n\n")
            // Handle case where the app is not found
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse("market://details?id=$packageName")
            startActivity(intent)
        }
    }

    @SuppressLint("CommitPrefEdits", "LaunchActivityFromNotification")
    private fun showCustomNotification(args: HashMap<*, *>): String {
        println("Showing custom notification with args: $args\n\n\n\n\n\n\n\n\n")
        lockedAppList = emptyList()
        appInfo = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val arr: ArrayList<Map<String, *>> = args["app_list"] as ArrayList<Map<String, *>>
        for (element in arr) {
            run breaking@{
                for (i in appInfo!!.indices) {
                    if (appInfo!![i].packageName.toString() == element["package_name"].toString()) {
                        println("Adding app to locked list: ${appInfo!![i].packageName}\n\n\n\n\n\n\n\n\n")
                        val ogList = lockedAppList
                        lockedAppList = ogList + appInfo!![i]
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

        println("Locked app package data: $packageData\n\n\n\n\n\n\n\n\n")
        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.remove("app_data")
        editor.putString("app_data", "$packageData")
        editor.apply()

        startForegroundService()

        return "Success"
    }

    private fun setIfServiceClosed(data: String) {
        println("Setting service closed status: $data\n\n\n\n\n\n\n\n\n")
        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.putString("is_stopped", data)
        editor.apply()
    }

    private fun startForegroundService() {
        println("Starting foreground service\n\n\n\n\n\n\n\n\n")
        if (Settings.canDrawOverlays(this)) {
            setIfServiceClosed("1")
            ContextCompat.startForegroundService(this, Intent(this, ForegroundService::class.java))
        }
    }

    private fun stopForegroundService() {
        println("Stopping foreground service\n\n\n\n\n\n\n\n\n")
        setIfServiceClosed("0")
        stopService(Intent(this, ForegroundService::class.java))
    }

    private fun checkOverlayPermission(): Boolean {
        val canDrawOverlays = Settings.canDrawOverlays(this)
        println("Overlay permission check: $canDrawOverlays\n\n\n\n\n\n\n\n\n")
        if (!canDrawOverlays) {
            val myIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            startActivity(myIntent)
        }
        return canDrawOverlays
    }

    private fun isAccessGranted(): Boolean {
        return try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            val appOpsManager: AppOpsManager = getSystemService(APP_OPS_SERVICE) as AppOpsManager
            val mode = appOpsManager.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                applicationInfo.uid, applicationInfo.packageName
            )
            val accessGranted = mode == AppOpsManager.MODE_ALLOWED
            println("Usage stats access granted: $accessGranted\n\n\n\n\n\n\n\n\n")
            accessGranted
        } catch (e: PackageManager.NameNotFoundException) {
            println("Package name not found: ${e.message}\n\n\n\n\n\n\n\n\n")
            false
        }
    }
}
