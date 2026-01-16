package com.base.common.timepicker;

import com.base.common.Preferences;
import com.base.common.utils.DateTimeUtils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class DateFormatUtils {

    private static final String DATE_FORMAT_PATTERN_YMD = "yyyy-MM-dd";
    private static final String DATE_FORMAT_PATTERN_YMD_HM = "yyyy-MM-dd HH:mm:ss";
    private static final String DATE_FORMAT_PATTERN_YMD_1 = "MMM dd,yyyy";
    private static final String DATE_FORMAT_PATTERN_YMD_HM_1 = "MMM dd,yyyy HH:mm:ss";
    public static final String DATE_FORMAT_PATTERN_YMD_HM_2 = "MMM dd,yyyy HH:mm";

    /**
     * 字符串转时间戳
     *
     * @param dateStr       日期字符串
     * @param isPreciseTime 是否包含时分
     * @return 时间戳
     */
    public static long str2Long(String dateStr, boolean isPreciseTime) {
        return str2Long(dateStr, getFormatPattern(isPreciseTime));
    }

    private static long str2Long(String dateStr, String pattern) {
        try {
            return new SimpleDateFormat(pattern).parse(dateStr).getTime();
        } catch (Throwable ignored) {
        }
        return 0;
    }
    /**
     * 时间戳转字符串
     *
     * @param timestamp     时间戳
     * @param isPreciseTime 是否包含时分
     * @return 格式化的日期字符串
     */
    public static String long2Str(long timestamp, boolean isPreciseTime) {
        return long2Str(timestamp, getFormatPattern(isPreciseTime));
    }

    public static String long2Str(long timestamp, String pattern) {
        Locale locale = DateTimeUtils.getLocaleByLanguage(Preferences.getInstance().getLanguage());
        return new SimpleDateFormat(pattern, locale).format(new Date(timestamp));
    }


    /**
     * 日期格式转换
     *
     * @param date 日期
     * @return
     */
    public static String formatTranslate(String date, Locale locale) {
        long l = str2Long2(date, false, locale);
        return long2Str(l, false, locale);
    }

    /**
     * 日期格式转换
     *
     * @param date 日期
     * @return
     */
    public static String formatTranslate2(String date, Locale locale) {
        long l = str2Long(date, false, locale);
        return long2Str1(l, false, locale);
    }

    /**
     * 时间戳转字符串
     *
     * @param timestamp     时间戳
     * @param isPreciseTime 是否包含时分
     * @return 格式化的日期字符串
     */
    public static String long2Str(long timestamp, boolean isPreciseTime, Locale locale) {
        return long2Str(timestamp, getFormatPattern(isPreciseTime), locale);
    }

    public static String long2Str(long timestamp, String pattern, Locale locale) {
        return new SimpleDateFormat(pattern, locale).format(new Date(timestamp));
    }

    /**
     * 时间戳转字符串
     *
     * @param timestamp     时间戳
     * @param isPreciseTime 是否包含时分
     * @return 格式化的日期字符串
     */
    public static String long2Str1(long timestamp, boolean isPreciseTime) {
        return long2Str1(timestamp, getFormatPattern1(isPreciseTime), Locale.US);
    }

    public static String long2Str1(long timestamp, boolean isPreciseTime, Locale locale) {
        return long2Str1(timestamp, getFormatPattern1(isPreciseTime), locale);
    }

    public static String long2Str1(long timestamp, String pattern, Locale locale) {
        return new SimpleDateFormat(pattern, locale).format(new Date(timestamp));
    }

    /**
     * 字符串转时间戳
     *
     * @param dateStr       日期字符串
     * @param isPreciseTime 是否包含时分
     * @return 时间戳
     */
    public static long str2Long(String dateStr, boolean isPreciseTime, Locale locale) {
        return str2Long(dateStr, getFormatPattern(isPreciseTime), locale);
    }

    /**
     * 字符串转时间戳
     *
     * @param dateStr       日期字符串
     * @param isPreciseTime 是否包含时分
     * @return 时间戳
     */
    public static long str2Long2(String dateStr, boolean isPreciseTime, Locale locale) {
        return str2Long(dateStr, getFormatPattern1(isPreciseTime), locale);
    }

    private static long str2Long(String dateStr, String pattern, Locale locale) {
        try {
            return new SimpleDateFormat(pattern, locale).parse(dateStr).getTime();
        } catch (Throwable ignored) {
        }
        return 0;
    }

    private static String getFormatPattern(boolean showSpecificTime) {
        if (showSpecificTime) {
            return DATE_FORMAT_PATTERN_YMD_HM;
        } else {
            return DATE_FORMAT_PATTERN_YMD;
        }
    }

    private static String getFormatPattern1(boolean showSpecificTime) {
        if (showSpecificTime) {
            return DATE_FORMAT_PATTERN_YMD_HM_1;
        } else {
            return DATE_FORMAT_PATTERN_YMD_1;
        }
    }

    /**
     * 通用的日期格式化方法
     *
     * @param dateStr       要格式化的日期字符串（例如 "2002-06-11"）
     * @param inputPattern  输入字符串的 SimpleDateFormat 模式（例如 "yyyy-MM-dd"）
     * @param outputPattern 输出字符串的 SimpleDateFormat 模式（例如 "MMM dd, yyyy" 或 "MM dd,yyyy"）
     * @param locale        用于解析和格式化的 Locale
     * @return 按照 outputPattern 格式化后的日期字符串
     * @throws IllegalArgumentException 如果解析失败会抛出
     */
    public static String formatDate(
            String dateStr,
            String inputPattern,
            String outputPattern,
            Locale locale
    ) {
        // 创建解析器
        SimpleDateFormat inputFmt = new SimpleDateFormat(inputPattern, locale);
        Date date;
        try {
            date = inputFmt.parse(dateStr);
        } catch (ParseException e) {
            throw new IllegalArgumentException("无法按照模式解析日期: " + dateStr
                    + "，模式：" + inputPattern, e);
        }

        // 创建格式化器
        SimpleDateFormat outputFmt = new SimpleDateFormat(outputPattern, locale);

        //格式化并返回
        return outputFmt.format(date);
    }

}
