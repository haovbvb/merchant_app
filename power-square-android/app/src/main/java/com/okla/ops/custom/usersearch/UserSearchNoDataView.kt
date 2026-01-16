package com.okla.ops.custom.usersearch

import android.content.Context
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.okla.ops.R

class UserSearchNoDataView(context: Context, attrs: AttributeSet?) :
    ConstraintLayout(context, attrs) {

    init {
        initTypeValue(context, attrs)
        initView(context)
    }

    private lateinit var tvContent: TextView
    private lateinit var ivImg: ImageView

    private var mTips: Int = 0
    private var mImg: Drawable? = null

    private fun initTypeValue(context: Context, attrs: AttributeSet?) {
        val typeArray = context.obtainStyledAttributes(attrs, R.styleable.SearchNoDataView)
        mTips = typeArray.getResourceId(R.styleable.SearchNoDataView_SearchNoDataTips, -1)
        mImg = typeArray.getDrawable(R.styleable.SearchNoDataView_SearchNoDataImg)
        typeArray.recycle()
    }

    private fun initView(context: Context) {
        val inflate =
            LayoutInflater.from(context).inflate(R.layout.layout_user_search_no_data, this)
        ivImg = inflate.findViewById(R.id.ivImg)
        ivImg.setImageDrawable(mImg)
        tvContent = inflate.findViewById(R.id.tvContent)
        tvContent.text = context.getString(mTips)
    }

}