pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    // Le projet exige un JDK 17 (voir compileOptions dans app/build.gradle.kts).
    // Sans ce résolveur, Gradle refuse de télécharger un JDK manquant côté
    // machine : c'est l'erreur « Toolchain download repositories have not
    // been configured » qu'on obtient sinon.
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

include(":app")
