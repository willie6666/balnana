package me.devvillie.balnana

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Resources
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val LOCATION_REQUEST = 1
private const val LOCATION_WAIT_MS = 15_000L
private const val LAST_KNOWN_MAX_AGE_MS = 10 * 60_000L

class MainActivity : FlutterActivity() {
    private val handler = Handler(Looper.getMainLooper())
    private var locationResult: MethodChannel.Result? = null
    private var locationTimeout: Runnable? = null

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
        // The device's position, read once when the person taps "Use current
        // location". LocationManager rather than Play Services keeps the app
        // free of proprietary libraries.
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, "balnana/location").setMethodCallHandler { call, result ->
            if (call.method != "current") return@setMethodCallHandler result.notImplemented()
            if (locationResult != null) return@setMethodCallHandler result.error("busy", null, null)
            locationResult = result
            if (granted(Manifest.permission.ACCESS_COARSE_LOCATION) ||
                granted(Manifest.permission.ACCESS_FINE_LOCATION)
            ) {
                locate()
            } else {
                requestPermissions(
                    arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION),
                    LOCATION_REQUEST,
                )
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != LOCATION_REQUEST) return
        if (grantResults.any { it == PackageManager.PERMISSION_GRANTED }) locate() else sendLocation(null, "denied")
    }

    private fun granted(permission: String) = checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    @SuppressLint("MissingPermission")
    private fun locate() {
        val manager = getSystemService(LocationManager::class.java)
        val providers = buildList {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) add(LocationManager.FUSED_PROVIDER)
            add(LocationManager.NETWORK_PROVIDER)
            if (granted(Manifest.permission.ACCESS_FINE_LOCATION)) add(LocationManager.GPS_PROVIDER)
        }.filter { it in manager.allProviders && manager.isProviderEnabled(it) }
        val provider = providers.firstOrNull() ?: return sendLocation(null, "off")
        // A position the device found a few minutes ago beats none at all.
        val recent = {
            providers.mapNotNull { manager.getLastKnownLocation(it) }
                .filter { System.currentTimeMillis() - it.time < LAST_KNOWN_MAX_AGE_MS }
                .maxByOrNull { it.time }
        }
        val timeout: Runnable
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val cancel = CancellationSignal()
            manager.getCurrentLocation(provider, cancel, mainExecutor) { sendLocation(it ?: recent()) }
            timeout = Runnable {
                cancel.cancel()
                sendLocation(recent())
            }
        } else {
            // Every method is spelled out: before Android 11 the interface
            // has no default ones, and the system calls them all.
            val listener = object : LocationListener {
                override fun onLocationChanged(location: Location) = sendLocation(location)

                @Deprecated("Deprecated in Java")
                override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}

                override fun onProviderEnabled(provider: String) {}

                override fun onProviderDisabled(provider: String) {}
            }
            @Suppress("DEPRECATION")
            manager.requestSingleUpdate(provider, listener, Looper.getMainLooper())
            timeout = Runnable {
                manager.removeUpdates(listener)
                sendLocation(recent())
            }
        }
        locationTimeout = timeout
        handler.postDelayed(timeout, LOCATION_WAIT_MS)
    }

    private fun sendLocation(location: Location?, error: String = "unavailable") {
        val result = locationResult ?: return
        locationResult = null
        locationTimeout?.let { handler.removeCallbacks(it) }
        locationTimeout = null
        if (location == null) {
            result.error(error, null, null)
        } else {
            result.success(mapOf("latitude" to location.latitude, "longitude" to location.longitude))
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
