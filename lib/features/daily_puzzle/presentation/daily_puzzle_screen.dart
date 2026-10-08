import 'package:flutter/material.dart';
import '../../game/presentation/daily_puzzle_screen.dart' as game_daily;

export '../../game/presentation/daily_puzzle_screen.dart';

/// Legacy DailyPuzzleScreen adapter pointing to new game daily puzzle screen
class DailyPuzzleScreen extends StatelessWidget {
  const DailyPuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const game_daily.DailyPuzzleScreen();
  }
}
