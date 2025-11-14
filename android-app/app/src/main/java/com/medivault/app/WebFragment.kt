package com.medivault.app

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import dev.hotwire.turbo.fragments.TurboWebFragment
import dev.hotwire.turbo.nav.TurboNavGraphDestination

@TurboNavGraphDestination(uri = "turbo://fragment/web")
class WebFragment : TurboWebFragment() {

    @SuppressLint("SetJavaScriptEnabled")
    override fun onViewCreated(view: android.view.View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Log.d("WebFragment", "onViewCreated called")
    }
}
