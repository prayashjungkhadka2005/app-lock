package com.example.gobbl

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.os.Handler
import android.os.Looper
import android.view.*
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.andrognito.pinlockview.IndicatorDots
import com.andrognito.pinlockview.PinLockListener
import com.andrognito.pinlockview.PinLockView
import com.example.gobbl.R

@SuppressLint("InflateParams")
class Window(private val context: Context) {
    private val mView: View
    private val mParams: WindowManager.LayoutParams?
    private val mWindowManager: WindowManager
    private val layoutInflater: LayoutInflater

    init {
        mParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )

        mWindowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        layoutInflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        mView = layoutInflater.inflate(R.layout.activity_native, null)
    }

    fun open() {
        try {
            if (mView.windowToken == null) {
                if (mView.parent == null) {
                    mWindowManager.addView(mView, mParams)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun close() {
        try {
            Handler(Looper.getMainLooper()).postDelayed({
                (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).removeView(mView)
                mView.invalidate()
            }, 500)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun isOpen(): Boolean {
        return (mView.windowToken != null && mView.parent != null)
    }
}
