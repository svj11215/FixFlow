# Flutter-specific ProGuard rules
# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep generated plugin files
-keep class com.example.fixflow.GeneratedPluginRegistrant { *; }

# Keep Dart reflection
-keep class dart.** { *; }
-keep class com.google.dart.** { *; }

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Cloudinary
-keep class com.cloudinary.** { *; }
-dontwarn com.cloudinary.**
