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
class Window(
    private val context: Context
) {
    private val mView: View
    private var mParams: WindowManager.LayoutParams? = null
    private val mWindowManager: WindowManager
    private val layoutInflater: LayoutInflater
    private var mPinLockView: PinLockView? = null
    private var mIndicatorDots: IndicatorDots? = null
    var txtView: TextView? = null
    var pinCode: String = ""

    private val mPinLockListener: PinLockListener = object : PinLockListener {
        override fun onComplete(pin: String) {
            println("Window: onComplete - PIN entered: $pin")
            pinCode = pin
            validatePinCode()
        }

        override fun onEmpty() {
            println("Window: onEmpty - PIN entry cleared")
        }

        override fun onPinChange(pinLength: Int, intermediatePin: String) {
            println("Window: onPinChange - PIN length: $pinLength, intermediate PIN: $intermediatePin")
        }
    }

    init {
        println("Window: Initializing")

        mParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
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
        mPinLockView!!.pinLength = 6
        mPinLockView!!.textColor = ContextCompat.getColor(context, R.color.ic_launcher_background)
        mIndicatorDots!!.indicatorType = IndicatorDots.IndicatorType.FILL_WITH_ANIMATION

        println("Window: Initialization complete")
    }

    fun open() {
        try {
            if (mView.windowToken == null && mView.parent == null) {
                println("Window: Opening window")
                mWindowManager.addView(mView, mParams)
            } else {
                println("Window: Window is already open")
            }
        } catch (e: Exception) {
            println("Window: Failed to open window")
            e.printStackTrace()
        }
    }

    fun close() {
        try {
            println("Window: Closing window")
            Handler(Looper.getMainLooper()).postDelayed({
                if (mView.windowToken != null && mView.parent != null) {
                    (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).removeView(mView)
                    mView.invalidate()
                    println("Window: Window closed")
                } else {
                    println("Window: View not attached to window, skipping removal")
                }
            }, 500)
        } catch (e: Exception) {
            println("Window: Failed to close window")
            e.printStackTrace()
        }
    }

    fun isOpen(): Boolean {
        val open = (mView.windowToken != null && mView.parent != null)
        println("Window: isOpen() - $open")
        return open
    }

    private fun validatePinCode() {
        println("Window: Validating PIN")
        val saveAppData: SharedPreferences = context.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val savedPin = saveAppData.getString("password", "PASSWORD")!!
        if (pinCode == savedPin) {
            println("Window: PIN is correct")
            close()
        } else {
            println("Window: PIN is incorrect")
            txtView!!.visibility = View.VISIBLE
            mPinLockView!!.resetPinLockView()
        }
    }
}
