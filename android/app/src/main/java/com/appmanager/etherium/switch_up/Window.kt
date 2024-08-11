package com.example.gobbl

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.graphics.PixelFormat
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.andrognito.pinlockview.IndicatorDots
import com.andrognito.pinlockview.PinLockListener
import com.andrognito.pinlockview.PinLockView

@SuppressLint("InflateParams")
class Window(private val context: Context) {
    private val mView: View
    private var mParams: WindowManager.LayoutParams? = null
    private val mWindowManager: WindowManager
    private val layoutInflater: LayoutInflater
    private var mPinLockView: PinLockView? = null
    private var mIndicatorDots: IndicatorDots? = null
    private var txtView: TextView? = null
    private var pinCode: String = ""
    private var lastOpenTime: Long = 0
    private val debounceDelay = 500L
    private var isViewAttached = false

    private val mPinLockListener: PinLockListener = object : PinLockListener {
        override fun onComplete(pin: String) {
            pinCode = pin
            validatePinCode()
        }

        override fun onEmpty() {}

        override fun onPinChange(pinLength: Int, intermediatePin: String) {}
    }

    init {
        mParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
            PixelFormat.TRANSLUCENT
        )

        layoutInflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        mView = layoutInflater.inflate(R.layout.pin_activity, null)
        mParams!!.gravity = Gravity.CENTER
        mWindowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

        mPinLockView = mView.findViewById(R.id.pin_lock_view)
        mIndicatorDots = mView.findViewById(R.id.indicator_dots)
        txtView = mView.findViewById(R.id.alertError) as TextView

        mPinLockView!!.attachIndicatorDots(mIndicatorDots)
        mPinLockView!!.setPinLockListener(mPinLockListener)
        mPinLockView!!.pinLength = 4
        mPinLockView!!.textColor = ContextCompat.getColor(context, R.color.black)
        mIndicatorDots!!.indicatorType = IndicatorDots.IndicatorType.FILL_WITH_ANIMATION
    }

    @Synchronized
    fun open() {
        Handler(Looper.getMainLooper()).post {
            val currentTime = System.currentTimeMillis()
            if (!isOpen() && (currentTime - lastOpenTime) > debounceDelay) {
                lastOpenTime = currentTime
                try {
                    if (mView.parent == null) {
                        mWindowManager.addView(mView, mParams)
                    }
                    mView.visibility = View.VISIBLE
                    isViewAttached = true
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    @Synchronized
    fun close() {
        Handler(Looper.getMainLooper()).post {
            if (isOpen()) {
                try {
                    mView.visibility = View.GONE
                    mWindowManager.removeView(mView)
                    isViewAttached = false
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    fun isOpen(): Boolean {
        return isViewAttached
    }

    private fun validatePinCode() {
        val saveAppData: SharedPreferences = context.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val savedPin = saveAppData.getString("password", "") ?: ""
        if (pinCode == savedPin) {
            close()
        } else {
            txtView!!.visibility = View.VISIBLE
            mPinLockView!!.resetPinLockView()
        }
    }
}
