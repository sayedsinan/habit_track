package com.example.habit_builder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class MinimalWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout_minimal).apply {
                
                // Read data passed from Flutter
                val progressPercent = widgetData.getInt("progressPercent", 0)
                val nextTask = widgetData.getString("nextTask", "Mission Control")

                // Set text views and progress bar
                setTextViewText(R.id.widget_progress, "${progressPercent}%")
                setTextViewText(R.id.widget_title, nextTask)
                setProgressBar(R.id.widget_progress_bar, 100, progressPercent, false)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
