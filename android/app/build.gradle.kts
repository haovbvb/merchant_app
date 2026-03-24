import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val autoVersionCode =
    ((System.currentTimeMillis() / 1000L) % 2000000000L).toInt()
android {
    namespace = "com.okla.user"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.okla.user"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = autoVersionCode
        versionName = "1.0.2"
    }

    val nativeKeystoreFile = rootProject.file("../power-square-android/app/keystore/okla_admin.jks")
    signingConfigs {
        create("release") {
            check(nativeKeystoreFile.exists()) {
                "Missing native keystore: ${nativeKeystoreFile.path}"
            }
            storeFile = nativeKeystoreFile
            storePassword = "aa668899"
            keyAlias = "key0"
            keyPassword = "aa668899"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_11
    }
}

flutter {
    source = "../.."
}
