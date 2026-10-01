import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/shop_provider.dart';
import '../../domain/models/shop_item.dart';
import '../../../../core/theme/neon_colors.dart';
import '../../../../core/ads/ad_service.dart';

class ShopModal extends ConsumerWidget {
  const ShopModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopState = ref.watch(shopProvider);
    final shopNotifier = ref.read(shopProvider.notifier);

    return Scaffold(
      backgroundColor: NeonColors.darkBackground,
      appBar: AppBar(
        backgroundColor: NeonColors.cardSurface,
        title: Text(
          'DATA MARKETPLACE',
          style: GoogleFonts.orbitron(
            color: NeonColors.cyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NeonColors.matrixGreen),
            ),
            child: Row(
              children: [
                const Icon(Icons.memory_rounded, color: NeonColors.matrixGreen, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${shopState.dataBits} BITS',
                  style: GoogleFonts.orbitron(
                    color: NeonColors.matrixGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earn Free Bits Banner
            Card(
              color: NeonColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: NeonColors.cyberYellow, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.ondemand_video_rounded, color: NeonColors.cyberYellow, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EARN FREE DATA BITS',
                            style: GoogleFonts.orbitron(
                              color: NeonColors.cyberYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Watch a quick rewarded video to claim +100 Data Bits!',
                            style: GoogleFonts.orbitron(
                              color: NeonColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NeonColors.cyberYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        AdService().showRewardedAd(
                          onUserEarnedReward: (reward) {
                            shopNotifier.addDataBits(100);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('+100 Data Bits added to balance!')),
                            );
                          },
                        );
                      },
                      child: Text('CLAIM', style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'TILE SKINS',
              style: GoogleFonts.orbitron(
                color: NeonColors.cyan,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            ...shopState.items
                .where((item) => item.type == ShopItemType.tileSkin)
                .map((item) => _buildItemCard(context, item, shopState, shopNotifier)),

            const SizedBox(height: 24),
            Text(
              'COLOR THEMES',
              style: GoogleFonts.orbitron(
                color: NeonColors.neonMagenta,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            ...shopState.items
                .where((item) => item.type == ShopItemType.colorTheme)
                .map((item) => _buildItemCard(context, item, shopState, shopNotifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ShopItem item,
    ShopState state,
    ShopNotifier notifier,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: NeonColors.darkBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: NeonColors.cyan),
              ),
              child: Icon(
                item.type == ShopItemType.tileSkin ? Icons.grid_view_rounded : Icons.palette_rounded,
                color: NeonColors.cyan,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.orbitron(
                      color: NeonColors.textBright,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: GoogleFonts.orbitron(
                      color: NeonColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            if (item.isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: NeonColors.matrixGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NeonColors.matrixGreen),
                ),
                child: Text(
                  'EQUIPPED',
                  style: GoogleFonts.orbitron(
                    color: NeonColors.matrixGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              )
            else if (item.isUnlocked)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: NeonColors.cyan),
                ),
                onPressed: () => notifier.equipItem(item),
                child: Text('EQUIP', style: GoogleFonts.orbitron(color: NeonColors.cyan, fontSize: 10)),
              )
            else
              ElevatedButton(
                onPressed: () {
                  bool success = notifier.buyItem(item);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Insufficient Data Bits! Watch an ad or clear levels to earn more.')),
                    );
                  }
                },
                child: Text('${item.priceBits} BITS', style: GoogleFonts.orbitron(color: Colors.black, fontSize: 10)),
              ),
          ],
        ),
      ),
    );
  }
}
