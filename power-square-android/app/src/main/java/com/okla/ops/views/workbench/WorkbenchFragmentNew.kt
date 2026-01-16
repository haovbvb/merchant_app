package com.okla.ops.views.workbench

import android.Manifest
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.lifecycle.ViewModelProvider
import com.base.common.Preferences
import com.base.common.base.mvvm.BaseNormalVActivity.RESULT_OK
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.db.entity.RoleEntity
import com.base.common.permission.PermissionListenerImpl
import com.base.common.permission.PermissionManager
import com.base.common.utils.DataStoreKeyUtils
import com.base.common.utils.DataStoreUtils
import com.base.common.utils.DateTimeUtils
import com.base.common.utils.LanguageUtils
import com.base.common.utils.NumToStrUtil
import com.base.library.utils.GsonUtils
import com.chad.library.adapter.base.BaseViewHolder
import com.google.gson.reflect.TypeToken
import com.google.zxing.integration.android.IntentIntegrator
import com.luck.picture.lib.utils.SdkVersionUtils
import com.okla.ops.R
import com.okla.ops.adapter.SingleDataBindingNoPUseAdapter
import com.okla.ops.databinding.FragmentWorkbenchNewBinding
import com.okla.ops.dialog.DialogBatteryEntry
import com.okla.ops.dialog.SelectRolesDialog
import com.okla.ops.utils.ScanUtils
import com.okla.ops.views.workbench.cabinetopt.CabinetOperateActivity
import com.okla.ops.views.workbench.devicedetail.DeviceDetailActivity
import com.okla.ops.views.workbench.entry.BatteryEntryActivity
import com.okla.ops.views.workbench.entry.StationEntryActivity
import com.okla.ops.views.workbench.entry.VehicleEntryActivity
import com.okla.ops.views.workbench.equipmentsearch.EquipmentSearchActivityNew
import com.okla.ops.views.workbench.putawaycabinet.PutawayCabinetActivityNew
import com.okla.ops.views.workbench.qm.aftersalebind.AfterSaleBindActivity
import com.okla.ops.views.workbench.qm.maintenance.MaintenanceBookActivity
import com.okla.ops.views.workbench.qm.repairrecord.RepairRecordActivity
import com.okla.ops.views.workbench.qm.roadassistance.RoadSideAssistantActivity
import com.okla.ops.views.workbench.qm.unbind.UnbindDeviceActivity
import com.okla.ops.views.workbench.sales.depositrefund.DepositRefundActivity
import com.okla.ops.views.workbench.sales.installmentPayment.InstallmentPayActivity
import com.okla.ops.views.workbench.sales.manualreplace.MerchantReplaceActivityNew
import com.okla.ops.views.workbench.sales.offlineregister.OfflineUserRegisterActivity
import com.okla.ops.views.workbench.sales.rentbind.RentBindActivity
import com.okla.ops.views.workbench.sales.salesummary.SaleSummaryActivity
import com.okla.ops.views.workbench.sales.sellbind.SellBindActivity
import com.okla.ops.views.workbench.sales.swapbind.SwapBindActivity
import com.okla.ops.views.workbench.unshelve.UnshelveActivityNew
import com.okla.ops.views.workbench.user.UserListActivity
import com.okla.ops.views.workbench.vcu.VcuDeviceSearchActivity
import com.okla.ops.views.workbench.warehouse.deviceinventory.DeviceInventoryActivity
import com.okla.ops.views.workbench.warehouse.devicetransport.DeviceTransportIssueActivity
import com.okla.ops.views.workbench.warehouse.devicetransport.DeviceTransportReceiveActivity


class WorkbenchFragmentNew :
    BaseNormalVFragment<WorkbenchViewModel, FragmentWorkbenchNewBinding>() {
    private val mRolesEntities = ArrayList<RoleEntity>();
    private lateinit var adapter: SingleDataBindingNoPUseAdapter<ModuleItem>


    companion object {
        fun newInstance(): WorkbenchFragmentNew {
            return WorkbenchFragmentNew()
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_workbench_new
    }

    override fun onCreateViewModel(): WorkbenchViewModel {
        return ViewModelProvider(this)[WorkbenchViewModel::class.java]
    }

    private lateinit var permissionManager: PermissionManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        permissionManager = PermissionManager.getInstance(
            requireActivity().activityResultRegistry, this.javaClass.name, this
        )
        lifecycle.addObserver(permissionManager)
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initClick()
        initObserver()
        initData()
    }

    override fun onNoDoubleClick(v: View?) {
        super.onNoDoubleClick(v)
        when (v?.id) {
            R.id.ivScan -> {
                askPermission()
            }

            R.id.tv_role -> {
                if (mRolesEntities.size > 1) {
                    showSelectRolesDialog()
                }
            }

            R.id.iv_down -> {
                if (mRolesEntities.size > 1) {
                    showSelectRolesDialog()
                }
            }
        }
    }

    private fun initObserver() {
        mBinding.mSmartRefresh.setOnRefreshListener {
            getSaleData()
        }
        getViewModel().mSaleDataLiveData.observe(this, {
            mBinding.mSmartRefresh.isRefreshing = false
            if (it != null) {
                mBinding.tvAmount.text =
                    "$".plus(NumToStrUtil.DoubleToStrWith2(it.orderIncome ?: 0.00))
                mBinding.tvQuantity.text = (it.orderNum ?: 0).toString()
                mBinding.tvDate.text = DateTimeUtils.getTimeString(
                    DateTimeUtils.dateFormatY,
                    it.today,
                    LanguageUtils.LanguageUtil.getLocalByLanguage()
                )
            }
        })
        getViewModel().carTypeListLiveData.observe(this, {
            dialogDeviceEntry?.updateCarData(it)
            getViewModel().getBatteryTypeList()

        })
        getViewModel().batteryTypeListLiveData.observe(this, {
            dialogDeviceEntry?.updateBatteryData(it)
            getViewModel().getStationTypeList()
        })
        getViewModel().stationTypeListLiveData.observe(this,{
            dialogDeviceEntry?.updateStationData(it)
            dialogDeviceEntry?.show()
        })
    }

    private fun initClick() {
        mBinding.mSmartRefresh.isEnabled = false
        mBinding.ivScan.setOnClickListener(this)
        mBinding.tvRole.setOnClickListener(this)
        mBinding.ivDown.setOnClickListener(this)
    }

    private var warehouseRole = 0
    private fun initData() {
        warehouseRole = DataStoreUtils.readIntData(DataStoreKeyUtils.ROLE, 0)
        val roles = Preferences.getInstance().roles
//        val roles =
//            "[{\"isSelected\":false,\"role\":\"app_role_op\"},{\"isSelected\":false,\"role\":\"app_role_store_man\"},{\"isSelected\":false,\"role\":\"app_role_sales\"}]";
        if (!TextUtils.isEmpty(roles)) {
            try {
                val type = object : TypeToken<List<RoleEntity?>?>() {
                }.type
                val list = GsonUtils.fromGson<List<RoleEntity>>(roles, type)
                mRolesEntities.clear()
                if (list != null && !list.isEmpty()) {
                    mRolesEntities.addAll(list)
                    selectRole(list[0].role, warehouseRole)
                }
                if (mRolesEntities.isEmpty() || mRolesEntities.size == 1) {
                    mBinding.ivDown.visibility = View.GONE
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun selectRole(selectRole: String, warehouseRole: Int) {
        for (roleEntity in mRolesEntities) {
            roleEntity.selected = roleEntity.role == selectRole
        }
        if (TextUtils.equals(selectRole, "app_role_op")) {
            mBinding.tvRole.text = getString(R.string.workbench_role_om)
            mBinding.layoutSaledata.visibility = View.GONE
            mBinding.mSmartRefresh.isEnabled = false
        } else if (TextUtils.equals(selectRole, "app_role_store_man")) {
            mBinding.tvRole.text = getString(R.string.workbench_role_warehouse)
            mBinding.layoutSaledata.visibility = View.GONE
            mBinding.mSmartRefresh.isEnabled = false
        } else if (TextUtils.equals(selectRole, "app_role_sales")) {
            mBinding.tvRole.text = getString(R.string.workbench_role_Sales)
            mBinding.layoutSaledata.visibility = View.VISIBLE
            mBinding.mSmartRefresh.isEnabled = true
            getSaleData()
        } else {
            mBinding.ivDown.visibility = View.GONE
            mBinding.layoutSaledata.visibility = View.GONE
            mBinding.mSmartRefresh.isEnabled = false
        }
        adapter = object : SingleDataBindingNoPUseAdapter<ModuleItem>(R.layout.item_workbench) {
            override fun convert(helper: BaseViewHolder, item: ModuleItem?) {
                super.convert(helper, item)
                val ivImg = helper.getView<ImageView>(R.id.imgWorkbenchItem)
                val tvWorkbenchItem = helper.getView<TextView>(R.id.tvWorkbenchItem)
                item?.module?.let { it?.iconRes?.let { it1 -> ivImg.setImageResource(it1) } }
                tvWorkbenchItem.text = item?.module?.let {
                    it?.titleResId?.let { it1 ->
                        context?.getString(
                            it1
                        )
                    }
                }
            }
        }
        adapter.setOnItemClickListener { adapter, view, position ->
            val item = adapter.getItem(position)
            if (item is ModuleItem) {
                item.onClick()
            }
        }
        adapter.setNewData(getModuleItems(selectRole, warehouseRole))
        mBinding.rvBottom.adapter = adapter;
    }

    // 动态生成当前角色可用的模块项（带点击事件）
    private fun getModuleItems(roleKey: String, warehouseRole: Int): List<ModuleItem> {
        val readOnlyList = when (roleKey) {
            //仓管
            Role.WAREHOUSE_MANAGER.roleKey -> {
                return when (warehouseRole) {
                    //平台
                    1 -> {
                        listOf(
                            //设备录入
                            ModuleItem(Module.DEVICE_RECORD) {
                                initDialogDeviceEntry()
                                getViewModel().getCarTypeList()
                            },
                            //设备发出
                            ModuleItem(Module.DEVICE_SEND) {
                                context?.let { DeviceTransportIssueActivity.Companion.getIntents(it) }
                            },
                            //设备接收
                            ModuleItem(Module.DEVICE_RECEIVE) {
                                context?.let {
                                    DeviceTransportReceiveActivity.Companion.getIntents(
                                        it
                                    )
                                }
                            },
                            //库存盘点
                            ModuleItem(Module.INVENTORY_AUDIT) {
                                context?.let { DeviceInventoryActivity.Companion.getIntents(it) }
                            },
                            //VCU测试
                            ModuleItem(Module.VCU_TESTING) {
                                context?.let { VcuDeviceSearchActivity.startVcuDeviceSearchActivity(it) }
                            },
                            ModuleItem(Module.DEVICE_QUERY) {
                                startActivity(
                                    EquipmentSearchActivityNew.getIntents(
                                        context, "", 0, EquipmentSearchActivityNew.QUERY_DEVICE,false
                                    )
                                )

                            }

                        );
                    }
                    //经销商
                    2 -> {
                        listOf(
                            //设备发出
                            ModuleItem(Module.DEVICE_SEND) {
                                context?.let { DeviceTransportIssueActivity.Companion.getIntents(it) }
                            },
                            //设备接收
                            ModuleItem(Module.DEVICE_RECEIVE) {
                                context?.let {
                                    DeviceTransportReceiveActivity.Companion.getIntents(
                                        it
                                    )
                                }
                            },

                            //库存盘点
                            ModuleItem(Module.INVENTORY_AUDIT) {
                                context?.let { DeviceInventoryActivity.Companion.getIntents(it) }
                            },
                            ModuleItem(Module.DEVICE_QUERY) {
                                startActivity(
                                    EquipmentSearchActivityNew.getIntents(
                                        context, "", 0, EquipmentSearchActivityNew.QUERY_DEVICE,false
                                    )
                                )

                            }
                        )
                    }

                    3 -> {
                        listOf(
                            //设备接收
                            ModuleItem(Module.DEVICE_RECEIVE) {
                                context?.let {
                                    DeviceTransportReceiveActivity.Companion.getIntents(
                                        it
                                    )
                                }
                            },
                            //库存盘点
                            ModuleItem(Module.INVENTORY_AUDIT) {
                                context?.let { DeviceInventoryActivity.Companion.getIntents(it) }
                            },
                            ModuleItem(Module.DEVICE_QUERY) {
                                startActivity(
                                    EquipmentSearchActivityNew.getIntents(
                                        context, "", 0, EquipmentSearchActivityNew.QUERY_DEVICE,false
                                    )
                                )

                            }
                        )
                    }

                    else -> {
                        listOf()
                    }
                }
            }
            //运维
            Role.MAINTENANCE.roleKey ->
                return when (warehouseRole) {
                    //经销商账号
                    2 -> {
                        //电柜上架
                        listOf(
                            ModuleItem(Module.RELEASE_STATION) {
                                startActivity(PutawayCabinetActivityNew.getIntents(mActivity));
                            },
                            //电柜下架
                            ModuleItem(Module.RETIRE_STATION) {
                                startActivity(UnshelveActivityNew.getIntents(mActivity));
                            },
                            //电柜操作
                            ModuleItem(Module.STATION_OPERATION){
                                startActivity(
                                    Intent(
                                        context,
                                        CabinetOperateActivity::class.java
                                    )
                                )
                            },
                            //电柜维修登记
                            ModuleItem(Module.REPAIR_REGISTRATION_STATION) {
                                context?.let { RepairRecordActivity.Companion.getIntents(it,true) }
                            },
                            //电柜查询
                            ModuleItem(Module.STATION_QUERY) {
                                startActivity(
                                    EquipmentSearchActivityNew.getIntents(
                                        context, "", 0, EquipmentSearchActivityNew.QUERY_DEVICE,true
                                    )
                                )
                            }
                        )
                    }
                    else -> {
                        //预约保养
                        listOf(ModuleItem(Module.MAINTENANCE_SCHEDULE) {
                            context?.let { MaintenanceBookActivity.Companion.getIntents(it) }
                        },
                            //维修登记
                            ModuleItem(Module.REPAIR_REGISTRATION) {
                                context?.let { RepairRecordActivity.Companion.getIntents(it,false) }
                            },
                            //道路救援
                            ModuleItem(Module.ROAD_ASSISTANCE) {
                                context?.let { RoadSideAssistantActivity.Companion.getIntents(it) }
                            },
                            //设备解绑
                            ModuleItem(Module.DEVICE_UNBIND) {
                                context?.let { UnbindDeviceActivity.Companion.getIntents(it) }
//                     showSelectDeviceTypeDialog()
                            },
                            //售后绑定
                            ModuleItem(Module.AFTER_SALE_BIND) {
                                context?.let { AfterSaleBindActivity.Companion.startActivity(it) }
                            },
                            ModuleItem(Module.USER_QUERY) {
                                context?.let { UserListActivity.startUserListActivity(it) }
                            },
                            ModuleItem(Module.DEVICE_QUERY) {
                                startActivity(
                                    EquipmentSearchActivityNew.getIntents(
                                        context, "", 0, EquipmentSearchActivityNew.QUERY_DEVICE,false
                                    )
                                )

                            }
                        )
                    }
                }


            Role.SALES.roleKey -> listOf(
                //销售绑定
                ModuleItem(Module.SALE_BIND) {
                    context?.let { SellBindActivity.Companion.startActivity(it) }
                },
                //租赁绑定
                ModuleItem(Module.LEASE_BIND) {
                    context?.let { RentBindActivity.Companion.startActivity(it) }
                },
                //换电绑定
                ModuleItem(Module.BATTERY_SWAP_BIND) {
                    context?.let { SwapBindActivity.startActivity(it) }
                },
                //人工换电
                ModuleItem(Module.BATTERY_SWAP) {
                    context?.let { MerchantReplaceActivityNew.Companion.getIntents(it) }
                },
                //销售业绩统计
                ModuleItem(Module.SALE_STATISTICS) {
                    context?.let {
                        SaleSummaryActivity.startActivity(it)
                    }
                },
                //押金退还
                ModuleItem(Module.DEPOST_REFUND) {
                    context?.let { DepositRefundActivity.Companion.startActivity(it) }
                },
                //线下用户注册
                ModuleItem(Module.OFFLINE_USER_REGISTER) {
                    this.context?.let { OfflineUserRegisterActivity.Companion.getIntents(it) }
                },
                //分期缴纳
                ModuleItem(Module.INSTALLMENT_PAYMENT) {
                    context?.let { InstallmentPayActivity.Companion.startActivity(it) }
                },
                //用户查询
                ModuleItem(Module.USER_QUERY) {
                    context?.let { UserListActivity.startUserListActivity(it) }
                },
                //设备查询
                ModuleItem(Module.DEVICE_QUERY) {
                    startActivity(
                        EquipmentSearchActivityNew.getIntents(
                            context, "", 0, EquipmentSearchActivityNew.QUERY_DEVICE,false
                        )
                    )
                }

            )

            else -> listOf<ModuleItem>()
        }
        val modules: MutableList<ModuleItem> = readOnlyList.toMutableList()
        //shop
        if (warehouseRole == 3) {
            val serviceTypes = Preferences.getInstance().serviceTypes
            val serviceTypeSet: Set<Int> = parseServiceTypes(serviceTypes).toSet()
//            val serviceTypes = "[1,5]"
            if (!TextUtils.isEmpty(serviceTypes)) {
                try {
                    // "[1,2,3,4,5]" 1=用户注册 2=售卖服务 3=租赁服务 4=换电服务 5=维修保养
                    if (roleKey == Role.SALES.roleKey) {
                        modules.removeAll { item ->
                            val action = item.module.actionKey
                            // 打印每次判断的结果，帮你定位到底哪个分支为 true
                            val shouldRemove = when (action) {
                                "OfflineUserRegistration" ->
                                    !serviceTypeSet.contains(1)

                                "SalesBinding", "InstallmentPayment" ->
                                    !serviceTypeSet.contains(2)

                                "LeaseBinding", "DepositRefund" ->
                                    !serviceTypeSet.contains(3)

                                "BatterySwapBinding", "ManualBatterySwap" ->
                                    !serviceTypeSet.contains(4)

                                "SalesPerformanceStatistics" -> {
                                    (serviceTypeSet.contains(1) || serviceTypeSet.contains(5)) && !serviceTypeSet.contains(
                                        2
                                    ) && !serviceTypeSet.contains(3) && !serviceTypeSet.contains(4)
                                }

                                else -> false
                            }
//                            Log.d("DEBUG", "module=$action, shouldRemove=$shouldRemove")
                            shouldRemove
                        }
                    } else if (roleKey == Role.MAINTENANCE.roleKey) {
                        //移除维修保养
                        modules.removeAll { moduleItem ->
                            when (moduleItem.module.actionKey) {
                                "MaintenanceScheduling", "RepairRegistration", "RoadsideAssistance", "DeviceUnbinding", "AfterSalesBinding" ->
                                    !serviceTypeSet.contains(5)

                                else ->
                                    // 其他模块不动
                                    false
                            }
                        }

                    }

                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
        return modules.toList()
    }


    // 选择要录入的出货设备类型
    private var dialogDeviceEntry: DialogBatteryEntry? = null
    private fun initDialogDeviceEntry() {
        if (dialogDeviceEntry == null) {
            dialogDeviceEntry =
                DialogBatteryEntry(
                    context
                )
        }
        dialogDeviceEntry?.setOnClickListener { batteryType, carType,stationType ->
            if (batteryType != null) {
                //电池
                context?.let {
                    BatteryEntryActivity.startBatteryEntryActivity(
                        it,
                        batteryType
                    )
                }
            } else if(carType!=null){
                //车辆
                context?.let {
                    VehicleEntryActivity.startVehicleEntryActivity(
                        it,
                        carType,
                    )
                }
            }else{
                //电柜
                context?.let {
                    StationEntryActivity.startStationEntryActivity(
                        it,
                        stationType,
                    )
                }
            }
        }
    }

    private fun askPermission() {
        val permissions = mutableListOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.CAMERA,
        )
        if (SdkVersionUtils.isTIRAMISU()) {
            permissions.remove(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
        permissionManager.checkPermissions(object : PermissionListenerImpl() {
            override fun passPermission() {
                super.passPermission()
//                requestScanLauncher.launch(QrCodeUtils.getScanIntent(mActivity))
                IntentIntegrator.forSupportFragment(this@WorkbenchFragmentNew)
                    .setOrientationLocked(false)
                    .addExtra(QRCodeActivity.QR_TYPE_TARGET, QRCodeActivity.NORMAL)
                    .setCaptureActivity(QRCodeActivity::class.java)
                    .initiateScan() //  初始化扫描
            }

            override fun showRequestPermissionRationale() {
                super.showRequestPermissionRationale()
                PermissionManager.askForPermission(mActivity, "")
            }
        }, *permissions.toTypedArray())
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode != RESULT_OK || data == null) {
            return
        }
        if (requestCode == IntentIntegrator.REQUEST_CODE) {
            val intentResult = IntentIntegrator.parseActivityResult(requestCode, resultCode, data)
            var scanResult = intentResult?.contents ?: ""
            val deviceSn = context?.let { ScanUtils.getDeviceSn(it, scanResult) }
            if (!TextUtils.isEmpty(deviceSn)) {
                context?.let { context ->
                    DeviceDetailActivity.startDeviceDetailActivity(
                        context,
                        deviceSn, 0
                    )
                }
            }
        }


    }

    private fun getSaleData() {
        getViewModel().getSaleData()
    }

    private var selectRolesDialog: SelectRolesDialog? = null

    private fun showSelectRolesDialog() {
        if (selectRolesDialog == null) {
            selectRolesDialog = SelectRolesDialog(mActivity, mRolesEntities)
            selectRolesDialog?.setOnClickListener { str ->
                selectRole(str, warehouseRole)
            }
        }
        selectRolesDialog?.updateData()
        selectRolesDialog?.show()
    }

    override fun onDestroy() {
        super.onDestroy()
        if (selectRolesDialog != null) selectRolesDialog?.destroy()
    }

    private fun parseServiceTypes(raw: String): List<Int> {
        // 先 trim 整体空白
        val fullTrim = raw.trim()
        //如果包了双引号，就去掉它
        val noQuotes = fullTrim
            .removePrefix("\"")
            .removeSuffix("\"")
        //再去掉方括号
        val inner = noQuotes
            .removePrefix("[")
            .removeSuffix("]")
            .trim()
        if (inner.isBlank()) return emptyList()
        // 最后 split + trim + toIntOrNull
        return inner
            .split(",")
            .mapNotNull { it.trim().toIntOrNull() }
    }

}