package com.medivault.app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import androidx.activity.result.ActivityResultLauncher
import androidx.core.content.FileProvider
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class FileChooserDelegate(
    private val activity: Activity,
    private val fileChooserLauncher: ActivityResultLauncher<Intent>
) {
    private var filePathCallback: ValueCallback<Array<Uri>>? = null
    private var cameraPhotoUri: Uri? = null

    companion object {
        private const val TAG = "FileChooserDelegate"
    }

    fun onShowFileChooser(
        filePathCallback: ValueCallback<Array<Uri>>?,
        fileChooserParams: WebChromeClient.FileChooserParams?
    ): Boolean {
        Log.d(TAG, "onShowFileChooser called")
        // Cancel any previous callbacks
        this.filePathCallback?.onReceiveValue(null)
        this.filePathCallback = filePathCallback

        val acceptTypes = fileChooserParams?.acceptTypes?.joinToString(",") ?: "*/*"
        val captureEnabled = fileChooserParams?.isCaptureEnabled ?: false
        Log.d(TAG, "Accept types: $acceptTypes, Capture enabled: $captureEnabled")

        try {
            val chooserIntent = createChooserIntent(acceptTypes, captureEnabled)
            Log.d(TAG, "Launching file chooser intent")
            fileChooserLauncher.launch(chooserIntent)
            Log.d(TAG, "File chooser launched successfully")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error launching file chooser", e)
            this.filePathCallback?.onReceiveValue(null)
            this.filePathCallback = null
            return false
        }
    }

    private fun createChooserIntent(acceptTypes: String, captureEnabled: Boolean): Intent {
        Log.d(TAG, "Creating chooser intent for accept types: $acceptTypes")
        val intents = mutableListOf<Intent>()

        // Always add camera intent when accepting images
        // This ensures camera option is available on mobile devices
        if (acceptTypes.contains("image") || acceptTypes == "*/*") {
            Log.d(TAG, "Accept types include images, attempting to add camera intent")
            val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            if (cameraIntent.resolveActivity(activity.packageManager) != null) {
                Log.d(TAG, "Camera app available, creating image URI")
                cameraPhotoUri = createImageUri()
                cameraPhotoUri?.let {
                    Log.d(TAG, "Image URI created: $it")
                    cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, it)
                    intents.add(cameraIntent)
                    Log.d(TAG, "Camera intent added to chooser")
                } ?: Log.w(TAG, "Failed to create image URI")
            } else {
                Log.w(TAG, "No camera app available on device")
            }
        } else {
            Log.d(TAG, "Accept types don't include images, skipping camera intent")
        }

        // Add file picker intent
        val filePickerIntent = Intent(Intent.ACTION_GET_CONTENT).apply {
            type = when {
                acceptTypes.contains("image") -> "image/*"
                acceptTypes.contains("application/pdf") -> "application/pdf"
                acceptTypes.contains("application") -> "application/*"
                else -> "*/*"
            }
            addCategory(Intent.CATEGORY_OPENABLE)
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        }

        return if (intents.isEmpty()) {
            Log.d(TAG, "No camera intent, returning file picker only")
            filePickerIntent
        } else {
            Log.d(TAG, "Creating chooser with ${intents.size} additional intent(s) (camera)")
            Intent.createChooser(filePickerIntent, "Choose File or Take Photo").apply {
                putExtra(Intent.EXTRA_INITIAL_INTENTS, intents.toTypedArray())
            }
        }
    }

    private fun createImageUri(): Uri? {
        return try {
            val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
            val imageFileName = "MEDIVAULT_$timeStamp.jpg"
            val storageDir = activity.cacheDir
            val imageFile = File(storageDir, imageFileName)

            FileProvider.getUriForFile(
                activity,
                "${activity.packageName}.fileprovider",
                imageFile
            )
        } catch (e: Exception) {
            null
        }
    }

    fun onActivityResult(resultCode: Int, data: Intent?) {
        val callback = filePathCallback ?: return
        filePathCallback = null

        if (resultCode != Activity.RESULT_OK) {
            callback.onReceiveValue(null)
            return
        }

        val results = mutableListOf<Uri>()

        // Check if a photo was taken with the camera
        cameraPhotoUri?.let { uri ->
            if (data == null || data.data == null) {
                // Camera photo was taken
                results.add(uri)
            }
        }

        // Handle file picker results
        data?.let { intent ->
            // Single file selection
            intent.data?.let { uri ->
                results.add(uri)
            }

            // Multiple file selection
            intent.clipData?.let { clipData ->
                for (i in 0 until clipData.itemCount) {
                    clipData.getItemAt(i).uri?.let { uri ->
                        results.add(uri)
                    }
                }
            }
        }

        callback.onReceiveValue(
            if (results.isEmpty()) null else results.toTypedArray()
        )

        cameraPhotoUri = null
    }

    fun cancelCallback() {
        filePathCallback?.onReceiveValue(null)
        filePathCallback = null
        cameraPhotoUri = null
    }
}
