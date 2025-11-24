package com.medivault.app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
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

    fun onShowFileChooser(
        filePathCallback: ValueCallback<Array<Uri>>?,
        fileChooserParams: WebChromeClient.FileChooserParams?
    ): Boolean {
        // Cancel any previous callbacks
        this.filePathCallback?.onReceiveValue(null)
        this.filePathCallback = filePathCallback

        val acceptTypes = fileChooserParams?.acceptTypes?.joinToString(",") ?: "*/*"
        val captureEnabled = fileChooserParams?.isCaptureEnabled ?: false

        try {
            val chooserIntent = createChooserIntent(acceptTypes, captureEnabled)
            fileChooserLauncher.launch(chooserIntent)
            return true
        } catch (e: Exception) {
            this.filePathCallback?.onReceiveValue(null)
            this.filePathCallback = null
            return false
        }
    }

    private fun createChooserIntent(acceptTypes: String, captureEnabled: Boolean): Intent {
        val intents = mutableListOf<Intent>()

        // Add camera intent if capture is enabled and accepting images
        if (captureEnabled && (acceptTypes.contains("image") || acceptTypes == "*/*")) {
            val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            if (cameraIntent.resolveActivity(activity.packageManager) != null) {
                cameraPhotoUri = createImageUri()
                cameraPhotoUri?.let {
                    cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, it)
                    intents.add(cameraIntent)
                }
            }
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
            filePickerIntent
        } else {
            Intent.createChooser(filePickerIntent, "Upload File").apply {
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
