package com.okla.ops.views.workbench.qm.repairrecord.net;

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

public interface RepairRecordOpsService {

    /**
     * 查询维修设备信息
     */
    @Headers("Content-Type: application/json")
    @GET("admin/op/queryDeviceForFix")
    Observable<BaseResponse<DeviceFix>> getFixDeviceInfo(@QueryMap Map<String, Object> map);

    /**
     * 维修设备登记
     */
    @Headers("Content-Type: application/json")
    @POST("admin/op/saveDeviceFixRecord")
    Observable<BaseResponse<Object>> addFixDeviceRecord(@Body Object body);

    /**
     * 上傳設備維修圖片
     *
     * @param file
     * @return
     */
    @Multipart
    @POST("admin/op/uploadImg")
    Observable<BaseResponse<String>> uploadFixImg(@Part MultipartBody.Part file);
    /**
     * 获取搜索设备列表
     */
    @Headers("Content-Type: application/json")
    @GET("admin/device/commonSearch")
    Observable<BaseResponse<EquipmentDeviceSearchBeanNew>> getDeviceListSearchDataNew(@QueryMap Map<String, String> map);

}
