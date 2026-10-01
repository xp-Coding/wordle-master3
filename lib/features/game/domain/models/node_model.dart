enum NodeType {
  base,
  overcharge,      // Match-4: cross-axis clear
  quantumSingularity, // Match-5: clear all of color
  firewall,        // Immobile obstacle, health = 2
  glitchedTimer,   // Countdown node
}

class DataNode {
  final String id;
  final int colorIndex; // 0 to 4 for base colors
  final NodeType type;
  final int row;
  final int col;
  final int firewallHealth; // default 2 for firewall
  final int timerRemaining;  // default 5 for glitched timer
  final bool isMatched;
  final bool isFalling;

  const DataNode({
    required this.id,
    required this.colorIndex,
    required this.type,
    required this.row,
    required this.col,
    this.firewallHealth = 2,
    this.timerRemaining = 5,
    this.isMatched = false,
    this.isFalling = false,
  });

  DataNode copyWith({
    String? id,
    int? colorIndex,
    NodeType? type,
    int? row,
    int? col,
    int? firewallHealth,
    int? timerRemaining,
    bool? isMatched,
    bool? isFalling,
  }) {
    return DataNode(
      id: id ?? this.id,
      colorIndex: colorIndex ?? this.colorIndex,
      type: type ?? this.type,
      row: row ?? this.row,
      col: col ?? this.col,
      firewallHealth: firewallHealth ?? this.firewallHealth,
      timerRemaining: timerRemaining ?? this.timerRemaining,
      isMatched: isMatched ?? this.isMatched,
      isFalling: isFalling ?? this.isFalling,
    );
  }

  bool get isImmobile => type == NodeType.firewall;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          colorIndex == other.colorIndex &&
          type == other.type &&
          row == other.row &&
          col == other.col &&
          firewallHealth == other.firewallHealth &&
          timerRemaining == other.timerRemaining &&
          isMatched == other.isMatched &&
          isFalling == other.isFalling;

  @override
  int get hashCode =>
      id.hashCode ^
      colorIndex.hashCode ^
      type.hashCode ^
      row.hashCode ^
      col.hashCode ^
      firewallHealth.hashCode ^
      timerRemaining.hashCode ^
      isMatched.hashCode ^
      isFalling.hashCode;
}
