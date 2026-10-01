# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.app.FlutterPlayStoreSplitApplication
-dontwarn com.google.android.play.core.**

# Hive Keep Rules
-keep class com.io7m.r2.jaxb.** { *; }
-keepclassmembers class * extends hive.HiveObject { *; }

# Google Mobile Ads (AdMob) Keep Rules
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# AudioPlayers Keep Rules
-keep class com.xyz.audioplayers.** { *; }
