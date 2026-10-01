enum ShopItemType {
  tileSkin,
  colorTheme,
}

class ShopItem {
  final String id;
  final String title;
  final String description;
  final ShopItemType type;
  final int priceBits;
  final bool isUnlocked;
  final bool isEquipped;

  const ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priceBits,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  ShopItem copyWith({
    bool? isUnlocked,
    bool? isEquipped,
  }) {
    return ShopItem(
      id: id,
      title: title,
      description: description,
      type: type,
      priceBits: priceBits,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
