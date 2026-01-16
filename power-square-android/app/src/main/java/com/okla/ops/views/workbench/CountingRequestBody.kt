package com.okla.ops.views.workbench

import okhttp3.MediaType
import okhttp3.RequestBody
import okio.Buffer
import okio.BufferedSink
import okio.ForwardingSink
import okio.buffer

class CountingRequestBody(
    private val delegate: RequestBody,
    private val onProgress: (bytesWritten: Long, contentLength: Long) -> Unit
) : RequestBody() {

    override fun contentType(): MediaType? = delegate.contentType()

    override fun contentLength(): Long = delegate.contentLength()

    override fun writeTo(sink: BufferedSink) {
        // 用 ForwardingSink 包一层，拦截写入
        val countingSink = object : ForwardingSink(sink) {
            var bytesWrittenSoFar = 0L
            val totalBytes = contentLength()

            override fun write(source: Buffer, byteCount: Long) {
                super.write(source, byteCount)
                bytesWrittenSoFar += byteCount
                onProgress(bytesWrittenSoFar, totalBytes)
            }
        }
        val buffered = countingSink.buffer()
        delegate.writeTo(buffered)
        buffered.flush()
    }
}
