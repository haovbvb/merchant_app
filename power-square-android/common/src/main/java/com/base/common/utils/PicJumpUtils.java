package com.base.common.utils;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;

import androidx.fragment.app.Fragment;

import com.base.common.GlobalConfigure;
import com.luck.picture.lib.basic.PictureSelector;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.engine.CompressFileEngine;
import com.luck.picture.lib.engine.UriToFileTransformEngine;
import com.luck.picture.lib.interfaces.OnKeyValueResultCallbackListener;
import com.luck.picture.lib.language.LanguageConfig;
import com.luck.picture.lib.style.PictureSelectorStyle;
import com.luck.picture.lib.utils.DateUtils;
import com.luck.picture.lib.utils.SandboxTransformUtils;

import java.io.File;
import java.util.ArrayList;

import top.zibin.luban.Luban;
import top.zibin.luban.OnNewCompressListener;

public class PicJumpUtils {

    public static void jumpMultiChooseAlbumByFragment(Fragment fragment, int maxSelectNum, int selectionMode, int requestCode, boolean isCamera, int chooseMode) {
        PictureSelector pictureSelector = PictureSelector.create(fragment);
        startPhoto(pictureSelector, maxSelectNum, selectionMode, requestCode, isCamera, chooseMode);
    }

    public static void jumpMultiChooseAlbum(Activity activity, int maxSelectNum, int selectionMode, int requestCode, boolean isCamera, int chooseMode) {
        PictureSelector pictureSelector = PictureSelector.create(activity);
        startPhoto(pictureSelector, maxSelectNum, selectionMode, requestCode, isCamera, chooseMode);
    }

    private static void startPhoto(PictureSelector pictureSelector, int maxSelectNum, int selectionMode, int requestCode, boolean isCamera, int chooseMode) {
        pictureSelector
                .openGallery(chooseMode)// 全部.PictureMimeType.ofAll()、图片.ofImage()、视频.ofVideo()、音频.ofAudio()
                .setSelectorUIStyle(new PictureSelectorStyle())// 设置相册主题
                .setLanguage(getPictureSelectorLanguage())// 设置相册语言
                .setImageEngine(GlideEngine.createGlideEngine())// 设置相册图片加载引擎
                .setCompressEngine(new ImageFileCompressEngine())// 设置相册压缩引擎
                .setSandboxFileEngine(new MeSandboxFileEngine())
                .setImageSpanCount(4)// 每行显示个数
                .isDisplayCamera(isCamera)// 是否显示相机入口
                .setSelectionMode(selectionMode)// 单选或是多选
                .setMaxSelectNum(maxSelectNum)// 图片最大选择数量
                .setMinSelectNum(1)// 图片最小选择数量
                .isFilterSizeDuration(true)// 是否过滤图片或音视频大小时长为0的资源
                .forResult(requestCode);// 结果回调onActivityResult code
        //.theme(themeId)// 主题样式设置 具体参考 values/styles   用法：R.style.picture.white.style
        //.maxSelectNum(maxSelectNum)// 最大图片选择数量
        //.minSelectNum(1)// 最小选择数量
        //.imageSpanCount(4)// 每行显示个数
        //.setLanguage(getPictureSelectorLanguage())
        //.selectionMode(PictureConfig.MULTIPLE)// 多选 or 单选
        //.isMaxSelectEnabledMask(true)
        //.selectionMode(selectionMode)// 多选 or 单选
        //.isPreviewImage(true)// 是否可预览图片
        //.isPreviewVideo(true)// 是否可预览视频
        //.isCamera(isCamera)// 是否显示拍照按钮
        //.isZoomAnim(false)// 图片列表点击 缩放效果 默认true
        //.isEnableCrop(false)// 是否裁剪
        //.imageFormat(PictureMimeType.PNG_Q)
        //.isCompress(true)// 是否压缩
        //.synOrAsy(true)//同步true或异步false 压缩 默认同步
        //.compressSavePath(getPath())//压缩图片保存地址
        //.sizeMultiplier(0.5f)// glide 加载图片大小 0~1之间 如设置 .glideOverride()无效
        //.withAspectRatio(aspect_ratio_x, aspect_ratio_y)// 裁剪比例 如16:9 3:2 3:4 1:1 可自定义
        //.hideBottomControls(cb_hide.isChecked() ? false : true)// 是否显示uCrop工具栏，默认不显示
        //.isGif(false)// 是否显示gif图片
        //.freeStyleCropEnabled(true)// 裁剪框是否可拖拽
        //.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED)// 设置相册Activity方向，不设置默认使用系统
        //.circleDimmedLayer(cb_crop_circular.isChecked())// 是否圆形裁剪
        //.showCropFrame(cb_showCropFrame.isChecked())// 是否显示裁剪矩形边框 圆形裁剪时建议设为false
        //.showCropGrid(cb_showCropGrid.isChecked())// 是否显示裁剪矩形网格 圆形裁剪时建议设为false
        //.openClickSound(cb_voice.isChecked())// 是否开启点击声音
        //.selectionMedia(selectList)// 是否传入已选图片
        //.isDragFrame(false)// 是否可拖动裁剪框(固定)
//                        .videoMaxSecond(15)
//                        .videoMinSecond(10)
        //.previewEggs(false)// 预览图片时 是否增强左右滑动图片体验(图片滑动一半即可看到上一张是否选中)
        //.cropCompressQuality(90)// 裁剪压缩质量 默认100
        //.minimumCompressSize(100)// 小于100kb的图片不压缩
        //.cropWH()// 裁剪宽高比，设置如果大于图片本身宽高则无效
        //.rotateEnabled(true) // 裁剪是否可旋转图片
        //.scaleEnabled(true)// 裁剪是否可放大缩小图片
        //.videoQuality()// 视频录制质量 0 or 1
        //.videoSecond()//显示多少秒以内的视频or音频也可适用
        //.recordVideoSecond()//录制视频秒数 默认60s
        //.forResult(PictureConfig.CHOOSE_REQUEST);//结果回调onActivityResult code
        //.forResult(requestCode);//结果回调onActivityResult code
    }

    public static void jumpCameraByFragment(Fragment fragment, int requestCode, int chooseMode) {
        PictureSelector pictureSelector = PictureSelector.create(fragment);
        startCamera(pictureSelector, requestCode, chooseMode);
    }

    public static void jumpCamera(Activity activity, int requestCode, int chooseMode) {
        PictureSelector pictureSelector = PictureSelector.create(activity);
        startCamera(pictureSelector, requestCode, chooseMode);
    }

    private static void startCamera(PictureSelector pictureSelector, int requestCode, int chooseMode) {
        pictureSelector
                .openCamera(chooseMode)
                .setLanguage(getPictureSelectorLanguage())// 设置相机语言
                .setCompressEngine(new ImageFileCompressEngine())// 设置相册压缩引擎
                .isCameraRotateImage(true)// 拍照是否纠正旋转图片
                .forResultActivity(requestCode);
    }

    private static int getPictureSelectorLanguage() {
        String localLanguage = DataStoreUtils.readStringData(DataStoreKeyUtils.Companion.getLANGUAGE_SETTING(), LanguageUtils.LanguageType.ENGLISH.getLanguage());
        if (TextUtils.equals(localLanguage, LanguageUtils.LanguageType.CHINESE.getLanguage())) {
            return LanguageConfig.CHINESE;
        } else {
            return LanguageConfig.ENGLISH;
        }
    }

    /**
     * 自定义压缩
     */
    private static class ImageFileCompressEngine implements CompressFileEngine {

        @Override
        public void onStartCompress(Context context, ArrayList<Uri> source, OnKeyValueResultCallbackListener call) {
            Luban.with(context).load(source).ignoreBy(100).setRenameListener(filePath -> {
                int indexOf = filePath.lastIndexOf(".");
                String postfix = indexOf != -1 ? filePath.substring(indexOf) : ".jpg";
                return DateUtils.getCreateFileName("CMP_") + postfix;
            }).filter(path -> {
                if (PictureMimeType.isUrlHasImage(path) && !PictureMimeType.isHasHttp(path)) {
                    return true;
                }
                return !PictureMimeType.isUrlHasGif(path);
            }).setCompressListener(new OnNewCompressListener() {
                @Override
                public void onStart() {
                }

                @Override
                public void onSuccess(String source, File compressFile) {
                    if (call != null) {
                        call.onCallback(source, compressFile.getAbsolutePath());
                    }
                }

                @Override
                public void onError(String source, Throwable e) {
                    if (call != null) {
                        call.onCallback(source, null);
                    }
                }
            }).launch();
        }
    }

    /**
     * 自定义沙盒文件处理
     */
    private static class MeSandboxFileEngine implements UriToFileTransformEngine {

        @Override
        public void onUriToFileAsyncTransform(Context context, String srcPath, String mineType, OnKeyValueResultCallbackListener call) {
            if (call != null) {
                call.onCallback(srcPath, SandboxTransformUtils.copyPathToSandbox(context, srcPath, mineType));
            }
        }
    }

}
