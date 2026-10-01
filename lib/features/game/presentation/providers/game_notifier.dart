import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/board_matrix.dart';
import '../../domain/models/node_model.dart';
import '../../domain/services/grid_engine.dart';
import '../../../../core/audio/audio_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../campaign/data/level_definitions.dart';
import '../../../campaign/domain/models/level_model.dart';

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, BoardMatrix>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<BoardMatrix> {
  Timer? _endlessTicker;

  GameNotifier()
      : super(BoardMatrix(
          grid: GridEngine.createInitialGrid(),
          status: GameStatus.idle,
        ));

  void startCampaignLevel(int levelId) {
    _endlessTicker?.cancel();
    LevelModel level = LevelDefinitions.getLevel(levelId);

    List<List<DataNode?>> grid = GridEngine.createInitialGrid(
      firewallsCount: level.firewallCount,
      glitchedTimersCount: level.glitchedTimerCount,
    );

    state = BoardMatrix(
      grid: grid,
      score: 0,
      comboMultiplier: 1,
      movesRemaining: level.movesLimit,
      firewallsCleared: 0,
      totalFirewallsTarget: level.firewallCount,
      targetScore: level.targetScore,
      status: GameStatus.playing,
      mode: GameMode.campaign,
      levelId: levelId,
      isProcessingCascade: false,
    );

    AudioService().playBgm();
  }

  void startEndlessRun() {
    _endlessTicker?.cancel();
    List<List<DataNode?>> grid = GridEngine.createInitialGrid();

    state = BoardMatrix(
      grid: grid,
      score: 0,
      comboMultiplier: 1,
      movesRemaining: 9999,
      endlessOverchargeMeter: GameConstants.endlessInitialOvercharge,
      firewallsCleared: 0,
      totalFirewallsTarget: 0,
      targetScore: 999999,
      status: GameStatus.playing,
      mode: GameMode.endless,
      levelId: 0,
      isProcessingCascade: false,
    );

    AudioService().playBgm();

    // 60FPS / 100ms decay tick loop for endless overcharge meter (2% per second)
    _endlessTicker = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (state.status != GameStatus.playing) return;

      double newMeter = state.endlessOverchargeMeter - (GameConstants.endlessDecayRatePerSecond * 0.2);
      if (newMeter <= 0) {
        newMeter = 0;
        timer.cancel();
        _triggerGameOver(false);
      } else {
        state = state.copyWith(endlessOverchargeMeter: newMeter);
      }
    });
  }

  Future<void> attemptSwap(int r1, int c1, int r2, int c2) async {
    if (state.status != GameStatus.playing || state.isProcessingCascade) return;

    if (!GridEngine.isValidSwap(state.grid, r1, c1, r2, c2)) {
      return;
    }

    state = state.copyWith(isProcessingCascade: true);
    AudioService().playSfx(SfxType.swap);

    // Swap matrix
    List<List<DataNode?>> swappedGrid = GridEngine.swapNodes(state.grid, r1, c1, r2, c2);
    state = state.copyWith(grid: swappedGrid);

    // Delay for swap visual animation
    await Future.delayed(const Duration(milliseconds: 250));

    // Process cascade
    CascadeResult result = GridEngine.processFullCascade(swappedGrid);
    AudioService().playSfx(SfxType.match);

    int updatedScore = state.score + result.pointsEarned;
    int updatedFirewalls = state.firewallsCleared + result.totalFirewallsDestroyed;
    int remainingMoves = state.mode == GameMode.campaign ? state.movesRemaining - 1 : state.movesRemaining;

    // Recharge Endless Meter if in endless mode
    double updatedMeter = state.endlessOverchargeMeter;
    if (state.mode == GameMode.endless && result.totalClearedNodes > 0) {
      updatedMeter = (updatedMeter + (result.totalClearedNodes * GameConstants.baseMatchRechargeAmount * result.comboReached))
          .clamp(0.0, 100.0);
    }

    // Ensure grid has valid moves remaining, otherwise reshuffle
    List<List<DataNode?>> finalGrid = result.grid;
    if (!GridEngine.hasValidMoves(finalGrid)) {
      finalGrid = GridEngine.createInitialGrid();
    }

    state = state.copyWith(
      grid: finalGrid,
      score: updatedScore,
      comboMultiplier: result.comboReached,
      firewallsCleared: updatedFirewalls,
      movesRemaining: remainingMoves,
      endlessOverchargeMeter: updatedMeter,
      isProcessingCascade: false,
    );

    _checkGameCondition();
  }

  void _checkGameCondition() {
    if (state.mode == GameMode.campaign) {
      LevelModel level = LevelDefinitions.getLevel(state.levelId);

      bool targetMet = false;
      if (level.objectiveType == ObjectiveType.scoreTarget) {
        targetMet = state.score >= level.targetScore;
      } else if (level.objectiveType == ObjectiveType.clearFirewalls) {
        targetMet = state.firewallsCleared >= level.firewallCount;
      } else if (level.objectiveType == ObjectiveType.moveLimitedSurvival) {
        targetMet = state.movesRemaining >= 0 && state.score >= level.targetScore;
      }

      if (targetMet) {
        _triggerGameOver(true);
      } else if (state.movesRemaining <= 0) {
        _triggerGameOver(false);
      }
    }
  }

  void _triggerGameOver(bool isVictory) {
    _endlessTicker?.cancel();
    if (isVictory) {
      AudioService().playSfx(SfxType.levelWin);
      state = state.copyWith(status: GameStatus.won);

      // Save campaign progress and calculate stars & data bits
      if (state.mode == GameMode.campaign) {
        LevelModel level = LevelDefinitions.getLevel(state.levelId);
        int stars = level.calculateStars(state.score, state.movesRemaining);
        int dataBitsEarned = (state.score * GameConstants.scoreToBitsRatio).round() + (stars * 50);

        StorageService().saveLevelStars(state.levelId, stars);
        StorageService().saveUnlockedLevel(state.levelId + 1);
        int currentBits = StorageService().getDataBits();
        StorageService().saveDataBits(currentBits + dataBitsEarned);
      }
    } else {
      AudioService().playSfx(SfxType.levelLoss);
      state = state.copyWith(status: GameStatus.lost);

      if (state.mode == GameMode.endless) {
        StorageService().saveEndlessHighScore(state.score);
        StorageService().saveEndlessMaxCombo(state.comboMultiplier);
        int currentBits = StorageService().getDataBits();
        int dataBitsEarned = (state.score * GameConstants.scoreToBitsRatio).round();
        StorageService().saveDataBits(currentBits + dataBitsEarned);
      }
    }
  }

  void addExtraMoves(int extraMoves) {
    if (state.status == GameStatus.lost && state.mode == GameMode.campaign) {
      state = state.copyWith(
        movesRemaining: extraMoves,
        status: GameStatus.playing,
      );
    }
  }

  void pauseGame() {
    if (state.status == GameStatus.playing) {
      state = state.copyWith(status: GameStatus.paused);
      AudioService().pauseBgm();
    }
  }

  void resumeGame() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      AudioService().resumeBgm();
    }
  }

  @override
  void dispose() {
    _endlessTicker?.cancel();
    super.dispose();
  }
}
