import 'package:flutter/material.dart';
import '../../game/presentation/three_clues_screen.dart';

export '../../game/presentation/three_clues_screen.dart';

/// Legacy AssociationScreen adapter pointing to ThreeCluesScreen
class AssociationScreen extends StatelessWidget {
  final int puzzleIndex;

  const AssociationScreen({
    super.key,
    this.puzzleIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ThreeCluesScreen(initialLevel: puzzleIndex + 1);
  }
}
