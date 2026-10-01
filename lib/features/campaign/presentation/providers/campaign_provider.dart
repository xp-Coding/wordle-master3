import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/storage_service.dart';

final campaignProgressProvider = StateNotifierProvider<CampaignProgressNotifier, int>((ref) {
  return CampaignProgressNotifier();
});

class CampaignProgressNotifier extends StateNotifier<int> {
  CampaignProgressNotifier() : super(StorageService().getUnlockedLevel());

  void refreshProgress() {
    state = StorageService().getUnlockedLevel();
  }

  int getStarsForLevel(int levelId) {
    return StorageService().getLevelStars(levelId);
  }

  int getTotalStarsEarned() {
    int total = 0;
    for (int i = 1; i <= 30; i++) {
      total += StorageService().getLevelStars(i);
    }
    return total;
  }
}
