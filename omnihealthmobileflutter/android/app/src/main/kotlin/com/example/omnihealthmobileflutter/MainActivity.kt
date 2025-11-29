package com.example.omnihealthmobileflutter

// Để Health Connect hoạt động tốt trên Android 14, bạn cần đổi lớp cha từ FlutterActivity sang FlutterFragmentActivity
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    // ...
}