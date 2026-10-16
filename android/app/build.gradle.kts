import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile: File = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}

android {
    namespace = "com.baristabrew.barista_brew"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.baristabrew.barista_brew"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias").orEmpty()
                keyPassword = keystoreProperties.getProperty("keyPassword").orEmpty()
                storeFile = file(keystoreProperties.getProperty("storeFile").orEmpty())
                storePassword = keystoreProperties.getProperty("storePassword").orEmpty()
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

tasks.configureEach {
    if (
        name == "validateSigningRelease" ||
        name == "packageRelease" ||
        name == "signReleaseBundle" ||
        name == "assembleRelease" ||
        name == "bundleRelease"
    ) {
        doFirst {
            if (!keystorePropertiesFile.isFile) {
                throw GradleException(
                    "Release signing is not configured. Add android/key.properties and a production keystore."
                )
            }

            val requiredProperties = listOf(
                "keyAlias",
                "keyPassword",
                "storeFile",
                "storePassword",
            )
            val missingProperties = requiredProperties.filter {
                keystoreProperties.getProperty(it).isNullOrBlank()
            }
            if (missingProperties.isNotEmpty()) {
                throw GradleException(
                    "Release signing is incomplete. Set: ${missingProperties.joinToString(", ")}."
                )
            }

            val configuredKeystore = file(keystoreProperties.getProperty("storeFile"))
            if (!configuredKeystore.isFile) {
                throw GradleException("The configured release keystore does not exist.")
            }
        }
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
