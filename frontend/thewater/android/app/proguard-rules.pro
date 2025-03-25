-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.** { *; }

-dontwarn com.google.auto.value.AutoValue$Builder
-dontwarn com.google.auto.value.AutoValue
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options