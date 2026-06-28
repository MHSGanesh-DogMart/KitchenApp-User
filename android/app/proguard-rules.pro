# Razorpay — keep its classes & annotations so checkout works when
# code shrinking (R8/Proguard) is enabled. (Currently minify is off, so these
# are a no-op until you set isMinifyEnabled = true.)
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepattributes *Annotation*
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
# Razorpay uses Google Pay ProtoBuf APIs reflectively
-optimizations !method/inlining/*
-keepclasseswithmembers class * {
    public void onPayment*(...);
}
