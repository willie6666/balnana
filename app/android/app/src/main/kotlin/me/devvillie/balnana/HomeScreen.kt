package me.devvillie.balnana

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

// Launchers show four or five; HomeScreen.shortcuts in Dart says the same.
private const val SHORTCUTS = 4

/** A group as the app last worded it for the home screen. */
data class HomeGroup(val token: String, val name: String, val balance: String, val tone: Int, val shortcut: String)

/**
 * The app icon's shortcuts and the group widget, which Android draws while
 * the app is not running. The app hands over its groups, worded and
 * formatted in its language, on "balnana/home"; they are kept here for the
 * widget and its picker.
 */
object HomeScreen {
    private const val PREFS = "balnana_home"

    fun listen(context: Context, messenger: BinaryMessenger) {
        MethodChannel(messenger, "balnana/home").setMethodCallHandler { call, result ->
            if (call.method == "clear") {
                val saved = prefs(context)
                val edit = saved.edit().remove("server")
                for (key in saved.all.keys) if (key.startsWith("groups.")) edit.remove(key)
                edit.apply()
                renderAll(context)
                setShortcuts(context, "", emptyList())
                return@setMethodCallHandler result.success(null)
            }
            if (call.method != "update") return@setMethodCallHandler result.notImplemented()
            val server = call.argument<String>("server") ?: return@setMethodCallHandler result.error("server", null, null)
            val list = JSONArray(call.argument<List<Map<String, Any>>>("groups") ?: emptyList<Map<String, Any>>())
            val labels = JSONObject(call.argument<Map<String, String>>("labels") ?: emptyMap<String, String>())
            prefs(context).edit()
                .putString("server", server)
                .putString("groups.$server", list.toString())
                .putString("labels", labels.toString())
                .apply()
            renderAll(context)
            setShortcuts(context, server, groups(context, server))
            result.success(null)
        }
    }

    fun prefs(context: Context): SharedPreferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /** The server the app talks to now, whose groups a new widget may show. */
    fun server(context: Context): String? = prefs(context).getString("server", null)

    /**
     * What the app words [name] as. [fallback] is for a widget placed before
     * the app was ever opened, when there is nothing in its language yet.
     */
    fun label(context: Context, name: String, fallback: String): String =
        prefs(context).getString("labels", null)?.let { JSONObject(it).optString(name) }?.ifEmpty { null } ?: fallback

    fun groups(context: Context, server: String): List<HomeGroup> {
        val json = JSONArray(prefs(context).getString("groups.$server", null) ?: return emptyList())
        return (0 until json.length()).map { i ->
            val g = json.getJSONObject(i)
            HomeGroup(g.getString("token"), g.getString("name"), g.getString("balance"), g.getInt("tone"), g.getString("shortcut"))
        }
    }

    /** Has widget [id] show [group] of [server] from now on. */
    fun pick(context: Context, id: Int, server: String, group: HomeGroup) {
        val target = JSONObject().put("server", server).put("token", group.token).put("name", group.name)
        prefs(context).edit().putString("widget.$id", target.toString()).apply()
        render(context, AppWidgetManager.getInstance(context), id)
    }

    fun forget(context: Context, ids: IntArray) {
        val edit = prefs(context).edit()
        for (id in ids) edit.remove("widget.$id")
        edit.apply()
    }

    fun renderAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        for (id in manager.getAppWidgetIds(ComponentName(context, GroupWidget::class.java))) render(context, manager, id)
    }

    /**
     * Draws widget [id]: the group's name and this device's balance in it,
     * in the colour for owed, owing or settled. A tap opens the group; "+"
     * opens a new expense in it.
     */
    fun render(context: Context, manager: AppWidgetManager, id: Int) {
        val target = prefs(context).getString("widget.$id", null)?.let(::JSONObject) ?: return
        val server = target.getString("server")
        val token = target.getString("token")
        // A previous account's group must not keep showing on the launcher.
        val group = groups(context, server).firstOrNull { it.token == token }
        val views = RemoteViews(context.packageName, R.layout.group_widget)
        views.setTextViewText(R.id.name, group?.name ?: label(context, "empty", "Open Balnana and add a group first."))
        val tones = mapOf(1 to R.id.balance_owed, -1 to R.id.balance_owe, 0 to R.id.balance_settled)
        for ((tone, view) in tones) {
            val shown = group != null && group.tone == tone
            views.setViewVisibility(view, if (shown) View.VISIBLE else View.GONE)
            if (shown) views.setTextViewText(view, group!!.balance)
        }
        views.setContentDescription(R.id.add, label(context, "add", "Add expense"))
        views.setOnClickPendingIntent(R.id.open, pending(context, 2 * id, open(context, server, token, add = false)))
        views.setOnClickPendingIntent(R.id.add, pending(context, 2 * id + 1, open(context, server, token, add = true)))
        manager.updateAppWidget(id, views)
    }

    /** balnana://app/open, which the app opens only for the server it uses. */
    private fun open(context: Context, server: String, token: String, add: Boolean): Intent {
        val uri = Uri.Builder()
            .scheme("balnana")
            .authority("app")
            .path("/open")
            .appendQueryParameter("server", server)
            .appendQueryParameter("token", token)
            .apply { if (add) appendQueryParameter("add", "1") }
            .build()
        return Intent(Intent.ACTION_VIEW, uri, context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    }

    private fun pending(context: Context, code: Int, intent: Intent) =
        PendingIntent.getActivity(context, code, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

    /** "Add expense in …" for the first groups, in the order the app shows them. */
    private fun setShortcuts(context: Context, server: String, groups: List<HomeGroup>) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) return
        val manager = context.getSystemService(ShortcutManager::class.java) ?: return
        val icon = Icon.createWithResource(context, R.drawable.ic_shortcut_add)
        manager.dynamicShortcuts = groups.take(minOf(SHORTCUTS, manager.maxShortcutCountPerActivity)).map { g ->
            ShortcutInfo.Builder(context, "add:${g.token}")
                .setShortLabel(g.name)
                .setLongLabel(g.shortcut)
                .setIcon(icon)
                .setIntent(open(context, server, g.token, add = true))
                .build()
        }
    }
}
