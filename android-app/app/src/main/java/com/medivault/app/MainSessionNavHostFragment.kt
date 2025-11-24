package com.medivault.app

import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import dev.hotwire.turbo.config.TurboPathConfiguration
import dev.hotwire.turbo.session.TurboSessionNavHostFragment
import kotlin.reflect.KClass

class MainSessionNavHostFragment : TurboSessionNavHostFragment() {

    override val sessionName = "main"

    override val startLocation = MainActivity.BASE_URL

    override val registeredActivities: List<KClass<out AppCompatActivity>>
        get() = listOf(
            // Register any custom activities here
        )

    override val registeredFragments: List<KClass<out Fragment>>
        get() = listOf(
            WebFragment::class,
            // Register any custom fragments here
        )

    override val pathConfigurationLocation: TurboPathConfiguration.Location
        get() = TurboPathConfiguration.Location(
            assetFilePath = "json/configuration.json"
        )

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        Log.d("MainSessionNavHost", "onCreateView called")
        Log.d("MainSessionNavHost", "Start location: $startLocation")
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Log.d("MainSessionNavHost", "onViewCreated called")
        Log.d("MainSessionNavHost", "Session name: $sessionName")
    }

    override fun onSessionCreated() {
        super.onSessionCreated()

        // Setup file upload support
        session.webView.webChromeClient = object : WebChromeClient() {
            override fun onShowFileChooser(
                webView: WebView?,
                filePathCallback: ValueCallback<Array<Uri>>?,
                fileChooserParams: FileChooserParams?
            ): Boolean {
                val mainActivity = activity as? MainActivity
                return mainActivity?.handleFileChooser(filePathCallback, fileChooserParams) ?: false
            }
        }

        Log.d("MainSessionNavHost", "File upload support enabled")
    }
}
