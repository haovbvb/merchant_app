package com.okla.ops.views.workbench.qm.aftersalebind

import android.content.Context
import android.view.LayoutInflater
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.beans.UserDetail

class AfterSaleUserInfoView(context: Context) : ConstraintLayout(context) {

    private lateinit var tvUserName: AppCompatTextView
    private lateinit var tvUserPhone: AppCompatTextView
    private lateinit var ivUserHead: AppCompatImageView

    init {
        LayoutInflater.from(context).inflate(R.layout.layout_aftersale_userinfo, this)
        initView()
    }

    private fun initView() {
        tvUserName = findViewById(R.id.tv_username)
        tvUserPhone = findViewById(R.id.tv_phone)
        ivUserHead = findViewById(R.id.ivUser)
    }

    fun updateData(userInfo: UserDetail) {
        val areaCode = DataStoreUtils.readStringData(
            DataStoreKeyUtils.AREA_CODE, ""
        )
        tvUserPhone.text = context.getString(R.string.str_phone_colon)
            .plus(areaCode)
            .plus(userInfo.phone ?: "-")
        tvUserName.text = userInfo.username ?: "-"
        Glide.with(context)
            .load(userInfo.avatar ?: "")
            .error(R.mipmap.icon_def_avatar)
            .into(ivUserHead)
    }
}