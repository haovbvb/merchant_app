package com.okla.ops.views.workbench.putawaycabinet;

import android.net.Uri;
import android.text.TextUtils;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.base.common.image.compress.Compressor;
import com.base.common.net.NullAbleObserver;
import com.base.common.net.loading.LoadingTransHelper;
import com.base.common.utils.ToastUtils;
import com.base.library.base.mvvm.BaseViewModel;
import com.base.library.base.mvvm.State;
import com.base.library.net.exception.ErrorMsgBean;
import com.base.library.utils.FileUtils;
import com.okla.ops.Myapplication;
import com.okla.ops.beans.CabinetAndCameraBoundBean;
import com.okla.ops.beans.CityCode;
import com.okla.ops.beans.CurrentPointBean;
import com.okla.ops.beans.ImageBean;
import com.okla.ops.beans.NewCabinetBean;
import com.okla.ops.http.HttpMethods;
import com.okla.ops.utils.EventUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.ObservableSource;
import io.reactivex.functions.Function;
import io.reactivex.schedulers.Schedulers;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;

/**
 * @Date: DATE.{TIME}
 * @Author: hong_world
 * @Description:
 * @Version:
 */
public class PutawayCabinetViewModel extends BaseViewModel {
    MutableLiveData<List<CurrentPointBean>> mCurrentAndPointsData = new MutableLiveData<>();
    MutableLiveData<String> mPutawayCabinetData = new MutableLiveData<>();
    MutableLiveData<List<String>> mUpdateCabinetImage = new MutableLiveData<>();
    MutableLiveData<List<CityCode>> mCityCodeListData = new MutableLiveData<>();
    MutableLiveData<CabinetAndCameraBoundBean> mCabinetAndCameraBoundData = new MutableLiveData<>();
    MutableLiveData<String> mUnbindCabinetAndCameraData = new MutableLiveData<>();

    MutableLiveData<String> mUploadImage = new MutableLiveData<>();
    MutableLiveData<ImageBean> mUploadImageBean = new MutableLiveData<>();

    public MutableLiveData<NewCabinetBean> newCabinetBeanMutableLiveData = new MutableLiveData<>();

    //根据sn或pid获取柜子名称和规格
    public LiveData<NewCabinetBean> getStationType(String type, String code) {
        addDisposable(HttpMethods.INSTANCE.getStationSource(type, code)
                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<NewCabinetBean>() {
            @Override
            protected void onSuccess(NewCabinetBean data) {
                if (data != null) {
                    newCabinetBeanMutableLiveData.setValue(data);
                }
                loadState.setValue(
                        State.getInstance(State.SUCCESS));
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
                loadState.setValue(
                        State.getInstance(State.ERROR));
            }
        }));
        return newCabinetBeanMutableLiveData;
    }

    //获取城市列表
    public LiveData<List<CityCode>> getCityCodeList() {
        addDisposable(HttpMethods.INSTANCE.getCityCodeList().subscribeWith(new NullAbleObserver<List<CityCode>>() {
            @Override
            protected void onSuccess(List<CityCode> data) {
                if (data != null) {
                    mCityCodeListData.setValue(data);
                } else {
                    mCityCodeListData.setValue(new ArrayList<CityCode>());
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {

            }
        }));
        return mCityCodeListData;
    }

    public LiveData<List<CurrentPointBean>> getCurrentAndPoints() {
        addDisposable(HttpMethods.INSTANCE.getCurrentAndPoints().subscribeWith(new NullAbleObserver<List<CurrentPointBean>>() {
            @Override
            protected void onSuccess(List<CurrentPointBean> currentPointBeans) {
                if (currentPointBeans != null) {
                    mCurrentAndPointsData.setValue(currentPointBeans);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {

            }
        }));
        return mCurrentAndPointsData;
    }

    public String customPushFileName(File file1) {
        return System.currentTimeMillis() + "android" + FileUtils.getFileRealNameFromUri(Myapplication.getInstance(), Uri.fromFile(file1));
    }

    public LiveData<List<String>> updateCabinetImages(String pid, List<ImageBean> files) {
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
                                    if (!files.get(i).isAdd) {
                                        filesList.add(new Compressor().compressToFile(files.get(i).fileUri, String.format("compress_%s", FileUtils.getFileRealNameFromUri(Myapplication.getInstance(), files.get(i).fileUri))));
                                    }
                                }
//                        List<File> filesList = new Compressor(CommonApplication.INSTANCE).compressToFile(files);
                                List<MultipartBody.Part> mPartList = new ArrayList<>();
                                for (int i = 0; i < filesList.size(); i++) {
                                    if (filesList.get(i) != null) {
                                        RequestBody requestFile =
                                                RequestBody.create(MediaType.parse("image/png"), filesList.get(i));
                                        MultipartBody.Part part = MultipartBody.Part.createFormData("files", customPushFileName(filesList.get(i)), requestFile);
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

    public LiveData<List<String>> updateCabinetImages(List<String> files) {
        mUpdateCabinetImage.setValue(files);
        return mUpdateCabinetImage;
    }

    public LiveData<String> uploadImage(ImageBean imageBean) {
        addDisposable(Observable.just(imageBean)
                .subscribeOn(Schedulers.single())
                .observeOn(Schedulers.io())
                .compose(LoadingTransHelper.loadingState(loadState))
                .flatMap(new Function<ImageBean, ObservableSource<String>>() {
                    @Override
                    public ObservableSource<String> apply(ImageBean imageBean) throws Exception {
                        File file = new Compressor().compressToFile(imageBean.fileUri, String.format("compress_%s", FileUtils.getFileRealNameFromUri(Myapplication.getInstance(), imageBean.fileUri)));
                        RequestBody requestFile =
                                RequestBody.create(MediaType.parse("multipart/form-data"), file);
                        MultipartBody.Part part = MultipartBody.Part.createFormData("file", customPushFileName(file), requestFile);
                        return HttpMethods.INSTANCE.updateCabinetImage(part);
                    }
                })
                .subscribeWith(new NullAbleObserver<String>() {
                    @Override
                    protected void onSuccess(String str) {
                        mUploadImage.setValue(str);
                        mUploadImageBean.setValue(imageBean);
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        ToastUtils.showShort(e.getMsg());
                    }
                }));
        return mUploadImage;
    }

    public LiveData<String> putawayCabinet(String pid,
                                           String sn,
                                           String cityCode,
                                           double latitude,
                                           double longitude,
                                           double chargingCurrent,
                                           String standardName,
                                           String stationModel,
                                           String cameraSn,
                                           String cameraCode,
                                           String maxC,
                                           String label,
                                           String imgs,
                                           String name) {

        addDisposable(HttpMethods.INSTANCE.putawayCabinet(pid, sn, cityCode, latitude, longitude,
                        chargingCurrent, standardName, stationModel, cameraSn, cameraCode, maxC, label, imgs, name)

                .compose(LoadingTransHelper.loadingState(loadState))
                .subscribeWith(new NullAbleObserver<String>() {
                    @Override
                    protected void onSuccess(String str) {
                        mPutawayCabinetData.setValue(TextUtils.isEmpty(str) ? "" : str);
                        if (!TextUtils.isEmpty(str)) {
                            ToastUtils.showShort(str);
                        }
                        loadState.setValue(
                                State.getInstance(State.SUCCESS));
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        if (e.getCode() == EventUtils.INSTANCE.getSuccessResponeCode()) {
                            mPutawayCabinetData.setValue(e.getMsg());
                        }
                        ToastUtils.showShort(e.getMsg());
                        loadState.setValue(
                                State.getInstance(State.ERROR));
                    }
                })
        );
        return mPutawayCabinetData;
    }

    public LiveData<CabinetAndCameraBoundBean> checkCabinetAndCameraBound(String cameraSn, String sn) {
        addDisposable(HttpMethods.INSTANCE.checkCabinetAndCameraBound(cameraSn, sn).subscribeWith(new NullAbleObserver<CabinetAndCameraBoundBean>() {
            @Override
            protected void onSuccess(CabinetAndCameraBoundBean cabinetAndCameraBoundBean) {
                if (cabinetAndCameraBoundBean == null) {
                    mCabinetAndCameraBoundData.setValue(new CabinetAndCameraBoundBean());
                } else {
                    mCabinetAndCameraBoundData.setValue(cabinetAndCameraBoundBean);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                mCabinetAndCameraBoundData.setValue(new CabinetAndCameraBoundBean());
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mCabinetAndCameraBoundData;
    }

    public LiveData<String> unbindCabinetAndCamera(String oldCameraSn, String newCameraSn,
                                                   String oldSn, String newSn, String cameraCode) {
        addDisposable(HttpMethods.INSTANCE.unbindCabinetAndCamera(oldCameraSn, newCameraSn, oldSn, newSn, cameraCode).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String str) {
                mUnbindCabinetAndCameraData.setValue(TextUtils.isEmpty(str) ? "" : str);
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                mUnbindCabinetAndCameraData.setValue(e.getMsg());
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mUnbindCabinetAndCameraData;
    }
}
