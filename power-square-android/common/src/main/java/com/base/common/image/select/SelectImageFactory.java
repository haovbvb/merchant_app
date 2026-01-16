package com.base.common.image.select;

import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;
import android.webkit.MimeTypeMap;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.base.common.CommonApplication;
import com.base.common.image.compress.Compressor;
import com.base.library.utils.FileUtils;
import com.orhanobut.logger.Logger;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;


import static android.app.Activity.RESULT_OK;


/**
 * Date: 2019/9/27 13:45
 * Author: Jayden
 * Description: 统一选择图片上传适用于Activity\Fragment
 * 功能包含：录像/拍照上传、拍照裁剪上传、相册上传、相册裁剪上传、选择多图上传（默认调用系统的，可集成第三方）
 * Version:
 */
public abstract class SelectImageFactory {
    private static final int REQUEST_MULTIPLE_CODE_CHOOSE = 19;
    private static final int PHOTO_REQUEST_GALLERY = 20;
    private static final int PHOTO_REQUEST_GALLERY_CROP = 21;
    private static final int PHOTO_REQUEST_CUT = 22;
    private static final int PHOTO_REQUEST_CAMERA_CROP = 23;
    private static final int PHOTO_REQUEST_CAMERA_FILE = 24;
    private static final int PHOTO_REQUEST_CAMERA_VIDEO_FILE = 25;
    private static final int REQUEST_MULTIMEDIA_FILE = 26;

    //拍照后的完整图片文件
    public File tempFile;

    /**
     * 用于保存拍照/录像文件的uri
     */
    private Uri mCameraUri;

    /**
     * TODO: 获取多媒体文件
     *
     * @param file
     */
    public void upLoadMultimediaFile(Uri file) {
    }

    /**
     * TODO: 获取录像
     *
     * @param file
     */
    public void upLoadVideoFile(Uri file) {
    }

    /**
     * TODO: 获取返回多个文件
     *
     * @param selected
     */
    public void upLoadMultipleUrl(List<Uri> selected) {
    }


    /**
     * TODO: 获取多张图片
     *
     * @param selected
     */
    public void upLoadMultipleFileImage(List<File> selected) {
    }

    /**
     * TODO:  一般用于获取完整的拍照图片
     *
     * @param uri
     */
    public abstract void upLoadImageFile(Uri uri);

    /**
     * TODO:  一般用于获取完整的拍照图片
     *
     * @param uri
     */
    public void upLoadImageFile(File file) {
    }


    /**
     * 多张选择
     *
     * @param fragment
     * @param type     图片 "image/*"；音频 "audio/*"； 视频 "video/*";  图片视频 "image/*;video/*"
     */
    public void selectMultiple(Fragment fragment, String type) {
        fragment.startActivityForResult(getMultipleIntent(type), REQUEST_MULTIPLE_CODE_CHOOSE);
    }

    /**
     * 多张选择
     *
     * @param activity
     * @param type     图片 "image/*"；音频 "audio/*"； 视频 "video/*";  图片视频 "image/*;video/*"
     */
    public void selectMultiple(Activity activity, String type) {
        activity.startActivityForResult(getMultipleIntent(type), REQUEST_MULTIPLE_CODE_CHOOSE);
    }

    private Intent getMultipleIntent(String type) {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType(type);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
        return intent;
    }

    /**
     * 多张图片选择
     */
    public void selectMultipleImage(Fragment fragment) {
//        selectMultipleImage(9, Matisse.from(fragment));
        selectMultiple(fragment, "image/*");
    }

    public void selectMultipleImage(Activity activity) {
//        selectMultipleImage(9, Matisse.from(activity));
        selectMultiple(activity, "image/*");
    }

    public void selectMultipleImage(int maxSize, Fragment fragment) {
//        selectMultipleImage(maxSize, Matisse.from(fragment));
    }

    public void selectMultipleImage(int maxSize, Activity activity) {
//        selectMultipleImage(maxSize, Matisse.from(activity));
    }

//    /**
//     * 多张图片选择
//     *
//     * @param maxSize 最多选择的个数
//     */
//    private void selectMultipleImage(int maxSize, Matisse matisse) {
//        matisse
//                .choose(MimeType.ofImage())
//                .theme(R.style.Matisse_Dracula)
//                .countable(false)
//                .addFilter(new GifSizeFilter(320, 320, 5 * Filter.K * Filter.K))
//                .maxSelectable(9)
//                .originalEnable(true)
//                .maxOriginalSize(10)
//                .imageEngine(new Glide4Engine())
//                .forResult(REQUEST_MULTIPLE_CODE_CHOOSE);
//    }


    /**
     * 自带图库选择图片进行裁剪
     */
    public void galleryCrop(Fragment fragment) {
        // 激活系统图库，选择一张图片
        fragment.startActivityForResult(getGalleryIntent(), PHOTO_REQUEST_GALLERY_CROP);
    }

    public void galleryCrop(Activity activity) {
        // 激活系统图库，选择一张图片
        activity.startActivityForResult(getGalleryIntent(), PHOTO_REQUEST_GALLERY_CROP);
    }

    /**
     * 自带图库选择图片
     */
    public void gallery(Fragment fragment) {
        // 激活系统图库，选择一张图片
        fragment.startActivityForResult(getGalleryIntent(), PHOTO_REQUEST_GALLERY);
    }

    /**
     * 自带图库选择图片
     */
    public void gallery(Activity activity) {
        // 激活系统图库，选择一张图片
        activity.startActivityForResult(getGalleryIntent(), PHOTO_REQUEST_GALLERY);
    }

    /**
     * @param fragment
     * @param type     图片 "image/*"；音频 "audio/*"； 视频 "video/*";  图片视频 "image/*;video/*"
     */
    public void getMultimedia(Fragment fragment, String type) {
        fragment.startActivityForResult(getMultimediaIntent(type), REQUEST_MULTIMEDIA_FILE);
    }

    /**
     * @param activity
     * @param type     图片 "image/*"；音频 "audio/*"； 视频 "video/*";  图片视频 "image/*;video/*"
     */
    public void getMultimedia(Activity activity, String type) {
        activity.startActivityForResult(getMultimediaIntent(type), REQUEST_MULTIMEDIA_FILE);
    }

    private Intent getGalleryIntent() {
        return getMultimediaIntent("image/*");
    }

    private Intent getMultimediaIntent(String type) {
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, type);
        return intent;
    }

    /**
     * 拍照（拍照后进行图片裁剪）
     */
    public void cameraCropPhoto(Fragment fragment) {
        Intent intent = getCameraPhotoIntent(fragment.getContext());
        if (intent == null) return;
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_CAMERA
        fragment.startActivityForResult(intent, PHOTO_REQUEST_CAMERA_CROP);
    }

    /**
     * 拍照（拍照后进行图片裁剪）
     */
    public void cameraCropPhoto(Activity activity) {
        Intent intent = getCameraPhotoIntent(activity);
        if (intent == null) return;
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_CAMERA
        activity.startActivityForResult(intent, PHOTO_REQUEST_CAMERA_CROP);
    }

    /**
     * 拍照（直接获取拍照后的图片文件）
     */
    public void cameraPhotoFile(Activity activity) {
        Intent intent = getCameraPhotoIntent(activity);
        if (intent == null) return;
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_CAMERA
        activity.startActivityForResult(intent, PHOTO_REQUEST_CAMERA_FILE);
    }

    /**
     * 调用系统相机拍摄照片
     *
     * @param fragment
     */
    public void cameraPhotoFile(Fragment fragment) {
        // 激活相机
        Intent intent = getCameraPhotoIntent(fragment.getContext());
        if (intent == null) return;
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_CAMERA
        fragment.startActivityForResult(intent, PHOTO_REQUEST_CAMERA_FILE);
    }

    /**
     * 调用系统相机拍摄视频
     *
     * @param activity
     */
    public void cameraVideoFile(Activity activity) {
        Intent intent = getCameraVideoIntent(activity);
        if (intent == null) return;
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_CAMERA
        activity.startActivityForResult(intent, PHOTO_REQUEST_CAMERA_VIDEO_FILE);
    }

    /**
     * 调用系统相机拍摄视频
     *
     * @param fragment
     */
    public void cameraVideoFile(Fragment fragment) {
        // 激活相机
        Intent intent = getCameraVideoIntent(fragment.getContext());
        if (intent == null) return;
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_CAMERA
        fragment.startActivityForResult(intent, PHOTO_REQUEST_CAMERA_VIDEO_FILE);
    }

    @Nullable
    private Intent getCameraPhotoIntent(Context context) {
        // 激活相机
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        mCameraUri = customImageUri(context, String.format("camera%d", System.currentTimeMillis()), "jpg");
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        if (mCameraUri != null)
            intent.putExtra(MediaStore.EXTRA_OUTPUT, mCameraUri);
        return intent;
    }

    @Nullable
    private Intent getCameraVideoIntent(Context context) {
        // 激活相机
        Intent intent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
        mCameraUri = createVideoUri(context, String.format("camera_VID_%d", System.currentTimeMillis()), "mp4");
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        if (mCameraUri != null)
            intent.putExtra(MediaStore.EXTRA_OUTPUT, mCameraUri);
        return intent;
    }

    /**
     * 兼容7以下/7+/10+
     *
     * @param context
     * @return
     */
    public Uri customImageUri(Context context, String fileName, String fileSuffix) {
        Uri photoUri = null;
        photoUri = createImageUri(context, fileName, fileSuffix);
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
//            photoUri = createImageUri(context, fileName);
//        } else {
//            tempFile = createCacheFile(String.format("%s%s%s", Environment.DIRECTORY_PICTURES, File.separator, context.getPackageName()), String.format("%s.jpg", fileName));
//            if (tempFile == null) {
//                return null;
//            }
//            photoUri = getImageUri(tempFile, context);
//        }
        return photoUri;
    }

    /**
     * 裁剪图片
     *
     * @param uri
     * @param fragment
     */
    public void crop(Uri uri, Fragment fragment, boolean fromCamera) {
        Intent intent = getCropIntent(uri, fragment.getContext(), fromCamera);
        if (intent == null) return;
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_CUT
        fragment.startActivityForResult(intent, PHOTO_REQUEST_CUT);
    }

    /**
     * 裁剪图片
     *
     * @param uri
     * @param activity
     */
    public void crop(Uri uri, Activity activity, boolean fromCamera) {
        Intent intent = getCropIntent(uri, activity, fromCamera);
        if (intent == null) return;
        // 开启一个带有返回值的Activity，请求码为PHOTO_REQUEST_CUT
        activity.startActivityForResult(intent, PHOTO_REQUEST_CUT);
    }

    @Nullable
    private Intent getCropIntent(Uri uri, Context context, boolean fromCamera) {
        if (uri == null) return null;
        // 裁剪图片意图
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/*");
        intent.putExtra("crop", "true");
        // 裁剪框的比例，1：1
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        // 裁剪后输出图片的尺寸大小
        intent.putExtra("outputX", 250);
        intent.putExtra("outputY", 250);

        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());// 图片格式
        intent.putExtra("noFaceDetection", true);// 取消人脸识别
        intent.putExtra("return-data", true);
        if (fromCamera)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, mCameraUri = customImageUri(context, String.format("cropImage%s", System.currentTimeMillis()), "jpg"));//裁剪后图片保存位置
        return intent;
    }

    /**
     * 文件获取bitmap
     *
     * @param file
     * @return
     */
    public Bitmap decodeFileAsBitmap(File file) {
        Bitmap bitmap = null;
        try {
            FileInputStream fis = new FileInputStream(file);
            bitmap = BitmapFactory.decodeStream(fis);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            return null;
        }
        return bitmap;
    }

    /**
     * 创建图片地址uri,用于保存拍照后的照片 Android 10以后使用这种方法
     *
     * @return 图片的uri
     */
    private Uri createMediaUri(Context context, String fileName, String fileSuffix, String mimeType) {
        //设置保存参数到ContentValues中
        ContentValues contentValues = new ContentValues();
        //设置文件名
        contentValues.put(MediaStore.Images.Media.DISPLAY_NAME, fileName);
        long date = System.currentTimeMillis();
        contentValues.put(MediaStore.Images.Media.DATE_ADDED, date);
        contentValues.put(MediaStore.Images.Media.DATE_TAKEN, date);
        contentValues.put(MediaStore.Images.Media.DATE_MODIFIED, date);
        //兼容Android Q和以下版本
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            //android Q中不再使用DATA字段，而用RELATIVE_PATH代替
            //TODO RELATIVE_PATH是相对路径不是绝对路径;照片存储的地方为：内部存储/Pictures/preventpro
            contentValues.put(MediaStore.Images.Media.RELATIVE_PATH, String.format("%s%s%s", Environment.DIRECTORY_PICTURES, File.separator, context.getPackageName()));
        } else {
            File tempFile = createCacheFile(String.format("%s%s%s", Environment.DIRECTORY_PICTURES, File.separator, context.getPackageName()), String.format("%s.%s", fileName, fileSuffix));
            if (tempFile != null)
                contentValues.put(MediaStore.Images.Media.DATA, tempFile.getAbsolutePath());
        }
        //设置文件类型
        contentValues.put(MediaStore.Images.Media.MIME_TYPE, mimeType);
        //执行insert操作，向系统文件夹中添加文件
        //EXTERNAL_CONTENT_URI代表外部存储器，该值不变
        Uri uri = context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
        return uri;

    }

    /**
     * 创建图片地址uri,用于保存拍照后的照片 Android 10以后使用这种方法
     *
     * @return 图片的uri
     */
    private Uri createImageUri(Context context, String fileName, String fileSuffix) {
        return createMediaUri(context, fileName, fileSuffix, "image/JPEG");

    }

    private Uri createVideoUri(Context context, String fileName, String fileSuffix) {
        return createMediaUri(context, fileName, fileSuffix, "video/mp4");

    }

    public void deleteFile(Context context, Uri uri) {
        context.getContentResolver().delete(uri, null, null);
    }

    /**
     * 文件Uri （适配android7.0）
     *
     * @param file
     * @return
     */
    public Uri getImageUri(File file, Context mActivity) {
        Uri pictureUri = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            ContentValues contentValues = new ContentValues(1);
            long date = System.currentTimeMillis();
            contentValues.put(MediaStore.Images.Media.DATE_ADDED, date);
            contentValues.put(MediaStore.Images.Media.DATE_TAKEN, date);
            contentValues.put(MediaStore.Images.Media.DATE_MODIFIED, date);
            contentValues.put(MediaStore.Images.Media.DATA, file.getAbsolutePath());
            pictureUri = mActivity.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues);
        } else {
            pictureUri = Uri.fromFile(file);
        }
        return pictureUri;
    }

    /**
     * 安卓7.0裁剪根据文件路径获取uri
     */
    public Uri getImageContentUri(File imageFile, Context mActivity) {
        String filePath = imageFile.getAbsolutePath();
        Cursor cursor = mActivity.getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                new String[]{MediaStore.Images.Media._ID},
                MediaStore.Images.Media.DATA + "=? ",
                new String[]{filePath}, null);

        if (cursor != null && cursor.moveToFirst()) {
            int id = cursor.getInt(cursor
                    .getColumnIndex(MediaStore.MediaColumns._ID));
            Uri baseUri = Uri.parse("content://media/external/images/media");
            return Uri.withAppendedPath(baseUri, "" + id);
        } else {
            if (imageFile.exists()) {
                ContentValues values = new ContentValues();
                values.put(MediaStore.Images.Media.DATA, filePath);
                return mActivity.getContentResolver().insert(
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            } else {
                return null;
            }
        }
    }

    /**
     * 创建临时文件
     *
     * @param fileName
     * @return
     */
    public File createCacheFile(String dirName, String fileName) {
        String publicDir = FileUtils.getPublicDir(dirName);
        if (publicDir == null) {
            Logger.e("创建文件夹失败");
            return null;
        }
        return new File(publicDir, fileName);
    }


    public void onActivityResult(int requestCode, int resultCode, Intent data, Fragment fragment, Activity activity) {
        if (resultCode != RESULT_OK) {
            if (mCameraUri != null
                    && (requestCode == PHOTO_REQUEST_CAMERA_VIDEO_FILE
                    || requestCode == PHOTO_REQUEST_CAMERA_CROP
                    || requestCode == PHOTO_REQUEST_CAMERA_FILE
                    || requestCode == PHOTO_REQUEST_CUT)) {
                deleteFile(fragment == null ? activity : fragment.getContext(), mCameraUri);
            }
            return;
        }
        if (requestCode == PHOTO_REQUEST_GALLERY) {
            // 从相册返回的数据
            if (data != null && data.getData() != null) {
                upLoadImageFile(data.getData());
            }
        } else if (requestCode == PHOTO_REQUEST_GALLERY_CROP) {
            // 从相册返回的数据
            if (data != null && data.getData() != null) {
                Uri uri = data.getData();
                if (fragment != null) {
                    crop(uri, fragment, false);
                } else if (activity != null) {
                    crop(uri, activity, false);
                }
            }
        } else if (requestCode == PHOTO_REQUEST_CAMERA_CROP) {
            Uri uri = mCameraUri;
            if (uri == null) return;
            if (fragment != null) {
                crop(uri, fragment, true);
            } else if (activity != null) {
                crop(uri, activity, true);
            }
        } else if (requestCode == PHOTO_REQUEST_CAMERA_FILE || requestCode == PHOTO_REQUEST_CUT) {
            if (mCameraUri == null) return;
            upLoadImageFile(mCameraUri);
            upLoadImageFile(new File(FileUtils.getContentUriFilePath(fragment == null ? activity : fragment.getContext(), mCameraUri)));
        } else if (requestCode == REQUEST_MULTIPLE_CODE_CHOOSE) {
//            uriList = Matisse.obtainResult(data);
//            mSelectedPath = Matisse.obtainPathResult(data);
            List<Uri> uriList = new ArrayList<>();
            if (data != null && data.getData() != null) {
                uriList.add(data.getData());
            } else if (data == null || data.getClipData() == null) {
                for (int i = 0; i < data.getClipData().getItemCount(); i++) {
                    uriList.add(data.getClipData().getItemAt(i).getUri());
                }
            }
            if (uriList.size() > 0) {
                upLoadMultipleUrl(uriList);
//                compressImage(uriList, fragment != null ? fragment.getContext() : activity);
            }
//            Logger.i("OnActivityResult :" + String.valueOf(Matisse.obtainOriginalState(data)));
        } else if (requestCode == PHOTO_REQUEST_CAMERA_VIDEO_FILE) {
            if (mCameraUri == null) return;
            upLoadVideoFile(mCameraUri);
        } else if (requestCode == REQUEST_MULTIMEDIA_FILE) {
            if (data != null && data.getData() != null) {
                upLoadMultimediaFile(data.getData());
            }
        }
    }

    private void getUriFile(Fragment fragment, Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (mCameraUri == null) {
                Logger.i("SelectImageFactory PHOTO_REQUEST_CAMERA_FILE mCameraUri =null");
            }
            if (fragment != null) {
//                    tempFile = (uriToFileApiQ(fragment.getContext(), mCameraUri));
                tempFile = new File((FileUtils.getFileFromContentUri(fragment.getContext(), mCameraUri)));
            } else if (activity != null) {
//                    tempFile = (uriToFileApiQ(activity, mCameraUri));
                tempFile = new File((FileUtils.getFileFromContentUri(activity, mCameraUri)));
            }
        }
    }

//    /**
//     * 压缩图片,压缩示例,建议在调用者处订阅
//     *
//     * @param imageFile
//     */
//    public static Observable<File> compressImage(File imageFile) {
//        Logger.i("FileImageSize-start:=" + imageFile.length());
//        try {
//            return Observable.just(new Compressor().compressToFile(imageFile));
////                    .compose(ServiceGenerator.uiScheduler());
////                    .subscribeWith(new DisposableObserver<File>() {
////                        @Override
////                        protected void onStart() {
////                            super.onStart();
////                        }
////
////                        @Override
////                        public void onNext(File file) {
////                            Logger.i("FileImageSize-end:=" + file.length());
////                            upLoadImageFile(file);
////                        }
////
////                        @Override
////                        public void onError(Throwable e) {
////                            Logger.e(e.toString());
////                        }
////
////                        @Override
////                        public void onComplete() {
////                        }
////                    });
//        } catch (IOException e) {
//            e.printStackTrace();
//            Logger.e(e.toString());
//        }
//        return null;
//    }

//    /**
//     * 压缩图片,压缩示例，建议在调用者处订阅
//     *
//     * @param selected
//     * @return
//     */
//    public DisposableSingleObserver<List<File>> compressImage(List<Uri> selected) {
//        return Observable.fromIterable(selected)
//                .map(new Function<Uri, File>() {
//                    @Override
//                    public File apply(Uri uri) throws Throwable {
//                        try {
//                            String displayName = String.format("%s.%s", System.currentTimeMillis() + Math.round((Math.random() + 1) * 1000), MimeTypeMap.getSingleton().getExtensionFromMimeType(CommonApplication.getInstance().getContentResolver().getType(uri)));
//                            File file = new Compressor().compressToFile(uri, displayName);
//                            return file;
//                        } catch (Exception e) {
//                            e.printStackTrace();
//                        }
//                        return null;
//                    }
//                })
//                .filter(new Predicate<File>() {
//                    @Override
//                    public boolean test(File file) throws Throwable {
//                        if (file != null)
//                            Logger.i("fileImageSize-End-" + file.getPath() + "Length=" + file.length());
//                        return file != null;
//                    }
//                })
//                .toList()
//                .subscribeOn(Schedulers.io())
//                .observeOn(AndroidSchedulers.mainThread())
//                .subscribeWith(new DisposableSingleObserver<List<File>>() {
//                    @Override
//                    protected void onStart() {
//                        super.onStart();
//                    }
//
//                    @Override
//                    public void onSuccess(List<File> files) {
//                        upLoadMultipleFileImage(files);
//                    }
//
//                    @Override
//                    public void onError(Throwable e) {
//                        Logger.e(e.toString());
//                    }
//                });
//    }

}
