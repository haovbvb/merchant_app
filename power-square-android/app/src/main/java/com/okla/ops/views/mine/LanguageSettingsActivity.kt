package com.okla.ops.views.mine

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.LanguageUtils
import com.base.common.utils.LanguageUtils.LanguageUtil.changeAppLanguage
import com.base.library.base.mvvm.BaseViewModel
import com.okla.ops.R
import com.okla.ops.databinding.ActivityLanguageSettingsBinding
import com.okla.ops.views.MainActivity

class LanguageSettingsActivity :
    BaseNormalVActivity<BaseViewModel, ActivityLanguageSettingsBinding>() {

    companion object {
        fun startLanguageSettingsActivity(context: Context) {
            val intent = Intent(context, LanguageSettingsActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): BaseViewModel {
        return ViewModelProvider(this)[BaseViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_language_settings
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        mBinding.tvEnglish.setOnClickListener(this)
        mBinding.tvChinese.setOnClickListener(this)
        mBinding.tvEnglish.setTextColor(ContextCompat.getColor(this, R.color.color_e60c0c0d))
        mBinding.tvChinese.setTextColor(ContextCompat.getColor(this, R.color.color_e60c0c0d))
        val local = DataStoreUtils.readStringData(
            DataStoreKeyUtils.LANGUAGE_SETTING,
            LanguageUtils.LanguageType.ENGLISH.language
        )
        when (local) {
            LanguageUtils.LanguageType.ENGLISH.language -> {
                mBinding.tvEnglish.isSelected = true
                mBinding.tvChinese.isSelected = false
                mBinding.imgSelectEn.visibility = View.VISIBLE
                mBinding.imgSelectChinese.visibility = View.GONE
                mBinding.tvEnglish.setTextColor(
                    ContextCompat.getColor(
                        this,
                        R.color.main_color
                    )
                )
            }

            LanguageUtils.LanguageType.CHINESE.language -> {
                mBinding.tvEnglish.isSelected = false
                mBinding.tvChinese.isSelected = true
                mBinding.imgSelectEn.visibility = View.GONE
                mBinding.imgSelectChinese.visibility = View.VISIBLE
                mBinding.tvChinese.setTextColor(
                    ContextCompat.getColor(
                        this,
                        R.color.main_color
                    )
                )
            }
        }
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        mBinding.imgSelectEn.visibility = View.GONE
        mBinding.imgSelectChinese.visibility = View.GONE

        mBinding.tvEnglish.isSelected = v.id == R.id.tvEnglish
        mBinding.tvChinese.isSelected = v.id == R.id.tvChinese

        when (v.id) {
            R.id.tvEnglish -> {
                mBinding.imgSelectEn.visibility = View.VISIBLE
                if (LanguageUtils.LanguageType.ENGLISH.language == DataStoreUtils.readStringData(
                        DataStoreKeyUtils.LANGUAGE_SETTING
                    )
                ) {
                    return
                }
                changeLanguage(LanguageUtils.LanguageType.ENGLISH.language)
            }

            R.id.tvChinese -> {
                mBinding.imgSelectChinese.visibility = View.VISIBLE
                if (LanguageUtils.LanguageType.CHINESE.language == DataStoreUtils.readStringData(
                        DataStoreKeyUtils.LANGUAGE_SETTING
                    )
                ) {
                    return
                }
                changeLanguage(LanguageUtils.LanguageType.CHINESE.language)
            }
        }
    }

    /**
     * 经过测试：android 8.0 以下的版本需要更新 configuration 和 resources，
     * android 8.0 以上只需要将当前的语言环境写入 Sp 文件即可。
     * 测试机型 android4.4、android6.0、android7.0、android7.1、android8.1
     * 然后，重新创建当前页面。
     * @param language
     */
    private fun changeLanguage(language: String) {
        // 版本低于 android 8.0 不执行该方法
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            // 注意，这里的 context 不能传 Application 的 context
            changeAppLanguage(this, language)
        }
        DataStoreUtils.saveSyncStringData(DataStoreKeyUtils.LANGUAGE_SETTING, language)
        val intent = Intent(this, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)
    }


    override fun title(): Int {
        return R.string.title_language
    }
}