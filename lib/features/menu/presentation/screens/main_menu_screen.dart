import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/game_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../game/presentation/classic_wordle_screen.dart';
import '../../../game/presentation/daily_puzzle_screen.dart';
import '../../../game/presentation/three_clues_screen.dart';
import '../../../game/presentation/word_connect_screen.dart';
import '../../widgets/lucky_spin_dialog.dart';
import '../widgets/piggy_bank_modal.dart';
import '../widgets/settings_modal.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final GameStorage _storage = GameStorage();
  final AudioService _audio = AudioService();

  void _refresh() {
    setState(() {});
  }

  void _openSettings() {
    _audio.playSfx(GameSfx.click);
    showDialog(
      context: context,
      builder: (ctx) => SettingsModal(onChanged: _refresh),
    );
  }

  void _openDailySpin() {
    _audio.playSfx(GameSfx.click);
    showDialog(
      context: context,
      builder: (ctx) => LuckySpinDialog(onRewardClaimed: _refresh),
    );
  }

  void _openPiggyBank() {
    _audio.playSfx(GameSfx.click);
    showDialog(
      context: context,
      builder: (ctx) => PiggyBankModal(onClaimed: _refresh),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCoins = _storage.coins;
    final currentLevel = _storage.playerLevel;
    final currentStreak = _storage.dailyStreak;
    final piggyCoins = _storage.piggyBankCoins;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.menuGradientStart, // Soft Coral/Peach
              AppColors.menuWarmAmber,
              AppColors.menuGradientEnd,   // Creamy Amber
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top HUD Navigation
              _buildTopHUD(
                coins: currentCoins,
                level: currentLevel,
                streak: currentStreak,
              ),

              // Title Branding Banner
              const SizedBox(height: 12),
              _buildLogoBanner(),

              // Quick Action Metagame Floating Bar (Daily Spin & Piggy Bank)
              const SizedBox(height: 16),
              _buildMetagameBar(piggyCoins: piggyCoins),

              // Game Modes List
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    _buildModeCard(
                      title: 'CLASSIC WORDLE',
                      subtitle: '50 progressive levels • Emoji hints • Two-Pass logic',
                      icon: Icons.grid_view_rounded,
                      badgeText: 'LEVEL ${_storage.classicLevel} / 50',
                      gradientColors: const [Color(0xFF538D4E), Color(0xFF6AAA64)],
                      onTap: () {
                        _audio.playSfx(GameSfx.click);
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => ClassicWordleScreen(
                                  initialLevel: _storage.classicLevel,
                                ),
                              ),
                            )
                            .then((_) => _refresh());
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModeCard(
                      title: 'DAILY PUZZLE',
                      subtitle: 'October 2026 calendar grid • Milestone chests',
                      icon: Icons.calendar_month_rounded,
                      badgeText: _storage.isDailyCompletedToday ? 'DONE TODAY' : 'NEW TODAY',
                      badgeColor: _storage.isDailyCompletedToday
                          ? Colors.grey.shade700
                          : AppColors.streakOrange,
                      gradientColors: const [Color(0xFFFF7043), Color(0xFFFF8A65)],
                      onTap: () {
                        _audio.playSfx(GameSfx.click);
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => const DailyPuzzleScreen(),
                              ),
                            )
                            .then((_) => _refresh());
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModeCard(
                      title: 'WORD CONNECT',
                      subtitle: '50 levels • Radial anagram wheel • Swipe gestures',
                      icon: Icons.gesture_rounded,
                      badgeText: 'LEVEL ${_storage.wordConnectLevel} / 50',
                      gradientColors: const [Color(0xFF8E24AA), Color(0xFFAB47BC)],
                      onTap: () {
                        _audio.playSfx(GameSfx.click);
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => WordConnectScreen(
                                  initialLevel: _storage.wordConnectLevel,
                                ),
                              ),
                            )
                            .then((_) => _refresh());
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModeCard(
                      title: '3 CLUES • 1 WORD',
                      subtitle: '50 deduction puzzles • 3 hearts • Shuffled letters',
                      icon: Icons.psychology_rounded,
                      badgeText: 'LEVEL ${_storage.threeCluesLevel} / 50',
                      gradientColors: const [Color(0xFF0097A7), Color(0xFF00ACC1)],
                      onTap: () {
                        _audio.playSfx(GameSfx.click);
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) => ThreeCluesScreen(
                                  initialLevel: _storage.threeCluesLevel,
                                ),
                              ),
                            )
                            .then((_) => _refresh());
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHUD({
    required int coins,
    required int level,
    required int streak,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.xpPurple, size: 18),
                const SizedBox(width: 4),
                Text(
                  'LVL $level',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),

          // Streak Badge & Coins
          Row(
            children: [
              // Daily Streak
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.streakOrange, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$streak',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Coins HUD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: AppColors.coinGoldDark, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$coins',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Settings Gear Button
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 26),
                onPressed: _openSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoBanner() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['W', 'O', 'R', 'D', 'L', 'E'].map((letter) {
            final isGreen = letter == 'W' || letter == 'D';
            final isYellow = letter == 'O' || letter == 'L';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 38,
              height: 42,
              decoration: BoxDecoration(
                color: isGreen
                    ? AppColors.tileCorrect
                    : (isYellow ? AppColors.tileMisplaced : AppColors.tileAbsent),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        Text(
          'CASUAL PUZZLE PLATFORM',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.0,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMetagameBar({required int piggyCoins}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Daily Spin Button
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              shadowColor: Colors.black26,
              child: InkWell(
                onTap: _openDailySpin,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded, color: AppColors.menuWarmAmber, size: 22),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LUCKY SPIN',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Free Coins',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Piggy Bank Button
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              shadowColor: Colors.black26,
              child: InkWell(
                onTap: _openPiggyBank,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFCE4EC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.savings_rounded, color: Colors.pinkAccent, size: 22),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PIGGY BANK',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '$piggyCoins Coins',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.pinkAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    Color? badgeColor,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final effectiveBadgeColor = badgeColor ?? gradientColors.first;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Gradient Icon Tile
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSubtle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: effectiveBadgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: effectiveBadgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Action
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.tileFilledBorder,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
