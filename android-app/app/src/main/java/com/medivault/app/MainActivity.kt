package com.medivault.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat

class MainActivity : AppCompatActivity() {

    private lateinit var fileChooserDelegate: FileChooserDelegate
    private lateinit var fileChooserLauncher: ActivityResultLauncher<Intent>
    private lateinit var permissionLauncher: ActivityResultLauncher<Array<String>>

    private var pendingFileChooserCallback: ValueCallback<Array<Uri>>? = null
    private var pendingFileChooserParams: WebChromeClient.FileChooserParams? = null

    companion object {
        private const val TAG = "MainActivity"

        // For Android Emulator (10.0.2.2 is the special IP for host machine's localhost)
        // NOTE: localhost won't work on Android - use 10.0.2.2 instead
        // const val BASE_URL = "http://10.0.2.2:3000"

        // For physical device on same WiFi network, use your computer's IP:
        const val BASE_URL = "http://192.168.1.144:3000"

        // For production:
        // const val BASE_URL = "https://your-production-url.com"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Enable debugging in development
        WebView.setWebContentsDebuggingEnabled(true)

        // Setup permissions
        setupPermissions()

        // Setup file chooser
        setupFileChooser()
    }

    private fun setupPermissions() {
        Log.d(TAG, "Setting up permissions")
        // Register permission request launcher
        permissionLauncher = registerForActivityResult(
            ActivityResultContracts.RequestMultiplePermissions()
        ) { permissions ->
            Log.d(TAG, "Permission result received: $permissions")
            val allGranted = permissions.values.all { it }

            if (allGranted) {
                Log.d(TAG, "All permissions granted, proceeding with file chooser")
                // Permissions granted, proceed with file chooser
                pendingFileChooserCallback?.let { callback ->
                    fileChooserDelegate.onShowFileChooser(callback, pendingFileChooserParams)
                }
                pendingFileChooserCallback = null
                pendingFileChooserParams = null
            } else {
                Log.w(TAG, "Some permissions denied: $permissions")
                // Permissions denied, show message
                Toast.makeText(
                    this,
                    "Camera and storage permissions are required to upload photos",
                    Toast.LENGTH_LONG
                ).show()
                pendingFileChooserCallback?.onReceiveValue(null)
                pendingFileChooserCallback = null
                pendingFileChooserParams = null
            }
        }
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
        Log.d(TAG, "handleFileChooser called")
        Log.d(TAG, "Accept types: ${fileChooserParams?.acceptTypes?.joinToString()}")

        // Check if we need to request permissions
        if (!hasRequiredPermissions()) {
            Log.d(TAG, "Permissions not granted, requesting permissions")
            // Store callbacks for later
            pendingFileChooserCallback = filePathCallback
            pendingFileChooserParams = fileChooserParams

            // Request permissions
            requestRequiredPermissions()
            return true
        }

        Log.d(TAG, "Permissions already granted, proceeding with file chooser")
        // Permissions already granted, proceed with file chooser
        return fileChooserDelegate.onShowFileChooser(filePathCallback, fileChooserParams)
    }

    private fun hasRequiredPermissions(): Boolean {
        val permissions = getRequiredPermissions()
        Log.d(TAG, "Checking permissions: $permissions")

        val granted = permissions.all { permission ->
            val result = ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
            Log.d(TAG, "Permission $permission: ${if (result) "GRANTED" else "DENIED"}")
            result
        }

        Log.d(TAG, "All permissions granted: $granted")
        return granted
    }

    private fun requestRequiredPermissions() {
        val permissions = getRequiredPermissions()
        Log.d(TAG, "Requesting permissions: $permissions")
        Log.d(TAG, "Android version: ${Build.VERSION.SDK_INT}")
        permissionLauncher.launch(permissions.toTypedArray())
        Log.d(TAG, "Permission launcher called")
    }

    private fun getRequiredPermissions(): List<String> {
        val permissions = mutableListOf(Manifest.permission.CAMERA)

        // For Android 13+ (API 33+), use granular media permissions
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.READ_MEDIA_IMAGES)
        } else {
            // For older versions, use READ_EXTERNAL_STORAGE
            permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
        }

        Log.d(TAG, "Required permissions for SDK ${Build.VERSION.SDK_INT}: $permissions")
        return permissions
    }

    override fun onDestroy() {
        super.onDestroy()
        fileChooserDelegate.cancelCallback()
    }
}
