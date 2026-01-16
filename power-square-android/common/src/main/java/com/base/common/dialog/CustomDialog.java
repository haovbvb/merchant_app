package com.base.common.dialog;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Typeface;
import android.text.SpannableString;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.constraintlayout.widget.Group;

import com.base.common.R;
import com.base.library.utils.DensityUtils;

/**
 * 根据设计，有 7 个元素，所有元素都是不传入就显示默认
 * 右上角 x 按钮-- 对应 cancelClickListener事件，不传入则自动隐藏；
 * 标题         -- 对应 title ，不传入则自动隐藏；
 * 内容         -- 对应 message ，默认一直显示；
 * 知道了       -- 对应 iKnowClickListener事件 ，不传入则自动隐藏,显示取消和确认双按钮,二者只能显示一个；
 * 确认         -- 对应 positiviClickListener ，传入iKnowClickListener 则双按钮自动隐藏,二者只能显示一个；
 * 取消         -- 对应 negativeClickListener ，传入iKnowClickListener 则双按钮自动隐藏,二者只能显示一个；
 * 默认外部不可点击取消，可设置----setCanceledOnTouchOutside（true）
 */
public class CustomDialog extends Dialog {

    public CustomDialog(Context context) {
        super(context);
    }

    public CustomDialog(Context context, int themeResId) {
        super(context, themeResId);
    }

    public static class Builder {
        private OnClickListener positiviClickListener;
        private OnClickListener negativeClickListener;
        private OnClickListener iKnowClickListener;
        private OnClickListener cancelClickListener;
        private Context mContext;
        private String title;
        private String message;
        private SpannableString spannableMessage;
        private String positiveBtnText;
        private String negativeBtnText;
        private String iKnowBtnText;
        private View contentView;
        private boolean isCanceledOnTouchOutsice;
        private int isTvDialogCancelColor = 0;
        private int isTvDialogConfirmColor = 0;
        private int messageGravity;

        public Builder(Context context) {
            this.mContext = context;
        }

        public Builder Builder(String message) {
            this.message = message;
            return this;
        }

        /**
         * Set the Dialog message from resource
         *
         * @param message
         * @return
         */
        public Builder setMessage(String message) {
            this.message = message;
            return this;
        }

        /**
         * Set the Dialog message from resource
         *
         * @param message
         * @return
         */
        public Builder setSpannableMessage(SpannableString message) {
            this.spannableMessage = message;
            return this;
        }

        /**
         * Set the Dialog title from resource
         *
         * @param title
         * @return
         */
        public Builder setTitle(String title) {
            this.title = title;
            return this;
        }

        public Builder setContentView(View view) {
            this.contentView = view;
            return this;
        }

        public Builder setPositiveButton(OnClickListener listener) {
            this.positiviClickListener = listener;
            return this;
        }

        public Builder setPositiveButton(int positiveText, OnClickListener listener) {
            this.positiveBtnText = mContext.getResources().getString(positiveText);
            this.positiviClickListener = listener;
            return this;
        }

        public Builder setPositiveButton(String positiveText, OnClickListener listener) {
            this.positiveBtnText = positiveText;
            this.positiviClickListener = listener;
            return this;
        }

        public Builder setNegativeButton(int negativeText, OnClickListener listener) {
            this.negativeBtnText = mContext.getResources().getString(negativeText);
            this.negativeClickListener = listener;
            return this;
        }

        public Builder setNegativeButton(OnClickListener listener) {
            this.negativeClickListener = listener;
            return this;
        }

        public Builder setNegativeButton(String negativeText, OnClickListener listener) {
            this.negativeBtnText = negativeText;
            this.negativeClickListener = listener;
            return this;
        }

        public Builder setIKnowButton(OnClickListener listener) {
            this.iKnowClickListener = listener;
            return this;
        }

        public Builder setIKnowButton(int iKnowText, OnClickListener listener) {
            this.iKnowBtnText = mContext.getResources().getString(iKnowText);
            this.iKnowClickListener = listener;
            return this;
        }

        public Builder setIKnowButton(String iKnowText, OnClickListener listener) {
            this.iKnowBtnText = iKnowText;
            this.iKnowClickListener = listener;
            return this;
        }

        public Builder setCancelButton(OnClickListener listener) {
            this.cancelClickListener = listener;
            return this;
        }

        public Builder setCanceledOnTouchOutside(boolean isCanceledOnTouchOutsice) {
            this.isCanceledOnTouchOutsice = isCanceledOnTouchOutsice;
            return this;
        }

        public Builder setTvDialogCancelColor(int cancelColor) {
            this.isTvDialogCancelColor = cancelColor;
            return this;
        }

        public Builder setTvDialogMessageGravity(int gravity) {
            this.messageGravity = gravity;
            return this;
        }

        public Builder setTvDialogConfirmColor(int confirmColor) {
            this.isTvDialogConfirmColor = confirmColor;
            return this;
        }

        public CustomDialog create() {
            final CustomDialog dialog = new CustomDialog(mContext, R.style.CustomDialog);
            LayoutInflater inflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            View layoutView = inflater.inflate(R.layout.dialog_custom_for_app, null);

            TextView tvDialogTitle = layoutView.findViewById(R.id.tvDialogTitle);
            ImageView ivDialogCancel = layoutView.findViewById(R.id.ivDialogCancel);
            TextView tvDialogMessage = layoutView.findViewById(R.id.tvDialogMessage);
            TextView tvDialogIKnow = layoutView.findViewById(R.id.tvDialogIKnow);
            TextView tvDialogCancel = layoutView.findViewById(R.id.tvDialogCancel);
            TextView tvDialogConfirm = layoutView.findViewById(R.id.tvDialogConfirm);
            Group gGroupDialogForIKnowToHide = layoutView.findViewById(R.id.gGroupDialogForIKnowToHide);
            Group gGroupDialogForTwoBtnToHide = layoutView.findViewById(R.id.gGroupDialogForTwoBtnToHide);

            tvDialogMessage.setText(message);
            if (spannableMessage != null) {
                tvDialogMessage.setText(spannableMessage);
            }
            tvDialogMessage.post(new Runnable() {
                @Override
                public void run() {
                    if (tvDialogMessage != null && tvDialogMessage.getLineCount() == 1) {
                        tvDialogMessage.setGravity(Gravity.CENTER);
                    }
                }
            });

            if (TextUtils.isEmpty(title)) {
                tvDialogTitle.setVisibility(View.GONE);
            } else {
                tvDialogTitle.setText(title);
                tvDialogTitle.setVisibility(View.VISIBLE);
                tvDialogTitle.setTypeface(null, Typeface.BOLD);
            }
            if (cancelClickListener == null) {
                ivDialogCancel.setVisibility(View.GONE);
            } else {
                ivDialogCancel.setVisibility(View.VISIBLE);
                ivDialogCancel.setOnClickListener(v -> cancelClickListener.onClick(dialog, DialogInterface.BUTTON_NEUTRAL));
            }
            if (iKnowClickListener == null) {
                gGroupDialogForIKnowToHide.setVisibility(View.GONE);
                gGroupDialogForTwoBtnToHide.setVisibility(View.VISIBLE);
            } else {
                if (!TextUtils.isEmpty(iKnowBtnText)) {
                    tvDialogIKnow.setText(iKnowBtnText);
                }
                gGroupDialogForIKnowToHide.setVisibility(View.VISIBLE);
                gGroupDialogForTwoBtnToHide.setVisibility(View.GONE);
                tvDialogIKnow.setOnClickListener(v -> iKnowClickListener.onClick(dialog, DialogInterface.BUTTON_NEUTRAL));
            }
            if (positiviClickListener != null) {
                if (!TextUtils.isEmpty(positiveBtnText)) {
                    tvDialogConfirm.setText(positiveBtnText);
                }
                tvDialogConfirm.setOnClickListener(v -> positiviClickListener.onClick(dialog, DialogInterface.BUTTON_POSITIVE));
            }
            if (isTvDialogCancelColor != 0) {
                tvDialogCancel.setTextColor(mContext.getResources().getColor(isTvDialogCancelColor));
            }
            if (isTvDialogConfirmColor != 0) {
                tvDialogConfirm.setTextColor(mContext.getResources().getColor(isTvDialogConfirmColor));
            }
            if (negativeClickListener != null) {
                if (!TextUtils.isEmpty(negativeBtnText)) {
                    tvDialogCancel.setText(negativeBtnText);
                }
                tvDialogCancel.setOnClickListener(v -> negativeClickListener.onClick(dialog, DialogInterface.BUTTON_NEGATIVE));
            }
            dialog.setCanceledOnTouchOutside(isCanceledOnTouchOutsice);
            dialog.setContentView(layoutView);
            return dialog;
        }
    }

    @Override
    public void show() {
        super.show();
        Window window = getWindow();
        WindowManager.LayoutParams params = window.getAttributes();
        params.width = DensityUtils.dp2px(310f);
        window.setAttributes(params);
    }
}
