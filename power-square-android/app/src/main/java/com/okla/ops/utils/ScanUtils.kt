package com.okla.ops.utils

import android.content.Context
import android.text.InputFilter
import android.text.InputFilter.LengthFilter
import android.text.Spanned
import android.widget.EditText
import com.base.common.utils.ToastUtils
import com.okla.ops.R

class ScanUtils() {
    companion object {
        private var deviceSn = "";
        private var userId = ""
        val chinesePattern = ".*[\\u4e00-\\u9fa5]+.*".toRegex()

        fun getDeviceSn(mContext: Context, mScanResult: String): String {
            if (mScanResult.isBlank()) return ""

            // 禁止中文
            if (mScanResult.matches(chinesePattern)) {
                if(mContext!=null){
                    ToastUtils.showShort(mContext.getString(R.string.tip_no_chinese))
                }
                return ""
            }
            var result = mScanResult.trim()
            //处理 B: 开头的二维码
            if (result.startsWith("B:", ignoreCase = true)) {
                result = result
                    .substringAfter("B:", "")
                    // 移除所有非字母数字的字符（只保留 A-Z a-z 0-9）
                    .replace("[^A-Za-z0-9]".toRegex(), "")
                    .replace(" ","").replace("\n","")
                    .trim()
                return result
            }
            if((result.lowercase().contains("sn:")||result.lowercase().contains("sn="))&& isContainsKeyValue(result)){
                return  parseBatteryQr(mContext, result,0)?.sn?:result
            }else{
                // 格式：sn=xxxx
                if (result.lowercase().contains("sn=")) {
                    val deviceSn = result.substringAfter("sn=", "").substringBefore(",").trim()
                    if (deviceSn.isNotEmpty()) return deviceSn
                }
                if (result.lowercase().contains("sn:")) {
                    val deviceSn = result.substringAfter("sn:", "").substringBefore(",").trim()
                    if (deviceSn.isNotEmpty()) return deviceSn
                }
            }
            if((result.lowercase().contains("vin:")||result.lowercase().contains("vin="))&& isContainsKeyValue(result)){
                return  parseVehicleQr(mContext, result,0)?.sn?:result
            }else{
                // 格式：vin:xxxx
                if (result.lowercase().contains("vin:")) {
                    val keyIndex = result.lowercase().indexOf("vin:")
                    if (keyIndex != -1) {
                        val startIndex = keyIndex + 4
                        val endIndex = result.indexOf(",", startIndex).takeIf { it != -1 } ?: result.length
                        return result.substring(startIndex, endIndex).trim()
                    }
                }
                // 格式：vin=xxxx
                if (result.lowercase().contains("vin=")) {
                    val keyIndex = result.lowercase().indexOf("vin=")
                    if (keyIndex != -1) {
                        val startIndex = keyIndex + 4
                        val endIndex = result.indexOf(",", startIndex).takeIf { it != -1 } ?: result.length
                        return result.substring(startIndex, endIndex).trim()
                    }
                }
            }

            //默认返回清理后的结果
            return mScanResult.trim()
        }

        fun getUserCarNum(mContext: Context, mScanResult: String): String {
            if (mScanResult.toString().matches(chinesePattern)) {
                if(mContext!=null){
                    ToastUtils.showShort(mContext.getString(R.string.tip_no_chinese))
                }
                return ""
            }
            if (mScanResult.contains("cardNum")) {
                val index = mScanResult.indexOf("cardNum=")
                if (index > -1) {
                    userId = mScanResult.substring(index + 8);
                }
                return userId
            } else {
                return mScanResult
            }
        }

//        fun getVehicleVin(mContext: Context, mScanResult: String): String {
//            if (mScanResult.toString().matches(chinesePattern)) {
//                ToastUtils.showShort(mContext.getString(R.string.tip_no_chinese))
//                return ""
//            }
//            if (mScanResult.contains("sn=") && mScanResult.contains(",") && mScanResult.contains("vin=")) {
//                val startIndex = mScanResult.indexOf(",") + 5
//                vehicleVin = mScanResult.substring(startIndex)
//                return vehicleVin
//            } else if (!mScanResult.contains("sn=") && !mScanResult.contains(",") && mScanResult.contains(
//                    "vin="
//                )
//            ) {
//                val startIndex = mScanResult.indexOf("vin=") + 4
//                vehicleVin = mScanResult.substring(startIndex)
//                return vehicleVin
//            } else {
//                return mScanResult;
//            }
//        }


        fun setFilter(etContent: EditText) {
            val filter =
                InputFilter { source: CharSequence, start: Int, end: Int, dest: Spanned?, dstart: Int, dend: Int ->
                    // 不允许中文
                    if (source.toString().matches(chinesePattern)) {
                        "" // 返回空字符串，表示拒绝输入
                    } else {
                        return@InputFilter source
                    }
                }
            val filter1: InputFilter = LengthFilter(50)
            etContent.setFilters(arrayOf<InputFilter>(filter, filter1))
        }


        /**
         * 解析电池二维码，格式示例：
         * "sn=XXXXX,imei=YYYYY,iccid=ZZZZZ" clickType: 0 1 2
         */
        fun parseBatteryQr(mContext: Context, qr: String, clickType: Int): QrCodeBattery? {
            if (qr.matches(chinesePattern)) {
                if(mContext!=null){
                    ToastUtils.showShort(mContext.getString(R.string.tip_no_chinese))
                }
                return null;
            }
            //处理 B: 开头的二维码
            var result= qr.trim()
            if (result.startsWith("B:", ignoreCase = true)) {
                result = result
                    .substringAfter("B:", "")
                    // 移除所有非字母数字的字符（只保留 A-Z a-z 0-9）
                    .replace("[^A-Za-z0-9]".toRegex(), "")
                    .replace(" ","").replace("\n","")
                    .trim()
                return QrCodeBattery(result, "", "")
            }
            if (qr.contains(",")) {
                if(isContainsKeyValue(qr)){
                    // 用逗号拆分，再用 : 或 = 拆键值
                    val map = qr
                        .replace(Regex("[\\r\\n]+"), ",") // 去掉换行
                        .split(',') // 按逗号分割字段
                        .mapNotNull { part ->
                            val cleanPart = part.trim()
                            if (cleanPart.isEmpty()) return@mapNotNull null

                            // 支持 key=value 或 key:value
                            val parts = cleanPart.split(Regex("[:=]"), limit = 2).map { it.trim() }

                            if (parts.size == 2) {
                                val (key, value) = parts
                                if (key.isNotEmpty() && value.isNotEmpty()) key.lowercase() to value else null
                            } else {
                                null
                            }
                        }
                        .toMap()

                    val sn = map["sn"]
                    val imei = map["imei"]
                    val iccid = map["iccid"]
                    return if (!sn.isNullOrEmpty() || !imei.isNullOrEmpty() || !iccid.isNullOrEmpty()) {
                        //至少有一个 key 解析成功，返回正常对象
                        QrCodeBattery(sn, imei, iccid)
                    } else {
                        //全部为空，返回原始字符串
                        QrCodeBattery(qr, "", "")
                    }

                }else{
                    return  dealBatteryNotContainsKeyValue(qr.trim(),clickType)
                }
            } else {
                return dealBatteryNotContainsKeyValue(qr.trim(),clickType)
            }
            return QrCodeBattery(qr, "","")
        }



        /**
         * 解析车辆二维码，格式示例：
         * MODEL:TS1,VIN:WTKB16305S1000699,M:20250115043,C:J0063B25GC0034,VCU:A1905C24C00115,B:613882735933
         */
        fun parseVehicleQr(mContext: Context, qr: String, clickType: Int): QrCodeVehicle? {
            if (qr.matches(chinesePattern)) {
                if(mContext!=null){
                    ToastUtils.showShort(mContext.getString(R.string.tip_no_chinese))
                }
                return null
            }
            //处理 B: 开头的二维码
            var result= qr.trim()
            if (result.startsWith("B:", ignoreCase = true)) {
                result = result
                    .substringAfter("B:", "")
                    // 移除所有非字母数字的字符（只保留 A-Z a-z 0-9）
                    .replace("[^A-Za-z0-9]".toRegex(), "")
                    .replace(" ","").replace("\n","")
                    .trim()
                return QrCodeVehicle(result, result, "")
            }
            if (qr.contains(",")) {
                if(isContainsKeyValue(qr)){
                    // 先去掉换行符，统一用逗号分隔
                    val map = qr.replace(Regex("[\\r\\n]+"), ",") // 去掉换行
                        .split(',') // 按逗号分割
                        .mapNotNull { part ->
                            val cleanPart = part.trim()
                            if (cleanPart.isEmpty()) return@mapNotNull null

                            // 支持 key:value 或 key=value 两种格式
                            val parts = cleanPart.split(Regex("[:=]"), limit = 2).map { it.trim() }

                            if (parts.size == 2) {
                                val (key, value) = parts
                                if (key.isNotEmpty() && value.isNotEmpty()) {
                                    key.uppercase() to value
                                } else null
                            } else {
                                null
                            }
                        }
                        .toMap()

                    val sn = map["VIN"]
                    val vin = map["VIN"]
                    val vcu = map["VCU"]
                    return if (!sn.isNullOrEmpty() || !vin.isNullOrEmpty() || !vcu.isNullOrEmpty()) {
                        //至少一个字段解析成功
                        QrCodeVehicle(sn, vin, vcu)
                    } else {
                        // 全为空，直接返回原始字符串
                        QrCodeVehicle(qr, qr, "")
                    }
                }else{
                    return dealVehicleNotContainsKeyValue(qr.trim(),clickType)
                }

            } else {
                return dealVehicleNotContainsKeyValue(qr.trim(),clickType)
            }
            return QrCodeVehicle(qr.trim(), qr.trim(), "")
        }


        /**
         * 解析电柜二维码
         * 格式 示例https://za-download.esquare-global.com?tenantId=760722E145604BE59D6A5F941E6C52AA&sn=AAAAAA&bt=gadgagasd
         *
         */
        fun parseStationQr(mContext: Context, qr: String): QrCodeStation? {
            if (qr.matches(chinesePattern)) {
                ToastUtils.showShort(mContext.getString(R.string.tip_no_chinese))
                return null
            }
            try {
                if (qr.lowercase().contains("sn=") && qr.lowercase().contains("bt=") && qr.contains(
                        "&"
                    )
                ) {
                    val query = if (qr.contains("?")) qr.substringAfter("?") else qr
                    val map = query.split("&")
                        .mapNotNull { part ->
                            val keyValue = part.split("=", limit = 2)
                            if (keyValue.size == 2) {
                                val key = keyValue[0].lowercase().trim()
                                val value = keyValue[1].trim()
                                key to value
                            } else null
                        }
                        .toMap()

                    val sn = map["sn"] ?: ""
                    val lockDevId = map["bt"] ?: ""
                    return QrCodeStation(sn, lockDevId)
                } else if (qr.lowercase().contains("sn=") && !qr.lowercase().contains("bt=")) {
                    if (qr.contains(",")) {
                        if(isContainsKeyValue(qr)){
                            // 用逗号拆分，再用等号拆键值
                            val map = qr.split(',')
                                .mapNotNull { part ->
                                    val parts = part.split('=', limit = 2).map { it.trim() }
                                    // 确保分割后得到两个非空部分
                                    if (parts.size == 2) {
                                        val (key, value) = parts
                                        if (key.isNotEmpty() && value.isNotEmpty()) key to value else null
                                    } else {
                                        null // 跳过无效分割
                                    }
                                }
                                .toMap()
                            val sn = map["sn"]
                            return QrCodeStation(sn,"")

                        }else{
                            var sn=qr;
                            val index = qr.lowercase().indexOf("sn=")
                            if (index > -1) {
                                sn = qr.substring(index + 3)
                            }
                            return QrCodeStation(sn,"")
                        }
                    } else {
                        var sn=qr;
                        val index = qr.lowercase().indexOf("sn=")
                        if (index > -1) {
                            sn = qr.substring(index + 3)
                        }
                        return QrCodeStation(sn,"")
                    }
                } else {
                    return QrCodeStation(qr, "")
                }
            } catch (e: Exception) {
                e.printStackTrace()
                return null
            }
        }
        fun parseQrCodeCashPay(qr: String): QrCodeCashPay {
            // 先在 "amount=" 和 "payType=" 之间补充逗号，确保能正确 split
            val normalized = qr.replace("amount=", ",amount=").replace("payType=", ",payType=")
            val map = normalized
                .split(",")
                .map { it.trim() }
                .filter { it.contains("=") }
                .map {
                    val (key, value) = it.split("=", limit = 2)
                    key to value
                }
                .toMap()

            return QrCodeCashPay(
                cardNum = map["cardNum"] ?: "",
                orderNo = map["orderNo"] ?: "",
                period = map["period"] ?: "",
                amount = map["amount"] ?: "",
                payType = map["payType"] ?: ""
            )
        }

        private fun dealVehicleNotContainsKeyValue(qr: String,clickType: Int): QrCodeVehicle {
            // 小写 VIN 也要识别
            val qrUpper = qr.uppercase()
            if (!(qrUpper.contains("VIN:") || qrUpper.contains("VIN="))) {
                return when (clickType) {
                    0, 1 -> QrCodeVehicle(qr, qr, "")
                    2 -> QrCodeVehicle("", "", qr)
                    else -> QrCodeVehicle(qr, qr, qr)
                }
            } else if (qrUpper.contains("VIN:")) {
                val keyIndex = qrUpper.indexOf("VIN:")
                val vehicleSN = if (keyIndex != -1) qr.substring(keyIndex + 4).trim() else qr.trim()
                return when (clickType) {
                    0, 1 -> QrCodeVehicle(vehicleSN, vehicleSN, "")
                    2 -> QrCodeVehicle("", "", qr)
                    else -> QrCodeVehicle(vehicleSN, vehicleSN, "")
                }
            } else if (qrUpper.contains("VIN=")) {
                val keyIndex = qrUpper.indexOf("VIN=")
                val vehicleSN = if (keyIndex != -1) qr.substring(keyIndex + 4).trim() else qr.trim()
                return when (clickType) {
                    0, 1 -> QrCodeVehicle(vehicleSN, vehicleSN, "")
                    2 -> QrCodeVehicle("", "", qr)
                    else -> QrCodeVehicle(vehicleSN, vehicleSN, "")
                }
            }
            return QrCodeVehicle(qr, qr,"")
        }

        private fun dealBatteryNotContainsKeyValue(qr:String,clickType: Int): QrCodeBattery {
            if (!qr.lowercase().contains("sn=")) {
                when (clickType) {
                    0 -> {
                        return QrCodeBattery(qr, "", "")
                    }

                    1 -> {
                        return QrCodeBattery("", qr, "")
                    }

                    2 -> {
                        return QrCodeBattery("", "", qr)
                    }
                }
            } else {
                var batterySN = qr
                val index = qr.lowercase().indexOf("sn=")
                if (index > -1) {
                    batterySN = qr.substring(index + 3)
                }
                when (clickType) {
                    0 -> {
                        return QrCodeBattery(batterySN, "", "")
                    }

                    1 -> {
                        return QrCodeBattery("", qr, "")
                    }

                    2 -> {
                        return QrCodeBattery("", "", qr)
                    }
                }
                return QrCodeBattery(batterySN, "", "")
            }
            return QrCodeBattery(qr, "", "")
        }

        private fun isContainsKeyValue(input: String?): Boolean {
            if (input == null) return false

            val trimmedInput = input.trim()
            if (trimmedInput.isEmpty()) return false

            //统一把常见的分隔符替换成逗号，便于拆分
            var normalized = input.trim()
                .replace(Regex("[\\r\\n]+"), "") //去掉所有换行符
                .replace(Regex("[;|]"), ",")   // 统一替换其他分隔符为逗号
            //按逗号拆分并 trim 每一项，过滤掉空项
            val tokens = normalized
                .split(",")
                .map { it.trim() }
                .filter { it.isNotEmpty() }

            if (tokens.isEmpty()) return false

            //检查是否存在 key/value 形式（含 ':' 或 '='），若存在则不是纯 token 列表
            val containsKeyValue = tokens.all { token ->
                token.contains(":") || token.contains("=")
            }
            if (containsKeyValue) return true

            return  false
        }

    }


    data class QrCodeBattery(val sn: String? = "", val imei: String? = "", val iccid: String? = "")
    data class QrCodeVehicle(val sn: String? = "", val vin: String? = "", val vcu: String? = "")
    data class QrCodeStation(val sn: String?="", val lockDevId: String?="")


    data class QrCodeCashPay(
        val cardNum: String,
        val orderNo: String,
        val period: String,
        val amount: String,
        val payType: String
    )


}