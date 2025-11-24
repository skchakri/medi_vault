package com.medivault.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    private lateinit var fileChooserDelegate: FileChooserDelegate
    private lateinit var fileChooserLauncher: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Enable debugging in development
        WebView.setWebContentsDebuggingEnabled(true)

        // Setup file chooser
        setupFileChooser()
    }

    private fun setupFileChooser() {
        // Register activity result launcher
        fileChooserLauncher = registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { result ->
            fileChooserDelegate.onActivityResult(result.resultCode, result.data)
        }

        // Create file chooser delegate
        fileChooserDelegate = FileChooserDelegate(this, fileChooserLauncher)
    }

    fun handleFileChooser(
        filePathCallback: ValueCallback<Array<Uri>>?,
        fileChooserParams: WebChromeClient.FileChooserParams?
    ): Boolean {
        return fileChooserDelegate.onShowFileChooser(filePathCallback, fileChooserParams)
    }

    override fun onDestroy() {
        super.onDestroy()
        fileChooserDelegate.cancelCallback()
    }

    companion object {
        // For Android Emulator (10.0.2.2 is the special IP for host machine's localhost)
        // NOTE: localhost won't work on Android - use 10.0.2.2 instead
        // const val BASE_URL = "http://10.0.2.2:3000"

        // For physical device on same WiFi network, use your computer's IP:
        const val BASE_URL = "http://192.168.1.144:3000"

        // For production:
        // const val BASE_URL = "https://your-production-url.com"
    }
}
