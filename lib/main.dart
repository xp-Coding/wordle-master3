import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/audio_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/game_theme.dart';
import 'features/menu/presentation/screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred portrait orientations for casual mobile experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize persistence and audio engines
  await StorageService().init();
  final soundEnabled = StorageService().isSoundEnabled;
  await AudioService().init(soundEnabled: soundEnabled);

  runApp(
    const ProviderScope(
      child: WordleMasterApp(),
    ),
  );
}

class WordleMasterApp extends StatelessWidget {
  const WordleMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle Master',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.themeData,
      home: const MainMenuScreen(),
    );
  }
}
