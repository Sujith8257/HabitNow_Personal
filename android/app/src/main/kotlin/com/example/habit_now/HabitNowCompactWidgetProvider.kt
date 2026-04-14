package com.example.habit_now

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class HabitNowCompactWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.habit_now_widget_compact)
            val data = HomeWidgetPlugin.getData(context)
            val title = data.getString("widget_title", "HabitNow")
            val subtitle = data.getString("widget_subtitle", "0 pending - 0 completed")

            views.setTextViewText(R.id.widget_compact_title, title)
            views.setTextViewText(R.id.widget_compact_subtitle, subtitle)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
