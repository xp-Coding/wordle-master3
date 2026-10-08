import 'package:flutter/material.dart';
import '../../game/presentation/word_connect_screen.dart' as game_wc;

export '../../game/presentation/word_connect_screen.dart';

/// Legacy WordConnectScreen adapter pointing to new game word connect screen
class WordConnectScreen extends StatelessWidget {
  final int levelNumber;

  const WordConnectScreen({
    super.key,
    this.levelNumber = 1,
  });

  @override
  Widget build(BuildContext context) {
    return game_wc.WordConnectScreen(initialLevel: levelNumber);
  }
}
