package com.base.common.custom

import android.content.Context
import android.os.CountDownTimer
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatButton
import androidx.core.content.ContextCompat
import com.base.common.R

class TimerButton(context: Context, attrs: AttributeSet) : AppCompatButton(context, attrs) {

    private val duration: Long
    private val interval: Long

    init {
        isAllCaps = false
        val typeArray = context.obtainStyledAttributes(attrs, R.styleable.TimerButton)
        duration = (1000 * typeArray.getInteger(R.styleable.TimerButton_duration, 60)).toLong()
        interval = (1000 * typeArray.getInteger(R.styleable.TimerButton_interval, 1)).toLong()
        typeArray.recycle()
        text = context.getString(R.string.cc_text_get_code_number)
        textSize = 14f
        setBackgroundDrawable(ContextCompat.getDrawable(context, R.drawable.bg_line_r6_fa4332))
    }

    private val countdownTimer: CountDownTimer by lazy {
        object : CountDownTimer(duration, interval) {
            override fun onTick(millisUntilFinished: Long) {
                text = context.getString(R.string.cc_send_countdown, (millisUntilFinished / 1000))
                setTextColor(ContextCompat.getColor(context, R.color.cc_color_800c0c0d))
                setBackgroundDrawable(
                    ContextCompat.getDrawable(
                        context,
                        R.drawable.bg_line_r6_330c0c0d
                    )
                )
            }

            override fun onFinish() {
                isEnabled = true
                text = context.getString(R.string.cc_text_get_code_number)
                setTextColor(ContextCompat.getColor(context, R.color.cc_main_color))
                setBackgroundDrawable(
                    ContextCompat.getDrawable(
                        context,
                        R.drawable.bg_line_r6_fa4332
                    )
                )
            }
        }
    }

    fun startTimer() {
        isEnabled = false
        countdownTimer.start()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        countdownTimer.cancel()
    }

}