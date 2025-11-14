package com.medivault.app

import android.app.Application
import dev.hotwire.turbo.config.TurboPathConfiguration
import dev.hotwire.turbo.session.TurboSessionNavHostFragment

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Initialize Turbo with path configuration
        TurboSessionNavHostFragment.pathConfiguration = TurboPathConfiguration(
            context = this
        )
    }
}
