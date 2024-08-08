package com.example.gobbl

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
        startActivity(intent)
        finish() // To close AuthActivity and keep only the Flutter activity on stack
    }
}
