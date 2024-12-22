package com.example.flixstar

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        private const val CHANNEL = "flixstar/tv_channel"
    }
    
    private lateinit var tvChannelManager: TvChannelManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tvChannelManager = TvChannelManager(context)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createChannel" -> tvChannelManager.createChannel(call, result)
                "updatePrograms" -> tvChannelManager.updatePrograms(call, result)
                else -> result.notImplemented()
            }
        }
    }
} 