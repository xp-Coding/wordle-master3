enum SectorType {
  slums,       // Sector 1: Levels 1-10
  core,        // Sector 2: Levels 11-20
  quantumGrid, // Sector 3: Levels 21-30
}

enum ObjectiveType {
  scoreTarget,
  clearFirewalls,
  moveLimitedSurvival,
}

class LevelModel {
  final int id;
  final SectorType sector;
  final String title;
  final ObjectiveType objectiveType;
  final int targetScore;
  final int firewallCount;
  final int glitchedTimerCount;
  final int movesLimit;

  // Star calculation thresholds
  final int star1Score;
  final int star2Score;
  final int star3Score;

  const LevelModel({
    required this.id,
    required this.sector,
    required this.title,
    required this.objectiveType,
    required this.targetScore,
    this.firewallCount = 0,
    this.glitchedTimerCount = 0,
    required this.movesLimit,
    required this.star1Score,
    required this.star2Score,
    required this.star3Score,
  });

  int calculateStars(int scoreAchieved, int movesRemaining) {
    if (scoreAchieved < star1Score) return 1;
    if (scoreAchieved >= star3Score && movesRemaining >= 5) return 3;
    if (scoreAchieved >= star2Score || movesRemaining >= 3) return 2;
    return 1;
  }
}
