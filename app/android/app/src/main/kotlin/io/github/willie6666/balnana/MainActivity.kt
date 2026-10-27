package io.github.willie6666.balnana

import android.content.Intent
import android.content.res.Resources
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        intent = withWholeLink(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(withWholeLink(intent))
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The system draws the splash screen before the app runs, so the app
        // tells it ahead of time which colors the next launch opens in.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "balnana/splash").setMethodCallHandler { call, result ->
            if (call.method != "setWallpaper") return@setMethodCallHandler result.notImplemented()
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                return@setMethodCallHandler result.error("unsupported", null, null)
            }
            val theme = if (call.arguments == true) R.style.LaunchTheme_Wallpaper else Resources.ID_NULL
            splashScreen.setSplashScreenTheme(theme)
            result.success(null)
        }
    }

    /**
     * Flutter hands the app only a link's path. A web link (an App Link to
     * this build's server) becomes balnana://app/link?url=<the link>, so the
     * app sees which server it is for before it uses the secret in it.
     */
    private fun withWholeLink(intent: Intent): Intent {
        val data = intent.data ?: return intent
        if (intent.action != Intent.ACTION_VIEW || (data.scheme != "https" && data.scheme != "http")) return intent
        val route = Uri.Builder()
            .scheme("balnana")
            .authority("app")
            .path("/link")
            .appendQueryParameter("url", data.toString())
            .build()
        return Intent(intent).setData(route)
    }
}
