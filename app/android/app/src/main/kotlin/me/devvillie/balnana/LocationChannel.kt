package me.devvillie.balnana

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// Plugins ask for permissions through this activity too, and their results
// come back here as well: flutter_local_notifications asks for notifications
// with request code 1. This one is the app's own.
private const val LOCATION_REQUEST = 0xBA1
private const val LOCATION_WAIT_MS = 15_000L
private const val LAST_KNOWN_MAX_AGE_MS = 10 * 60_000L

/** Owns one location lookup at a time for the attached Flutter engine. */
internal class LocationChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "balnana/location")
    private val handler = Handler(Looper.getMainLooper())
    private val waiting = mutableListOf<MethodChannel.Result>()
    private var stopLookup: (() -> Unit)? = null

    init {
        channel.setMethodCallHandler { call, result ->
            if (call.method != "current") return@setMethodCallHandler result.notImplemented()
            waiting.add(result)
            if (waiting.size > 1) return@setMethodCallHandler
            if (hasPermission()) {
                locate()
            } else {
                activity.requestPermissions(
                    arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION),
                    LOCATION_REQUEST,
                )
            }
        }
    }

    fun permissionResult(requestCode: Int) {
        if (requestCode != LOCATION_REQUEST || waiting.isEmpty()) return
        if (hasPermission()) locate() else finish(null, "denied")
    }

    fun close() {
        channel.setMethodCallHandler(null)
        finish(null)
    }

    private fun granted(permission: String) =
        activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    private fun hasPermission() =
        granted(Manifest.permission.ACCESS_COARSE_LOCATION) || granted(Manifest.permission.ACCESS_FINE_LOCATION)

    @SuppressLint("MissingPermission")
    private fun locate() {
        val manager = activity.getSystemService(LocationManager::class.java) ?: return finish(null)
        val providers = buildList {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) add(LocationManager.FUSED_PROVIDER)
            add(LocationManager.NETWORK_PROVIDER)
            if (granted(Manifest.permission.ACCESS_FINE_LOCATION)) add(LocationManager.GPS_PROVIDER)
        }.filter { it in manager.allProviders && manager.isProviderEnabled(it) }
        val provider = providers.firstOrNull() ?: return finish(null, "off")

        fun recent(): Location? = providers.mapNotNull { manager.getLastKnownLocation(it) }
            .filter { System.currentTimeMillis() - it.time < LAST_KNOWN_MAX_AGE_MS }
            .maxByOrNull { it.time }

        // Only the active lookup may reply. An old callback can already be
        // queued when a lookup times out and the user asks again.
        lateinit var stop: () -> Unit
        fun complete(location: Location?) {
            if (stopLookup !== stop) return
            try {
                finish(location ?: recent())
            } catch (_: SecurityException) {
                finish(null, "denied")
            } catch (_: IllegalArgumentException) {
                finish(null, "off")
            }
        }
        val timeout = Runnable { complete(null) }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val cancel = CancellationSignal()
                stop = {
                    handler.removeCallbacks(timeout)
                    cancel.cancel()
                }
                stopLookup = stop
                manager.getCurrentLocation(provider, cancel, activity.mainExecutor, ::complete)
            } else {
                val listener = object : LocationListener {
                    override fun onLocationChanged(location: Location) = complete(location)

                    @Deprecated("Deprecated in Java")
                    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}

                    override fun onProviderEnabled(provider: String) {}
                    override fun onProviderDisabled(provider: String) {}
                }
                stop = {
                    handler.removeCallbacks(timeout)
                    manager.removeUpdates(listener)
                }
                stopLookup = stop
                @Suppress("DEPRECATION")
                manager.requestSingleUpdate(provider, listener, Looper.getMainLooper())
            }
            if (stopLookup === stop) handler.postDelayed(timeout, LOCATION_WAIT_MS)
        } catch (_: SecurityException) {
            finish(null, "denied")
        } catch (_: IllegalArgumentException) {
            finish(null, "off")
        }
    }

    private fun finish(location: Location?, error: String = "unavailable") {
        val stop = stopLookup
        stopLookup = null
        try {
            stop?.invoke()
        } catch (_: SecurityException) {
            // Permission can be revoked while a lookup is running.
        }
        val results = waiting.toList()
        waiting.clear()
        for (result in results) {
            if (location == null) {
                result.error(error, null, null)
            } else {
                result.success(mapOf("latitude" to location.latitude, "longitude" to location.longitude))
            }
        }
    }
}
