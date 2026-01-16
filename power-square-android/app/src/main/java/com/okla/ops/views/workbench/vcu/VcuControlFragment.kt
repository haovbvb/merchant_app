package com.okla.ops.views.workbench.vcu

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.view.View
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import com.base.common.Preferences
import com.base.common.base.mvvm.BaseNormalVFragment
import com.base.common.dialog.DialogDownloadLoading
import com.base.common.utils.ToastUtils
import com.base.library.utils.GsonUtils
import com.okla.ops.R
import com.okla.ops.ble.BluetoothBleUtil
import com.okla.ops.ble.VehicleCommandUtil
import com.okla.ops.ble.ack.AttrInfo
import com.okla.ops.ble.ack.BaseAck
import com.okla.ops.ble.ack.CommonAck
import com.okla.ops.ble.ack.IccidAck
import com.okla.ops.ble.ack.OtaAck
import com.okla.ops.ble.cmd.BaseCmd
import com.okla.ops.ble.enums.CommandEnum
import com.okla.ops.ble.enums.UpDataEnum
import com.okla.ops.databinding.FragmentVcuControlBinding
import com.lxj.xpopup.XPopup
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.coroutines.launch
import java.io.File
import java.util.concurrent.TimeUnit

class VcuControlFragment :
    BaseNormalVFragment<VcuViewModel, FragmentVcuControlBinding>() {

    companion object {
        fun newInstance(sn: String, ctrlId: String): VcuControlFragment {
            val fragment = VcuControlFragment()
            val bundle = Bundle()
            bundle.putString("sn", sn)
            bundle.putString("ctrlId", ctrlId)
            fragment.arguments = bundle
            return fragment
        }
    }

    private var deviceSn: String = ""
    private var deviceCtrlId: String = ""
    private var isUserChange = false
    override fun getArgumentsBundle(arguments: Bundle?) {
        super.getArgumentsBundle(arguments)
        arguments?.let {
            deviceSn = it.getString("sn", "")
            deviceCtrlId = it.getString("ctrlId", "")
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.fragment_vcu_control
    }

    override fun onCreateViewModel(): VcuViewModel? {
        return ViewModelProvider(requireActivity())[VcuViewModel::class.java]
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        addObserver()
        initBluetooth()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopBluetoothConnect()
    }

    override fun onResume() {
        super.onResume()
        isUserChange = false
        mBinding.iosSwitch.isChecked = getCarBleState()
        isUserChange = true
        if (mBinding.iosSwitch.isChecked) {
            safeStartScan()
        }
    }

    private fun safeStartScan() {
        Handler(Looper.getMainLooper()).post {
            startConnectDevice()
        }
    }

    override fun initViews(view: View?, savedInstanceState: Bundle?) {
        super.initViews(view, savedInstanceState)
        initClick()
        initData()
    }

    private fun addObserver() {
        getViewModel().mSendCommandToCarLiveData.observe(this) {
            context?.run {
                ToastUtils.showShort(getString(R.string.tips_sent_successfully))
            }
        }
        getViewModel().mDownloadLiveData.observe(this) {
            getLoading().onFinish()
            if (!TextUtils.isEmpty(it)) {
                val split = it.split(",")
                val file = File(split[1])
                if (file.exists()) {
                    lifecycleScope.launch {
                        getViewModel().readOtaData(file)
                        sendOtaVersion(split[0])
                    }
                }
            }
        }
    }

    private fun initData() {
        mBinding.invDeviceSn.setValue(deviceSn)
        getViewModel().queryCtrlVersionList()
    }

    private fun initClick() {
        mBinding.mSmartRefresh.setOnRefreshListener {
            getViewModel().queryCtrlVersionList()
            getNewData()
        }
        mBinding.iosSwitch.setOnCheckedChangeListener { _, isChecked ->
            if (!isUserChange) return@setOnCheckedChangeListener
            mBinding.iosSwitch.startAnimate()
            Preferences.getInstance().setDetectVehicleBle(Preferences.getInstance().name, isChecked)
            if (isChecked) {
                if (!TextUtils.isEmpty(deviceCtrlId)) {
                    startConnectDevice()//开启自动蓝牙连接
                }
            } else {
                stopBluetoothConnect()
            }
        }
        mBinding.btnStart.setOnClickListener(this)
        mBinding.btnLock.setOnClickListener(this)
        mBinding.btnAntiTheft.setOnClickListener(this)
        mBinding.btnFindVehicle.setOnClickListener(this)
        mBinding.btnRemoteLock.setOnClickListener(this)
        mBinding.btnRemoteUnlock.setOnClickListener(this)
        mBinding.invPlatformUrl.setOnClickListener(this)
        mBinding.invAPN.setOnClickListener(this)
        mBinding.invGpsFrequency.setOnClickListener(this)
        mBinding.invDataFrequency.setOnClickListener(this)
        mBinding.invOta.setOnClickListener(this)
    }

    override fun onNoDoubleClick(v: View) {
        super.onNoDoubleClick(v)
        when (v.id) {
            R.id.btnStart -> {
                val command =
                    VehicleCommandUtil.buildCommand(CommandEnum.LAUNCH.id, 1)
                showCtrlDialog(
                    R.drawable.icon_vcu_start_fff,
                    R.string.str_onclick_start,
                    command,
                    CommandEnum.LAUNCH.cmd
                )
            }

            R.id.btnLock -> {
                val command = VehicleCommandUtil.buildCommand(CommandEnum.LOCK.id, 1)
                showCtrlDialog(
                    R.drawable.icon_vcu_lock_fff,
                    R.string.str_lock,
                    command,
                    CommandEnum.LOCK.cmd
                )
            }

            R.id.btnAntiTheft -> {
                val command =
                    VehicleCommandUtil.buildCommand(CommandEnum.ANTI_THEFT.id, 1)
                showCtrlDialog(
                    R.drawable.icon_vcu_anti_theft_fff,
                    R.string.str_anti_theft,
                    command,
                    CommandEnum.ANTI_THEFT.cmd
                )
            }

            R.id.btnFindVehicle -> {
                val command = VehicleCommandUtil.buildCommand(CommandEnum.FIND.id, 1)
                showCtrlDialog(
                    R.drawable.icon_vcu_find_fff,
                    R.string.str_find_vehicle,
                    command,
                    CommandEnum.FIND.cmd
                )
            }

            R.id.btnRemoteLock -> {
                val command =
                    VehicleCommandUtil.buildCommand(CommandEnum.REMOTE_LOCK.id, 1)
                showCtrlDialog(
                    R.drawable.icon_vcu_remote_lock_fff,
                    R.string.str_remote_lock,
                    command,
                    CommandEnum.REMOTE_LOCK.cmd
                )
            }

            R.id.btnRemoteUnlock -> {
                val command =
                    VehicleCommandUtil.buildCommand(CommandEnum.REMOTE_UNLOCK.id, 1)
                showCtrlDialog(
                    R.drawable.icon_vcu_remote_unlock_fff,
                    R.string.str_remote_unlock,
                    command,
                    CommandEnum.REMOTE_UNLOCK.cmd
                )
            }

            R.id.invPlatformUrl -> {
                val view = VcuListView(requireContext())
                val list = mutableListOf<VcuData>()
                context?.run {
                    list.add(
                        VcuData(
                            getString(R.string.str_production_server),
                            VehicleCommandUtil.buildCommand(
                                mutableListOf(
                                    VehicleCommandUtil.CommandParam(
                                        CommandEnum.EDIT_URL.id,
                                        "okla-irontower-controller-netty.esquare-global.com"
                                    ),
                                    VehicleCommandUtil.CommandParam(CommandEnum.EDIT_PORT.id, 9401),
                                )
                            ),
                            select = true,
                            net = false
                        )
                    )
                    list.add(
                        VcuData(
                            getString(R.string.str_testing_server),
                            VehicleCommandUtil.buildCommand(
                                mutableListOf(
                                    VehicleCommandUtil.CommandParam(
                                        CommandEnum.EDIT_URL.id,
                                        "t-ov-irontower-controller-netty2.esquare-global.com"
                                    ),
                                    VehicleCommandUtil.CommandParam(CommandEnum.EDIT_PORT.id, 9001),
                                )
                            ),
                            select = false,
                            net = false
                        )
                    )
                }
                view.updateData(list)
                showCustomDialog(R.string.str_platform_url, view)
            }

            R.id.invAPN -> {
                val view = VcuInputView(requireContext())
                view.setHintText(R.string.hint_enter_apn)
                view.setFunction { input ->
                    VehicleCommandUtil.buildCommand(
                        CommandEnum.EDIT_APN.id,
                        input
                    )
                }
                showCustomDialog(R.string.str_apn, view)
            }

            R.id.invGpsFrequency -> {
                val view = VcuInputView(requireContext())
                view.setHintText(R.string.hint_enter_gps_query_frequency)
                view.showUnit()
                view.setInputNumberType()
                view.setFunction { input ->
                    val frequency = input.toInt() * 100
                    VehicleCommandUtil.buildCommand(
                        CommandEnum.EDIT_FREQUENCY_GPS.id,
                        frequency
                    )
                }
                showCustomDialog(R.string.str_gps_query_frequency, view)
            }

            R.id.invDataFrequency -> {
                val view = VcuInputView(requireContext())
                view.setHintText(R.string.hint_enter_vehicle_upload_frequency)
                view.showUnit()
                view.setInputNumberType()
                view.setFunction { input ->
                    val frequency = input.toInt() * 100
                    VehicleCommandUtil.buildCommand(
                        mutableListOf(
                            VehicleCommandUtil.CommandParam(
                                CommandEnum.EDIT_FREQUENCY_VEHICLE.id,
                                frequency
                            ),
                            VehicleCommandUtil.CommandParam(
                                CommandEnum.EDIT_FREQUENCY_VEHICLE_1.id,
                                frequency
                            )
                        )
                    )
                }
                showCustomDialog(R.string.str_vehicle_upload_frequency, view)
            }

            R.id.invOta -> {
                val view = VcuListView(requireContext())
                val list = mutableListOf<VcuData>()
                val vcuVersionList = getViewModel().getVcuVersionList()
                for ((index, value) in vcuVersionList.withIndex()) {
                    list.add(
                        VcuData(
                            value.name, value.url,
                            select = index == 0,
                            net = true
                        )
                    )
                }
                view.updateData(list)
                showCustomDialog(R.string.str_ota, view)
            }
        }
    }

    private fun showCtrlDialog(drawableRes: Int, textRes: Int, data: String, cmd: Int) {
        XPopup.Builder(requireContext()).asCustom(
            VucCtrlDialog(requireContext(), drawableRes, textRes, data) { it ->
                if (it.net) {
                    getViewModel().sendCommandToCar(cmd, deviceSn)
                    val hashMap = HashMap<String, Any>()
                    hashMap["cmd"] = cmd
                    hashMap["devId"] = deviceSn
                    getViewModel().saveVcuData(
                        deviceSn, 1, 1, CommandEnum.getCommandByCmd(cmd),
                        GsonUtils.toGson(hashMap)
                    )
                } else {
                    sendCommandToVcu(it.data)
                }
            }
        ).show()
    }

    private fun showCustomDialog(textRes: Int, view: VcuCustomView) {
        XPopup.Builder(requireContext()).asCustom(
            VucCustomDialog(requireContext(), textRes, view) { it ->
                if (it.net) {
                    context?.run {
                        val savePath = "$cacheDir/${it.name}.bin"
                        val file = File(savePath)
                        if (file.exists()) {
                            lifecycleScope.launch {
                                getViewModel().readOtaData(file)
                                sendOtaVersion(it.name)
                            }
                        } else {
//                            file.delete()
                            getLoading().onStart()
                            getViewModel().downloadFile(
                                it.name,
                                it.data,
                                "$cacheDir",
                                "${it.name}.bin"
                            )
                        }
                    }
                } else {
                    sendCommandToVcu(it.data)
                }
            }
        ).show()
    }

    private fun initBluetooth() {
        BluetoothBleUtil.getInstance().init(context)
        BluetoothBleUtil.getInstance()
            .setBluetoothBleCallback(object : BluetoothBleUtil.BluetoothBleCallback {
                override fun onScanning() {
                    context?.run {
                        ToastUtils.showShort(getString(R.string.str_scanning))
                    }
                }

                override fun onScanTimeout() {
                    context?.run {
                        ToastUtils.showShort(getString(R.string.str_scan_timeout))
                    }
                    reconnectDevice() //扫描超时
                }

                override fun onConnecting() {
                    context?.run {
                        ToastUtils.showShort(getString(R.string.str_start_connecting))
                    }
                }

                override fun onConnected() {
                    context?.run {
                        ToastUtils.showShort(getString(R.string.str_connected))
                    }
                }

                override fun onDiscoverServices() {
                    getNewData()
                }

                override fun onDisconnect(msg: String) {
                    context?.run {
                        ToastUtils.showShort(getString(R.string.str_disconnected))
                    }
                    reconnectDevice() //连接断开
                    getViewModel().stopOta()
                    hideDownloadDialog()
                }

                override fun onReadFailure(msg: String) {
//                    ToastUtils.showShort("读取失败!msg: $msg")
                    context?.run {
                        ToastUtils.showShort(
                            getString(
                                R.string.tips_ble_failed_to_read_s,
                                msg
                            )
                        )
                    }
                }

                override fun onWriteSuccess(msg: String) {
                    getLoading().onFinish()
                    if (!getViewModel().isOta()) {
                        parseWriteData(msg)
                        mBinding.mSmartRefresh.isRefreshing = false
                    }
                }

                override fun onWriteFailure(msg: String?) {
                    getLoading().onFinish()
                    context?.run {
                        ToastUtils.showShort(
                            getString(
                                R.string.tips_ble_failed_to_send_s,
                                msg ?: getString(R.string.str_unknow)
                            )
                        )
                    }
                }

                override fun onReceiveData(data: String?) {
                    data?.let { it ->
                        parseReceiveData(it)
                    }
                }
            })
    }

    private var disposable: Disposable? = null
    private fun reconnectDevice() {
        if (isResumed && getCarBleState()) {
            disposable = Observable.timer(10, TimeUnit.SECONDS) // 10 秒后触发
                .observeOn(AndroidSchedulers.mainThread()) // 切换到主线程
                .subscribe { _ ->
                    startConnectDevice()//重连
                }
        }
    }

    private fun getCarBleState(): Boolean =
        Preferences.getInstance().getDetectVehicleBle(Preferences.getInstance().name)

    private fun startConnectDevice() {
        if (!BluetoothBleUtil.getInstance().isConnected) {
            BluetoothBleUtil.getInstance()
                .askBluetoothPermission(deviceCtrlId)
        }
    }

    private fun stopBluetoothConnect() {
        BluetoothBleUtil.getInstance().stopScan("")
        BluetoothBleUtil.getInstance().disconnect()
        disposable?.dispose()
    }

    private fun parseWriteData(data: String) {
        val ctrlCmd = GsonUtils.fromGson(data, BaseCmd::class.java)
        ctrlCmd?.let {
            for (item in it.paramList) {
                val commandById = CommandEnum.getCommandById(item.id)
                if (commandById != null) {
                    getViewModel().saveVcuData(deviceCtrlId, 1, 2, commandById, data)
                    break
                }
            }
        }
    }

    private fun parseReceiveData(data: String) {
        val ack: BaseAck? = GsonUtils.fromGson(data, BaseAck::class.java)
        if (!getViewModel().isOta()) {
            getViewModel().saveVcuData(
                deviceCtrlId,
                2,
                2,
                getViewModel().getCommand(ack?.txnNo ?: 0),
                data
            )
        }
        if (ack?.txnNo == getViewModel().getOtaDataTxnNo()) {
            val otaAck: OtaAck? =
                GsonUtils.fromGson(data, OtaAck::class.java)
            if (otaAck?.b_result == 1) {
                val ext = otaAck.b_extVal
                if (ext.contains("=")) {
                    val split = ext.split("=")
                    val index = split[1].toInt()
                }
                setDownloadProcess()
                sendOtaData(getViewModel().getOtaDataByIndex())
            } else {
                context?.run {
                    ToastUtils.showShort(getString(R.string.tips_ble_failed_to_ota))
                }
            }
        } else if (ack?.txnNo == getViewModel().getOtaCheckTxnNo()) {
            val otaAck: OtaAck? =
                GsonUtils.fromGson(data, OtaAck::class.java)
            if (otaAck?.b_result == 1) {
                showDownloadDialog()
                getViewModel().startOta()
                setDownloadProcess()
                sendOtaData(getViewModel().getOtaDataByIndex())
            } else {
                context?.run {
                    ToastUtils.showShort(
                        getString(
                            R.string.tips_ble_failed_to_verify_s,
                            when (otaAck?.b_result) {
                                2 -> getString(R.string.tips_ota_reject_ver_too_low)
                                3 -> getString(R.string.tips_ota_reject_other)
                                else -> getString(R.string.str_unknow)
                            }
                        )
                    )
                }
            }
        } else {
            val commonAck = GsonUtils.fromGson(data, CommonAck::class.java)
            commonAck?.run {
                if (this.result == 1) {
                    context?.run {
                        ToastUtils.showShort(getString(R.string.tips_set_successfully))
                    }
                }
            }
            val attrAck = GsonUtils.fromGson(data, AttrInfo::class.java)
            attrAck?.run {
                this.attrList?.let { list ->
                    for (item in list) {
                        if (TextUtils.equals(item.id, UpDataEnum.OTA_RESULT.id)) {
                            context?.run {
                                ToastUtils.showShort(getString(if (item.value == 1) R.string.tips_ota_completed_successfully else R.string.tips_ble_failed_to_ota))
                            }
                        }
                        if (TextUtils.equals(item.id, UpDataEnum.VERIFY_RESULT.id)) {
                            if (item.value != 1) {
                                context?.run {
                                    ToastUtils.showShort(getString(R.string.tips_ble_failed_to_verify))
                                }
                            }
                        }
                        if (TextUtils.equals(item.id, UpDataEnum.MCU_VERSION.id)) {
                            try {
                                mBinding.invOta.setValue(item.value as String)
                            } catch (e: Exception) {
                                mBinding.invOta.setValue("-")
                            }
                        }
                    }
                }
            }
            val iccidAck = GsonUtils.fromGson(data, IccidAck::class.java)
            iccidAck?.run {
                if (!TextUtils.isEmpty(this.iccid)) {

                }
            }
        }
    }

    private fun sendCommandToVcu(command: String, show: Boolean = true) {
        if (BluetoothBleUtil.getInstance().isConnected) {
            if (show) getLoading().onStart()
            BluetoothBleUtil.getInstance().addDataToQueue(command)
            val ctrlCmd = GsonUtils.fromGson(command, BaseCmd::class.java)
            ctrlCmd?.let {
                for (item in it.paramList) {
                    val commandById = CommandEnum.getCommandById(item.id)
                    if (commandById != null) {
                        getViewModel().addCommand(it.txnNo, commandById)
                    }
                }
            }
        } else {
            mBinding.mSmartRefresh.isRefreshing = false
            ToastUtils.showShort(context?.getString(R.string.tips_ble_failed_to_send))
        }
    }

    private fun sendOtaVersion(version: String) {
        val txnNo = System.currentTimeMillis()
        getViewModel().setOtaCheckTxnNo(txnNo)
        val buildCommand = VehicleCommandUtil.buildCommand(
            mutableListOf(
                VehicleCommandUtil.CommandParam(CommandEnum.OTA_VERIFY_VERSION.id, version),
                VehicleCommandUtil.CommandParam(CommandEnum.OTA_UPGRADE.id, 1),
            ),
            txnNo
        )
        sendCommandToVcu(buildCommand)
    }

    private fun sendOtaData(data: String) {
        val txnNo = System.currentTimeMillis()
        getViewModel().setOtaDataTxnNo(txnNo)
        val buildCommand =
            VehicleCommandUtil.buildCommand(CommandEnum.OTA_DATA.id, data, txnNo)
        sendCommandToVcu(buildCommand, false)
    }

    private fun getNewData() {
        val queryVer =
            VehicleCommandUtil.buildCommand(CommandEnum.QUERY_MCU_VERSION.id, 1)
        sendCommandToVcu(queryVer)
        val queryICCID =
            VehicleCommandUtil.buildCommand(CommandEnum.QUERY_ICCID.id, 0)
        sendCommandToVcu(queryICCID)
    }

    private var downloadDialog: DialogDownloadLoading? = null

    private fun showDownloadDialog() {
        context?.let {
            if (downloadDialog == null) {
                downloadDialog = DialogDownloadLoading(it, false)
            }
            downloadDialog?.onStart()
        }
    }

    private fun setDownloadProcess() {
        downloadDialog?.setProcess(getViewModel().getOtaProcess())
    }

    private fun hideDownloadDialog() {
        downloadDialog?.onFinish()
    }

}