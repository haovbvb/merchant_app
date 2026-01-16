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
import com.okla.ops.beans.CurrentPointBean;
import com.okla.ops.beans.ImageBean;
import com.okla.ops.beans.NewCabinetBean;
import com.okla.ops.http.HttpMethods;
import com.okla.ops.utils.EventUtils;

import java.io.File;
import java.util.List;

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
public class PutawayCabinetViewModelNew extends BaseViewModel {
    MutableLiveData<List<CurrentPointBean>> mCurrentAndPointsData = new MutableLiveData<>();
    MutableLiveData<String> mPutawayCabinetData = new MutableLiveData<>();
    MutableLiveData<List<String>> mUpdateCabinetImage = new MutableLiveData<>();
    MutableLiveData<String> mUploadImage = new MutableLiveData<>();
    MutableLiveData<ImageBean> mUploadImageBean = new MutableLiveData<>();

    public MutableLiveData<NewCabinetBean> newCabinetBeanMutableLiveData = new MutableLiveData<>();

    //根据sn或pid获取柜子名称和规格
    public LiveData<NewCabinetBean> getStationSource(String source, String code) {
        addDisposable(HttpMethods.INSTANCE.getStationSource(source, code)
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
                if (e.getCode() == 400) {
                    newCabinetBeanMutableLiveData.setValue(null);
                } else {
                    ToastUtils.showShort(e.getMsg());
                }
                loadState.setValue(
                        State.getInstance(State.ERROR));
            }
        }));
        return newCabinetBeanMutableLiveData;
    }

    public String customPushFileName(File file1) {
        return System.currentTimeMillis() + "android" + FileUtils.getFileRealNameFromUri(Myapplication.getInstance(), Uri.fromFile(file1));
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
        return mUploadImage;
    }

    public LiveData<String> putawayCabinet(String pid,
                                           String sn,
                                           String imgs,
                                           double latitude,
                                           double longitude,
                                           String standardName,//电柜名称
                                           String stationModel,//电柜型号
                                           int standardSwapTime,//换电次数标准
                                           int storeNum,//仓数规格
                                           int label,//落柜区域
                                           String address) {

        addDisposable(HttpMethods.INSTANCE.putawayCabinetNew(pid, sn, imgs, latitude, longitude,
                        standardName, stationModel, standardSwapTime, storeNum, label, address)
                .subscribeWith(new NullAbleObserver<Object>() {
                    @Override
                    protected void onSuccess(Object obj) {
                        mPutawayCabinetData.setValue("");
                    }

                    @Override
                    protected void onFail(ErrorMsgBean e) {
                        ToastUtils.showShort(e.getMsg());
                        if (e.getCode() == EventUtils.INSTANCE.getSuccessResponeCode()) {
                            mPutawayCabinetData.setValue("");
                        } else {
                            mPutawayCabinetData.setValue(e.getMsg());
                        }
                    }
                })
        );
        return mPutawayCabinetData;
    }

    MutableLiveData<String> mGetDeviceSn = new MutableLiveData<>();

    public LiveData<String> getDeviceSn(String content) {
        addDisposable(HttpMethods.INSTANCE.getDeviceSn(1, content).subscribeWith(new NullAbleObserver<String>() {
            @Override
            protected void onSuccess(String str) {
                if (TextUtils.isEmpty(str)) {
                    mGetDeviceSn.setValue(content);
                } else {
                    mGetDeviceSn.setValue(str);
                }
            }

            @Override
            protected void onFail(ErrorMsgBean e) {
                ToastUtils.showShort(e.getMsg());
            }
        }));
        return mGetDeviceSn;
    }

}
