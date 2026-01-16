package com.okla.ops.views.workbench.qm.unbind.net;

import com.base.common.net.BaseResponse;
import com.okla.ops.beans.BatteryUnbindBean;

import io.reactivex.Observable;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface UnbindOpsService {
//    /**
//     * 解绑中控/电池
//     */
//    @Headers("Content-Type: application/json")
//    @POST("admin/device/unbindUserBatteryInfo")
//    Observable<BaseResponse<BatteryUnbindBean>> unBindBattery(@Body Object body);

    @Headers("Content-Type: application/json")
    @POST("admin/op/unbindDevice")
    Observable<BaseResponse<Object>> unBindDevice(@Body Object body);

//    /**
//     * 解绑车辆设备
//     */
//    @Headers("Content-Type: application/json")
//    @POST("admin/op/unbindUserCarInfo")
//    Observable<BaseResponse<Object>> unBindCar(@Body Object body);

    /**
     * 检测是否存在尚未完结预约保养单
     * @param cardNum
     * @param vehicleSn
     * @return
     */
    @Headers("Content-Type: application/json")
    @GET("admin/op/queryMaintainRecord")
    Observable<BaseResponse<String>> checkExistUnCompleteCarOrder(@Query("cardNum")String cardNum, @Query("vehicleSn") String vehicleSn);


}
