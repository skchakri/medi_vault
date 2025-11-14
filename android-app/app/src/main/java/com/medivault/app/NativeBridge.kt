package com.medivault.app

import android.app.Activity
import android.content.Intent
import android.webkit.JavascriptInterface
import android.widget.Toast

class NativeBridge(private val activity: Activity) {

    @JavascriptInterface
    fun showToast(message: String) {
        activity.runOnUiThread {
            Toast.makeText(activity, message, Toast.LENGTH_SHORT).show()
        }
    }

    @JavascriptInterface
    fun scanQRCode() {
        activity.runOnUiThread {
            val intent = Intent(activity, QRScannerActivity::class.java)
            activity.startActivity(intent)
        }
    }

    @JavascriptInterface
    fun vibrate(duration: Long = 100) {
        activity.runOnUiThread {
            val vibrator = activity.getSystemService(android.content.Context.VIBRATOR_SERVICE)
                as android.os.Vibrator
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                vibrator.vibrate(
                    android.os.VibrationEffect.createOneShot(
                        duration,
                        android.os.VibrationEffect.DEFAULT_AMPLITUDE
                    )
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(duration)
            }
        }
    }

    @JavascriptInterface
    fun shareText(text: String, title: String = "Share") {
        activity.runOnUiThread {
            val sendIntent = Intent().apply {
                action = Intent.ACTION_SEND
                putExtra(Intent.EXTRA_TEXT, text)
                type = "text/plain"
            }
            val shareIntent = Intent.createChooser(sendIntent, title)
            activity.startActivity(shareIntent)
        }
    }
}
