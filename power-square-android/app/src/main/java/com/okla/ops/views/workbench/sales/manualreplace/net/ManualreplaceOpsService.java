package com.okla.ops.views.workbench.sales.manualreplace.net;

import com.base.common.net.BaseResponse;

import io.reactivex.Observable;
import retrofit2.http.Body;
import retrofit2.http.Headers;
import retrofit2.http.POST;

public interface ManualreplaceOpsService {
    /**
     * 人工换电
     */
    @Headers("Content-Type: application/json")
    @POST("admin/swap/exchange")
    Observable<BaseResponse<String>> manualReplace(@Body Object body);
}
