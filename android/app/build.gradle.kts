import org.gradle.api.JavaVersion

plugins {
    id("com.android.application")
    id("kotlin-android")
    // FlutterFire and Firebase Google Services plugin
    id("com.google.gms.google-services")
    // Flutter Gradle plugin (must be applied after Android/Kotlin plugins)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Explicitly set the required NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // For now, signing with debug keys (update for production signing as needed)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
