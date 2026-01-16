package com.base.common.qrcode

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.core.app.ActivityCompat
import com.luck.picture.lib.utils.SdkVersionUtils

class QrCodeUtils {
    companion object {
        //const val CAMERA_REQ_CODE = 111
        //自定义
        const val DEFINED_CODE = 222
        const val REQUEST_CODE_SCAN_ONE = 0X01
        const val REQUEST_CODE_SCAN_SN_LIST = 0X02
        const val REQUEST_CODE_DEFINE = 0X0111

        /**
         * @param activity
         * @param requestCode
         * 申请扫码权限
         */
        fun decodePermission(requestCode: Int, activity: Activity) {
            val permissions = mutableListOf(
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.CAMERA,
            )
            if (SdkVersionUtils.isTIRAMISU()) {
                permissions.remove(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
            ActivityCompat.requestPermissions(
                activity, permissions.toTypedArray(),
                requestCode
            )
        }

//        /**
//         * 启动扫码
//         */
//        fun startScanQrCode(activity: Activity) {
//            //ScanUtil.startScan(activity, REQUEST_CODE_SCAN_ONE, HmsScanAnalyzerOptions.Creator().create())
//            val intent = Intent(activity, ScanQrCodeActivity::class.java)
//            activity.startActivityForResult(intent, REQUEST_CODE_DEFINE)
//        }
//        /**
//         * 启动扫码
//         */
//        fun startScanQrCode(activity: Activity,extras:Bundle) {
//            //ScanUtil.startScan(activity, REQUEST_CODE_SCAN_ONE, HmsScanAnalyzerOptions.Creator().create())
//            val intent = Intent(activity, ScanQrCodeActivity::class.java)
//            intent.putExtras(extras)
//            activity.startActivityForResult(intent, REQUEST_CODE_DEFINE)
//        }
        /**
         * 获取扫码意图
         */
        fun getScanIntent(activity: Activity): Intent {
            return Intent(activity, ScanQrCodeActivity::class.java)
        }

    }
}