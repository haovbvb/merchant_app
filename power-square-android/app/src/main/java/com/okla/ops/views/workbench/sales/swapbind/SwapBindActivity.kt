package com.okla.ops.views.workbench.sales.swapbind

import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.os.Bundle
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.okla.ops.R
import com.okla.ops.databinding.ActivityRentbindBinding
import com.okla.ops.databinding.ActivitySwapbindBinding

class SwapBindActivity : BaseNormalVActivity<SwapBindViewModel, ActivitySwapbindBinding>() {

    companion object {
        fun startActivity(context: Context) {
            val intent = Intent(context, SwapBindActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): SwapBindViewModel {
        return ViewModelProvider(this)[SwapBindViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_swapbind
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            finish()
        }
        return super.onKeyDown(keyCode, event)
    }
    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        if (ev.action == MotionEvent.ACTION_DOWN) {
            // currentFocus 无论是在 Fragment 还是 Activity 布局里的 EditText，都能拿到
            val v = currentFocus
            if (v is EditText) {
                // 计算点击区域是否在 EditText 之外
                val outRect = Rect()
                v.getGlobalVisibleRect(outRect)
                if (!outRect.contains(ev.rawX.toInt(), ev.rawY.toInt())) {
                    // 清除焦点 & 隐藏键盘
                    v.clearFocus()
                    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.hideSoftInputFromWindow(v.windowToken, 0)
                }
            }
        }
        return super.dispatchTouchEvent(ev)
    }

}