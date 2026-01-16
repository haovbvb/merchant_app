package com.base.library.utils;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Parcel;
import android.os.ParcelFileDescriptor;
import android.os.Parcelable;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.text.TextUtils;

import androidx.annotation.RequiresApi;
import androidx.documentfile.provider.DocumentFile;

import com.base.library.base.BaseApplication;
import com.orhanobut.logger.Logger;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * Refactored FileUtils
 * Key changes:
 * - Deprecated direct usage of Environment.getExternalStorageDirectory() and hard-coded public paths.
 * - Added safe alternatives that use Context.getExternalFilesDir(), getCacheDir(), Uri streams and MediaStore queries.
 * - getFileFromContentUri now falls back to copying content:// URIs into app cache if _data is not available.
 * - Added MediaStore-based scanFilesByExtension to replace recursive File scanning for public storage.
 *
 * NOTE: This class keeps some legacy methods for backward compatibility but marks them as @Deprecated.
 */
public class FileUtils {
    public static final String ROOT_DIR = "Android/data/" + BaseApplication.getInstance().getPackageName();
    public static final String DOWNLOAD_DIR = "download";
    public static final String CACHE_DIR = "cache";
    public static final String HTTP_DIR = "http";
    public static final String ICON_DIR = "icon";
    public static final String APK_DIR = "apk";
    public static final String IMG_DIR = "img";

    public static final long ONE_KB = 1024;
    public static final BigDecimal ONE_KB_BI = BigDecimal.valueOf(ONE_KB);
    public static final BigDecimal ONE_MB_BI = ONE_KB_BI.multiply(ONE_KB_BI);
    public static final BigDecimal ONE_GB_BI = ONE_KB_BI.multiply(ONE_MB_BI);
    public static final BigDecimal ONE_TB_BI = ONE_KB_BI.multiply(ONE_GB_BI);
    public static final BigDecimal ONE_PB_BI = ONE_KB_BI.multiply(ONE_TB_BI);
    public static final BigDecimal ONE_EB_BI = ONE_KB_BI.multiply(ONE_PB_BI);

    // ---------------------------------------------------------------------
    // Safer path getters (use these instead of hard-coded external root paths)
    // ---------------------------------------------------------------------

    /**
     * App private external files directory (e.g. /storage/emulated/0/Android/data/<pkg>/files/dirName)
     */
    public static String getAppExternalFilesDir(Context context, String dirName) {
        if (context == null) context = BaseApplication.getInstance();
        File f = context.getExternalFilesDir(dirName);
        return f == null ? null : (f.getAbsolutePath() + File.separator);
    }

    /**
     * App cache directory (internal)
     */
    public static String getAppCachePath(Context context) {
        if (context == null) context = BaseApplication.getInstance();
        File f = context.getCacheDir();
        return f == null ? null : (f.getAbsolutePath() + File.separator);
    }
    /**
     * 返回 app 缓存目录下的子目录（安全实现，不需要 MANAGE_EXTERNAL_STORAGE）
     *
     * 用法示例：
     * destinationDirectoryPath = FileUtils.getAppCachePath(FileUtils.IMG_DIR + File.separator + "compressor", true);
     */
    public static String getAppCachePath(String name, boolean isFirstSDCard) {
        Context ctx = BaseApplication.getInstance();
        if (ctx == null || TextUtils.isEmpty(name)) return null;

        String basePath = null;

        try {
            if (isFirstSDCard) {
                File extCache = ctx.getExternalCacheDir(); // 优先外部 app cache（不需全文件权限）
                if (extCache != null) {
                    basePath = extCache.getAbsolutePath() + File.separator;
                } else {
                    File internalCache = ctx.getCacheDir();
                    if (internalCache != null) basePath = internalCache.getAbsolutePath() + File.separator;
                }
            } else {
                File internalCache = ctx.getCacheDir();
                if (internalCache != null) {
                    basePath = internalCache.getAbsolutePath() + File.separator;
                } else {
                    File extCache = ctx.getExternalCacheDir();
                    if (extCache != null) basePath = extCache.getAbsolutePath() + File.separator;
                }
            }
        } catch (Exception e) {
            // 保守降级到内部 cache
            File fallback = ctx.getCacheDir();
            if (fallback != null) basePath = fallback.getAbsolutePath() + File.separator;
        }

        if (TextUtils.isEmpty(basePath)) return null;

        String fullPath = basePath + name + File.separator;
        if (createDirs(fullPath)) return fullPath;
        return null;
    }

    /**
     * App external cache path
     */
    public static String getAppExternalCachePath(Context context) {
        if (context == null) context = BaseApplication.getInstance();
        File f = context.getExternalCacheDir();
        return f == null ? null : (f.getAbsolutePath() + File.separator);
    }

    // ---------------------------------------------------------------------
    // Backwards-compatible helper: getPrivateDir(name) (safe, uses app private dirs)
    // ---------------------------------------------------------------------

    /**
     * Returns a private directory for the app for the given name.
     * This implementation prefers the app's external files directory (no MANAGE_EXTERNAL_STORAGE required)
     * and falls back to the app internal cache directory if unavailable.
     *
     * Usage: FileUtils.getPrivateDir(FileUtils.DOWNLOAD_DIR);
     */
    public static String getPrivateDir(String name) {
        return getPrivateDir(name, true);
    }

    /**
     * Returns private directory, with an option to prefer external files dir.
     * If preferExternal is true, attempt getExternalFilesDir(name) and create the folder.
     * Otherwise use the app cache directory.
     */
    public static String getPrivateDir(String name, boolean preferExternal) {
        Context ctx = BaseApplication.getInstance();
        if (ctx == null) return null;

        // try external app-specific files dir first (does not require all-files permission)
        if (preferExternal) {
            String ext = getAppExternalFilesDir(ctx, name);
            if (!TextUtils.isEmpty(ext)) {
                if (createDirs(ext)) return ext;
            }
        }

        // fallback: use external cache if available
        String extCache = getAppExternalCachePath(ctx);
        if (!TextUtils.isEmpty(extCache)) {
            String path = extCache + name + File.separator;
            if (createDirs(path)) return path;
        }

        // final fallback: internal cache
        String cache = getAppCachePath(ctx);
        if (!TextUtils.isEmpty(cache)) {
            String path = cache + name + File.separator;
            if (createDirs(path)) return path;
        }

        return null;
    }

    /**
     * Returns app http cache dir safely.
     * Prefer private external files dir and fall back to internal cache.
     * This does not require MANAGE_EXTERNAL_STORAGE.
     */
    public static String getHttpCacheDir() {
        Context ctx = BaseApplication.getInstance();
        // try the reusable getPrivateDir first
        try {
            String dir = getPrivateDir(HTTP_DIR);
            if (!TextUtils.isEmpty(dir)) return dir;
        } catch (Exception ignored) {
        }

        // fallback to internal cache
        if (ctx != null) {
            File cache = ctx.getCacheDir();
            if (cache != null) {
                String path = cache.getAbsolutePath() + File.separator + HTTP_DIR + File.separator;
                createDirs(path);
                return path;
            }
            File extCache = ctx.getExternalCacheDir();
            if (extCache != null) {
                String path = extCache.getAbsolutePath() + File.separator + HTTP_DIR + File.separator;
                createDirs(path);
                return path;
            }
        }
        return null;
    }

    // ---------------------------------------------------------------------
    // Deprecated / legacy methods — keep but mark deprecated so we can find usages
    // ---------------------------------------------------------------------

    /**
     * Deprecated: Do not use. Hard-coded external root paths are unsafe on Android 10+.
     */
    @Deprecated
    public static String getSDCardPath() {
        try {
            return Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator;
        } catch (Throwable t) {
            return null;
        }
    }

    @Deprecated
    public static String getExternalStoragePath() {
        String sd = getSDCardPath();
        if (sd == null) return null;
        return sd + ROOT_DIR + File.separator;
    }

    @Deprecated
    public static String getPublicDir(String name) {
        // Legacy: prefer MediaStore or SAF for public directories
        String sd = getSDCardPath();
        if (sd == null) return null;
        StringBuilder sb = new StringBuilder();
        sb.append(sd).append(name).append(File.separator);
        String path = sb.toString();
        if (createDirs(path)) {
            return path;
        } else {
            return null;
        }
    }

    // ---------------------------
    // File utilities (safe patterns)
    // ---------------------------

    public static boolean createDirs(String dirPath) {
        if (TextUtils.isEmpty(dirPath)) return false;
        File file = new File(dirPath);
        if (!file.exists() || !file.isDirectory()) {
            return file.mkdirs();
        }
        return true;
    }

    public static boolean createDirs(File file) {
        if (file == null) return false;
        if (!file.exists() || !file.isDirectory()) {
            return file.mkdirs();
        }
        return true;
    }

    public static boolean isFileExist(String filePath) {
        if (TextUtils.isEmpty(filePath)) return false;
        File file = new File(filePath);
        return file.exists();
    }

    public static boolean copyFile(File srcFile, File destFile, boolean deleteSrc) {
        if (srcFile == null || destFile == null) return false;
        if (!srcFile.exists() || !srcFile.isFile()) return false;
        try (InputStream in = new FileInputStream(srcFile);
             OutputStream out = new FileOutputStream(destFile)) {
            byte[] buffer = new byte[4096];
            int i;
            while ((i = in.read(buffer)) > 0) {
                out.write(buffer, 0, i);
            }
            out.flush();
            if (deleteSrc) srcFile.delete();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean copyFile(InputStream srcFile, FileOutputStream destFile, boolean deleteSrc) {
        if (srcFile == null || destFile == null) return false;
        try (InputStream in = srcFile; OutputStream out = destFile) {
            byte[] buffer = new byte[4096];
            int i;
            while ((i = in.read(buffer)) > 0) {
                out.write(buffer, 0, i);
            }
            out.flush();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean delFile(String filePath) {
        if (TextUtils.isEmpty(filePath)) return false;
        File file = new File(filePath);
        if (file.isFile()) return file.delete();
        return false;
    }

    public static void deleteDir(String dirPath) {
        if (TextUtils.isEmpty(dirPath)) return;
        File dir = new File(dirPath);
        if (dir == null || !dir.exists() || !dir.isDirectory()) return;
        File[] files = dir.listFiles();
        if (files == null) return;
        for (File file : files) {
            if (file.isFile()) file.delete();
            else if (file.isDirectory()) deleteDir(file.getAbsolutePath());
        }
        dir.delete();
    }

    public static long getFileSize(File file) {
        if (file == null || !file.exists()) return 0;
        try (FileInputStream fis = new FileInputStream(file)) {
            return fis.available();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static String byteCountToDisplaySize(BigDecimal size) {
        String displaySize;
        if (size.divide(ONE_EB_BI).compareTo(BigDecimal.ONE) > 0) {
            displaySize = size.divide(ONE_EB_BI, 2, BigDecimal.ROUND_HALF_UP) + " EB";
        } else if (size.divide(ONE_PB_BI).compareTo(BigDecimal.ONE) > 0) {
            displaySize = size.divide(ONE_PB_BI, 2, BigDecimal.ROUND_HALF_UP) + " PB";
        } else if (size.divide(ONE_TB_BI).compareTo(BigDecimal.ONE) > 0) {
            displaySize = size.divide(ONE_TB_BI, 2, BigDecimal.ROUND_HALF_UP) + " TB";
        } else if (size.divide(ONE_GB_BI).compareTo(BigDecimal.ONE) > 0) {
            displaySize = size.divide(ONE_GB_BI, 2, BigDecimal.ROUND_HALF_UP) + " GB";
        } else if (size.divide(ONE_MB_BI).compareTo(BigDecimal.ONE) > 0) {
            displaySize = size.divide(ONE_MB_BI, 2, BigDecimal.ROUND_HALF_UP) + " MB";
        } else if (size.divide(ONE_KB_BI).compareTo(BigDecimal.ONE) > 0) {
            displaySize = size.divide(ONE_KB_BI, 2, BigDecimal.ROUND_HALF_UP) + " KB";
        } else {
            displaySize = size + " B";
        }
        return displaySize;
    }

    // ---------------------------------------------------------------------
    // Content Uri helpers (robust)
    // ---------------------------------------------------------------------

    /**
     * Try to get real file path from content Uri. If _data is not available or empty, fallback to copying into app cache and return the cache file path.
     */
    public static String getFileFromContentUri(Context context, Uri uri) {
        if (context == null) context = BaseApplication.getInstance();
        if (uri == null) return null;
        // First try to query _data
        String[] projection = {MediaStore.MediaColumns.DATA};
        try (Cursor cursor = context.getContentResolver().query(uri, projection, null, null, null)) {
            if (cursor != null && cursor.moveToFirst()) {
                int idx = cursor.getColumnIndex(projection[0]);
                if (idx != -1) {
                    String path = cursor.getString(idx);
                    if (!TextUtils.isEmpty(path)) {
                        File f = new File(path);
                        if (f.exists()) return path;
                    }
                }
            }
        } catch (Exception e) {
            // ignore and fallback
        }
        // Fallback: copy to cache and return path
        File cache = copyUriToCacheFile(context, uri);
        return cache == null ? "" : cache.getAbsolutePath();
    }

    /**
     * Copy content:// URI to app cache and return File.
     */
    public static File copyUriToCacheFile(Context context, Uri uri) {
        if (context == null) context = BaseApplication.getInstance();
        if (uri == null) return null;
        ContentResolver cr = context.getContentResolver();
        String displayName = "tmp_" + System.currentTimeMillis();
        try (Cursor cursor = cr.query(uri, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null)) {
            if (cursor != null && cursor.moveToFirst()) {
                int idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                if (idx != -1) displayName = cursor.getString(idx);
            }
        } catch (Exception ignored) {
        }

        File cacheDir = context.getCacheDir();
        if (cacheDir == null) return null;
        File out = new File(cacheDir, displayName);
        try (InputStream is = cr.openInputStream(uri);
             OutputStream os = new FileOutputStream(out)) {
            if (is == null) return null;
            byte[] buf = new byte[4096];
            int len;
            while ((len = is.read(buf)) > 0) {
                os.write(buf, 0, len);
            }
            os.flush();
            return out;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static Bitmap readUriToBitmap(Context context, Uri uri) {
        ParcelFileDescriptor parcelFileDescriptor = null;
        FileDescriptor fileDescriptor = null;
        Bitmap tagBitmap = null;
        try {
            parcelFileDescriptor = context.getContentResolver().openFileDescriptor(uri, "r");
            if (parcelFileDescriptor != null && parcelFileDescriptor.getFileDescriptor() != null) {
                fileDescriptor = parcelFileDescriptor.getFileDescriptor();
                tagBitmap = BitmapFactory.decodeFileDescriptor(fileDescriptor);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } finally {
            try {
                if (parcelFileDescriptor != null) parcelFileDescriptor.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return tagBitmap;
    }

    public static byte[] readUriToByte(Context context, Uri uri) {
        InputStream fileInputStream = null;
        ByteArrayOutputStream byteArrayOutputStream = null;
        byte[] fileByte = null;
        try {
            fileInputStream = context.getContentResolver().openInputStream(uri);
            if (fileInputStream != null) {
                byteArrayOutputStream = new ByteArrayOutputStream();
                byte[] buff = new byte[4096];
                int rc = 0;
                while ((rc = fileInputStream.read(buff)) > 0) {
                    byteArrayOutputStream.write(buff, 0, rc);
                }
                fileByte = byteArrayOutputStream.toByteArray();
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (fileInputStream != null) fileInputStream.close();
                if (byteArrayOutputStream != null) byteArrayOutputStream.close();
            } catch (IOException e) {
            }
        }
        return fileByte;
    }

    public static String getFileRealNameFromUri(Context context, Uri uri) {
        if (context == null || uri == null) return null;
        String fileName = null;
        if (ContentResolver.SCHEME_FILE.equals(uri.getScheme())) {
            fileName = new File(uri.getPath()).getName();
        } else if (ContentResolver.SCHEME_CONTENT.equals(uri.getScheme())) {
            ContentResolver contentResolver = context.getContentResolver();
            Cursor cursor = null;
            try {
                cursor = contentResolver.query(uri, null, null, null, null);
                if (cursor != null && cursor.moveToFirst()) {
                    fileName = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                }
            } finally {
                if (cursor != null) cursor.close();
            }
        }
        return fileName;
    }

    // ---------------------------------------------------------------------
    // MediaStore-based scanning (safe, supports Android Q+)
    // ---------------------------------------------------------------------

    /**
     * Scan files by extension using MediaStore. Returns list of BPFile with path = content uri string.
     * This DOES NOT attempt to traverse file system directly and therefore works with scoped storage.
     */
    public static List<BPFile> scanFilesByExtension(Context context, String ext) {
        List<BPFile> list = new ArrayList<>();
        if (context == null) context = BaseApplication.getInstance();
        if (TextUtils.isEmpty(ext)) return list;
        String selection = MediaStore.MediaColumns.DISPLAY_NAME + " LIKE ?";
        String[] selectionArgs = new String[]{"%." + ext};
        Uri filesUri = MediaStore.Files.getContentUri("external");
        String[] projection = new String[]{
                MediaStore.Files.FileColumns._ID,
                MediaStore.Files.FileColumns.DISPLAY_NAME,
                MediaStore.Files.FileColumns.MIME_TYPE,
                MediaStore.Files.FileColumns.SIZE,
                MediaStore.Files.FileColumns.DATE_MODIFIED
        };
        ContentResolver cr = context.getContentResolver();
        try (Cursor cursor = cr.query(filesUri, projection, selection, selectionArgs, null)) {
            if (cursor == null) return list;
            int idIdx = cursor.getColumnIndex(MediaStore.Files.FileColumns._ID);
            int nameIdx = cursor.getColumnIndex(MediaStore.Files.FileColumns.DISPLAY_NAME);
            int sizeIdx = cursor.getColumnIndex(MediaStore.Files.FileColumns.SIZE);
            int dateIdx = cursor.getColumnIndex(MediaStore.Files.FileColumns.DATE_MODIFIED);

            while (cursor.moveToNext()) {
                long id = idIdx != -1 ? cursor.getLong(idIdx) : -1;
                String name = nameIdx != -1 ? cursor.getString(nameIdx) : "";
                long size = sizeIdx != -1 ? cursor.getLong(sizeIdx) : 0;
                long date = dateIdx != -1 ? cursor.getLong(dateIdx) : 0;
                Uri contentUri = id != -1 ? ContentUris.withAppendedId(filesUri, id) : null;

                BPFile info = new BPFile();
                info.name = name;
                info.path = contentUri == null ? "" : contentUri.toString(); // use content uri
                try {
                    info.size = byteCountToDisplaySize(BigDecimal.valueOf(size));
                } catch (Exception e) {
                    info.size = "0 B";
                }
                info.time = date * 1000L; // DATE_MODIFIED is seconds
                list.add(info);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // -----------------------------
    // Legacy helpers kept
    // -----------------------------
    @Deprecated
    public static String getDataColumn(Context context, Uri uri, String selection, String[] selectionArgs) {
        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {column};
        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs, null);
            if (cursor != null && cursor.moveToFirst()) {
                final int index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(index);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (cursor != null) cursor.close();
        }
        return null;
    }

    // -----------------------------
    // Other utility methods unchanged but safe usage must be ensured by caller
    // -----------------------------

    public static byte[] readInputStream(InputStream in) {
        try {
            ByteArrayOutputStream os = new ByteArrayOutputStream();
            byte[] b = new byte[4096];
            int length;
            while ((length = in.read(b)) != -1) {
                os.write(b, 0, length);
            }
            byte[] result = os.toByteArray();
            in.close();
            os.close();
            return result;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static byte[] readNetWorkInputStream(InputStream in) {
        ByteArrayOutputStream os = null;
        try {
            os = new ByteArrayOutputStream();
            int readCount = 0;
            int len = 1024;
            byte[] buffer = new byte[len];
            while ((readCount = in.read(buffer)) != -1) {
                os.write(buffer, 0, readCount);
            }
            in.close();
            return os.toByteArray();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (os != null) try { os.close(); } catch (IOException ignored) {}
        }
        return null;
    }

    public static InputStream String2InputStream(String str) {
        return new ByteArrayInputStream(str.getBytes());
    }

    public static String inputStream2String(InputStream is) {
        BufferedReader in = new BufferedReader(new InputStreamReader(is));
        StringBuilder buffer = new StringBuilder();
        String line = "";
        try {
            while ((line = in.readLine()) != null) {
                buffer.append(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return buffer.toString();
    }

    public static boolean writeFile(byte[] content, String path, boolean append) {
        if (content == null || TextUtils.isEmpty(path)) return false;
        File f = new File(path);
        RandomAccessFile raf = null;
        try {
            if (f.exists()) {
                if (!append) {
                    f.delete();
                    f.createNewFile();
                }
            } else {
                f.createNewFile();
            }
            if (f.canWrite()) {
                raf = new RandomAccessFile(f, "rw");
                raf.seek(raf.length());
                raf.write(content);
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (raf != null) try { raf.close(); } catch (IOException ignored) {}
        }
        return false;
    }

    public static void writeProperties(String filePath, String key, String value, String comment) {
        if (TextUtils.isEmpty(key) || TextUtils.isEmpty(filePath)) return;
        FileInputStream fis = null;
        FileOutputStream fos = null;
        File f = new File(filePath);
        try {
            if (!f.exists() || !f.isFile()) f.createNewFile();
            fis = new FileInputStream(f);
            Properties p = new Properties();
            p.load(fis);
            p.setProperty(key, value);
            fos = new FileOutputStream(f);
            p.store(fos, comment);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (fis != null) fis.close(); } catch (IOException ignored) {}
            try { if (fos != null) fos.close(); } catch (IOException ignored) {}
        }
    }

    public static String readProperties(String filePath, String key, String defaultValue) {
        if (TextUtils.isEmpty(key) || TextUtils.isEmpty(filePath)) return null;
        String value = null;
        FileInputStream fis = null;
        File f = new File(filePath);
        try {
            if (!f.exists() || !f.isFile()) f.createNewFile();
            fis = new FileInputStream(f);
            Properties p = new Properties();
            p.load(fis);
            value = p.getProperty(key, defaultValue);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try { if (fis != null) fis.close(); } catch (IOException ignored) {}
        }
        return value;
    }

    // -----------------------------
    // BPFile Parcelable unchanged
    // -----------------------------
    public static class BPFile implements Parcelable {
        public String id;
        public String name;
        public long time;
        public String size;
        public String path;
        public boolean isChecked;

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(this.id);
            dest.writeString(this.name);
            dest.writeLong(this.time);
            dest.writeString(this.size);
            dest.writeString(this.path);
            dest.writeByte(this.isChecked ? (byte) 1 : (byte) 0);
        }

        public BPFile() {
        }

        protected BPFile(Parcel in) {
            this.id = in.readString();
            this.name = in.readString();
            this.time = in.readLong();
            this.size = in.readString();
            this.path = in.readString();
            this.isChecked = in.readByte() != 0;
        }

        public static final Parcelable.Creator<BPFile> CREATOR = new Parcelable.Creator<BPFile>() {
            @Override
            public BPFile createFromParcel(Parcel source) {
                return new BPFile(source);
            }

            @Override
            public BPFile[] newArray(int size) {
                return new BPFile[size];
            }
        };
    }
    /**
     * Ensure a file to save to under directory `dirPath` with name `fileName`.
     * If dirPath is null/empty, fallback to app-private cache directory.
     * If a file with the same name exists, it will return a new File with a suffix like "(1)" to make it unique.
     *
     * Usage: File f = FileUtils.checkDownFile(path, picName + ".png");
     */
    public static File checkDownFile(String dirPath, String fileName) {
        // normalize filename
        if (TextUtils.isEmpty(fileName)) {
            fileName = "file_" + System.currentTimeMillis();
        }

        // resolve target directory safely
        String targetDir = dirPath;
        try {
            if (TextUtils.isEmpty(targetDir)) {
                // prefer external app cache
                targetDir = getAppExternalCachePath(BaseApplication.getInstance());
            }
        } catch (Exception ignored) {}

        if (TextUtils.isEmpty(targetDir)) {
            // fallback to getPrivateDir if available
            try {
                targetDir = getPrivateDir(DOWNLOAD_DIR);
            } catch (Exception ignored) {}
        }

        if (TextUtils.isEmpty(targetDir)) {
            // final fallback to internal cache
            try {
                File cache = BaseApplication.getInstance().getCacheDir();
                if (cache != null) {
                    targetDir = cache.getAbsolutePath() + File.separator;
                }
            } catch (Exception ignored) {}
        }

        if (TextUtils.isEmpty(targetDir)) {
            // last-ditch: use current dir
            targetDir = "." + File.separator;
        }

        // ensure directory ends with separator
        if (!targetDir.endsWith(File.separator)) {
            targetDir = targetDir + File.separator;
        }

        // create dirs if necessary
        createDirs(targetDir);

        // create file and ensure unique name if needed
        File file = new File(targetDir, fileName);
        if (file.exists()) {
            String baseName = fileName;
            String extension = "";
            int dotIndex = fileName.lastIndexOf('.');
            if (dotIndex != -1) {
                baseName = fileName.substring(0, dotIndex);
                extension = fileName.substring(dotIndex); // includes '.'
            }
            int i = 1;
            while (file.exists()) {
                String newName = baseName + "(" + i + ")" + extension;
                file = new File(targetDir, newName);
                i++;
            }
        }

        return file;
    }
    /**
     * Resolve a Uri (content:// or file:// or document://) to a local file system path.
     * - For Android Q+ this will copy the Uri content into app cache and return the cache file path (safe).
     * - For pre-Q and Document Uris it attempts to resolve the _data column when possible.
     *
     * NOTE: May return null on failure — caller should null-check before new File(path).
     */
    public static String getContentUriFilePath(final Context context, final Uri uri) {
        if (context == null || uri == null) return null;

        Logger.i("getContentUriFilePath getAuthority=" + uri.getAuthority()
                + " scheme=" + uri.getScheme()
                + " path=" + uri.getPath());

        // DocumentsContract (Android 4.4 <= API < Q)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT
                && Build.VERSION.SDK_INT < Build.VERSION_CODES.Q
                && DocumentsContract.isDocumentUri(context, uri)) {

            // ExternalStorageProvider
            if (isExternalStorageDocument(uri)) {
                try {
                    final String docId = DocumentsContract.getDocumentId(uri);
                    final String[] split = docId.split(":");
                    final String type = split[0];

                    if ("primary".equalsIgnoreCase(type)) {
                        // legacy: direct external storage path (pre-Q)
                        return Environment.getExternalStorageDirectory() + "/" + split[1];
                    } else {
                        // non-primary volumes are tricky on some devices - fallback to safe copy
                        File f = copyUriToCacheFile(context, uri);
                        return f == null ? null : f.getAbsolutePath();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    File f = copyUriToCacheFile(context, uri);
                    return f == null ? null : f.getAbsolutePath();
                }
            }
            // DownloadsProvider
            else if (isDownloadsDocument(uri)) {
                try {
                    final String id = DocumentsContract.getDocumentId(uri);
                    if (id != null && id.startsWith("raw:")) {
                        // raw:/storage/...
                        return id.substring(4);
                    }
                    try {
                        final Uri contentUri = ContentUris.withAppendedId(
                                Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));
                        String path = getDataColumn(context, contentUri, null, null);
                        if (!TextUtils.isEmpty(path)) return path;
                    } catch (NumberFormatException e) {
                        // Some providers return non-numeric id — try direct query
                        String path = getDataColumn(context, uri, null, null);
                        if (!TextUtils.isEmpty(path)) return path;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                // fallback to copying
                File f = copyUriToCacheFile(context, uri);
                return f == null ? null : f.getAbsolutePath();
            }
            // MediaProvider
            else if (isMediaDocument(uri)) {
                try {
                    final String docId = DocumentsContract.getDocumentId(uri);
                    final String[] split = docId.split(":");
                    final String type = split[0];
                    Uri contentUri = null;
                    if ("image".equals(type)) {
                        contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                    } else if ("video".equals(type)) {
                        contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                    } else if ("audio".equals(type)) {
                        contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                    }
                    final String selection = "_id=?";
                    final String[] selectionArgs = new String[]{ split[1] };
                    String path = getDataColumn(context, contentUri, selection, selectionArgs);
                    if (!TextUtils.isEmpty(path)) return path;
                } catch (Exception e) {
                    e.printStackTrace();
                }
                // fallback
                File f = copyUriToCacheFile(context, uri);
                return f == null ? null : f.getAbsolutePath();
            }
        }

        // For Android Q and above, and for any Uri we cannot resolve to a _data path,
        // copy the content to app cache and return that file path (safe, no special permission).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            File f = copyUriToCacheFile(context, uri);
            return f == null ? null : f.getAbsolutePath();
        }

        // For older devices (< Q) with content scheme, try to resolve the _data column first
        if ("content".equalsIgnoreCase(uri.getScheme())) {
            // Return the remote address for Google Photos
            if (isGooglePhotosUri(uri)) {
                return uri.getLastPathSegment();
            }
            String path = null;
            try {
                path = getDataColumn(context, uri, null, null);
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (!TextUtils.isEmpty(path)) return path;

            // fallback: try safe copy
            File f = copyUriToCacheFile(context, uri);
            return f == null ? null : f.getAbsolutePath();
        }
        // file scheme
        else if ("file".equalsIgnoreCase(uri.getScheme())) {
            return uri.getPath();
        }

        // unknown scheme - fallback to safe copy
        File f = copyUriToCacheFile(context, uri);
        return f == null ? null : f.getAbsolutePath();
    }
    /**
     * @return Whether the Uri authority is DownloadsProvider.
     */
    public static boolean isDownloadsDocument(Uri uri) {
        if (uri == null) return false;
        return "com.android.providers.downloads.documents".equals(uri.getAuthority());
    }

    /**
     * @return Whether the Uri authority is Google Photos.
     */
    public static boolean isGooglePhotosUri(Uri uri) {
        if (uri == null) return false;
        return "com.google.android.apps.photos.content".equals(uri.getAuthority());
    }

    /**
     * @return Whether the Uri authority is MediaProvider.
     */
    public static boolean isMediaDocument(Uri uri) {
        if (uri == null) return false;
        return "com.android.providers.media.documents".equals(uri.getAuthority());
    }
    /**
     * @return Whether the Uri authority is ExternalStorageProvider.
     */
    public static boolean isExternalStorageDocument(Uri uri) {
        if (uri == null) return false;
        return "com.android.externalstorage.documents".equals(uri.getAuthority());
    }

}
