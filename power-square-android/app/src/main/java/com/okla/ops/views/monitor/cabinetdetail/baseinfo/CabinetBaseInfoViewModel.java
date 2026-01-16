package com.okla.ops.views.monitor.cabinetdetail.baseinfo;

import android.net.Uri;
import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.CommonApplication;
import com.base.common.image.compress.Compressor;
import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.net.exception.ErrorMsgBean;
import com.base.library.utils.FileUtils;
import com.bumptech.glide.Glide;
import com.okla.ops.Myapplication;
import com.okla.ops.beans.CabinetDetailBaseInfoBean;
import com.okla.ops.beans.CurrentPointBean;
import com.okla.ops.beans.ImageBean;
import com.okla.ops.http.HttpMethods;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.ObservableSource;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;

/**
 * @Date: 2021/1/26 14:07
 * @Author: craz
 * @Description:
 * @Version:
 */

public class CabinetBaseInfoViewModel extends BaseViewModel {
    MutableLiveData<CabinetDetailBaseInfoBean> baseInfoData = new MutableLiveData<>();
    MutableLiveData<List<CurrentPointBean>> mCurrentAndPointsData = new MutableLiveData<>();
    MutableLiveData<List<ImageBean>> mImageListData = new MutableLiveData<>();
    MutableLiveData<List<String>> mUpdateCabinetImage = new MutableLiveData<>();
    MutableLiveData<String> mModifyCabinetInfo = new MutableLiveData<>();

    public LiveData<CabinetDetailBaseInfoBean> getCabinetBaseInfo(String sn) {
        addDisposable(HttpMethods.INSTANCE.getCabinetBaseInfo(sn).subscribeWith(new NullAbleObserver<CabinetDetailBaseInfoBean>() {
            @Override
            protected void onSuccess(CabinetDetailBaseInfoBean cabinetDetailBaseInfoBean) {
                baseInfoData.setValue(cabinetDetailBaseInfoBean);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                baseInfoData.setValue(null);
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return baseInfoData;
    }

    public LiveData<List<CurrentPointBean>> getCurrentAndPoints() {
        addDisposable(HttpMethods.INSTANCE.getCurrentAndPoints().subscribeWith(new NullAbleObserver<List<CurrentPointBean>>() {
            @Override
            protected void onSuccess(List<CurrentPointBean> currentAndPointBeans) {
                if (currentAndPointBeans != null) {
                    mCurrentAndPointsData.setValue(currentAndPointBeans);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {

            }
        }));
        return mCurrentAndPointsData;
    }

    public LiveData<List<ImageBean>> getImagesList(String imgs) {
        Observable.create(new ObservableOnSubscribe<List<ImageBean>>() {
            @Override
            public void subscribe(ObservableEmitter<List<ImageBean>> emitter) throws Exception {
                List<ImageBean> list = new ArrayList<>();
                String[] split = imgs.split(",");
                File file;
                for (int i = 0; i < split.length; i++) {
                    file = Glide.with(CommonApplication.getInstance()).downloadOnly().load(split[i]).submit().get();
                    list.add(new ImageBean(file, Uri.fromFile(file), false, false));
                }
                emitter.onNext(list);
                emitter.onComplete();
            }
        }).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new NullAbleObserver<List<ImageBean>>() {
                    @Override
                    protected void onSuccess(List<ImageBean> imageBeans) {
                        if (imageBeans != null) {
                            mImageListData.setValue(imageBeans);
                        }
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {

                    }
                });
        return mImageListData;
    }

    public LiveData<List<ImageBean>> getImagesList(List<String> imgs) {
        Observable.create(new ObservableOnSubscribe<List<ImageBean>>() {
                    @Override
                    public void subscribe(ObservableEmitter<List<ImageBean>> emitter) throws Exception {
                        List<ImageBean> list = new ArrayList<>();
                        File file;
                        for (int i = 0; i < imgs.size(); i++) {
                            file = Glide.with(CommonApplication.getInstance()).downloadOnly().load(imgs.get(i)).submit().get();
                            list.add(new ImageBean(file, Uri.fromFile(file), false, false));
                        }
                        emitter.onNext(list);
                        emitter.onComplete();
                    }
                }).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new NullAbleObserver<List<ImageBean>>() {
                    @Override
                    protected void onSuccess(List<ImageBean> imageBeans) {
                        if (imageBeans != null) {
                            mImageListData.setValue(imageBeans);
                        }
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {

                    }
                });
        return mImageListData;
    }


    public LiveData<List<String>> updateCabinetImage(String pid, List<ImageBean> files) {
        addDisposable(Observable.just(files)
                        .throttleFirst(1, TimeUnit.SECONDS)
                        .subscribeOn(Schedulers.io())
                        .observeOn(Schedulers.io())
                        .compose(LoadingTransHelper.loadingState(loadState))
                        .flatMap(new Function<List<ImageBean>, ObservableSource<List<String>>>() {
                            @Override
                            public ObservableSource<List<String>> apply(List<ImageBean> files) throws Exception {
                                List<File> filesList = new ArrayList<>();
                                for (int i = 0; i < files.size(); i++) {
                                    if (!files.get(i).isAdd && files.get(i).fileUri != null && files.get(i).file == null) {
                                        filesList.add(new Compressor().compressToFile(files.get(i).fileUri, String.format("compress_%s", FileUtils.getFileRealNameFromUri(Myapplication.getInstance(), files.get(i).fileUri))));
                                    } else if (!files.get(i).isAdd && files.get(i).getFile() != null) {
                                        filesList.add(files.get(i).getFile());
                                    }
                                }
//                        List<File> filesList = new Compressor(CommonApplication.getInstance()).compressToFile(files);
                                List<MultipartBody.Part> mPartList = new ArrayList<>();
                                for (int i = 0; i < filesList.size(); i++) {
                                    if (filesList.get(i) != null) {
                                        RequestBody requestFile =
                                                RequestBody.create(MediaType.parse("image/png"), filesList.get(i));
                                        MultipartBody.Part part = MultipartBody.Part.createFormData("files", customPushFileName(Uri.fromFile(filesList.get(i))), requestFile);
                                        mPartList.add(part);
                                    }
                                }
                                /**
                                 * Retrofit2.0 Multipart 让文件可传可不传
                                 * java.lang.IllegalStateException: Multipart body must have at least one part.
                                 * 即：至少有一个part文件
                                 */
                                if (filesList.size() == 0) {
                                    MultipartBody.Part part = MultipartBody.Part.createFormData("", "");
                                    mPartList.add(part);
                                }
                                return HttpMethods.INSTANCE.updateCabinetImage(pid, mPartList);
                            }
                        }).subscribeWith(new NullAbleObserver<List<String>>() {
                            @Override
                            protected void onSuccess(List<String> strList) {
                                if (strList != null) {
                                    mUpdateCabinetImage.setValue(strList);
                                } else {
                                    mUpdateCabinetImage.setValue(new ArrayList<>());
                                }
                            }

                            @Override
                            protected void onFail(ErrorMsgBean e) {
                                ToastUtils.showShort(e.getMsg());
                            }
                        })
        );
        return mUpdateCabinetImage;
    }

    public String customPushFileName(Uri file1) {
        return System.currentTimeMillis() + "android" + ".jpg";
    }

    public LiveData<String> modifyCabinetInfo(String sn, String address, String location, String imgs, String label) {
        addDisposable(HttpMethods.INSTANCE.modifyCabinetInfo(sn, address, location, imgs, label).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String s) {
                if (TextUtils.isEmpty(s)) {
                    mModifyCabinetInfo.setValue("");
                } else {
                    mModifyCabinetInfo.setValue(s);
                    ToastUtils.showShort(s);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                mModifyCabinetInfo.setValue(e.getMsg());
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mModifyCabinetInfo;
    }
}