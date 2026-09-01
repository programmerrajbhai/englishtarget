import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile =
    rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(
        keystorePropertiesFile
    ).use {
        keystoreProperties.load(it)
    }
}

android {
    namespace = "com.novatech.englishtarget"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility =
            JavaVersion.VERSION_17
        targetCompatibility =
            JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget =
            JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId =
            "com.novatech.englishtarget"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias =
                keystoreProperties.getProperty(
                    "keyAlias"
                )

            keyPassword =
                keystoreProperties.getProperty(
                    "keyPassword"
                )

            storePassword =
                keystoreProperties.getProperty(
                    "storePassword"
                )

            storeFile =
                keystoreProperties
                    .getProperty("storeFile")
                    ?.let {
                        file(it)
                    }
        }
    }

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName(
                    "release"
                )

            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}