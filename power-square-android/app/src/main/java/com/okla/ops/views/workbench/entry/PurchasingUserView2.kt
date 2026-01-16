package com.okla.ops.views.workbench.entry

import android.content.Context
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.base.common.custom.SpaceItemDecoration
import com.base.common.timepicker.CustomDatePicker
import com.base.common.timepicker.DateFormatUtils
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.base.library.utils.DensityUtils
import com.bumptech.glide.Glide
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.ImageBean
import com.okla.ops.beans.PurchasingUser
import com.okla.ops.utils.TextUtil
import com.okla.ops.utils.ViewClickUtils
import com.okla.ops.weight.CircleImageView
import com.okla.ops.weight.InputTextView
import com.orhanobut.logger.Logger

/**
 * 全款购买
 */
class PurchasingUserView2(context: Context) : ConstraintLayout(context), TextUtil {

    init {
        initView()
    }

    private lateinit var ivAvatar: CircleImageView
    private lateinit var tvId: AppCompatTextView
    private lateinit var itAccount: InputTextView
    private lateinit var itFirstName: InputTextView
    private lateinit var itLastName: InputTextView
    private lateinit var itPhone: InputTextView
    private lateinit var itBirthday: InputTextView
    private lateinit var itEmail: InputTextView
    private lateinit var itIdNumber: InputTextView
    private lateinit var itAddress: InputTextView
    private lateinit var rvPhotos: RecyclerView
    private lateinit var tvUploadPhoto: AppCompatTextView
    private lateinit var tvPersonalPhoto: AppCompatTextView
    private lateinit var ivPerson: ImageView
    private lateinit var ivDelete: ImageView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_purchasing_user2, this, true)
        ivAvatar = findViewById(R.id.ivAvatar)
        tvId = findViewById(R.id.tvId)
        itAccount = findViewById(R.id.itAccount)
        itAccount.setTitle(context.getString(R.string.title_account), true)
        itAccount.setEditEnable(false)
        itFirstName = findViewById(R.id.itFirstName)
        itFirstName.setTitle(context.getString(R.string.title_first_name), true)
        itFirstName.setHint(context.getString(R.string.hint_enter_first_name))
        itFirstName.setContentMaxLength(50)
        itFirstName.setOnInputTextListener {
            editPurchasingUser()
            detectSubmitState()
        }
        itLastName = findViewById(R.id.itLastName)
        itLastName.setTitle(context.getString(R.string.title_last_name), true)
        itLastName.setHint(context.getString(R.string.hint_enter_last_name))
        itLastName.setContentMaxLength(50)
        itLastName.setOnInputTextListener {
            editPurchasingUser()
            detectSubmitState()
        }
        itPhone = findViewById(R.id.itPhone)
        itPhone.setTitle(context.getString(R.string.title_phone), true)
        itPhone.setHint(context.getString(R.string.hint_enter_phone))
        itPhone.setContentMaxLength(20)
        itPhone.setOnlyNumber()
        itPhone.setOnInputTextListener {
            editPurchasingUser()
            detectSubmitState()
        }
        itIdNumber = findViewById(R.id.itIdNumber)
        itIdNumber.setTitle(context.getString(R.string.title_id_number), true)
        itIdNumber.setHint(context.getString(R.string.hint_enter_id_number))
        itIdNumber.setContentMaxLength(30)
        itIdNumber.setOnInputTextListener {
            editPurchasingUser()
            detectSubmitState()
        }
        itBirthday = findViewById(R.id.itBirthday)
        itBirthday.setTitle(context.getString(R.string.title_birthday))
        itBirthday.setHint(context.getString(R.string.hint_enter_birthday))
        itBirthday.switchFunctionToClick()
        itBirthday.setOnInputTextListener {
            if (it.isNullOrBlank()) {
                mBirthday = ""
            }
            editPurchasingUser()
        }
        itBirthday.setOnInputTextClickListener {
            initTimerPicker()
        }
        itEmail = findViewById(R.id.itEmail)
        itEmail.setTitle(context.getString(R.string.title_email))
        itEmail.setHint(context.getString(R.string.hint_enter_email))
        itEmail.setContentMaxLength(50)
        itEmail.setOnInputTextListener {
            editPurchasingUser()
            detectSubmitState()
        }
        itAddress = findViewById(R.id.itAddress)
        itAddress.setTitle(context.getString(R.string.title_address), true)
        itAddress.setHint(context.getString(R.string.hint_enter_address))
        itAddress.setContentMaxLength(200)
        itAddress.setOnInputTextListener {
            editPurchasingUser()
            detectSubmitState()
        }
        rvPhotos = findViewById(R.id.rvPhotos)
        initRecyclerview()
        tvUploadPhoto = findViewById(R.id.tvUploadPhoto)
        tvUploadPhoto.text = textAddStart(tvUploadPhoto.text.toString())
        tvPersonalPhoto = findViewById(R.id.tvPersonalPhoto)
        tvPersonalPhoto.text = textAddStart(tvPersonalPhoto.text.toString())
        ivPerson = findViewById(R.id.ivPhoto)
        ivPerson.setOnClickListener {
            if (ViewClickUtils.isFastClick()) {
                return@setOnClickListener
            }
            if (TextUtils.isEmpty(mPersonalImg)) {
                onPhotoListener?.onTakePhoto(2)
            } else {
                onPhotoListener?.onWatchPhoto(arrayListOf(mPersonalImg), 0)
            }
        }
        ivDelete = findViewById(R.id.ivDelete)
        ivDelete.setOnClickListener {
            Glide.with(context).load("")
                .placeholder(R.drawable.img_camera)
                .error(R.drawable.img_camera)
                .into(ivPerson)
            mPersonalImg = ""
            ivDelete.visibility = GONE
            detectSubmitState()
        }
        ivDelete.visibility = GONE
    }

    fun updateData(purchasingUser: PurchasingUser): PurchasingUserView2 {
        Glide.with(context).load(purchasingUser.avatar)
            .placeholder(R.drawable.icon_def_avator)
            .error(R.drawable.icon_def_avator)
            .into(ivAvatar)
        tvId.text = context.getString(R.string.text_ids, purchasingUser.cardNum)
        itAccount.setContent(purchasingUser.username ?: "")
        itFirstName.setContent(purchasingUser.firstName ?: "")
        itLastName.setContent(purchasingUser.lastName ?: "")
        itPhone.setContent(purchasingUser.phone ?: "")
        itPhone.setOnlyNumber()
        mBirthday = purchasingUser.birthday ?: ""
        if(!purchasingUser.birthday.isNullOrBlank()){
            val showBirthDayStr = DateFormatUtils.formatDate(
                purchasingUser.birthday,
                DateTimeUtils.dateFormat,
                DateTimeUtils.dateFormatY,
                LanguageUtils.LanguageUtil.getLocalByLanguage()
            )
            itBirthday.setContent(showBirthDayStr)
        }
        itEmail.setContent(purchasingUser.email ?: "")
        itAddress.setContent(purchasingUser.address ?: "")
        itIdNumber.setContent(purchasingUser.idNumber ?: "")
        mImageBeanList.clear()
        mUploadedImg.clear()
        val images = purchasingUser.cardImg
            .takeIf { !it.isNullOrBlank() }
            ?.split(",")
            ?.map { imgUrl ->
                ImageBean(imgUrl, false).also {
                    mImageBeanList.add(it)
                    mUploadedImg.add(imgUrl)
                }
            }
            .orEmpty()
            .toMutableList()

        if (images.isEmpty()) {
            mImageBeanList.add(ImageBean(true))
        } else if (images.size < 4) {
            mImageBeanList.add(ImageBean(true))
        }
        mAdapter.setNewData(mImageBeanList)
        setPersonalImg(purchasingUser.personImg ?: "")
        return this
    }

    private var mBirthday: String = ""
    private var mTimerPicker: CustomDatePicker? = null
    private fun initTimerPicker() {
        context?.let { context ->
            val beginTime: Long = System.currentTimeMillis() - 1000 * 60 * 60 * 24 * 365L * 100
            val endTime: Long = System.currentTimeMillis()
            if (mTimerPicker == null) {
                mTimerPicker = CustomDatePicker(
                    context,
                    {
                        if (it > 0) {
                            val selectDate = DateTimeUtils.getTimeString(
                                DateTimeUtils.dateFormatY,
                                it,
                                LanguageUtils.LanguageUtil.getLocalByLanguage()
                            )
                            itBirthday.setContent(selectDate)
                            mBirthday = DateTimeUtils.getTimeString(
                                DateTimeUtils.dateFormat,
                                it,
                                LanguageUtils.LanguageUtil.getLocalByLanguage()
                            )
                            editPurchasingUser()
                        }

                    },
                    beginTime,
                    endTime,
                    LanguageUtils.LanguageUtil.getLocalByLanguage()
                )
                mTimerPicker?.setCancelable(true)
                mTimerPicker?.setCanShowPreciseTime(false)
                mTimerPicker?.setScrollLoop(true)
                mTimerPicker?.setCanShowAnim(true)
                mTimerPicker?.setOnlyShowDate(true)
            }
            mTimerPicker?.show(System.currentTimeMillis())
        }
    }

    private lateinit var mAdapter: SingleDataBindingNoPUseAdapter<ImageBean>
    private lateinit var mImageBeanList: ArrayList<ImageBean>

    private fun initRecyclerview() {
        rvPhotos.layoutManager =
            LinearLayoutManager(context, RecyclerView.HORIZONTAL, false)
        rvPhotos.addItemDecoration(
            SpaceItemDecoration(DensityUtils.dp2px(10.0f), 0)
        )
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
                        if (mImageBeanList.size < 4 && !mImageBeanList[mImageBeanList.size - 1].isAdd) {
                            mImageBeanList.add(ImageBean(true))
                        }
                        mAdapter.setNewData(mImageBeanList)
                        detectSubmitState()
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
                    Logger.i("点击查看图片下标:$position")
                    onPhotoListener?.onWatchPhoto(imageUrlList, position)
                }
            }
        rvPhotos.adapter = mAdapter
        mImageBeanList = ArrayList()
        mImageBeanList.add(ImageBean(true))
        mAdapter.setNewData(mImageBeanList)
    }

    private var mUploadedImg: MutableList<String> = mutableListOf()//购买者证件照片
    fun setImages(path: String) {
        if (TextUtils.isEmpty(path)) return
        mUploadedImg.add(path)
        mImageBeanList.clear()
        for (item in mUploadedImg) {
            mImageBeanList.add(ImageBean(item, false))
        }
        if (mUploadedImg.size < 4) {
            mImageBeanList.add(ImageBean(true))
        }
        mAdapter.setNewData(mImageBeanList)
        detectSubmitState()
    }

    fun getIdCardImageCount(): Int {
        var count = 0
        mImageBeanList.forEach {
            if (!it.isAdd) {
                count += 1
            }
        }
        return count;
    }

    private var mPersonalImg = ""//个人照片
    fun setPersonalImg(path: String) {
        mPersonalImg = path
        Glide.with(context).load(mPersonalImg)
            .placeholder(R.drawable.img_camera)
            .error(R.drawable.img_camera)
            .into(ivPerson)
        ivDelete.visibility = if (!TextUtils.isEmpty(mPersonalImg)) VISIBLE else GONE
        detectSubmitState()
        editPurchasingUser()
    }

    private fun editPurchasingUser() {
        val cardImg: String = mUploadedImg.let {
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
        onPurchasingUserEditListener?.invoke(
            itFirstName.getContent(),
            itLastName.getContent(),
            itPhone.getContent(),
            itIdNumber.getContent(),
            cardImg,
            mPersonalImg,
            mBirthday,
            itEmail.getContent(),
            itAddress.getContent()
        )
    }

    private fun detectSubmitState() {
        onSubmitListener?.invoke(
            itAccount.getContent().isNotEmpty()
                    && itFirstName.getContent().isNotEmpty()
                    && itLastName.getContent().isNotEmpty()
                    && itPhone.getContent().isNotEmpty()
                    && itIdNumber.getContent().isNotEmpty()
                    && mUploadedImg.size >= 2
                    && mPersonalImg.isNotEmpty()
                    && itAddress.getContent().isNotEmpty()
        )
    }

    private var onSubmitListener: ((Boolean) -> Unit)? = null
    fun setOnSubmitListener(listener: (Boolean) -> Unit) {
        this.onSubmitListener = listener
    }

    private var onPurchasingUserEditListener: ((String, String, String, String, String, String, String, String, String) -> Unit)? =
        null

    fun setOnPurchasingUserEditListener(listener: (String, String, String, String, String, String, String, String, String) -> Unit) {
        this.onPurchasingUserEditListener = listener
    }

    interface OnPhotoListener {
        fun onTakePhoto(type: Int)

        fun onWatchPhoto(imgs: ArrayList<String>, position: Int)
    }

    private var onPhotoListener: OnPhotoListener? = null
    fun setOnPhotoListener(listener: OnPhotoListener) {
        onPhotoListener = listener
    }

}