import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/ad_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/game_storage.dart';
import 'core/services/storage_service.dart';
import 'core/theme/game_theme.dart';
import 'features/menu/presentation/screens/main_menu_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Prevent uncaught Flutter framework errors from terminating the app
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Caught Flutter Framework Error: ${details.exception}');
    };

    // Safe orientation lock for casual game experience
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      debugPrint('Orientation lock note: $e');
    }

    // Initialize unified persistence architecture
    try {
      await GameStorage().init();
      await StorageService().init();
    } catch (e) {
      debugPrint('GameStorage init note: $e');
    }

    // Initialize procedural low-latency audio synthesizer
    try {
      final soundEnabled = GameStorage().isSoundEnabled;
      await AudioService().init(soundEnabled: soundEnabled);
    } catch (e) {
      debugPrint('AudioService init note: $e');
    }

    runApp(
      const ProviderScope(
        child: WordleMasterApp(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('Caught Unhandled Async Error: $error\n$stackTrace');
  });
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class WordleMasterApp extends StatefulWidget {
  const WordleMasterApp({super.key});

  @override
  State<WordleMasterApp> createState() => _WordleMasterAppState();
}

class _WordleMasterAppState extends State<WordleMasterApp> with WidgetsBindingObserver {
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _wasBackgrounded = true;
    } else if (state == AppLifecycleState.resumed && _wasBackgrounded) {
      _wasBackgrounded = false;
      final navCtx = rootNavigatorKey.currentContext;
      if (navCtx != null) {
        Future.delayed(const Duration(milliseconds: 400), () {
          final ctx = rootNavigatorKey.currentContext;
          if (ctx != null && mounted) {
            AdService().showAppOpenAd(ctx);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Wordle Master',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.themeData,
      home: const MainMenuScreen(),
      builder: (context, child) {
        // Safe global error widget fallback
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            backgroundColor: const Color(0xFF121624),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: Colors.orangeAccent, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Resuming Wordle Master...',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

