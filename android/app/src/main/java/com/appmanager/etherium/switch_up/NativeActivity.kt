package com.example.gobbl

import android.annotation.SuppressLint
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class NativeActivity : AppCompatActivity() {

    @SuppressLint("SetTextI18n")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        println("NativeActivity: onCreate called")
        
        setContentView(R.layout.activity_native)
        println("NativeActivity: setContentView completed with activity_native layout")
    }
}
