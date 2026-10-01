import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_notifier.dart';
import '../widgets/game_hud.dart';
import '../widgets/cyber_board_canvas.dart';
import '../widgets/win_loss_modal.dart';
import '../../domain/models/board_matrix.dart';
import '../../../../core/theme/neon_colors.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/audio/audio_service.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int? campaignLevelId;
  final bool isEndless;

  const GameScreen({
    super.key,
    this.campaignLevelId,
    this.isEndless = false,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize game mode after first frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(gameNotifierProvider.notifier);
      if (widget.isEndless) {
        notifier.startEndlessRun();
      } else if (widget.campaignLevelId != null) {
        notifier.startCampaignLevel(widget.campaignLevelId!);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);
    final notifier = ref.read(gameNotifierProvider.notifier);

    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive) {
      notifier.pauseGame();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      // Audio resume handled gracefully inside audio service
      AudioService().resumeBgm();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AudioService().stopBgm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardMatrix = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);
    String equippedSkin = StorageService().getEquippedSkin();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              // HUD Header
              GameHud(
                boardMatrix: boardMatrix,
                onPausePressed: () {
                  notifier.pauseGame();
                  _showPauseDialog(context, notifier);
                },
              ),
              const Spacer(),

              // Interactive 6x6 Cyber Board Canvas
              CyberBoardCanvas(
                boardMatrix: boardMatrix,
                onSwap: (r1, c1, r2, c2) {
                  notifier.attemptSwap(r1, c1, r2, c2);
                },
                equippedSkin: equippedSkin,
              ),

              const Spacer(),

              // Trigger Win / Defeat Modal when game state changes
              if (boardMatrix.status == GameStatus.won || boardMatrix.status == GameStatus.lost)
                WinLossModal(
                  boardMatrix: boardMatrix,
                  onRetry: () {
                    if (widget.isEndless) {
                      notifier.startEndlessRun();
                    } else {
                      notifier.startCampaignLevel(widget.campaignLevelId ?? 1);
                    }
                  },
                  onNextLevel: () {
                    int next = (widget.campaignLevelId ?? 1) + 1;
                    notifier.startCampaignLevel(next);
                  },
                  onMenu: () {
                    Navigator.of(context).pop();
                  },
                  onAddExtraMoves: (moves) {
                    notifier.addExtraMoves(moves);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseDialog(BuildContext context, GameNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: NeonColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: NeonColors.cyan),
          ),
          title: Text(
            'GAME PAUSED',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              color: NeonColors.cyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  notifier.resumeGame();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: Text('RESUME', style: GoogleFonts.orbitron(color: Colors.black)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // pop dialog
                  Navigator.of(context).pop(); // pop game screen to menu
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: NeonColors.neonMagenta),
                ),
                child: Text('QUIT TO MENU', style: GoogleFonts.orbitron(color: NeonColors.neonMagenta)),
              ),
            ],
          ),
        );
      },
    );
  }
}
