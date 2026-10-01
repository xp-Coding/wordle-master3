import '../domain/models/level_model.dart';

class LevelDefinitions {
  static final List<LevelModel> allLevels = List.generate(30, (index) {
    int id = index + 1;
    SectorType sector;
    String sectorName;

    if (id <= 10) {
      sector = SectorType.slums;
      sectorName = 'Slums';
    } else if (id <= 20) {
      sector = SectorType.core;
      sectorName = 'Core';
    } else {
      sector = SectorType.quantumGrid;
      sectorName = 'Quantum';
    }

    ObjectiveType objType;
    int firewallCount = 0;
    int glitchedTimerCount = 0;

    if (id % 3 == 0) {
      objType = ObjectiveType.clearFirewalls;
      firewallCount = 2 + (id ~/ 5);
    } else if (id % 3 == 1) {
      objType = ObjectiveType.scoreTarget;
      if (id > 10) glitchedTimerCount = 1 + (id ~/ 10);
    } else {
      objType = ObjectiveType.moveLimitedSurvival;
      firewallCount = 1 + (id ~/ 8);
      glitchedTimerCount = 1;
    }

    int baseTargetScore = 800 + (id * 350);
    int movesLimit = (30 - (id ~/ 3)).clamp(15, 30);

    return LevelModel(
      id: id,
      sector: sector,
      title: '$sectorName Node 0x${id.toRadixString(16).padLeft(2, '0').toUpperCase()}',
      objectiveType: objType,
      targetScore: baseTargetScore,
      firewallCount: firewallCount,
      glitchedTimerCount: glitchedTimerCount,
      movesLimit: movesLimit,
      star1Score: baseTargetScore,
      star2Score: (baseTargetScore * 1.5).round(),
      star3Score: (baseTargetScore * 2.2).round(),
    );
  });

  static LevelModel getLevel(int levelId) {
    return allLevels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => allLevels.first,
    );
  }
}
