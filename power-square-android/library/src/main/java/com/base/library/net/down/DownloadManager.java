package com.base.library.net.down;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.base.library.utils.FileUtils;
import com.orhanobut.logger.Logger;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import io.reactivex.FlowableEmitter;
import okhttp3.ResponseBody;


/**
 * Date: 2018/11/21. 14:42
 * Author: base
 * Description:
 * Version:
 */
public class DownloadManager {
    private static String APK_CONTENT_TYPE = "application/vnd.android.package-archive";
    private static String PNG_CONTENT_TYPE = "image/png";
    private static String JPG_CONTENT_TYPE = "image/jpg";

    /**
     * 保存文件操作
     *
     * @param sub
     * @param path
     * @param start
     * @param resp
     */
    public static void saveFile(FlowableEmitter<? super DownProgress> sub, String path, long start, ResponseBody resp) {
        InputStream inputStream = null;
        OutputStream outputStream = null;
        File saveFile = new File(path);
        int readLen;
        long downloadSize = start;
        byte[] buffer = new byte[1024 * 2];
        long lastRefreshUiTime = 0;
        long contentLength = resp.contentLength();
        DownProgress downProgress = new DownProgress();
        try {
            try {
                inputStream = resp.byteStream();
                if (start > 0) {
                    contentLength = contentLength + start;
                }
                Logger.i("DownloadManager contentLength=" + contentLength + ",start=" + start);
                if (sub.isCancelled()) {
                    Logger.i("DownloadManager 取消下载0:" + downProgress.toString());
                    sub.onComplete();
                    return;
                }
                outputStream = new FileOutputStream(saveFile, start > 0);
                downProgress.setTotalSize(contentLength);
                downProgress.setPath(path);
                while (!sub.isCancelled() && (readLen = inputStream.read(buffer)) != -1) {
                    if (sub.isCancelled()) {
                        Logger.i("DownloadManager 取消下载1:" + downProgress.toString());
                        return;
                    }
                    outputStream.write(buffer, 0, readLen);
                    downloadSize = downloadSize + readLen;
                    downProgress.setDownloadSize(downloadSize);

                    //下载进度
                    float progress = downloadSize * 1.0f / contentLength;
                    long curTime = System.currentTimeMillis();
                    if (curTime - lastRefreshUiTime >= 200 || progress >= 1.0f) {
                        if (sub.isCancelled()) {
                            Logger.i("DownloadManager 取消下载2:" + downProgress.toString());
                            return;
                        }
                        Logger.i(" DownloadManager onNext:" + downProgress.toString() + " 下载进度：" + downProgress.getFormatStatusString());
                        sub.onNext(downProgress);
                        lastRefreshUiTime = System.currentTimeMillis();
                    }
                }
                outputStream.flush();
                sub.onComplete();
            } finally {
                if (inputStream != null) {
                    inputStream.close();
                }
                if (outputStream != null) {
                    outputStream.close();
                }
                if (resp != null) {
                    resp.close();
                }
            }
        } catch (IOException e) {
            if (sub.isCancelled())
                sub.onError(e);
        }
    }

    /**
     * fileName 传空时自行判断文件名称
     *
     * @param names
     * @param responseBody
     * @return
     */
    public static String getRealFileName(@Nullable String names, ResponseBody responseBody) {
        String name = names;
        String fileSuffix = "";
        if (!TextUtils.isEmpty(name)) {//text/html; charset=utf-8
            String type;
            if (!name.contains(".")) {
                type = responseBody.contentType().toString();
                if (type.equals(APK_CONTENT_TYPE)) {
                    fileSuffix = ".apk";
                } else if (type.equals(PNG_CONTENT_TYPE)) {
                    fileSuffix = ".png";
                } else if (type.equals(JPG_CONTENT_TYPE)) {
                    fileSuffix = ".jpg";
                } else {
                    fileSuffix = "." + responseBody.contentType().subtype();
                }
                name = name + fileSuffix;
            }
        } else {
            name = System.currentTimeMillis() + fileSuffix;
        }
        return name;
    }


    /**
     * 检查子目录是否存在
     *
     * @param paths
     * @param name
     * @return
     */
    public static String getRealFilePath(@Nullable String paths, String name) {
        String path = paths;

        if (path == null) {
            String dirPath = FileUtils.getPrivateDir(FileUtils.DOWNLOAD_DIR);
            path = dirPath + name;
        } else {
            File file = new File(path);
            if (!file.exists()) {
                file.mkdirs();
            }
            path = path + File.separator + name;
            path = path.replaceAll("//", "/");
        }

        return path;
    }


}
