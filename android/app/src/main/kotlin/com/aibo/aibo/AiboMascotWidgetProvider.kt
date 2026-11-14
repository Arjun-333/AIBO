package com.aibo.aibo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Android Home Screen Widget for AIBO featuring Muchi Neko mascot.
 * Like Duolingo, the mascot updates its expression, speech bubble, and reminders
 * directly on the user's home screen.
 */
class AiboMascotWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "AiboWidgetPrefs"

        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val dateJa = prefs.getString("date_ja", "2026年11月14日 (土)") ?: ""
            val nextMed = prefs.getString("next_med", "None pending (完了)") ?: ""
            val spentToday = prefs.getString("spent_today", "¥0") ?: "¥0"
            val trashAlert = prefs.getString("trash_alert", "Check schedule") ?: ""
            val muchiMood = prefs.getString("muchi_mood", "happy") ?: "happy"
            val muchiSpeech = prefs.getString("muchi_speech", "Life in Japan is peaceful today nya~") ?: ""

            val views = RemoteViews(context.packageName, R.layout.aibo_mascot_widget)

            // Dynamic mascot speech bubble (Duolingo style)
            views.setTextViewText(R.id.widget_mascot_speech, muchiSpeech)
            views.setTextViewText(R.id.widget_date_text, dateJa)
            views.setTextViewText(R.id.widget_med_text, "💊 $nextMed")
            views.setTextViewText(R.id.widget_spent_text, "💴 $spentToday spent")
            views.setTextViewText(R.id.widget_trash_text, "🗑️ $trashAlert")

            // Mascot mood icon / avatar
            val mascotEmoji = when (muchiMood) {
                "celebrate" -> "🐱✨"
                "urgent" -> "🙀⚠️"
                "reminder" -> "😼📢"
                "sleepy" -> "😸💤"
                else -> "😽🍵"
            }
            views.setTextViewText(R.id.widget_mascot_avatar, mascotEmoji)

            // Click action: tap widget to open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root_layout, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
