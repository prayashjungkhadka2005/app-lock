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
            println("Window: onPinChange - PIN length: $pinLength, Intermediate PIN: $intermediatePin")
        }
    }

    init {
        println("Window: Initializing")

        mParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
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

        println("Window: Initialization complete")
    }

    fun open() {
    Handler(Looper.getMainLooper()).post {
        try {
            if (mView.windowToken == null && mView.parent == null) {
                println("Window: Opening window")
                mView.visibility = View.VISIBLE
                mParams!!.flags = mParams!!.flags or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                mWindowManager.addView(mView, mParams)
                mView.alpha = 0f
                mView.animate().alpha(1f).setDuration(300).start()
            } else {
                println("Window: Window is already open")
            }
        } catch (e: Exception) {
            println("Window: Failed to open window")
            e.printStackTrace()
        }
    }
}

    fun close() {
        Handler(Looper.getMainLooper()).post {
            try {
                println("Window: Closing window")
                if (mView.windowToken != null && mView.parent != null) {
                    mView.animate().alpha(0f).setDuration(300).withEndAction {
                        mWindowManager.removeView(mView)
                        mView.visibility = View.GONE
                        mView.invalidate()
                        println("Window: Window closed")
                    }.start()
                } else {
                    println("Window: View not attached to window, skipping removal")
                }
            } catch (e: Exception) {
                println("Window: Failed to close window")
                e.printStackTrace()
            }
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
