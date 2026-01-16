package com.okla.ops.views.workbench.qm.aftersalebind.net;

import com.base.common.net.BaseResponse;
import com.okla.ops.beans.AfterSaleCanBindOrderBean;
import com.okla.ops.beans.BatterOrVehicleInfo;

import java.util.List;
import java.util.Map;

import io.reactivex.Observable;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.POST;
import retrofit2.http.Query;
import retrofit2.http.QueryMap;

public interface AfterSaleBindOpsService {
    @Headers("Content-Type: application/json")
    @GET("admin/op/queryCanBindOrderList")
    Observable<BaseResponse<List<AfterSaleCanBindOrderBean>>> queryCanBindOrderByUserId(@Query("cardNum") String userId);

    /**
     * 售后绑定，查询设备信息
     */
    @Headers("Content-Type: application/json")
    @GET("admin/op/queryDeviceForBindOrder")
    Observable<BaseResponse<BatterOrVehicleInfo>> getAfterSaleBindDeviceInfo(@QueryMap Map<String,Object> map);


    /**
     * 售后绑定设备
     */
    @Headers("Content-Type: application/json")
    @POST("admin/op/bindOrderDevice")
    Observable<BaseResponse<String>> afterSellBind(@Body Object body);

}
