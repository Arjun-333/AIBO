package com.aibo.aibo

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val WIDGET_CHANNEL = "com.aibo.aibo/widget"
    private val PREFS_NAME = "AiboWidgetPrefs"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateAppWidget") {
                val args = call.arguments as? Map<String, Any>
                if (args != null) {
                    val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    val editor = prefs.edit()
                    for ((k, v) in args) {
                        editor.putString(k, v.toString())
                    }
                    editor.apply()

                    // Broadcast update to all AIBO Home Screen widgets
                    try {
                        val intent = Intent(this, AiboMascotWidgetProvider::class.java).apply {
                            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                            val appWidgetManager = AppWidgetManager.getInstance(this@MainActivity)
                            val componentName = ComponentName(this@MainActivity, AiboMascotWidgetProvider::class.java)
                            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                        }
                        sendBroadcast(intent)
                    } catch (e: Exception) {
                        // Safe fallback if widget not currently placed on home screen
                    }

                    result.success(true)
                } else {
                    result.error("INVALID_ARGS", "Widget data payload was null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
