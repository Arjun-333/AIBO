package com.aibo.aibo

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

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
