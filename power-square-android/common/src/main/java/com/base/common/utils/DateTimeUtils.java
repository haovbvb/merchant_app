package com.base.common.utils;

import android.os.Build;
import android.text.TextUtils;

import androidx.annotation.RequiresApi;

import com.base.common.Preferences;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;
import java.util.regex.Pattern;

public class DateTimeUtils {
    public static String defaultFormat = "MMM dd,yyyy HH:mm:ss";
    public static String timeFormat = "HH:mm";
    public static String timeFormats = "HH:mm:ss";
    public static String dateFormat = "yyyy-MM-dd";
    public static String dateFormat2 = "yyyy/MM/dd";
    public static String dateFormatY = "MMM dd,YYYY";
    public static String dateFormatMMMDD = "MMM dd,YYYY";
    public static String dateFormatNormal = "yyyy-MM-dd HH:mm:ss";
    public static String YY_MM = "yyyy-MM";
    public static String MMM_YYYY = "MMM yyyy";
    public static String YYYYMM = "yyyyMM";
    public static String YYYY = "yyyy";
    public static String DD = "dd";
    public static String MM_DD ="MM-dd";
    public static String dateFormat3 = "yyyy/MM/dd HH:mm:ss";

    public static String dateFormatNormal2="yyyyMMdd HHmmss";

    /**
     * 当地时间 ---> UTC时间
     *
     * @return
     */
    public static String Local2UTC(Locale locale) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", locale);
        sdf.setTimeZone(TimeZone.getTimeZone("gmt"));
        return sdf.format(new Date());
    }

    /**
     * UTC时间 ---> 当地时间
     *
     * @param utcTime UTC时间
     * @return
     */
    public static String utc2Local(long utcTime, String format, Locale locale) {
        String strFormat;
        if (TextUtils.isEmpty(format)) {
            strFormat = "HH:mm:ss MM/dd";
        } else {
            strFormat = format;
        }
        SimpleDateFormat utcFormater = new SimpleDateFormat(strFormat, locale);//UTC时间格式

//        SimpleDateFormat utcFormater = new SimpleDateFormat("HH:mm:ss MM/dd");//UTC时间格式
        utcFormater.setTimeZone(TimeZone.getTimeZone("UTC"));
        Date gpsUTCDate = null;
        try {
            gpsUTCDate = utcFormater.parse(utcFormater.format(utcTime));
        } catch (ParseException e) {
            e.printStackTrace();
        }
        SimpleDateFormat localFormater = new SimpleDateFormat(strFormat, locale);//当地时间格式
        localFormater.setTimeZone(TimeZone.getDefault());
        if (gpsUTCDate != null) {
            return localFormater.format(gpsUTCDate.getTime());
        } else {
            return "";
        }
    }

    /**
     * UTC时间 ---> 当地时间
     *
     * @param utcTime UTC时间
     * @return
     */
    public static String utc2LocalByStr(String utcTime, String format, Locale locale) {
        String strFormat;
        if (TextUtils.isEmpty(format)) {
            strFormat = "HH:mm:ss MM/dd";
        } else {
            strFormat = format;
        }
        SimpleDateFormat utcFormater = new SimpleDateFormat(strFormat, locale);//UTC时间格式

//        SimpleDateFormat utcFormater = new SimpleDateFormat("HH:mm:ss MM/dd");//UTC时间格式
        utcFormater.setTimeZone(TimeZone.getTimeZone("UTC"));
        Date gpsUTCDate = null;
        try {
            gpsUTCDate = utcFormater.parse(utcFormater.format(Long.parseLong(utcTime)));
        } catch (ParseException e) {
            e.printStackTrace();
        }
        SimpleDateFormat localFormater = new SimpleDateFormat(strFormat, locale);//当地时间格式
        localFormater.setTimeZone(TimeZone.getDefault());
        if (gpsUTCDate != null) {
            return localFormater.format(gpsUTCDate.getTime());
        } else {
            return "";
        }
    }


    private static SimpleDateFormat getSimpleDateFormat(final String format, Locale locale) {
        final SimpleDateFormat sdf = new SimpleDateFormat(format, locale);
        sdf.setTimeZone(TimeZone.getDefault());
        return sdf;
    }

    public static String getTimeString(String timeFormat, long timeInMs, Locale locale) {
        return getSimpleDateFormat(timeFormat, locale).format(timeInMs);
    }

    public static String getTimeString(String timeFormat, String timeInMs, Locale locale) {
        return getSimpleDateFormat(timeFormat, locale).format(Double.parseDouble(TextUtils.isEmpty(timeInMs) ? "1" : timeInMs));
    }
    public static String getTimeString(String timeFormat, long timeInMs) {
        return getSimpleDateFormat(timeFormat).format(timeInMs);
    }

    public static String getTimeString(String timeFormat, String timeInMs) {
        return getSimpleDateFormat(timeFormat).format(Double.parseDouble(TextUtils.isEmpty(timeInMs) ? "1" : timeInMs));
    }

    private static SimpleDateFormat getSimpleDateFormat(final String format) {
        Locale locale = getLocaleByLanguage(Preferences.getInstance().getLanguage());
        final SimpleDateFormat sdf = new SimpleDateFormat(format, locale);
        sdf.setTimeZone(TimeZone.getDefault());
        return sdf;
    }

    /**
     * 根据语言获取所在地
     *
     * @param language
     * @return
     */
    public static Locale getLocaleByLanguage(String language) {
        if (!"".equals(language)) {
            switch (language) {
                case "en":
                    return Locale.US;
                case "zh":
                    return Locale.CHINA;
                case "pt":
                    return new Locale("pt");
            }
        }
        return Locale.US;
    }
    public static String getDay(String dateStr, Locale locale) {
        SimpleDateFormat sdfDef = new SimpleDateFormat(defaultFormat, locale);
        SimpleDateFormat sdfDes = new SimpleDateFormat(timeFormat, locale);
        try {
            Date date = sdfDef.parse(dateStr);
            return sdfDes.format(date);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String getHourMin(String dateStr, Locale locale) {
        SimpleDateFormat sdfDef = new SimpleDateFormat(defaultFormat, locale);
        SimpleDateFormat sdfDes = new SimpleDateFormat(timeFormat, locale);
        try {
            Date date = sdfDef.parse(dateStr);
            return sdfDes.format(date);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 时间格式转换为标准格式
     *
     * @param dateStr
     * @return
     */
    public static String changeDateFormatYH(String dateStr, Locale locale) {
        SimpleDateFormat sdfDef = new SimpleDateFormat(defaultFormat, locale);
        SimpleDateFormat sdfDes = new SimpleDateFormat(dateFormatNormal, locale);
        try {
            Date date = sdfDef.parse(dateStr);
            return sdfDes.format(date);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 时间格式转换为标准格式
     *
     * @param dateStr
     * @return
     */
    public static String changeDateFormatYH(String dateStr) {
        if (TextUtils.isEmpty(dateStr)) return "";

        // 支持多种常见格式
        String[] patterns = {
                "MMM dd,yyyy HH:mm:ss",
                "MMM dd, yyyy HH:mm:ss",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy/MM/dd HH:mm:ss"
        };

        for (String pattern : patterns) {
            try {
                SimpleDateFormat sdfDef = new SimpleDateFormat(pattern, Locale.ENGLISH);
                SimpleDateFormat sdfDes = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.ENGLISH);
                Date date = sdfDef.parse(dateStr);
                return sdfDes.format(date);
            } catch (ParseException ignored) {}
        }
        return "";
    }




    public static String changeDateFormat(String dateStr, String format, Locale locale) {
        SimpleDateFormat sdfDef = new SimpleDateFormat(format, locale);
        SimpleDateFormat sdfDes = new SimpleDateFormat(dateFormatY, locale);
        try {
            Date date = sdfDef.parse(dateStr);
            return sdfDes.format(date);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 判断字段是否为空，为空统一返回"-"
     */
    public static String getTimeFormatString(String timeFormat, String timeInMs) {
        return TextUtils.isEmpty(timeInMs) ? "—" : getTimeString(timeFormat, timeInMs, LanguageUtils.LanguageUtil.INSTANCE.getLocalByLanguage());
    }
    /**
     * 判断字段是否为空，为空统一返回"-"
     */
    public static String getTimeFormatString(String timeFormat, String timeInMs, Locale locale) {
        return TextUtils.isEmpty(timeInMs) ? "—" : getTimeString(timeFormat, timeInMs, locale);
    }

    // strTime要转换的String类型的时间
    // formatType时间格式
    // strTime的时间格式和formatType的时间格式必须相同
    public static long stringToLong(String strTime, String formatType, Locale locale) {
        Date date = null; // String类型转成date类型
        try {
            date = stringToDate(strTime, formatType, locale);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        if (date == null) {
            return 0;
        } else {
            long currentTime = dateToLong(date); // date类型转成long类型
            return currentTime;
        }
    }

    // strTime要转换的string类型的时间，formatType要转换的格式yyyy-MM-dd HH:mm:ss//yyyy年MM月dd日
    // HH时mm分ss秒，
    // strTime的时间格式必须要与formatType的时间格式相同
    private static Date stringToDate(String strTime, String formatType, Locale locale)
            throws ParseException {
        SimpleDateFormat formatter = new SimpleDateFormat(formatType, locale);
        Date date = null;
        date = formatter.parse(strTime);
        return date;
    }

    // date要转换的date类型的时间
    private static long dateToLong(Date date) {
        return date.getTime();
    }

    // 获取今天
    public static String getToday(Locale locale) {
        Calendar calendar = Calendar.getInstance();
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MMM dd,yyyy", locale);
        return simpleDateFormat.format(calendar.getTime());
    }

    // 获取前30日
    public static String getPast30Day(Locale locale) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DATE, -30);
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MMM dd,yyyy", locale);
        return simpleDateFormat.format(calendar.getTime());
    }

    // 获取前29日
    public static String getPast29Day(Locale locale) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DATE, -29);
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(dateFormat, locale);
        return simpleDateFormat.format(calendar.getTime());
    }

    // 获取昨天
    public static String getYesterday(Locale locale) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DATE, -1);
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd,yyyy", locale);
        return dateFormat.format(calendar.getTime());
    }

    // 获取当月首日
    public static String getFirstDayOfMonth(Locale locale) {
        Calendar firstDayOfMonth = Calendar.getInstance();
        firstDayOfMonth.set(Calendar.DAY_OF_MONTH, 1);
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd,yyyy", locale);
        return dateFormat.format(firstDayOfMonth.getTime());
    }
    // 获取当月首日
    public static String getCurrentMonthFirstDay(Locale locale) {
        Calendar firstDayOfMonth = Calendar.getInstance();
        firstDayOfMonth.set(Calendar.DAY_OF_MONTH, 1);
        SimpleDateFormat dateFormat = new SimpleDateFormat(DateTimeUtils.dateFormat, locale);
        return dateFormat.format(firstDayOfMonth.getTime());
    }
    /**
     * 获取当月第一天long格式
     * @return
     */
    public static long getFirstDayMillis() {
        // 1. 获取 Calendar 实例（当前时区当前时间）
        Calendar calendar = Calendar.getInstance();
        // 2. 设置为当月第一天
        calendar.set(Calendar.DAY_OF_MONTH, 1);
        // 3. 清零时分秒毫秒，定位到“00:00:00.000”
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        // 4. 返回毫秒值
        return calendar.getTimeInMillis();
    }
    // 获取当月最后一日
    public static String getLastDayOfMonth(Locale locale) {
        Calendar lastDayOfMonth = Calendar.getInstance();
        lastDayOfMonth.set(Calendar.DAY_OF_MONTH, lastDayOfMonth.getActualMaximum(Calendar.DAY_OF_MONTH));
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd,yyyy", locale);
        return dateFormat.format(lastDayOfMonth.getTime());
    }


    /**
     * 获取最近 12 个月的月份缩写（如 "Jan"、"Feb"…），按从当前月往前排（当前月在列表首位）。
     *
     * @param locale 用于本地化月份名称
     * @return 最近 12 个月的月份缩写列表
     */
    public static ArrayList<String> getLast12Months(Locale locale) {
        ArrayList<String> months = new ArrayList<>(12);
        // MMM 模式会输出月份的短名称，如 Jan、Feb 等
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM", locale);

        // 从当前年月开始，取过去 12 个月
        YearMonth now = YearMonth.now();
        for (int i = 0; i < 12; i++) {
            YearMonth ym = now.minusMonths(i);
            months.add(ym.format(formatter));
        }
        return months;
    }
}
