# Keep the class names and member names for the app's entry point
-keep class com.example.your_app.** { *; }

# Keep class members annotated with @Keep
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# Keep attributes related to annotations
-keepattributes *Annotation*

# Add rules to keep other necessary classes and methods as needed
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
