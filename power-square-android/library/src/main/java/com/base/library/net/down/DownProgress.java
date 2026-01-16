package com.base.library.net.down;

import android.os.Parcel;
import android.os.Parcelable;


import com.base.library.utils.FileUtils;

import java.math.BigDecimal;
import java.text.NumberFormat;

/**
 * Date: 2018/11/19. 11:32
 * Author: base
 * Description:
 * Version:
 */
public class DownProgress implements Parcelable {
    private long totalSize;
    private long downloadSize;
    private String path;

    public String getPath() {
        return path == null ? "" : path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public DownProgress() {
    }

    public DownProgress(long totalSize, long downloadSize) {
        this.totalSize = totalSize;
        this.downloadSize = downloadSize;
    }

    public long getTotalSize() {
        return totalSize;
    }

    public DownProgress setTotalSize(long totalSize) {
        this.totalSize = totalSize;
        return this;
    }

    public long getDownloadSize() {
        return downloadSize;
    }

    public DownProgress setDownloadSize(long downloadSize) {
        this.downloadSize = downloadSize;
        return this;
    }

    @Override
    public String toString() {
        return "DownProgress{" +
                "downloadSize=" + downloadSize +
                ", totalSize=" + totalSize +
                "，path=" + path +
                '}';
    }

    /**
     * 是否下载完成
     *
     * @return
     */
    public boolean isDownComplete() {
        return downloadSize == totalSize;
    }

    /**
     * 获得格式化的总Size
     *
     * @return example: 2.00KB , 10.00MB
     */
    public String getFormatTotalSize() {
        return byteCountToDisplaySize(totalSize);
    }

    /**
     * 获得格式化的当前大小
     *
     * @return
     */
    public String getFormatDownloadSize() {
        return byteCountToDisplaySize(downloadSize);
    }

    /**
     * 获得格式化的状态字符串
     *
     * @return example: 2.00MB/36.00MB
     */
    public String getFormatStatusString() {
        return getFormatDownloadSize() + "/" + getFormatTotalSize();
    }

    /**
     * 获得下载的百分比, 保留两位小数
     *
     * @return example: "5.25%"
     */
    public String getPercentString() {
        String percent;
        Double result;
        if (totalSize == 0L) {
            result = 0.0;
        } else {
            result = downloadSize * 1.0 / totalSize;
        }
        NumberFormat nf = NumberFormat.getPercentInstance();
        nf.setMinimumFractionDigits(2);//控制保留小数点后几位，2：表示保留2位小数点
        percent = nf.format(result);
        return percent;
    }

    /**
     * 获得下载的百分比, 保留两位小数
     *
     * @return example: 5.25
     */
    public double getPercent() {
        if (totalSize == 0L) {
            return 0.0;
        } else {
            return downloadSize * 1.0 / totalSize;
        }
    }

    public static String byteCountToDisplaySize(long size) {
        return FileUtils.byteCountToDisplaySize(BigDecimal.valueOf(size));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(this.totalSize);
        dest.writeLong(this.downloadSize);
        dest.writeString(this.path);
    }

    protected DownProgress(Parcel in) {
        this.totalSize = in.readLong();
        this.downloadSize = in.readLong();
        this.path = in.readString();
    }

    public static final Creator<DownProgress> CREATOR = new Creator<DownProgress>() {
        @Override
        public DownProgress createFromParcel(Parcel source) {
            return new DownProgress(source);
        }

        @Override
        public DownProgress[] newArray(int size) {
            return new DownProgress[size];
        }
    };
}

