package com.example.flixstar

import android.content.ContentUris
import android.content.Context
import android.media.tv.TvContract
import android.net.Uri
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class TvChannelManager(private val context: Context) {
    fun createChannel(call: MethodCall, result: MethodChannel.Result) {
        try {
            val channelId = call.argument<String>("channelId")!!
            val channelName = call.argument<String>("channelName")!!
            val channelDescription = call.argument<String>("channelDescription")!!

            val values = android.content.ContentValues().apply {
                put(TvContract.Channels.COLUMN_INPUT_ID, "flixstar_input")
                put(TvContract.Channels.COLUMN_DISPLAY_NAME, channelName)
                put(TvContract.Channels.COLUMN_DESCRIPTION, channelDescription)
                put(TvContract.Channels.COLUMN_INTERNAL_PROVIDER_ID, channelId)
                put(TvContract.Channels.COLUMN_TYPE, TvContract.Channels.TYPE_PREVIEW)
            }

            context.contentResolver.insert(TvContract.Channels.CONTENT_URI, values)
            result.success(null)
        } catch (e: Exception) {
            result.error("CREATE_CHANNEL_ERROR", e.message, null)
        }
    }

    fun updatePrograms(call: MethodCall, result: MethodChannel.Result) {
        try {
            val channelId = call.argument<String>("channelId")!!
            val programs = call.argument<List<Map<String, Any>>>("programs")!!

            // Clear existing programs
            context.contentResolver.delete(TvContract.PreviewPrograms.CONTENT_URI, null, null)

            // Add new programs
            for (program in programs) {
                val values = android.content.ContentValues().apply {
                    put(TvContract.PreviewPrograms.COLUMN_TITLE, program["title"] as String)
                    put(TvContract.PreviewPrograms.COLUMN_SHORT_DESCRIPTION, program["description"] as String)
                    put(TvContract.PreviewPrograms.COLUMN_POSTER_ART_URI, program["posterUrl"] as String)
                    put(TvContract.PreviewPrograms.COLUMN_INTENT_URI, program["intentUri"] as String)
                    put(TvContract.PreviewPrograms.COLUMN_INTERNAL_PROVIDER_ID, program["programId"] as String)
                    put(TvContract.PreviewPrograms.COLUMN_TYPE, TvContract.PreviewPrograms.TYPE_MOVIE)
                }

                context.contentResolver.insert(TvContract.PreviewPrograms.CONTENT_URI, values)
            }

            result.success(null)
        } catch (e: Exception) {
            result.error("UPDATE_PROGRAMS_ERROR", e.message, null)
        }
    }
} 