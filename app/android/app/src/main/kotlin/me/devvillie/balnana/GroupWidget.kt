package me.devvillie.balnana

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.ListView
import android.widget.TextView

/** One group on the home screen; see [HomeScreen.render]. */
class GroupWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) HomeScreen.render(context, manager, id)
    }

    override fun onDeleted(context: Context, ids: IntArray) = HomeScreen.forget(context, ids)
}

/**
 * Asks which group a widget shows, when it is placed or, from Android 12,
 * changed. Lists the groups the app last showed, worded by the app.
 */
class GroupWidgetPicker : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val id = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        // Backing out leaves no widget behind.
        setResult(RESULT_CANCELED, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id))
        if (id == AppWidgetManager.INVALID_APPWIDGET_ID) return finish()

        val server = HomeScreen.server(this)
        val groups = server?.let { HomeScreen.groups(this, it) }.orEmpty()
        title = HomeScreen.label(this, "pick", "Show which group?")
        if (server == null || groups.isEmpty()) {
            val padding = (24 * resources.displayMetrics.density).toInt()
            setContentView(TextView(this).apply {
                text = HomeScreen.label(this@GroupWidgetPicker, "empty", "Open Balnana and add a group first.")
                setPadding(padding, padding, padding, padding)
            })
            return
        }
        setContentView(ListView(this).apply {
            adapter = ArrayAdapter(this@GroupWidgetPicker, android.R.layout.simple_list_item_1, groups.map { it.name })
            setOnItemClickListener { _, _, position, _ ->
                HomeScreen.pick(this@GroupWidgetPicker, id, server, groups[position])
                setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id))
                finish()
            }
        })
    }
}
