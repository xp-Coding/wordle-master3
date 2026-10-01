import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/board_matrix.dart';
import '../../../../core/theme/neon_colors.dart';

class GameHud extends StatelessWidget {
  final BoardMatrix boardMatrix;
  final VoidCallback onPausePressed;

  const GameHud({
    super.key,
    required this.boardMatrix,
    required this.onPausePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: NeonColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeonColors.surfaceBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score & Combo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCORE',
                    style: GoogleFonts.orbitron(
                      color: NeonColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${boardMatrix.score}',
                        style: GoogleFonts.orbitron(
                          color: NeonColors.cyan,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (boardMatrix.comboMultiplier > 1) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: NeonColors.neonMagenta,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${boardMatrix.comboMultiplier}X',
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // Moves or Target
              if (boardMatrix.mode == GameMode.campaign)
                Column(
                  children: [
                    Text(
                      'MOVES',
                      style: GoogleFonts.orbitron(
                        color: NeonColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${boardMatrix.movesRemaining}',
                      style: GoogleFonts.orbitron(
                        color: boardMatrix.movesRemaining <= 5 ? NeonColors.neonMagenta : NeonColors.textBright,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              // Pause Button
              IconButton(
                onPressed: onPausePressed,
                icon: const Icon(Icons.pause_circle_filled, color: NeonColors.cyan, size: 36),
              ),
            ],
          ),

          // Endless Overcharge Meter bar or Firewall counter
          if (boardMatrix.mode == GameMode.endless) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'OVERCHARGE METER',
                      style: GoogleFonts.orbitron(
                        color: NeonColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${boardMatrix.endlessOverchargeMeter.toStringAsFixed(1)}%',
                      style: GoogleFonts.orbitron(
                        color: NeonColors.cyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (boardMatrix.endlessOverchargeMeter / 100.0).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.black45,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      boardMatrix.endlessOverchargeMeter < 25.0 ? NeonColors.neonMagenta : NeonColors.cyan,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (boardMatrix.totalFirewallsTarget > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FIREWALLS CLEARED',
                  style: GoogleFonts.orbitron(
                    color: NeonColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${boardMatrix.firewallsCleared} / ${boardMatrix.totalFirewallsTarget}',
                  style: GoogleFonts.orbitron(
                    color: NeonColors.cyberYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
