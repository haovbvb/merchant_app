package com.base.common.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class MD5Util {
    public static String encrypt2(String sourceStr) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(sourceStr.getBytes());
            byte[] digest = md.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b & 0xff)); // 转换成十六进制
            }
            return sb.toString().toUpperCase();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
    }
    public static String encrypt(String sourceStr) {
        String result = "";
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(sourceStr.getBytes());
            byte b[] = md.digest();
            int i;
            StringBuffer buf = new StringBuffer("");
            for (int offset = 0; offset < b.length; offset++) {
                i = b[offset];
                if (i < 0)
                    i += 256;
                if (i < 16)
                    buf.append("0");
                buf.append(Integer.toHexString(i));
            }
            result = buf.toString();
        } catch (NoSuchAlgorithmException e) {
           e.printStackTrace();
        }
        return result;
    }


    public static String encode(CharSequence input) {
        try {
            // 获取 MD5 加密对象
            MessageDigest instance = MessageDigest.getInstance("MD5");
            // 对字符串进行加密，返回字节数组
            byte[] digest = instance.digest(input.toString().getBytes());
            StringBuffer sb = new StringBuffer();
            for (byte b : digest) {
                // 获取低八位有效值
                int i = b & 0xff;
                // 将整数转化为 16 进制字符串
                String hexString = Integer.toHexString(i);
                if (hexString.length() < 2) {
                    // 如果是一位，则前补 0
                    hexString = "0" + hexString;
                }
                sb.append(hexString);
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return "";
    }
}
