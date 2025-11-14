package com.medivault.app

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import dev.hotwire.turbo.config.TurboPathConfiguration
import dev.hotwire.turbo.session.TurboSessionNavHostFragment

class MainActivity : AppCompatActivity() {
    private lateinit var navHostFragment: TurboSessionNavHostFragment

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        navHostFragment = supportFragmentManager.findFragmentById(R.id.nav_host_fragment) as TurboSessionNavHostFragment

        // Load path configuration
        TurboSessionNavHostFragment.pathConfiguration = TurboPathConfiguration(this)

        // Set the base URL - CHANGE THIS TO YOUR SERVER URL
        // For local development: http://10.0.2.2:3000 (Android emulator)
        // For production: https://your-domain.com
        val baseUrl = BuildConfig.DEBUG.let { debug ->
            if (debug) {
                // Use 10.0.2.2 to access localhost from Android emulator
                // Use your computer's IP address (e.g., 192.168.1.100:3000) for physical device
                "http://10.0.2.2:3000"
            } else {
                "https://medivault.com"
            }
        }

        if (savedInstanceState == null) {
            navHostFragment.session.visit(baseUrl)
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        return navHostFragment.navController.navigateUp() || super.onSupportNavigateUp()
    }

    override fun onBackPressed() {
        if (!navHostFragment.session.navigator.pop()) {
            super.onBackPressed()
        }
    }
}
