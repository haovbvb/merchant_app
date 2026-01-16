package com.base.library.utils;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.orhanobut.logger.Logger;

import java.lang.reflect.Type;

/**
 * Date: 2018/10/29. 11:53
 * Author: base
 * Description:
 * Version:
 */
public class GsonUtils {
    private static Gson gson;

    public static String toGson(Object object) {
        if (gson == null) {
            gson = new Gson();
        }
        String json = gson.toJson(object);
        Logger.e(json);
        return json;
    }

    public static <T> T fromGson(String json, Class<T> classofT) {
        if (gson == null) {
            gson = new Gson();
        }
        Logger.e(json);
        try {
            return gson.fromJson(json, classofT);
        } catch (JsonSyntaxException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static <T> T fromGson(String json, Type clazz) {
        if (gson == null) {
            gson = new Gson();
        }
        Logger.e(json);
        return gson.fromJson(json, clazz);
    }
}
