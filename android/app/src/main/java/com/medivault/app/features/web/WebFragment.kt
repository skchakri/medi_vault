package com.medivault.app.features.web

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import androidx.fragment.app.Fragment
import dev.hotwire.turbo.fragments.TurboWebFragment
import dev.hotwire.turbo.visit.TurboVisitOptions

class WebFragment : TurboWebFragment() {

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // Enable JavaScript (already enabled in Turbo by default)
        session.webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
        }
    }

    override fun onVisitCompleted(location: String, completedOffline: Boolean) {
        super.onVisitCompleted(location, completedOffline)
        // Handle visit completion if needed
    }

    override fun onVisitErrorReceived(location: String, errorCode: Int, description: String?) {
        super.onVisitErrorReceived(location, errorCode, description)
        // Handle errors - show error page or retry
    }

    override fun createErrorFragment(errorCode: Int): Fragment {
        return WebFragment()
    }
}
