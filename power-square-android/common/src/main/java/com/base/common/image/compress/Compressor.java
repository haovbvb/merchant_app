package com.base.common.image.compress;

import android.graphics.Bitmap;
import android.net.Uri;

import com.base.library.utils.FileUtils;

import java.io.File;
import java.io.IOException;


/**
 * Date: 2017/8/8. 17:54
 * Author: base
 * Description: 图片压缩
 * Version:
 */

public class Compressor {
    //max width and height values of the compressed image is taken as 612x816
    private int maxWidth = 612;
    private int maxHeight = 816;
    private Bitmap.CompressFormat compressFormat = Bitmap.CompressFormat.JPEG;
    private int quality = 80;
    private String destinationDirectoryPath;

    public Compressor() {
        destinationDirectoryPath = FileUtils.getAppCachePath(FileUtils.IMG_DIR + File.separator + "compressor", true);
    }

    public Compressor setMaxWidth(int maxWidth) {
        this.maxWidth = maxWidth;
        return this;
    }

    public Compressor setMaxHeight(int maxHeight) {
        this.maxHeight = maxHeight;
        return this;
    }

    public Compressor setCompressFormat(Bitmap.CompressFormat compressFormat) {
        this.compressFormat = compressFormat;
        return this;
    }

    public Compressor setQuality(int quality) {
        this.quality = quality;
        return this;
    }

    public Compressor setDestinationDirectoryPath(String destinationDirectoryPath) {
        this.destinationDirectoryPath = destinationDirectoryPath;
        return this;
    }

    public File compressToFile(File imageFile) throws IOException {
        return compressToFile(imageFile, imageFile.getName());
    }

    public File compressToFile(Uri imageFile, String fileName) throws IOException {
        return ImageUtil.compressImage(imageFile, maxWidth, maxHeight, compressFormat, quality,
                destinationDirectoryPath + File.separator + fileName);
    }

    public File compressToFile(File imageFile, String compressedFileName) throws IOException {
        return ImageUtil.compressImage(imageFile, maxWidth, maxHeight, compressFormat, quality,
                destinationDirectoryPath + File.separator + compressedFileName);
    }

    public Bitmap compressToBitmap(File imageFile) throws IOException {
        return ImageUtil.decodeSampledBitmapFromFile(imageFile, maxWidth, maxHeight);
    }

//    public Flowable<File> compressToFileAsFlowable(final File imageFile) {
//        return compressToFileAsFlowable(imageFile, imageFile.getName());
//    }
//
//    public Flowable<File> compressToFileAsFlowable(final File imageFile, final String compressedFileName) {
//        return Flowable.defer(new Callable<Flowable<File>>() {
//            @Override
//            public Flowable<File> call() {
//                try {
//                    return Flowable.just(compressToFile(imageFile, compressedFileName));
//                } catch (IOException e) {
//                    return Flowable.error(e);
//                }
//            }
//        });
//    }
//
//    public Flowable<Bitmap> compressToBitmapAsFlowable(final File imageFile) {
//        return Flowable.defer(new Callable<Flowable<Bitmap>>() {
//            @Override
//            public Flowable<Bitmap> call() {
//                try {
//                    return Flowable.just(compressToBitmap(imageFile));
//                } catch (IOException e) {
//                    return Flowable.error(e);
//                }
//            }
//        });
//    }
}
