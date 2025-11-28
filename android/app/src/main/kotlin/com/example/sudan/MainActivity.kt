package com.example.sudan

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.KeyEvent
import android.view.View
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sudan/launcher"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDefaultLauncher" -> {
                    result.success(isDefaultLauncher())
                }
                "openLauncherSettings" -> {
                    openLauncherSettings()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable immersive full screen mode
        enableFullScreenMode()
        
        // Check if app is default launcher, if not, open settings after a delay
        checkAndPromptLauncher()
    }
    
    private fun checkAndPromptLauncher() {
        // Check after a short delay to let the app initialize
        window.decorView.postDelayed({
            if (!isDefaultLauncher()) {
                openLauncherSettings()
            }
        }, 2000) // 2 seconds delay
    }
    
    private fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }
        val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        val currentHomePackage = resolveInfo?.activityInfo?.packageName
        return currentHomePackage == packageName
    }
    
    private fun openLauncherSettings() {
        try {
            // Try to open the launcher selection directly
            val intent = Intent(Settings.ACTION_HOME_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(intent)
        } catch (e: Exception) {
            try {
                // Fallback: open app settings
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = android.net.Uri.parse("package:$packageName")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
            } catch (e2: Exception) {
                // If all else fails, just show the home selector
                val intent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
            }
        }
    }
    
    override fun onBackPressed() {
        // Disable back button to prevent exiting the app
        // In kiosk mode, we don't want users to exit
        // Uncomment the line below if you want to allow back button
        // super.onBackPressed()
    }
    
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        // Handle HOME button - prevent default behavior
        if (keyCode == KeyEvent.KEYCODE_HOME) {
            // Return true to consume the event
            // This prevents the system from handling HOME button
            return true
        }
        return super.onKeyDown(keyCode, event)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // When app is already running and HOME is pressed,
        // bring it to front instead of creating new instance
        setIntent(intent)
    }
    
    override fun onResume() {
        super.onResume()
        // Re-enable full screen when app resumes
        enableFullScreenMode()
    }
    
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            // Re-enable full screen when window gains focus
            enableFullScreenMode()
        }
    }
    
    private fun enableFullScreenMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ (API 30+)
            window.setDecorFitsSystemWindows(false)
            val controller = WindowCompat.getInsetsController(window, window.decorView)
            controller?.let {
                it.hide(WindowInsetsCompat.Type.systemBars())
                it.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            // Android 10 and below
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            )
        }
        
        // Keep screen on (optional, for kiosk mode)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        // Disable screenshot (optional, for security)
        // window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }
}
