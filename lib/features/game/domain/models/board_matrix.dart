import 'node_model.dart';

enum GameStatus {
  idle,
  playing,
  paused,
  won,
  lost,
}

enum GameMode {
  campaign,
  endless,
}

class BoardMatrix {
  final List<List<DataNode?>> grid; // 6x6
  final int score;
  final int comboMultiplier; // 1, 2, 3, 5
  final int movesRemaining;
  final double endlessOverchargeMeter; // 0.0 to 100.0
  final int firewallsCleared;
  final int totalFirewallsTarget;
  final int targetScore;
  final GameStatus status;
  final GameMode mode;
  final int levelId;
  final bool isProcessingCascade;

  const BoardMatrix({
    required this.grid,
    this.score = 0,
    this.comboMultiplier = 1,
    this.movesRemaining = 25,
    this.endlessOverchargeMeter = 100.0,
    this.firewallsCleared = 0,
    this.totalFirewallsTarget = 0,
    this.targetScore = 1000,
    this.status = GameStatus.idle,
    this.mode = GameMode.campaign,
    this.levelId = 1,
    this.isProcessingCascade = false,
  });

  BoardMatrix copyWith({
    List<List<DataNode?>>? grid,
    int? score,
    int? comboMultiplier,
    int? movesRemaining,
    double? endlessOverchargeMeter,
    int? firewallsCleared,
    int? totalFirewallsTarget,
    int? targetScore,
    GameStatus? status,
    GameMode? mode,
    int? levelId,
    bool? isProcessingCascade,
  }) {
    return BoardMatrix(
      grid: grid ?? this.grid,
      score: score ?? this.score,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      movesRemaining: movesRemaining ?? this.movesRemaining,
      endlessOverchargeMeter: endlessOverchargeMeter ?? this.endlessOverchargeMeter,
      firewallsCleared: firewallsCleared ?? this.firewallsCleared,
      totalFirewallsTarget: totalFirewallsTarget ?? this.totalFirewallsTarget,
      targetScore: targetScore ?? this.targetScore,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      levelId: levelId ?? this.levelId,
      isProcessingCascade: isProcessingCascade ?? this.isProcessingCascade,
    );
  }
}
