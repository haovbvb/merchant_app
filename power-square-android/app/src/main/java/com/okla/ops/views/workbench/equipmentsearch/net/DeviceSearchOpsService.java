package com.okla.ops.views.workbench.equipmentsearch.net;

import com.base.common.net.BaseResponse;
import com.okla.ops.beans.DeviceFix;
import com.okla.ops.beans.EquipmentDeviceSearchBeanNew;

import java.util.Map;

import io.reactivex.Observable;
import okhttp3.MultipartBody;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;
import retrofit2.http.QueryMap;

public interface DeviceSearchOpsService {
    /**
     * 获取搜索设备列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/device/commonSearch")
    Observable<BaseResponse<EquipmentDeviceSearchBeanNew>> getDeviceListSearchDataNew(@QueryMap Map<String, String> map);


}
