package com.example.gobbl

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences

class BootUpReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        println("BootUpReceiver: onReceive called")

        // Check the intent action to ensure it is the boot completed action
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED || intent?.action == "android.intent.action.QUICKBOOT_POWERON") {
            println("BootUpReceiver: Device booted or quick boot detected")

            // Retrieve the SharedPreferences to check if the service should be started
            val saveAppData: SharedPreferences = context.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
            val isStopped = saveAppData.getString("is_stopped", "STOP")
            println("BootUpReceiver: Service state in SharedPreferences - is_stopped: $isStopped")

            // Start the service if it was not stopped before reboot
            if (isStopped == "1") {
                println("BootUpReceiver: Starting ForegroundService")
                context.startService(Intent(context, ForegroundService::class.java))
            } else {
                println("BootUpReceiver: ForegroundService not started (is_stopped != 1)")
            }
        } else {
            println("BootUpReceiver: Received unexpected intent action: ${intent?.action}")
        }
    }
}
