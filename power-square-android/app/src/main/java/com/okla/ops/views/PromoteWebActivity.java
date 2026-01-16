package com.okla.ops.views;

import static android.webkit.WebSettings.LOAD_NO_CACHE;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.webkit.GeolocationPermissions;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.Nullable;

import com.base.common.base.mvvm.BaseNormalVActivity;
import com.base.library.base.mvvm.BaseViewModel;
import com.okla.ops.R;
import com.okla.ops.databinding.ActivityPromoteWebBinding;

public class PromoteWebActivity extends BaseNormalVActivity<BaseViewModel, ActivityPromoteWebBinding> {
    private String mUrl, mTitle, mRightTitle;
    boolean needShare, isParse;
    private WebView mWebView;
    private WebViewClient mWebViewClient;

    public final static int PARSE_REQUEST_CODE = 1111;

    public static Intent getIntents(Context packageContext, String url, String title, String rightTitle, boolean needShare) {
        Intent intent = new Intent(packageContext, PromoteWebActivity.class);
        intent.putExtra("url", url);
        intent.putExtra("title", title);
        intent.putExtra("rightTitle", rightTitle);
        intent.putExtra("needShare", needShare);
        return intent;
    }

    public static Intent getIntents(Context packageContext, String url, boolean isParse) {
        Intent intent = new Intent(packageContext, PromoteWebActivity.class);
        intent.putExtra("url", url);
        intent.putExtra("isParse", isParse);
        return intent;
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void initViews(Bundle savedInstanceState) {
        super.initViews(savedInstanceState);
        getIntentsData();

        initView();

        initListen();
    }

    @Override
    protected BaseViewModel onCreateViewModel() {
        return null;
    }

    @Override
    protected int getLayoutId() {
        return R.layout.activity_promote_web;
    }

    private void initListen() {
        mBinding.includeTitle.topBack.setOnClickListener(v -> finish());
    }

    private void initView() {
        mWebView = new WebView(this);
        initWebSetting(mWebView);
        initWebViewClient();
        mWebView.setWebViewClient(mWebViewClient);
        mWebView.addJavascriptInterface(new InJavaScriptLocalObj(data -> {
            Intent intent = new Intent();
            intent.putExtra("parse_result", data);
            setResult(RESULT_OK, intent);
            finish();
        }), "java_obj");
        mBinding.mWebViewContainer.addView(mWebView);
        mWebView.loadUrl(mUrl);

        if (!TextUtils.isEmpty(mTitle)) {
            mBinding.includeTitle.topTitle.setText(mTitle);
        }
        if (!TextUtils.isEmpty(mRightTitle)) {
            mBinding.includeTitle.topRight.setVisibility(View.VISIBLE);
            mBinding.includeTitle.topRight.setText(mRightTitle);
        }
        if (isParse) {
            mBinding.includeTitle.rlContent.setVisibility(View.GONE);
            mBinding.mWebViewContainer.setVisibility(View.GONE);
        } else {
            mBinding.includeTitle.rlContent.setVisibility(View.VISIBLE);
            mBinding.mWebViewContainer.setVisibility(View.VISIBLE);
        }
        getLoading().onStart();
    }

    private void getIntentsData() {
        Intent intent = getIntent();
        mUrl = intent.getStringExtra("url");
        mTitle = intent.getStringExtra("title");
        mRightTitle = intent.getStringExtra("rightTitle");
        needShare = intent.getBooleanExtra("needShare", false);
        isParse = intent.getBooleanExtra("isParse", false);
    }

    @Override
    protected void onResume() {
        super.onResume();

    }

    private void initWebViewClient() {
        mWebViewClient = new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                getLoading().onFinish();
                String title = view.getTitle();
                if (!TextUtils.isEmpty(title)) {
                    if (title.startsWith("http")) {
                        mBinding.includeTitle.topTitle.setText(" ");
                    } else {
                        mBinding.includeTitle.topTitle.setText(title);
                    }
                }
            }

            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
            }
        };
    }

    private void initWebSetting(WebView mWebView) {
        WebSettings webSettings = mWebView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setLoadsImagesAutomatically(true);
        webSettings.setCacheMode(LOAD_NO_CACHE);

        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setSupportMultipleWindows(true);
//        webSettings.setAppCacheEnabled(false);
        webSettings.setDomStorageEnabled(true);
        webSettings.setAllowFileAccess(true);
        webSettings.setSupportZoom(true);

        //启用数据库
        webSettings.setDatabaseEnabled(true);
        //启用地理定位，默认为true
        webSettings.setGeolocationEnabled(true);

        //实现WebView下载功能
        mWebView.setDownloadListener((url, userAgent, contentDisposition, mimetype, contentLength) -> {
            try {//try catch 以免崩溃
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(url));
                PackageManager packageManager = getPackageManager();
                if (intent.resolveActivity(packageManager) != null) {
                    startActivity(intent);
                }
            } catch (Exception e) {
            }
        });
        mWebView.setWebChromeClient(new WebChromeClient() {
                                        @Nullable
                                        @Override
                                        public Bitmap getDefaultVideoPoster() {
                                            Bitmap bitmap = super.getDefaultVideoPoster();
                                            if (bitmap == null) {
                                                return BitmapFactory.decodeResource(getApplicationContext().getResources(),
                                                        R.mipmap.ic_launcher);
                                            } else {
                                                return bitmap;
                                            }
                                        }

                                        @Override
                                        public void onGeolocationPermissionsShowPrompt(String origin, GeolocationPermissions.Callback callback) {
                                            callback.invoke(origin, true, false);
                                            super.onGeolocationPermissionsShowPrompt(origin, callback);
                                        }

                                        @Override
                                        public void onReceivedTitle(WebView view, String title) {
                                            super.onReceivedTitle(view, title);
                                        }
                                    }
        );
    }

    private static class InJavaScriptLocalObj {
        interface Callback {
            void parseData(String data);
        }

        private final Callback callback;

        public InJavaScriptLocalObj(Callback callback) {
            this.callback = callback;
        }

        @JavascriptInterface
        public void getUrlData(String data) {
            if (callback != null)
                callback.parseData(data);
        }

    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

    }

    @Override
    protected void onStop() {
        if (mWebView != null) {
            mWebView.stopLoading();
        }
        super.onStop();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        if (mWebView.canGoBack()) {
            mWebView.goBack();
        } else {
            finish();
        }
    }

    @Override
    protected void onDestroy() {

        if (mWebView != null) {
            mWebView.clearHistory();
            mWebView.clearCache(true);
            mWebView.destroy();
            mWebView = null;
        }

        super.onDestroy();
    }
}
