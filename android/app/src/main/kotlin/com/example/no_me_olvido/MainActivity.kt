package com.example.no_me_olvido

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.nomeolvido/vibrator"
    private var vibrator: Vibrator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Inicializar el vibrator según la versión de Android
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibrator = vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    try {
                        val pattern = call.argument<LongArray>("pattern")
                        val repeat = call.argument<Int>("repeat") ?: -1
                        
                        if (pattern != null && vibrator != null) {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                vibrator?.vibrate(VibrationEffect.createWaveform(pattern, repeat))
                            } else {
                                @Suppress("DEPRECATION")
                                vibrator?.vibrate(pattern, repeat)
                            }
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENTS", "Pattern is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("VIBRATION_ERROR", e.message, null)
                    }
                }
                "cancel" -> {
                    try {
                        vibrator?.cancel()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                "openVibrationSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_SOUND_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("OPEN_SETTINGS_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
