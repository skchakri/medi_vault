# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep Hotwire classes
-keep class dev.hotwire.** { *; }
-keep interface dev.hotwire.** { *; }

# Keep Turbo classes
-keepclassmembers class * extends dev.hotwire.turbo.nav.TurboNavDestination {
    public <init>(...);
}

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**

# Kotlin
-dontwarn kotlin.**
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
