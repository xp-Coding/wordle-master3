# Flutter Wrapper Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep MainActivity
-keep class com.casualgames.wordlemaster.MainActivity { *; }

# Keep Audio & Persistence Plugins
-keep class xyz.luan.audioplayers.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Standard Android Keep
-dontwarn javax.annotation.**
-dontwarn io.flutter.embedding.**
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
