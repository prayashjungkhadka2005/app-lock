package com.example.gobbl

import android.annotation.SuppressLint
import android.content.Context
import androidx.core.content.ContextCompat
import com.andrognito.pinlockview.IndicatorDots
import com.andrognito.pinlockview.PinLockListener
import com.andrognito.pinlockview.PinLockView
import com.example.gobbl.R

class PinCodeActivity(
    private val context: Context
) {

    var pinCode: String = ""

    private var mPinLockView: PinLockView? = null
    private var mIndicatorDots: IndicatorDots? = null

    private val mPinLockListener: PinLockListener = object : PinLockListener {
        @SuppressLint("LogConditional")
        override fun onComplete(pin: String) {
            println("PinCodeActivity: Pin entry complete. Entered PIN: $pin")
            pinCode = pin
        }

        override fun onEmpty() {
            println("PinCodeActivity: Pin entry is empty")
            pinCode = ""
        }

        @SuppressLint("LogConditional")
        override fun onPinChange(pinLength: Int, intermediatePin: String) {
            println("PinCodeActivity: Pin changed. Length: $pinLength, Intermediate PIN: $intermediatePin")
            pinCode = intermediatePin
        }
    }

    init {
        try {
            println("PinCodeActivity: Initializing PinCodeActivity")

            // Assuming mPinLockView and mIndicatorDots have been initialized properly
            // with findViewById() or equivalent method.
            // Example initialization if it was within an activity:
            // mPinLockView = findViewById(R.id.pin_lock_view)
            // mIndicatorDots = findViewById(R.id.indicator_dots)

            // Attach the IndicatorDots to the PinLockView
            mPinLockView!!.attachIndicatorDots(mIndicatorDots)
            mPinLockView!!.setPinLockListener(mPinLockListener)
            println("PinCodeActivity: PinLockView and IndicatorDots setup completed")

            // Set the pin length
            mPinLockView!!.pinLength = 4  // Assuming the PIN length is 4 based on the image

            // Set the text color of the PIN digits
            mPinLockView!!.textColor = ContextCompat.getColor(context, R.color.black)  // Assuming black text color

            // Set up the indicator dots with animation
            mIndicatorDots!!.indicatorType = IndicatorDots.IndicatorType.FILL_WITH_ANIMATION

            println("PinCodeActivity: PinLockView configuration completed")

        } catch (e: Exception) {
            println("PinCodeActivity: Exception occurred during initialization")
            e.printStackTrace()
        }
    }

    companion object {
        const val TAG = "PinLockView"
    }
}
