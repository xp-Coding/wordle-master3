class GameConstants {
  static const String appTitle = 'NEON SHIFT: CYBER GRID';
  
  // Grid properties
  static const int gridRows = 6;
  static const int gridCols = 6;
  static const int baseColorCount = 5;

  // Endless Mode Overcharge properties
  static const double endlessInitialOvercharge = 100.0;
  static const double endlessDecayRatePerSecond = 2.0; // 2% per sec
  static const double baseMatchRechargeAmount = 8.0;

  // Scoring
  static const int baseMatch3Score = 100;
  static const int baseMatch4Score = 250;
  static const int baseMatch5Score = 600;

  // Firewall obstacle
  static const int firewallMaxHealth = 2;

  // Glitched Timer obstacle
  static const int glitchedTimerInitialMoves = 5;

  // Star calculation defaults
  static const int defaultStar1Score = 1000;
  static const int defaultStar2Score = 2500;
  static const int defaultStar3Score = 5000;

  // Data Bits reward multiplier
  static const double scoreToBitsRatio = 0.05;
}
