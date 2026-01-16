// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    dependencies {
        classpath(libs.gradle)
        classpath(libs.google.services)
        classpath(libs.firebase.crashlytics.gradle)
        classpath(libs.kotlin.gradle.plugin)
        classpath(libs.secrets.gradle.plugin)
        classpath(libs.r8)
        classpath(libs.androidx.navigation.safe.args.gradle.plugin)
    }
}
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
}

extra["compileSdkVersion"] = 35
extra["minSdkVersion"] = 23
extra["targetSdkVersion"] = 35