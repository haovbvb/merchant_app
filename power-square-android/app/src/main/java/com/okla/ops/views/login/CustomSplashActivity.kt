package com.okla.ops.views.login

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.lifecycle.ViewModelProvider
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.PlaybackException
import androidx.media3.exoplayer.ExoPlayer
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.StatusBarUtil
import com.okla.ops.R
import com.okla.ops.databinding.ActivitySplashBinding
import com.okla.ops.views.MainActivity

class CustomSplashActivity :
    BaseNormalVActivity<LoginViewModel, ActivitySplashBinding>() {

    companion object {
        fun startSplashActivity(context: Context) {
            val intent = Intent(context, CustomSplashActivity::class.java)
            context.startActivity(intent)
        }
    }

    private var player: ExoPlayer? = null
    private var hasJumped = false

    override fun onCreateViewModel(): LoginViewModel {
        return ViewModelProvider(this)[LoginViewModel::class.java]
    }

    override fun getLayoutId(): Int = R.layout.activity_splash

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)

        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)

        initPlayer()
    }

    // =========================
    // 初始化 Media3 ExoPlayer
    // =========================
    private fun initPlayer() {
//        // 首帧前兜底，避免黑屏
//        mBinding.ivFallback.visibility = View.VISIBLE
        player = ExoPlayer.Builder(this).build().also { exoPlayer ->
            mBinding.playerView.player = exoPlayer

            val uri =
                Uri.parse("android.resource://$packageName/${R.raw.okla_admin_splash}")
            val mediaItem = MediaItem.fromUri(uri)

            exoPlayer.setMediaItem(mediaItem)
            exoPlayer.repeatMode = Player.REPEAT_MODE_OFF
            exoPlayer.playWhenReady = true
            exoPlayer.prepare()

            exoPlayer.addListener(object : Player.Listener {

                override fun onPlaybackStateChanged(state: Int) {
                    when (state) {
                        Player.STATE_READY -> {
//                            // 首帧 ready
//                            mBinding.ivFallback.visibility = View.GONE
                        }

                        Player.STATE_ENDED -> {
                            goNext()
                        }
                    }
                }

                override fun onPlayerError(error: PlaybackException) {
                    // 播放异常直接兜底
                    goNext()
                }
            })
        }
    }

    // =========================
    // 视频结束 / 兜底跳转
    // =========================
    private fun goNext() {
        if (TextUtils.isEmpty(DataStoreUtils.readStringData(DataStoreKeyUtils.ACCESSTOKEN, ""))) {
            LoginActivity.startLoginActivity(this)
            finish()
        } else {
            initObserver()
            initData()
        }
    }

    private fun initData() {
        getViewModel().refreshToken()
    }

    private fun initObserver() {
        getViewModel().tokenLiveData.observe(this) {
            if (it == null) {
                LoginActivity.startLoginActivity(this)
            } else {
                MainActivity.startMainActivity(this)
            }
            finish()
        }
    }

    // =========================
    // 生命周期管理（Media3 推荐）
    // =========================
    override fun onStart() {
        super.onStart()
        player?.playWhenReady = true
    }

    override fun onStop() {
        super.onStop()
        player?.pause()
        player?.playWhenReady = false
    }

    override fun onDestroy() {
        super.onDestroy()
        player?.release()
        player = null
    }
}
