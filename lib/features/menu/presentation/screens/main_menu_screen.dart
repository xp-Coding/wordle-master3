import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../campaign/presentation/screens/sector_map_screen.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../../../economy_shop/presentation/screens/shop_modal.dart';
import '../widgets/settings_modal.dart';
import '../../../../core/theme/neon_colors.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/ads/ad_service.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = AdService().createBannerAd();
    _bannerAd?.load().then((_) {
      if (mounted) {
        setState(() {
          _isBannerLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int dataBits = StorageService().getDataBits();
    int endlessHighScore = StorageService().getEndlessHighScore();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Neon Cyber Title
              Text(
                'NEON SHIFT',
                style: GoogleFonts.orbitron(
                  color: NeonColors.cyan,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  shadows: [
                    const Shadow(blurRadius: 15, color: NeonColors.cyan, offset: Offset(0, 0)),
                  ],
                ),
              ),
              Text(
                'CYBER GRID',
                style: GoogleFonts.orbitron(
                  color: NeonColors.neonMagenta,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6.0,
                  shadows: [
                    const Shadow(blurRadius: 10, color: NeonColors.neonMagenta, offset: Offset(0, 0)),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Stats Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: NeonColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NeonColors.surfaceBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.memory_rounded, color: NeonColors.matrixGreen, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$dataBits BITS',
                      style: GoogleFonts.orbitron(
                        color: NeonColors.matrixGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.emoji_events_rounded, color: NeonColors.starGold, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'BEST: $endlessHighScore',
                      style: GoogleFonts.orbitron(
                        color: NeonColors.starGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Navigation Buttons
              _buildMenuButton(
                context,
                title: 'CAMPAIGN SECTORS',
                subtitle: '30 Levels Across 3 Sectors',
                color: NeonColors.cyan,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SectorMapScreen()),
                  );
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              _buildMenuButton(
                context,
                title: 'ENDLESS CYBER RUN',
                subtitle: 'Survival Mode with Overcharge Decay',
                color: NeonColors.neonMagenta,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GameScreen(isEndless: true)),
                  );
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildSmallButton(
                      context,
                      title: 'MARKETPLACE',
                      icon: Icons.storefront_rounded,
                      color: NeonColors.cyberYellow,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ShopModal()),
                        );
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallButton(
                      context,
                      title: 'SETTINGS',
                      icon: Icons.settings_rounded,
                      color: NeonColors.textMuted,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SettingsModal(),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // AdMob Banner Placement Hook
              if (_isBannerLoaded && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: NeonColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.orbitron(
                color: NeonColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: NeonColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
