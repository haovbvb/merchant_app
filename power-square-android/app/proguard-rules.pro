# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

-keep class com.okla.ops.beans.* { *; }

-dontwarn android.net.**
-keep class android.net.SSLCertificateSocketFactory{*;}

-keepclassmembers class fqcn.of.javascript.interface.for.webview {
   public *;
}
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

-keepattributes EnclosingMetho

#指定代码的压缩级别
-optimizationpasses 5

#包明不混合大小写
-dontusemixedcaseclassnames

#不去忽略非公共的库类
-dontskipnonpubliclibraryclasses

 #优化  不优化输入的类文件
-dontoptimize

 #预校验
-dontpreverify

 #混淆时是否记录日志
-verbose

 # 混淆时所采用的算法
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

#保护注解
-keepattributes *Annotation*
 #如果引用了v4或者v7包
    -dontwarn android.support.**
#保持 native 方法不被混淆
-keepclasseswithmembernames class * {
    native <methods>;
}

#保持自定义控件类不被混淆
-keepclasseswithmembers class * {
    public <init>(android.content.Context);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

#保持自定义控件类不被混淆
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}
#保持自定义控件类不被混淆
-keepclasseswithmembers  class * extends android.app.Activity {
   public void *(android.view.View);
}

#保持 Parcelable 不被混淆
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

#保持 Serializable 不被混淆
-keepnames class * implements java.io.Serializable

#保持 Serializable 不被混淆并且enum 类也不被混淆
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

#保持枚举 enum 类不被混淆 如果混淆报错，建议直接使用上面的 -keepclassmembers class * implements java.io.Serializable即可
#-keepclassmembers enum * {
#  public static **[] values();
#  public static ** valueOf(java.lang.String);
#}

-keepclassmembers class * {
    public void *ButtonClicked(android.view.View);
}
# retrofit不混淆
-dontwarn okio.**
-dontwarn javax.annotation.**

#不混淆资源类
-keepclassmembers class **.R$* {
    public static <fields>;
}

-keep class **$$ViewBinder { *; }

-keepclasseswithmembernames class * {
    @butterknife.* <fields>;
}

-keepclasseswithmembernames class * {
    @butterknife.* <methods>;
}

-keepattributes EnclosingMethod

#避免混淆泛型 如果混淆报错建议关掉

-dontwarn com.google.zxing.client.android.camera.**
-keep class com.google.zxing.client.android.camera.**{*;}

-dontwarn android.support.graphics.drawable.**
-keep class android.support.graphics.drawable.**{*;}
-keepclassmembers class **.R$drawable {
    public static final int *;
}
-keepclassmembers class **.R$mipmap {
    public static final int *;
}
-keepclassmembers class **.R$layout {
    public static final int *;
}

-keep class androidx.appcompat.widget.AppCompatImageView { *; }
-dontwarn android.support.v7.**
-keep class android.support.v7.**{*;}

-dontwarn android.support.v4.**
-keep class android.support.v4.**{*;}

-dontwarn me.relex.circleindicator.**
-keep class me.relex.circleindicator.**{*;}

-dontwarn com.google.zxing.**
-keep class com.google.zxing.**{*;}

-dontwarn android.support.design.**
-keep class android.support.design.**{*;}

-dontwarn com.google.**
-keep class com.google.**{*;}

-dontwarn freemarker.cache.**
-keep class freemarker.cache.**{*;}

-dontwarn com.bumptech.glide.**
-keep class com.bumptech.glide.**{*;}

-dontwarn de.greenrobot.dao.**
-keep class de.greenrobot.dao.**{*;}

-dontwarn de.greenrobot.daogenerator.**
-keep class de.greenrobot.daogenerator.**{*;}

-dontwarn com.google.gson.**
-keep class com.google.gson.**{*;}

-dontwarn org.hamcrest.**
-keep class org.hamcrest.**{*;}

-dontwarn lecho.lib.hellocharts.**
-keep class lecho.lib.hellocharts.**{*;}

-dontwarn junit.**
-keep class junit.**{*;}

-dontwarn com.liulishuo.filedownloader.**
-keep class com.liulishuo.filedownloader.**{*;}

-dontwarn com.viewpagerindicator.**
-keep class com.viewpagerindicator.**{*;}

-dontwarn okhttp3.logging.**
-keep class okhttp3.logging.**{*;}

-dontwarn internal.**
-keep class internal.**{*;}

-dontwarn com.zhy.http.okhttp.**
-keep class com.zhy.http.okhttp.**{*;}

-dontwarn okio.**
-keep class okio.**{*;}
-ignorewarnings

-keep class * {
    public private *;
}
-dontwarn android.support.percent.**
-keep class android.support.percent.**{*;}

-dontwarn com.makeramen.roundedimageview.**
-keep class com.makeramen.roundedimageview.**{*;}

-dontwarn rx.**
-keep class rx.**{*;}


-dontwarn android.support.annotation.**
-keep class android.support.annotation.**{*;}

-dontwarn android.support.graphics.drawable.**
-keep class android.support.graphics.drawable.**{*;}

-dontwarn com.github.yoojia.**
-keep class com.github.yoojia.**{*;}

-dontwarn com.amap.api.**
-keep class com.amap.api.**{*;}

-dontwarn com.autonavi.aps.amapapi.model.**
-keep class com.autonavi.aps.amapapi.model.**{*;}

# 保持自定义 NavType 和 Car 类
-keep class com.okla.ops.nav.** { *; }
-keep class com.okla.ops.beans.Car { *; }
-keepclassmembers class com.okla.ops.beans.Car implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

-dontwarn com.loc.**
-keep class com.loc.**{*;}

-dontwarn org.jcaki.**
-keep class org.jcaki.**{*;}

-dontwarn simplesound.**
-keep class simplesound.**{*;}

-keep class androidx.recyclerview.widget.**{*;}
-keep class androidx.viewpager2.widget.**{*;}

# monitor 抓包
-keep class com.lygttpod.monitor.** { *; }

-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}

-keep public class com.esquare.batterystation.android.R$*{
public static final int *;
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keepattributes *Annotation*
-keepclassmembers class ** {
@org.greenrobot.eventbus.Subscribe <methods>;
}
-keep enum org.greenrobot.eventbus.ThreadMode { *; }

-keep class com.baidu.mobstat.** { *; }
# Only required if you use AsyncExecutor
-keepclassmembers class * extends org.greenrobot.eventbus.util.ThrowableFailureEvent {
<init>(java.lang.Throwable);
}
-dontwarn com.tencent.bugly.**
-keep public class com.tencent.bugly.**{*;}
-keep class android.support.**{*;}
-keep class com.youth.banner.** {
    *;
 }
 -keep class com.just.agentweb.** {
     *;
 }
 -dontwarn com.just.agentweb.**
 -keepclassmembers class com.just.agentweb.sample.common.AndroidInterface{ *; }

 -keep class com.iflytek.**{*;}
 -keepattributes Signature


-ignorewarnings
-keepattributes *Annotation*
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-keep class com.hianalytics.android.**{*;}
-keep class com.huawei.updatesdk.**{*;}
-keep class com.huawei.hms.**{*;}

-dontwarn com.vivo.push.**
-keep class com.vivo.push.**{*; }
-keep class com.vivo.vms.**{*; }
-keep class xxx.xxx.xxx.PushMessageReceiverImpl{*;}

  -keep public class * extends android.app.Service
#-----------------greenDao-------
-keepclassmembers class * extends org.greenrobot.greendao.AbstractDao {
public static java.lang.String TABLENAME;
}
-keep class **$Properties { *; }

# If you DO use SQLCipher:
-keep class org.greenrobot.greendao.database.SqlCipherEncryptedHelper { *; }

# If you do NOT use SQLCipher:
-dontwarn net.sqlcipher.database.**
# If you do NOT use RxJava:
-dontwarn rx.**
#-----------------greenDao-------

-dontwarn com.okla.ops.beans.**
-keep class com.okla.ops.beans.**{*;}
-dontwarn com.base.common.beans.**
-keep class com.base.common.beans.**{*;}
-dontwarn com.base.common.db.**
-keep class com.base.common.db.**{*;}
-keep class com.okla.ops.map.**{*;}
-keep class android.location.**{*;}
#-keep class com.google.android.libraries.maps.model.**{*;}
-keep class com.okla.ops.ble.**{*;}
-dontwarn com.okla.ops.ble.**

#不混淆需要根据manifest来识别的类
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference