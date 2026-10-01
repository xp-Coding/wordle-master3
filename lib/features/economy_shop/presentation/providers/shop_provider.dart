import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/shop_item.dart';
import '../../../../core/storage/storage_service.dart';

class ShopState {
  final int dataBits;
  final List<ShopItem> items;
  final String equippedSkin;
  final String equippedTheme;

  const ShopState({
    required this.dataBits,
    required this.items,
    required this.equippedSkin,
    required this.equippedTheme,
  });

  ShopState copyWith({
    int? dataBits,
    List<ShopItem>? items,
    String? equippedSkin,
    String? equippedTheme,
  }) {
    return ShopState(
      dataBits: dataBits ?? this.dataBits,
      items: items ?? this.items,
      equippedSkin: equippedSkin ?? this.equippedSkin,
      equippedTheme: equippedTheme ?? this.equippedTheme,
    );
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier();
});

class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier()
      : super(ShopState(
          dataBits: StorageService().getDataBits(),
          items: [],
          equippedSkin: StorageService().getEquippedSkin(),
          equippedTheme: StorageService().getEquippedTheme(),
        )) {
    loadShopItems();
  }

  void loadShopItems() {
    int bits = StorageService().getDataBits();
    List<String> unlockedSkins = StorageService().getUnlockedSkins();
    String currentSkin = StorageService().getEquippedSkin();
    String currentTheme = StorageService().getEquippedTheme();

    List<ShopItem> catalog = [
      // Tile Skins
      ShopItem(
        id: 'chip_default',
        title: 'Data Chips',
        description: 'Standard cyberpunk data node design.',
        type: ShopItemType.tileSkin,
        priceBits: 0,
        isUnlocked: true,
        isEquipped: currentSkin == 'chip_default',
      ),
      ShopItem(
        id: 'skin_hexagon',
        title: 'Neon Hexagons',
        description: 'Futuristic geometric mesh nodes.',
        type: ShopItemType.tileSkin,
        priceBits: 300,
        isUnlocked: unlockedSkins.contains('skin_hexagon'),
        isEquipped: currentSkin == 'skin_hexagon',
      ),
      ShopItem(
        id: 'skin_orb',
        title: 'Pulse Orbs',
        description: 'Glowing energy sphere nodes.',
        type: ShopItemType.tileSkin,
        priceBits: 600,
        isUnlocked: unlockedSkins.contains('skin_orb'),
        isEquipped: currentSkin == 'skin_orb',
      ),

      // Color Themes
      ShopItem(
        id: 'theme_vaporwave',
        title: 'Vaporwave Sunset',
        description: 'Classic retrowave aesthetic palette.',
        type: ShopItemType.colorTheme,
        priceBits: 0,
        isUnlocked: true,
        isEquipped: currentTheme == 'theme_vaporwave',
      ),
      ShopItem(
        id: 'theme_obsidian',
        title: 'Obsidian Cyber',
        description: 'Stealth dark mode with high contrast.',
        type: ShopItemType.colorTheme,
        priceBits: 400,
        isUnlocked: unlockedSkins.contains('theme_obsidian'),
        isEquipped: currentTheme == 'theme_obsidian',
      ),
      ShopItem(
        id: 'theme_terminal',
        title: 'Terminal Green',
        description: 'Retro 80s matrix command prompt palette.',
        type: ShopItemType.colorTheme,
        priceBits: 750,
        isUnlocked: unlockedSkins.contains('theme_terminal'),
        isEquipped: currentTheme == 'theme_terminal',
      ),
    ];

    state = ShopState(
      dataBits: bits,
      items: catalog,
      equippedSkin: currentSkin,
      equippedTheme: currentTheme,
    );
  }

  bool buyItem(ShopItem item) {
    if (state.dataBits < item.priceBits) {
      return false; // Insufficient funds
    }

    int remainingBits = state.dataBits - item.priceBits;
    StorageService().saveDataBits(remainingBits);
    StorageService().unlockSkin(item.id);

    loadShopItems();
    return true;
  }

  void equipItem(ShopItem item) {
    if (item.type == ShopItemType.tileSkin) {
      StorageService().setEquippedSkin(item.id);
    } else {
      StorageService().setEquippedTheme(item.id);
    }
    loadShopItems();
  }

  void addDataBits(int amount) {
    int current = StorageService().getDataBits();
    StorageService().saveDataBits(current + amount);
    loadShopItems();
  }
}
