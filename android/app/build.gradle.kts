import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Release signing — load credentials from android/key.properties
// This file must NOT be committed to Git (it is excluded by .gitignore).
// ---------------------------------------------------------------------------
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.alanbiju.pocketmoney"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.alanbiju.pocketmoney"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Fail loudly if key.properties is missing so a release build
            // is never silently signed with the insecure debug keystore.
            check(keyPropertiesFile.exists()) {
                """
                |
                |  ❌  RELEASE BUILD FAILED — android/key.properties not found.
                |
                |  A valid upload keystore is required for release builds.
                |  Please follow the setup instructions in README.md:
                |
                |  1. Generate your upload keystore (run once):
                |       keytool -genkey -v \
                |         -keystore android/app/upload-keystore.jks \
                |         -keyalg RSA -keysize 2048 -validity 10000 \
                |         -alias upload
                |
                |  2. Create android/key.properties with:
                |       storePassword=<your-keystore-password>
                |       keyPassword=<your-key-password>
                |       keyAlias=upload
                |       storeFile=upload-keystore.jks
                |
                |  ⚠  Never commit key.properties or *.jks to version control.
                |
                """.trimMargin()
            }

            val storeFileProperty = keyProperties["storeFile"] as? String
            check(!storeFileProperty.isNullOrBlank()) {
                "❌  RELEASE BUILD FAILED — 'storeFile' is missing or blank in android/key.properties."
            }

            val resolvedStoreFile = file(storeFileProperty)
            check(resolvedStoreFile.exists()) {
                """
                |
                |  ❌  RELEASE BUILD FAILED — Keystore file not found at:
                |      ${resolvedStoreFile.absolutePath}
                |
                |  Ensure 'storeFile' in android/key.properties points to a valid .jks file.
                |
                """.trimMargin()
            }

            keyAlias     = keyProperties["keyAlias"]     as String
            keyPassword  = keyProperties["keyPassword"]  as String
            storeFile    = resolvedStoreFile
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // Release builds MUST use the production keystore.
            // Any misconfiguration is caught above at configuration time.
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = false
            isShrinkResources = false
        }
        // debug builds continue to use the default debug signing — untouched.
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
