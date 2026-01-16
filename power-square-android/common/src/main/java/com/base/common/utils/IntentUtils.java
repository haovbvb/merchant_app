package com.base.common.utils;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;

import androidx.core.content.FileProvider;

import com.base.common.CommonApplication;

import java.io.File;

public class IntentUtils {

    public static void installAPK(File apkFile) {
        if (!apkFile.exists()) {
            ToastUtils.showShort("apk不存在!");
            return;
        }

        Intent intent = new Intent(Intent.ACTION_VIEW);
        if (apkFile.getName().endsWith(".apk")) {
            try {
                //兼容7.0
                Uri uri;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) { // 适配Android 7系统版本
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION); //添加这一句表示对目标应用临时授权该Uri所代表的文件
                    uri = FileProvider.getUriForFile(CommonApplication.getInstance(), CommonApplication.getInstance().getPackageName() + ".fileProvider", apkFile);//通过FileProvider创建一个content类型的Uri
                } else {
                    uri = Uri.fromFile(apkFile);
                }
                intent.setDataAndType(uri, "application/vnd.android.package-archive"); // 对应apk类型
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            ToastUtils.showShort("不是apk文件!");
        }
        //弹出安装界面
        CommonApplication.getInstance().startActivity(intent);

    }
}
