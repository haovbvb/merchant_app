package com.okla.ops.beans
import android.os.Parcelable
import androidx.databinding.BaseObservable
import kotlinx.parcelize.Parcelize

@Parcelize
data class AreaCountryResp(
    var list: MutableList<AreaCountry>?,
) : Parcelable

@Parcelize
data class AreaCountry(
    var areaCode: String?,
    var country: String?,
    var countrySimpleName: String?,
    var tenantId: String?,
) : BaseObservable(), Parcelable