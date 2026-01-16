package com.okla.ops.ble

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

object OtaUtil {

    suspend fun readFileToByteArrayAsync(file: File): ByteArray? {
        return withContext(Dispatchers.IO) {
            readFileToByteArray(file)
        }
    }

    fun readFileToByteArray(file: File): ByteArray? {
        if (!file.exists() || !file.isFile) return null
        return try {
            file.readBytes()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun splitBytesToMap(bytes: ByteArray, segmentBytes: Int = 58): Map<Int, ByteArray> {
        val result = mutableMapOf<Int, ByteArray>()
        var index = 0
        var start = 0
        while (start < bytes.size) {
            var end = start + segmentBytes
            if (end > bytes.size) {
                end = bytes.size
            }
            val segment = bytes.copyOfRange(start, end)
            result[index++] = segment
            start = end
        }
        return result
    }


    fun intTo2ByteHexString(value: Int): String {
        require(value in 0..65535) { "error" }
        val high = (value shr 8) and 0xFF // 高 8 位
        val low = value and 0xFF           // 低 8 位
        return "%02X%02X".format(high, low)
    }

    fun intToByteHexString(value: Int): String {
        require(value in 0..65535) { "error" }
        val low = value and 0xFF           // 低 8 位
        return "%02X".format(low)
    }

    fun buildOtaData(data: String, size: Int, index: Int): String {
        val byteLength = data.length / 2
        val lengthHex = intToByteHexString(byteLength + 4)
        val sizeHex = intTo2ByteHexString(size)
        val currentPack = intTo2ByteHexString(index + 1)
        return "01A3${lengthHex}$sizeHex$currentPack$data".plus("0D")
    }
}
