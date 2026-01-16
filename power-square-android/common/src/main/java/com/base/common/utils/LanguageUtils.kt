package com.base.common.utils

import android.annotation.TargetApi
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.os.LocaleList
import android.text.TextUtils
import com.base.common.GlobalConfigure
import com.base.common.utils.DataStoreUtils.readStringData
import java.util.*

class LanguageUtils {
    enum class LanguageType(language: String) {

        CHINESE("zh"),
        ENGLISH("en"),
        PORTUGAL("pt");

        var language: String = language

    }

    @Suppress("unused", "DEPRECATION")
    object LanguageUtil {
        private const val TAG = "LanguageUtil"
        var sharedPreferences: SharedPreferences? = null
        var editor: SharedPreferences.Editor? = null

        /**
         * @param context 上下文
         * @param newLanguage 想要切换的语言类型 比如 "en" ,"zh"
         */
        fun changeAppLanguage(context: Context, newLanguage: String) {
            if (TextUtils.isEmpty(newLanguage)) {
                return
            }
            val resources = context.resources
            val configuration = resources.configuration
            // 获取想要切换的语言类型
            val locale = getLocaleByLanguage(newLanguage)
            configuration.setLocale(locale)
            // updateConfiguration
            val dm = resources.displayMetrics
            resources.updateConfiguration(configuration, dm)
        }

        private fun getLocaleByLanguage(language: String): Locale {
            // default
            var locale = Locale.SIMPLIFIED_CHINESE
            // chinese
            if (language == LanguageType.CHINESE.language) {
                locale = Locale.SIMPLIFIED_CHINESE
            }
            // english
            if (language == LanguageType.ENGLISH.language) {
                locale = Locale.ENGLISH
            }
            if (language == LanguageType.PORTUGAL.language) {
                locale = Locale(LanguageType.PORTUGAL.language)
            }
            return locale
        }

        fun attachBaseContext(context: Context, language: String): Context {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                updateResources(context, language)
            } else {
                context
            }
        }

        @TargetApi(Build.VERSION_CODES.N)
        private fun updateResources(context: Context, language: String): Context {
            val resources = context.resources
            val locale = getLocaleByLanguage(language)
            val configuration = resources.configuration
            configuration.setLocale(locale)
            configuration.setLocales(LocaleList(locale))
            return context.createConfigurationContext(configuration)
        }

        fun getLocalByLanguage(): Locale {
            val selectLanguage = readStringData(
                DataStoreKeyUtils.LANGUAGE_SETTING,
                LanguageType.ENGLISH.language
            )

            return when (selectLanguage) {
                LanguageType.ENGLISH.language -> Locale.US
                LanguageType.CHINESE.language -> Locale.CHINESE
                LanguageType.PORTUGAL.language -> Locale(LanguageType.PORTUGAL.language)
                else -> Locale.US
            }
        }

        fun getSystemLanguage(context: Context): String {
            return when (context.resources.configuration.locale.language) {
                Locale(LanguageType.CHINESE.language).language -> LanguageType.CHINESE.language
                Locale(LanguageType.ENGLISH.language).language -> LanguageType.ENGLISH.language
                Locale(LanguageType.PORTUGAL.language).language -> LanguageType.PORTUGAL.language
                else -> LanguageType.ENGLISH.language
            }
        }

    }
}