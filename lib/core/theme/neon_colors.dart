import 'package:flutter/material.dart';

class NeonColors {
  // Base 5 Data Node Colors
  static const Color cyan = Color(0xFF00F0FF);
  static const Color neonMagenta = Color(0xFFFF003C);
  static const Color electricViolet = Color(0xFF9D00FF);
  static const Color cyberYellow = Color(0xFFFFE600);
  static const Color matrixGreen = Color(0xFF00FF66);

  // Background and UI Cyberpunk Palette
  static const Color darkBackground = Color(0xFF0A0C14);
  static const Color cardSurface = Color(0xFF121624);
  static const Color surfaceBorder = Color(0xFF1F2840);
  
  // Special Node Colors
  static const Color overchargeNode = Color(0xFFFF6600);
  static const Color quantumSingularity = Color(0xFFFFFFFF);
  static const Color firewallBarrier = Color(0xFF556677);
  static const Color glitchedTimer = Color(0xFFFF0055);

  // HUD & Accents
  static const Color textBright = Color(0xFFE0F8FF);
  static const Color textMuted = Color(0xFF6C7D9C);
  static const Color starGold = Color(0xFFFFD700);

  // Map 5 index values to Base Node Colors
  static List<Color> get baseColors => [
        cyan,
        neonMagenta,
        electricViolet,
        cyberYellow,
        matrixGreen,
      ];

  static Color getColorByIndex(int index) {
    if (index >= 0 && index < baseColors.length) {
      return baseColors[index];
    }
    return cyan;
  }
}
