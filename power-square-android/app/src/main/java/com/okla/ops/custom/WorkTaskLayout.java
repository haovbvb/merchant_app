//package com.okla.ops.custom;
//
//import android.content.Context;
//import android.util.AttributeSet;
//import android.view.LayoutInflater;
//import android.view.View;
//
//import androidx.annotation.NonNull;
//import androidx.annotation.Nullable;
//import androidx.appcompat.widget.AppCompatTextView;
//import androidx.constraintlayout.widget.ConstraintLayout;
//
//import com.okla.ops.beans.WorkOrderStat;
//import com.okla.ops.R;
//import com.okla.ops.views.workbench.worktask.WorkTaskStatus;
//
//
//public class WorkTaskLayout extends ConstraintLayout implements View.OnClickListener {
//
//    private AppCompatTextView tvWorkingNum, tvTimeoutNum, tvFinishNum;
//
//    public WorkTaskLayout(@NonNull Context context) {
//        super(context);
//        init(context);
//    }
//
//    public WorkTaskLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
//        super(context, attrs);
//        init(context);
//    }
//
//    public WorkTaskLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
//        super(context, attrs, defStyleAttr);
//        init(context);
//    }
//
//    private void init(Context context) {
//        View view = LayoutInflater.from(context).inflate(R.layout.layout_worktask, this);
//        tvWorkingNum = view.findViewById(R.id.tv_working_num);
//        tvTimeoutNum = view.findViewById(R.id.tv_timeout_num);
//        tvFinishNum = view.findViewById(R.id.tv_finish_num);
//        view.findViewById(R.id.tv_title).setOnClickListener(this);
//        view.findViewById(R.id.view_1).setOnClickListener(this);
//        view.findViewById(R.id.view_2).setOnClickListener(this);
//        view.findViewById(R.id.view_3).setOnClickListener(this);
//    }
//
//    @Override
//    public void onClick(View v) {
//        switch (v.getId()) {
//            case R.id.tv_title:
//                if (layoutListener != null) layoutListener.onDetail(-1);
//                break;
//            case R.id.view_1:
//                if (layoutListener != null) layoutListener.onDetail(WorkTaskStatus.STATUS_PROCESSING);
//                break;
//            case R.id.view_2:
//                if (layoutListener != null) layoutListener.onDetail(WorkTaskStatus.STATUS_TIMEOUT);
//                break;
//            case R.id.view_3:
//                if (layoutListener != null) layoutListener.onDetail(WorkTaskStatus.STATUS_FINISHED);
//                break;
//        }
//    }
//
//    public void setData(WorkOrderStat workOrderStat) {
//        tvWorkingNum.setText(String.valueOf(workOrderStat.getProcessNum()));
//        tvFinishNum.setText(String.valueOf(workOrderStat.getFinishNum()));
//        tvTimeoutNum.setText(String.valueOf(workOrderStat.getTimeoutNum()));
//    }
//
//    public interface OnWorkTaskLayoutListener {
//        void onDetail(int status);
//    }
//
//    private OnWorkTaskLayoutListener layoutListener;
//
//    public void setLayoutListener(OnWorkTaskLayoutListener layoutListener) {
//        this.layoutListener = layoutListener;
//    }
//}
