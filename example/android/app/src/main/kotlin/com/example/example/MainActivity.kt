package com.example.example

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge: the app draws behind both the status bar and
        // navigation bar. Flutter's MediaQuery will then report the correct
        // top/bottom padding values via viewPadding / padding.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}
