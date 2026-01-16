package com.okla.ops.views.workbench.entry

import android.content.Context
import android.view.LayoutInflater
import androidx.appcompat.widget.AppCompatTextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.base.common.timepicker.CustomDatePicker
import com.base.common.timepicker.DateFormatUtils
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.bumptech.glide.Glide
import com.okla.ops.R
import com.okla.ops.beans.PurchasingUser
import com.okla.ops.utils.TextUtil
import com.okla.ops.weight.CircleImageView
import com.okla.ops.weight.InputTextView

/**
 * 全款购买
 */
class PurchasingUserView(context: Context) : ConstraintLayout(context), TextUtil {

    init {
        initView()
    }

    private lateinit var ivAvatar: CircleImageView
    private lateinit var tvId: AppCompatTextView
    private lateinit var tvAddress: AppCompatTextView
    private lateinit var itAccount: InputTextView
    private lateinit var itFirstName: InputTextView
    private lateinit var itLastName: InputTextView
    private lateinit var itPhone: InputTextView
    private lateinit var itBirthday: InputTextView
    private lateinit var itEmail: InputTextView
    private fun initView() {
        LayoutInflater.from(context).inflate(R.layout.layout_purchasing_user, this, true)
        ivAvatar = findViewById(R.id.ivAvatar)
        tvId = findViewById(R.id.tvId)
        tvAddress = findViewById(R.id.tvAddress)
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
        }
    }

    fun updateData(purchasingUser: PurchasingUser) {
        Glide.with(context).load(purchasingUser.avatar)
            .placeholder(R.drawable.icon_def_avator)
            .error(R.drawable.icon_def_avator)
            .into(ivAvatar)
        tvId.text = context.getString(R.string.text_ids, purchasingUser.cardNum)
        tvAddress.text = purchasingUser.address ?: "-"
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
        mIdNumber = purchasingUser.idNumber ?: ""
        mCardImg = purchasingUser.cardImg ?: ""
        mPersonalImg = purchasingUser.personImg ?: ""
        mAddress = purchasingUser.address ?: ""
        editPurchasingUser()
        detectSubmitState()
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

    private var mIdNumber: String = ""
    private var mCardImg: String = ""
    private var mPersonalImg: String = ""
    private var mAddress: String = ""
    private fun editPurchasingUser() {
        onPurchasingUserEditListener?.invoke(
            itFirstName.getContent(),
            itLastName.getContent(),
            itPhone.getContent(),
            mIdNumber,
            mCardImg,
            mPersonalImg,
            mBirthday,
            itEmail.getContent(),
            mAddress
        )
    }

    private fun detectSubmitState() {
        onSubmitListener?.invoke(
            itAccount.getContent().isNotEmpty()
                    && itFirstName.getContent().isNotEmpty()
                    && itLastName.getContent().isNotEmpty()
                    && itPhone.getContent().isNotEmpty()
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

}