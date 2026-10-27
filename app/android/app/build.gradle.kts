import java.net.URI
import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: android/key.properties (kept out of git) names the upload
// keystore. Without it, release APKs are signed with the debug key, with a
// warning, so `flutter run --release` still works; such builds cannot update
// an installed release. App bundles are only for the Play Store, so they need
// the real key. See README.md, "Android release builds".
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null

gradle.taskGraph.whenReady {
    if (hasReleaseKey) return@whenReady
    // This app's own tasks: plugin modules run bundleLib*Release tasks for
    // APKs too.
    val names = allTasks.filter { it.project == project }.map { it.name }
    if (names.any { it.startsWith("bundle") && !it.startsWith("bundleLib") && it.endsWith("Release") }) {
        throw GradleException(
            "No release key: create android/key.properties (README.md, \"Android release builds\") " +
                "before building an app bundle."
        )
    }
    if (names.any { it.startsWith("assemble") && it.endsWith("Release") }) {
        logger.warn("WARNING: android/key.properties is missing, so this release APK is signed with the debug key.")
    }
}

// Links to the server a build is made for open in the app (Android App
// Links). The server is the one baked in with
// --dart-define=BALNANA_SERVER_URL=https://..., which also makes it the app's
// default server. Builds without one leave links to the browser.
val dartDefines: Map<String, String> =
    (project.findProperty("dart-defines") as String?)
        ?.split(",")
        ?.mapNotNull { encoded ->
            String(Base64.getDecoder().decode(encoded)).split("=", limit = 2)
                .takeIf { it.size == 2 }
                ?.let { it[0] to it[1] }
        }
        ?.toMap() ?: emptyMap()
val linkServer: URI? =
    dartDefines["BALNANA_SERVER_URL"]?.trim()?.takeIf { it.isNotEmpty() }
        ?.let { URI(if ("://" in it) it else "https://$it") }
        ?.takeIf { (it.scheme == "https" || it.scheme == "http") && !it.host.isNullOrEmpty() }

android {
    namespace = "io.github.willie6666.balnana"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications uses java.time, which older Androids lack.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "io.github.willie6666.balnana"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Used by src/applinks/AndroidManifest.xml.
        manifestPlaceholders["balnanaLinkScheme"] = linkServer?.scheme ?: ""
        manifestPlaceholders["balnanaLinkHost"] = linkServer?.host ?: ""
        manifestPlaceholders["balnanaLinkPath"] = linkServer?.path?.trimEnd('/') ?: ""
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
        }
    }
}

androidComponents {
    onVariants { variant ->
        if (linkServer != null) variant.sources.manifests.addStaticManifestFile("src/applinks/AndroidManifest.xml")
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

dependencies {
    // Push notifications without a separate distributor app (UnifiedPush):
    // phones with Google Play services get them through FCM, with no
    // Firebase SDK in the app. Phones with a distributor such as ntfy use it
    // instead.
    implementation("org.unifiedpush.android:embedded-fcm-distributor:3.1.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
