import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Signature release : secrets EXTERNES, jamais versionnés.
// Source 1 : android/key.properties (ignoré par Git) contenant
//   storeFile=/chemin/absolu/vers/release.jks
//   storePassword=…  keyAlias=…  keyPassword=…
// Source 2 : variables d'environnement CYBERLAB_STORE_FILE,
//   CYBERLAB_STORE_PASSWORD, CYBERLAB_KEY_ALIAS, CYBERLAB_KEY_PASSWORD.
// Aucune clé n'est générée ni remplacée automatiquement. Sans ces secrets,
// la variante release est signée avec la clé DEBUG : l'APK obtenu est un
// APK DE TEST, non distribuable en production.
// ---------------------------------------------------------------------------
val keyProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) FileInputStream(f).use { load(it) }
}
fun signingValue(prop: String, env: String): String? =
    (keyProps.getProperty(prop) ?: System.getenv(env))?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("storeFile", "CYBERLAB_STORE_FILE")
val releaseStorePassword = signingValue("storePassword", "CYBERLAB_STORE_PASSWORD")
val releaseKeyAlias = signingValue("keyAlias", "CYBERLAB_KEY_ALIAS")
val releaseKeyPassword = signingValue("keyPassword", "CYBERLAB_KEY_PASSWORD")
val hasReleaseSigning = listOf(
    releaseStoreFile, releaseStorePassword, releaseKeyAlias, releaseKeyPassword,
).all { it != null } && file(releaseStoreFile!!).exists()

if (!hasReleaseSigning) {
    logger.warn(
        "CyberLab Agent : aucune clé de signature de production trouvée " +
            "(android/key.properties ou CYBERLAB_*). La variante release sera " +
            "signée avec la clé DEBUG -> APK DE TEST uniquement."
    )
}

android {
    namespace = "com.cyberlab.cyberlab_agent"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // applicationId conservé : l'application a déjà été distribuée sous cet
        // identifiant ; le changer créerait une application distincte.
        applicationId = "com.cyberlab.cyberlab_agent"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // APK DE TEST : signature debug, non destinée à la production.
                signingConfigs.getByName("debug")
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
