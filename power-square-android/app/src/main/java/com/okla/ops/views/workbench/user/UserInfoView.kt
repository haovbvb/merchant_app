package com.okla.ops.views.workbench.user

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.weight.CircleImageView

class UserInfoView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private lateinit var ivAvatar: CircleImageView
    private lateinit var tvName: AppCompatTextView
    private lateinit var tvId: AppCompatTextView
    private lateinit var ivPhone: AppCompatImageView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_user_info, this)
        ivAvatar = findViewById(R.id.ivAvatar)
        tvName = findViewById(R.id.tvName)
        tvId = findViewById(R.id.tvId)
        ivPhone = findViewById(R.id.ivPhone)
        ivPhone.setOnClickListener {
            onPhoneListener?.invoke()
        }
    }

    fun setAvatar(avatar: String) {
        Glide.with(context).load(avatar)
            .placeholder(R.drawable.icon_def_avator)
            .error(R.drawable.icon_def_avator).into(ivAvatar)
    }

    fun setName(name: String) {
        tvName.text = name
    }

    fun setId(id: String) {
        tvId.text = context.getString(R.string.text_ids, id)
    }

    private var onPhoneListener: (() -> Unit)? = null
    fun setOnPhoneListener(listener: () -> Unit) {
        this.onPhoneListener = listener
    }

}