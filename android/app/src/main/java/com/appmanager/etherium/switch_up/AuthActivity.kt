package com.example.gobbl

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity

class AuthActivity : AppCompatActivity() {

    private val tag = "AuthActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        println("$tag: onCreate called")
        launchFlutterAuthScreen()
    }

    private fun launchFlutterAuthScreen() {
        val intent = FlutterActivity
            .withNewEngine()
            .initialRoute("/auth")
            .build(this)
        startActivityForResult(intent, AUTH_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == AUTH_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            resumeLockedApp()
        }
    }

    private fun resumeLockedApp() {
        // Logic to resume the locked app
        val packageManager = packageManager
        val intent = packageManager.getLaunchIntentForPackage("com.google.android.youtube")
        if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
        finish()
        notifyServiceAuthCompleted()
    }

    private fun notifyServiceAuthCompleted() {
        val intent = Intent(this, ForegroundService::class.java).apply {
            action = "com.example.gobbl.AUTH_COMPLETED"
        }
        startService(intent)
    }

    companion object {
        private const val AUTH_REQUEST_CODE = 1001
    }
}
