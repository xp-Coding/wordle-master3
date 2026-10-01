import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/cyber_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/audio/audio_service.dart';
import 'core/ads/ad_service.dart';
import 'features/menu/presentation/screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core persistence, audio, and ad engines
  await StorageService().init();
  await AudioService().init();
  await AdService().init();

  runApp(
    const ProviderScope(
      child: NeonShiftApp(),
    ),
  );
}

class NeonShiftApp extends StatelessWidget {
  const NeonShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Shift: Cyber Grid',
      debugShowCheckedModeBanner: false,
      theme: CyberTheme.themeData,
      home: const MainMenuScreen(),
    );
  }
}
