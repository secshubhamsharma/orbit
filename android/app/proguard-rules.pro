# Flutter — keep the engine entry points intact
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase — keep reflection targets
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Hive — keep generated adapters
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements io.hive.** { *; }

# Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory { *; }
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler { *; }
-dontwarn kotlinx.coroutines.**

# Gson / JSON (used by Firebase internally)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# General: keep native methods and their classes
-keepclassmembers class * {
    native <methods>;
}
