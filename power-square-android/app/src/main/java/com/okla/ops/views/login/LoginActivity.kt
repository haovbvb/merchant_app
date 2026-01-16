package com.okla.ops.views.login

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.Html
import android.text.TextUtils
import android.text.TextWatcher
import android.text.method.HideReturnsTransformationMethod
import android.text.method.PasswordTransformationMethod
import android.view.View
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.databinding.ViewDataBinding
import androidx.lifecycle.ViewModelProvider
import com.base.common.BuildConfig
import com.base.common.Preferences
import com.base.common.base.mvvm.BaseNormalVActivity
import com.base.common.db.entity.RoleEntity
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.MD5Util
import com.base.common.utils.StatusBarUtil
import com.base.common.utils.ToastUtils
import com.base.library.utils.GsonUtils
import com.chad.library.adapter.base.BaseViewHolder
import com.google.android.flexbox.FlexboxLayoutManager
import com.google.gson.Gson
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.beans.User
import com.okla.ops.databinding.ActivityLoginBinding
import com.okla.ops.views.MainActivity
import com.okla.ops.views.PromoteWebActivity


class LoginActivity : BaseNormalVActivity<LoginViewModel, ActivityLoginBinding>() {

    companion object {
        fun startLoginActivity(context: Context) {
            val intent = Intent(context, LoginActivity::class.java)
            context.startActivity(intent)
        }
    }

    override fun onCreateViewModel(): LoginViewModel {
        return ViewModelProvider(this)[LoginViewModel::class.java]
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_login
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        StatusBarUtil.StatusBarLightMode(this)
    }

    override fun initViews(savedInstanceState: Bundle?) {
        super.initViews(savedInstanceState)
        iniObserver()
        initClick()
        initListener()
        initData()
        setAgreement()
    }

    private fun iniObserver() {
        getViewModel().userLiveData.observe(this) {
            val account = mBinding.etInputAccount.text.toString()
            DataStoreUtils.saveSyncStringData(
                DataStoreKeyUtils.USERNAME,
                account
            )
            Preferences.getInstance().account = account
            DataStoreUtils.saveSyncStringData(
                DataStoreKeyUtils.ACCESSTOKEN,
                it.token
            )
            DataStoreUtils.saveSyncIntData(
                DataStoreKeyUtils.ROLE,
                it.role
            )
            DataStoreUtils.saveSyncBooleanData(
                DataStoreKeyUtils.MANAGER,
                it.managerFlag
            )
            DataStoreUtils.saveSyncStringData(
                DataStoreKeyUtils.UNIT,
                it.currencyUnit
            )
            DataStoreUtils.saveSyncStringData(
                DataStoreKeyUtils.AREA_CODE,
                it.areaCode
            )
//            insertOpspermissionEntities(user)
            if(it.shopNo!=null){
                DataStoreUtils.saveSyncStringData(DataStoreKeyUtils.SHOP_NO,it.shopNo?:"")
            }
            insertRoleEntities(it)
            insertServiceType(it.serviceType)
            MainActivity.startMainActivity(this)
            finish()
        }
    }

    private fun initClick() {
        mBinding.ivClear.setOnClickListener(this)
        mBinding.ivEyePwd.setOnClickListener(this)
        mBinding.tvLoginIn.setOnClickListener(this)
        mBinding.checkbox.setOnCheckedChangeListener { buttonView, isChecked ->
            DataStoreUtils.saveSyncBooleanData(
                DataStoreKeyUtils.AGREE_AGREEMENT,
                isChecked
            )
        }
    }

    private fun initListener() {
        mBinding.etInputAccount.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }

            override fun afterTextChanged(s: Editable?) {
                if (TextUtils.isEmpty(mBinding.etInputAccount.text)) {
                    mBinding.vLine1.setBackgroundColor(
                        ContextCompat.getColor(
                            this@LoginActivity,
                            R.color.color_fff0f0f0
                        )
                    )
                } else {
                    mBinding.vLine1.setBackgroundColor(
                        ContextCompat.getColor(
                            this@LoginActivity,
                            com.base.common.R.color.color_242425
                        )
                    )
                }
                controlBtnConfirm()

            }
        })
        mBinding.etInputPsw.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(str: Editable?) {

            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val content = s.toString()
                if (TextUtils.isEmpty(content)) {
                    mBinding.ivClear.visibility = View.GONE
                    mBinding.vLine2.setBackgroundColor(
                        ContextCompat.getColor(
                            this@LoginActivity,
                            R.color.color_fff0f0f0
                        )
                    )
                } else {
                    mBinding.ivClear.visibility = View.VISIBLE
                    mBinding.vLine2.setBackgroundColor(
                        ContextCompat.getColor(
                            this@LoginActivity,
                            com.base.common.R.color.color_242425
                        )
                    )
                }
                controlBtnConfirm()
            }
        })
    }

    private fun controlBtnConfirm() {
        val account = mBinding.etInputAccount.text.toString()
        val pwd = mBinding.etInputPsw.text.toString()

        if (!TextUtils.isEmpty(account) && !TextUtils.isEmpty(pwd)) {
            mBinding.tvLoginIn.isEnabled = true
        } else {
            mBinding.tvLoginIn.isEnabled = false
        }
    }

    private fun initData() {
        mBinding.checkbox.isChecked =
            DataStoreUtils.readBooleanData(DataStoreKeyUtils.AGREE_AGREEMENT, false)
        mBinding.etInputAccount.setText(
            DataStoreUtils.readStringData(
                DataStoreKeyUtils.ACCOUNT,
                ""
            )
        )
        val account = DataStoreUtils.readStringData(DataStoreKeyUtils.USERNAME, "")
        mBinding.etInputAccount.setText(account)
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.ivClear -> {
                mBinding.etInputPsw.setText("")
            }

            R.id.ivEyePwd -> {
                if (mBinding.ivEyePwd.isSelected) {
                    mBinding.ivEyePwd.isSelected = false
                    mBinding.etInputPsw.transformationMethod =
                        PasswordTransformationMethod.getInstance()
                } else {
                    mBinding.ivEyePwd.isSelected = true
                    mBinding.etInputPsw.transformationMethod =
                        HideReturnsTransformationMethod.getInstance()
                }
                val pos = mBinding.etInputPsw.text.toString()
                if (TextUtils.isEmpty(pos)) {
                    mBinding.etInputPsw.setSelection(0)
                } else {
                    mBinding.etInputPsw.setSelection(pos.length)
                }
            }

            R.id.tvLoginIn -> {
                val account = mBinding.etInputAccount.text.toString()
                if (TextUtils.isEmpty(account)) {
                    ToastUtils.showShort(getString(R.string.tips_account_not_empty))
                    return
                }
                val pwd = mBinding.etInputPsw.text.toString()
                if (TextUtils.isEmpty(pwd)) {
                    ToastUtils.showShort(getString(R.string.tips_psw_not_empty))
                    return
                }
                if (!mBinding.checkbox.isChecked) {
                    ToastUtils.showShort(getString(R.string.tips_agree_agreement))
                    return
                }
                hideSoftInput()
                DataStoreUtils.saveSyncStringData(
                    DataStoreKeyUtils.ACCESSTOKEN,
                    ""
                )
                getViewModel().login(account, MD5Util.encrypt(pwd))
            }
        }
    }

    private fun setAgreement() {
        val string: MutableList<String> = mutableListOf()
        string.add(getString(R.string.text_agreement_pre))
        string.add(getString(R.string.text_user_agreement))
        string.add(getString(R.string.text_agreement_and))
        string.add(getString(R.string.text_privacy_policy))
        mBinding.rvFlexBox.layoutManager = FlexboxLayoutManager(this)
        val mFlexBoxAdapter =
            object : SingleDataBindingNoPUseAdapter<String>(R.layout.item_agreement) {
                override fun convert(
                    helper: BaseViewHolder?,
                    item: String?,
                    viewDataBinding: ViewDataBinding
                ) {
                    super.convert(helper, item, viewDataBinding)
                    if (data.indexOf(item) == 1 || data.indexOf(item) == 3) {
                        helper?.getView<TextView>(R.id.tvValue)?.setTextColor(
                            ContextCompat.getColor(this@LoginActivity, R.color.color_61729d)
                        )
                        if ("zh" != Preferences.getInstance().language) {
                            helper?.getView<TextView>(R.id.tvValue)?.text =
                                Html.fromHtml("<u>$item</u>")
                        }
                    }
                }
            }
        mFlexBoxAdapter.setOnItemClickListener { _, _, position ->
            if (position == 1) {
                startActivity(
                    PromoteWebActivity.getIntents(
                        this,
                        BuildConfig.USER_AGREEMENT,
                        "",
                        "",
                        false
                    )
                )
            } else if (position == 3) {
                startActivity(
                    PromoteWebActivity.getIntents(
                        this,
                        BuildConfig.PRIVACY_POLICY,
                        "",
                        "",
                        false
                    )
                )
            }
        }
        mBinding.rvFlexBox.adapter = mFlexBoxAdapter
        mFlexBoxAdapter.setNewData(string)
    }
//    var mList: List<OpsPermissionEntity> = java.util.ArrayList()
//    private fun insertOpspermissionEntities(user: User) {
//        mList.clear()
//        for (i in 0 until user.getOps().size()) {
//            mEntity = OpsPermissionEntity()
//            mEntity.setId(i)
//            mEntity.setIdStr(user.getOps().get(i).getId())
//            mEntity.setCode(user.getOps().get(i).getCode())
//            mEntity.setName(user.getOps().get(i).getName())
//            mEntity.setIsOwn(user.getOps().get(i).getIsOwn())
//            mEntity.setDictionaryCode(user.getOps().get(i).getDictionaryCode())
//            mEntity.setPlatform(user.getOps().get(i).getPlatform())
//            mList.add(mEntity)
//        }
//        CommonApplication.getCommonApplication().repository.insertOpsPermissionEntities(mList)
//    }

    var mRoleList: MutableList<RoleEntity> = ArrayList()
    var roleEntity: RoleEntity? = null

    private fun insertServiceType(serviceTypeStr: String) {
        if (serviceTypeStr == null || serviceTypeStr.isEmpty()) {
            return
        }
        val list = serviceTypeStr.split(",").map { it.toInt() }
        val jsonString = Gson().toJson(list)  // 结果: "[1,2,3,4,5]"
        Preferences.getInstance().serviceTypes = GsonUtils.toGson(jsonString)

    }

    private fun insertRoleEntities(user: User) {
        mRoleList.clear()
        val roleString = user.appRole
        if (roleString == null || roleString.isEmpty()) {
            return
        }
        val roles: MutableList<String> = ArrayList()
        for (r in roleString.split(",")) {
            when (r.trim { it <= ' ' }) {
                "1" -> roles.add("app_role_store_man")
                "2" -> roles.add("app_role_op")
                "3" -> roles.add("app_role_sales")
            }
        }
        if (roles != null) {
            if (roles.isNotEmpty()) {
                for (i in 0 until roles.size) {
                    roleEntity = RoleEntity()
                    roleEntity!!.role = roles.get(i)
                    mRoleList.add(roleEntity!!)
                }
                Preferences.getInstance().roles = GsonUtils.toGson(mRoleList)
            }
        }

    }
}