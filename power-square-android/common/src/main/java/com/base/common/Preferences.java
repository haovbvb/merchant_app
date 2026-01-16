package com.base.common;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.base.common.utils.DataStoreKeyUtils;
import com.base.common.utils.DataStoreUtils;

public class Preferences {

    private final SharedPreferences sprefs;
    private final SharedPreferences.Editor sprefsEditor;
    private static Preferences mSharePreferencesManager;

    private static String AREA_CODE = "area_code";
    private static String PHONE = "phone";
    private static String ACCOUNT = "account";
    private static String ROLES = "roles";

    private static String SERVICETYPES="servicetypes";
    private static String NAME = "name";
    private static String USER_CODE = "user_code";
    private static String AVATOR = "avator";
    private static String USER_PSW = "user_psw";
    private static String TOKEN = "token";
    private static String LANGUAGE = "language";
    private static String LANGUAGE_COUNTRY = "language_country";
    private static String LANGUAGE_NAME = "language_name";
    private static String LATITUDE = "latitude";
    private static String LONTITUDE = "lontitude";
    private static String LOGOUT = "logout";
    private static String SELECT = "select";
    private static String APP_SERVER = "app_server";
    private static String SEARCH_NAME = "search_name";
    private static String SEARCH_DEVICE = "search_device";
    private static String CURRENT_UNIT = "current_unit";
    private static String DANGER_REGION_LIST = "danger_region_list";
    private static String DANGER_REGION = "danger_region";
    private static String DETECT_VEHICLE_BLE = "detect_vehicle_ble";
    private static String VCU_HISTORY = "vcu_history";

    public Preferences(Context context) {
        sprefs = PreferenceManager.getDefaultSharedPreferences(context);
        sprefsEditor = sprefs.edit();
    }

    public static Preferences getInstance() {
        return getInstance(CommonApplication.getInstance());
    }

    private static Preferences getInstance(Context context) {
        if (mSharePreferencesManager == null) {
            synchronized (Preferences.class) {
                if (mSharePreferencesManager == null) {
                    mSharePreferencesManager = new Preferences(context);
                }
            }
        }
        return mSharePreferencesManager;
    }

    /**
     * 存储用户手机区号
     *
     * @param areaCode
     */
    public void setAreaCode(String areaCode) {
        sprefsEditor.putString(AREA_CODE, areaCode).apply();
    }

    public String getAreaCode() {
        return sprefs.getString(AREA_CODE, "");
    }

    /**
     * 存储用户手机号
     *
     * @param phone
     */
    public void setPhone(String phone) {
        sprefsEditor.putString(PHONE, phone).apply();
    }

    public String getPhone() {
        return sprefs.getString(PHONE, "");
    }

    /**
     * 存储用户登录账号
     *
     * @param account
     */
    public void setAccount(String account) {
        sprefsEditor.putString(ACCOUNT, account).apply();
    }

    public String getAccount() {
        return sprefs.getString(ACCOUNT, "");
    }

    /**
     * 存储用户角色
     *
     * @param roles
     */
    public void setRoles(String roles) {
        sprefsEditor.putString(ROLES, roles).apply();
    }

    public String getRoles() {
        return sprefs.getString(ROLES, "");
    }


    public void setServiceTypes(String serviceTypes) {
        sprefsEditor.putString(SERVICETYPES, serviceTypes).apply();
    }

    public String getServiceTypes() {
        return sprefs.getString(SERVICETYPES, "");
    }

    /**
     * 存储用户登录账户
     *
     * @param name
     */
    public void setName(String name) {
        sprefsEditor.putString(NAME, name).apply();
    }

    public String getName() {
        return sprefs.getString(NAME, "");
    }


    /**
     * 存储用户登录账户
     *
     * @param name
     */
    public void setUserCode(String name) {
        sprefsEditor.putString(USER_CODE, name).apply();
    }

    public String getUserCode() {
        return sprefs.getString(USER_CODE, "");
    }

    /**
     * 存储用户头像路径
     *
     * @param url
     */
    public void setAvator(String url) {
        sprefsEditor.putString(AVATOR, url).apply();
    }

    public String getAvator() {
        return sprefs.getString(AVATOR, "");
    }

    /**
     * 存储用户psw
     *
     * @param psw
     */
    public void setUserPSW(String psw) {
        sprefsEditor.putString(getPhone() + USER_PSW, psw).apply();
    }

    public String getUserPSW() {
        return sprefs.getString(getPhone() + USER_PSW, "");
    }

    /**
     * 存储token
     */
    public void setToken(String token) {
        sprefsEditor.putString(getPhone() + TOKEN, token).apply();
    }

    public String getToken() {
        return sprefs.getString(getPhone() + TOKEN, "");
    }

    /**
     * 存储语言
     */
    public void setLanguage(String token) {
        sprefsEditor.putString(LANGUAGE, token).apply();
    }

    public String getLanguage() {
        return sprefs.getString(LANGUAGE, "en");
    }

    /**
     * 存储语言-国家
     */
    public void setLanguageCountry(String token) {
        sprefsEditor.putString(LANGUAGE_COUNTRY, token).apply();
    }

    public String getLanguageCountry() {
        return sprefs.getString(LANGUAGE_COUNTRY, "");
    }

    /**
     * 存储语言-名称
     */
    public void setLanguageName(String token) {
        sprefsEditor.putString(LANGUAGE_NAME, token).apply();
    }

    public String getLanguageName() {
        return sprefs.getString(LANGUAGE_NAME, "United States - English");
    }

    /**
     * 存储货币-单位
     */
    public void setCurrentUnit(String unit) {
        sprefsEditor.putString(CURRENT_UNIT, unit).apply();
    }

    public String getCurrentUnit() {
        return sprefs.getString(CURRENT_UNIT, "$");
    }

    /**
     * 存储纬度
     */
    public void setLatitude(String latitude) {
        sprefsEditor.putString(LATITUDE, latitude).apply();
    }

    public String getLatitude() {
        return sprefs.getString(LATITUDE, "0.0");
    }

    /**
     * 存储经度
     */
    public void setLontitude(String lontitude) {
        sprefsEditor.putString(LONTITUDE, lontitude).apply();
    }

    public String getLontitude() {
        return sprefs.getString(LONTITUDE, "0.0");
    }

    /**
     * 存储登出状态
     * 0:登录中
     * 1：登出
     */
    public void setLogout(int tag) {
        sprefsEditor.putInt(LOGOUT, tag).apply();
    }

    public int getLogout() {
        return sprefs.getInt(LOGOUT, 0);
    }

    /**
     * 用户协议
     * 0:登录中
     * 1：登出
     */
    public void setAgreement(boolean isSelected) {
        sprefsEditor.putBoolean(SELECT, isSelected).apply();
    }

    public boolean getAgreement() {
        return sprefs.getBoolean(SELECT, false);
    }

    /**
     * 服务器
     * 0:新加坡节点
     * 1：开普敦节点
     */
    public void setAppServer(int tag) {
        sprefsEditor.putInt(APP_SERVER, tag).apply();
    }

    public int getAppServer() {
        return sprefs.getInt(APP_SERVER, 0);
    }

    /**
     * 存储搜索用户历史
     *
     * @param searchName
     */
    public void setSearchName(String searchName) {
        sprefsEditor.putString(SEARCH_NAME, searchName).apply();
    }

    public String getSearchName() {
        return sprefs.getString(SEARCH_NAME, "");
    }

    /**
     * 存储搜索用户历史
     *
     * @param searchName
     */
    public void setSearchDevice(String searchName) {
        sprefsEditor.putString(SEARCH_DEVICE+getAccount(), searchName).apply();
    }

    public String getSearchDevice() {
        return sprefs.getString(SEARCH_DEVICE+getAccount(), "");
    }

    /**
     * 存储危险区域列表
     *
     * @param dangerRegionList 危险区域列表
     */
    public void setDangerRegionList(String dangerRegionList) {
        sprefsEditor.putString(DANGER_REGION_LIST, dangerRegionList).apply();
    }

    public String getDangerRegionList() {
        return sprefs.getString(DANGER_REGION_LIST, "");
    }

    public void removeDangerRegionList() {
        sprefs.edit().remove(DANGER_REGION_LIST).apply();
    }

    /**
     * 存储危险区域详情
     *
     * @param regionNo     区域编号
     * @param dangerRegion 危险区域
     */
    public void setDangerRegion(String regionNo, String dangerRegion) {
        sprefsEditor.putString(DANGER_REGION + "_" + regionNo, dangerRegion).apply();
    }

    public String getDangerRegion(String regionNo) {
        return sprefs.getString(DANGER_REGION + "_" + regionNo, "");
    }

    public void removeDangerRegion(String regionNo) {
        sprefs.edit().remove(DANGER_REGION + "_" + regionNo).apply();
    }

    public void setDetectVehicleBle(String username, boolean isDetect) {
        sprefsEditor.putBoolean(DETECT_VEHICLE_BLE + "_" + username, isDetect).apply();
    }

    public boolean getDetectVehicleBle(String username) {
        return sprefs.getBoolean(DETECT_VEHICLE_BLE + "_" + username, true);
    }

    public void setVcuHistory(String username, String data) {
        sprefsEditor.putString(VCU_HISTORY + "_" + username, data).apply();
    }

    public String getVcuHistory(String username) {
        return sprefs.getString(VCU_HISTORY + "_" + username, "");
    }

    public void removeVcuHistory(String username) {
        sprefs.edit().remove(VCU_HISTORY + "_" + username).apply();
    }
}
