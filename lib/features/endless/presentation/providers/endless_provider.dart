import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/endless_stats.dart';
import '../../../../core/storage/storage_service.dart';

final endlessStatsProvider = StateNotifierProvider<EndlessStatsNotifier, EndlessStats>((ref) {
  return EndlessStatsNotifier();
});

class EndlessStatsNotifier extends StateNotifier<EndlessStats> {
  EndlessStatsNotifier()
      : super(EndlessStats(
          highScore: StorageService().getEndlessHighScore(),
          maxCombo: StorageService().getEndlessMaxCombo(),
          totalNodesCleared: 0,
        ));

  void refreshStats() {
    state = EndlessStats(
      highScore: StorageService().getEndlessHighScore(),
      maxCombo: StorageService().getEndlessMaxCombo(),
      totalNodesCleared: 0,
    );
  }
}
