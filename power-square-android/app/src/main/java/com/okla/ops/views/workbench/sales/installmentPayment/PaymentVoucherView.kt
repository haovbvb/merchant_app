package com.okla.ops.views.workbench.sales.installmentPayment

import android.content.Context
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.custom.GridSpacingItemDecoration
import com.base.library.utils.DensityUtils
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.ImageBean

class PaymentVoucherView(context: Context, attrs: AttributeSet) :
    ConstraintLayout(context, attrs) {

    init {
        initView()
    }

    private var rvPhotos: RecyclerView? = null
    private var tvCurrentCount: TextView? = null
    private var tvTitle: TextView? = null
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_payment_voucherview, this)
        rvPhotos = findViewById(R.id.rvPhotos)
        tvCurrentCount = findViewById(R.id.tv_currentCount)
        tvTitle = findViewById(R.id.tv_title)
        initRecyclerview()
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<ImageBean>
    private lateinit var mImageBeanList: ArrayList<ImageBean>
    private fun initRecyclerview() {
        rvPhotos?.layoutManager =
            GridLayoutManager(context, 3)
        val spacingItemDecoration = GridSpacingItemDecoration(3, DensityUtils.dp2px(4f), false)
        rvPhotos?.addItemDecoration(spacingItemDecoration)
        mAdapter = object :
            SingleDataBindingNoPUseAdapter<ImageBean>(R.layout.item_photo_80) {
            override fun convert(helper: BaseViewHolder, item: ImageBean) {
                super.convert(helper, item)
                item.run {
                    if (item.isAdd) helper.getView<ImageView>(R.id.ivDelete).visibility =
                        View.GONE
                    else helper.getView<ImageView>(R.id.ivDelete).visibility = View.VISIBLE
                    val imageView = helper.getView<ImageView>(R.id.ivPhoto)
                    if (item.fileUri != null) {
                        Glide.with(context).load(item.fileUri)
                            .error(R.drawable.img_camera)
                            .into(imageView)
                    } else if (item.file != null) {
                        Glide.with(context).load(item.file).error(R.drawable.img_camera)
                            .into(imageView)
                    } else if (item.path != null) {
                        Glide.with(context).load(item.path).error(R.drawable.img_camera)
                            .into(imageView)
                    } else {
                        Glide.with(context).load(R.drawable.img_camera)
                            .into(imageView)
                    }
                    helper.getView<ImageView>(R.id.ivDelete).setOnClickListener {
                        mUploadedImg.let { list ->
                            val index: Int = mImageBeanList.indexOfFirst { it == item }
                            if (list.size > index) {
                                list.removeAt(index)
                            }
                        }
                        mImageBeanList.remove(item)
                        if (mImageBeanList.size == 4 && !mImageBeanList[3].isAdd) {
                            mImageBeanList.add(ImageBean(true))
                        }
                        tvCurrentCount?.text =
                            "(".plus(mImageBeanList.size - 1).plus("/5").plus(")")
                        mAdapter.setNewData(mImageBeanList)
                        onPhotoListener?.onImageList(getImages())
                    }
                }
            }
        }
        mAdapter.onItemClickListener =
            BaseQuickAdapter.OnItemClickListener { adapter, _, position ->
                val bean = adapter.data[position] as ImageBean
                if (position == adapter.data.size - 1 && bean.isAdd) {
                    onPhotoListener?.onTakePhoto(1)
                } else {
                    val imageUrlList: ArrayList<String> = ArrayList()
                    mImageBeanList.forEach {
                        if (!it.isAdd) {
                            if (it.fileUri != null)
                                imageUrlList.add(it.fileUri.toString())
                            if (it.file != null)
                                imageUrlList.add(it.file.absolutePath)
                            if (it.path != null)
                                imageUrlList.add(it.path)
                        }
                    }
//                    Logger.i("点击查看图片下标:$position")
                    onPhotoListener?.onWatchPhoto(imageUrlList, position)
                }
            }
        rvPhotos?.adapter = mAdapter
        mImageBeanList = ArrayList()
        mImageBeanList.add(ImageBean(true))
        tvCurrentCount?.text = "(".plus(0).plus("/5").plus(")")
        mAdapter.setNewData(mImageBeanList)
    }

    private var mUploadedImg: MutableList<String> = mutableListOf()

    fun setImages(pathList: ArrayList<String>) {
        if (pathList.isNullOrEmpty()) return
        if (mUploadedImg.size < 5) {
            pathList.forEach {
                if (!mUploadedImg.contains(it)) {
                    mUploadedImg.add(it)
                }
            }
        }
        mImageBeanList.clear()
        for (item in mUploadedImg) {
            mImageBeanList.add(ImageBean(item, false))
        }
        if (mUploadedImg.size < 5) {
            tvCurrentCount?.text = "(".plus(mImageBeanList.size).plus("/5").plus(")")
            mImageBeanList.add(ImageBean(true))
        } else {
            tvCurrentCount?.text = "(".plus(5).plus("/5").plus(")")
        }
        mAdapter.setNewData(mImageBeanList)
        onPhotoListener?.onImageList(getImages())
    }

    fun setImages(path: String) {
        if (TextUtils.isEmpty(path)) return
        mUploadedImg.add(path)
        mImageBeanList.clear()
        for (item in mUploadedImg) {
            mImageBeanList.add(ImageBean(item, false))
        }
        if (mUploadedImg.size < 5) {
            tvCurrentCount?.text = "(".plus(mImageBeanList.size).plus("/5").plus(")")
            mImageBeanList.add(ImageBean(true))
        } else {
            tvCurrentCount?.text = "(".plus(5).plus("/5").plus(")")
        }
        mAdapter.setNewData(mImageBeanList)
        onPhotoListener?.onImageList(getImages())
    }

    private fun getImages(): String {
        return mUploadedImg.let {
            if (it.size == 1) {
                it[0]
            } else {
                val stringBuilder = StringBuilder()
                for ((index, item) in it.withIndex()) {
                    if (index == it.size - 1) {
                        stringBuilder.append(item)
                    } else {
                        stringBuilder.append(item).append(",")
                    }
                }
                stringBuilder.toString()
            }
        }
    }

    fun getCurrentImageSize(): Int {
        return mImageBeanList.size;
    }

    fun resetData() {
        mImageBeanList.clear()
        mImageBeanList.add(ImageBean(true))
        tvCurrentCount?.text = "(".plus(0).plus("/5").plus(")")
        mAdapter.setNewData(mImageBeanList)
        mUploadedImg.clear()
    }

    private var titleStr = context.getString(R.string.str_payment_voucher)
    fun setTitle(content: String) {
        titleStr = content
        if (tvTitle != null) {
            tvTitle?.text = titleStr
        }
    }

    interface OnPhotoListener {
        fun onTakePhoto(type: Int)

        fun onWatchPhoto(imgs: ArrayList<String>, position: Int)

        fun onImageList(imgData: String)
    }

    private var onPhotoListener: OnPhotoListener? = null
    fun setOnPhotoListener(listener: OnPhotoListener) {
        onPhotoListener = listener
    }
}