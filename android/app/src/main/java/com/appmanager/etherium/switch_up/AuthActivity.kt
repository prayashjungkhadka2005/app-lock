package com.example.gobbl

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity

class AuthActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

      window.setFlags(
    WindowManager.LayoutParams.FLAG_FULLSCREEN,
    WindowManager.LayoutParams.FLAG_FULLSCREEN
)


        // Hide the action bar if it exists
        supportActionBar?.hide()

        // Set the system UI visibility flags
        window.decorView.systemUiVisibility = (
    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
    or View.SYSTEM_UI_FLAG_FULLSCREEN
    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
)

        // Apply the theme
        setTheme(R.style.AppCompactTheme)

        // Launch the Flutter screen
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
        val packageManager = packageManager
        val intent = packageManager.getLaunchIntentForPackage("com.google.android.youtube")
        intent?.let {
            it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(it)
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
