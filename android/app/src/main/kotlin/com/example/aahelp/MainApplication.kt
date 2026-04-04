package com.example.aahelp

import android.app.Application
import android.util.Log
import com.yandex.mapkit.MapKitFactory

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        val apiKey = BuildConfig.YANDEX_MAPKIT_API_KEY
        if (apiKey.isBlank()) {
            Log.w("MainApplication", "YANDEX_MAPKIT_API_KEY is empty")
            return
        }

        MapKitFactory.setLocale("ru_RU")
        MapKitFactory.setApiKey(apiKey)
    }
}
