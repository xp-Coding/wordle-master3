import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/campaign_provider.dart';
import '../../domain/models/level_model.dart';
import '../../data/level_definitions.dart';
import '../../../../core/theme/neon_colors.dart';
import '../../../../core/ads/ad_service.dart';
import '../../../game/presentation/screens/game_screen.dart';

class SectorMapScreen extends ConsumerStatefulWidget {
  const SectorMapScreen({super.key});

  @override
  ConsumerState<SectorMapScreen> createState() => _SectorMapScreenState();
}

class _SectorMapScreenState extends ConsumerState<SectorMapScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize Banner Ad
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
    _tabController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedLevel = ref.watch(campaignProgressProvider);
    final notifier = ref.read(campaignProgressProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: NeonColors.cardSurface,
        title: Text(
          'SECTOR MAP',
          style: GoogleFonts.orbitron(
            color: NeonColors.cyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: NeonColors.cyan,
          labelColor: NeonColors.cyan,
          unselectedLabelColor: NeonColors.textMuted,
          labelStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: 'SECTOR 1\nSLUMS'),
            Tab(text: 'SECTOR 2\nCORE'),
            Tab(text: 'SECTOR 3\nQUANTUM'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSectorGrid(context, 1, 10, unlockedLevel, notifier),
                _buildSectorGrid(context, 11, 20, unlockedLevel, notifier),
                _buildSectorGrid(context, 21, 30, unlockedLevel, notifier),
              ],
            ),
          ),

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
    );
  }

  Widget _buildSectorGrid(
    BuildContext context,
    int startLevel,
    int endLevel,
    int unlockedLevel,
    CampaignProgressNotifier notifier,
  ) {
    List<LevelModel> sectorLevels = LevelDefinitions.allLevels
        .where((l) => l.id >= startLevel && l.id <= endLevel)
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: sectorLevels.length,
      itemBuilder: (context, index) {
        LevelModel level = sectorLevels[index];
        bool isUnlocked = level.id <= unlockedLevel;
        int stars = notifier.getStarsForLevel(level.id);

        return InkWell(
          onTap: isUnlocked
              ? () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GameScreen(campaignLevelId: level.id),
                    ),
                  );
                  notifier.refreshProgress();
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? NeonColors.cardSurface : Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked ? NeonColors.cyan.withOpacity(0.8) : NeonColors.surfaceBorder,
                width: isUnlocked ? 2.0 : 1.0,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: NeonColors.cyan.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isUnlocked)
                  const Icon(Icons.lock_outline_rounded, color: NeonColors.textMuted, size: 32)
                else ...[
                  Text(
                    'LEVEL ${level.id}',
                    style: GoogleFonts.orbitron(
                      color: NeonColors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    level.objectiveType == ObjectiveType.scoreTarget
                        ? 'Target: ${level.targetScore}'
                        : level.objectiveType == ObjectiveType.clearFirewalls
                            ? 'Firewalls: ${level.firewallCount}'
                            : 'Survival: ${level.movesLimit} Moves',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      color: NeonColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (starIdx) {
                      bool active = starIdx < stars;
                      return Icon(
                        active ? Icons.star_rounded : Icons.star_border_rounded,
                        color: active ? NeonColors.starGold : NeonColors.textMuted,
                        size: 20,
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
