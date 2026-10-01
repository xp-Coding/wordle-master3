import 'dart:math';
import '../models/node_model.dart';
import '../../../../core/constants/game_constants.dart';

class MatchResult {
  final List<List<DataNode?>> newGrid;
  final int matchedNodeCount;
  final bool hasOverchargeTriggered;
  final bool hasQuantumTriggered;
  final int firewallsDestroyed;

  const MatchResult({
    required this.newGrid,
    required this.matchedNodeCount,
    this.hasOverchargeTriggered = false,
    this.hasQuantumTriggered = false,
    this.firewallsDestroyed = 0,
  });
}

class CascadeResult {
  final List<List<DataNode?>> grid;
  final int totalClearedNodes;
  final int totalFirewallsDestroyed;
  final int comboReached;
  final int pointsEarned;

  const CascadeResult({
    required this.grid,
    required this.totalClearedNodes,
    required this.totalFirewallsDestroyed,
    required this.comboReached,
    required this.pointsEarned,
  });
}

class GridEngine {
  static final Random _random = Random();

  /// Create initial 6x6 grid with guaranteed no initial 3-matches
  static List<List<DataNode?>> createInitialGrid({
    int firewallsCount = 0,
    int glitchedTimersCount = 0,
  }) {
    List<List<DataNode?>> grid = List.generate(
      GameConstants.gridRows,
      (r) => List.generate(GameConstants.gridCols, (c) => null),
    );

    for (int r = 0; r < GameConstants.gridRows; r++) {
      for (int c = 0; c < GameConstants.gridCols; c++) {
        int color;
        do {
          color = _random.nextInt(GameConstants.baseColorCount);
        } while (
            (r >= 2 &&
                grid[r - 1][c]?.colorIndex == color &&
                grid[r - 2][c]?.colorIndex == color) ||
            (c >= 2 &&
                grid[r][c - 1]?.colorIndex == color &&
                grid[r][c - 2]?.colorIndex == color));

        grid[r][c] = DataNode(
          id: 'node_${r}_${c}_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1000)}',
          colorIndex: color,
          type: NodeType.base,
          row: r,
          col: c,
        );
      }
    }

    // Insert Firewalls if required by level definition
    int firewallsPlaced = 0;
    while (firewallsPlaced < firewallsCount) {
      int r = _random.nextInt(GameConstants.gridRows);
      int c = _random.nextInt(GameConstants.gridCols);
      if (grid[r][c]?.type == NodeType.base) {
        grid[r][c] = grid[r][c]!.copyWith(
          type: NodeType.firewall,
          firewallHealth: GameConstants.firewallMaxHealth,
        );
        firewallsPlaced++;
      }
    }

    // Insert Glitched Timers if required by level definition
    int timersPlaced = 0;
    while (timersPlaced < glitchedTimersCount) {
      int r = _random.nextInt(GameConstants.gridRows);
      int c = _random.nextInt(GameConstants.gridCols);
      if (grid[r][c]?.type == NodeType.base) {
        grid[r][c] = grid[r][c]!.copyWith(
          type: NodeType.glitchedTimer,
          timerRemaining: GameConstants.glitchedTimerInitialMoves,
        );
        timersPlaced++;
      }
    }

    return grid;
  }

  /// Check if two positions are adjacent and valid to swap
  static bool isValidSwap(
      List<List<DataNode?>> grid, int r1, int c1, int r2, int c2) {
    if (r1 < 0 || r1 >= GameConstants.gridRows || c1 < 0 || c1 >= GameConstants.gridCols) return false;
    if (r2 < 0 || r2 >= GameConstants.gridRows || c2 < 0 || c2 >= GameConstants.gridCols) return false;

    // Must be orthogonal neighbours
    int dr = (r1 - r2).abs();
    int dc = (c1 - c2).abs();
    if ((dr == 1 && dc == 0) || (dr == 0 && dc == 1)) {
      DataNode? node1 = grid[r1][c1];
      DataNode? node2 = grid[r2][c2];

      if (node1 == null || node2 == null) return false;
      if (node1.isImmobile || node2.isImmobile) return false;

      // Temporary swap to see if it creates a match
      List<List<DataNode?>> tempGrid = _deepCopyGrid(grid);
      tempGrid[r1][c1] = node2.copyWith(row: r1, col: c1);
      tempGrid[r2][c2] = node1.copyWith(row: r2, col: c2);

      // Quantum singularity special swap trigger: swapping quantum with any tile triggers immediate clear
      if (node1.type == NodeType.quantumSingularity || node2.type == NodeType.quantumSingularity) {
        return true;
      }

      return hasAnyMatches(tempGrid);
    }
    return false;
  }

  /// Perform swap on matrix
  static List<List<DataNode?>> swapNodes(
      List<List<DataNode?>> grid, int r1, int c1, int r2, int c2) {
    List<List<DataNode?>> newGrid = _deepCopyGrid(grid);
    DataNode? n1 = newGrid[r1][c1];
    DataNode? n2 = newGrid[r2][c2];

    if (n1 != null && n2 != null) {
      newGrid[r1][c1] = n2.copyWith(row: r1, col: c1);
      newGrid[r2][c2] = n1.copyWith(row: r2, col: c2);
    }
    return newGrid;
  }

  /// Detect matches and resolve overcharge, quantum, and firewall damage
  static MatchResult resolveMatches(List<List<DataNode?>> grid) {
    List<List<DataNode?>> newGrid = _deepCopyGrid(grid);
    Set<Point<int>> matchedCoords = {};
    Set<Point<int>> overchargeSpawnCoords = {};
    Set<Point<int>> quantumSpawnCoords = {};

    bool overchargeTriggered = false;
    bool quantumTriggered = false;

    // 1. Horizontal Matches
    for (int r = 0; r < GameConstants.gridRows; r++) {
      int matchLen = 1;
      for (int c = 0; c < GameConstants.gridCols; c++) {
        bool isMatch = false;
        if (c < GameConstants.gridCols - 1) {
          DataNode? curr = newGrid[r][c];
          DataNode? next = newGrid[r][c + 1];
          if (curr != null &&
              next != null &&
              curr.type != NodeType.firewall &&
              next.type != NodeType.firewall &&
              curr.colorIndex == next.colorIndex) {
            isMatch = true;
          }
        }

        if (isMatch) {
          matchLen++;
        } else {
          if (matchLen >= 3) {
            int startC = c - matchLen + 1;
            for (int i = startC; i <= c; i++) {
              matchedCoords.add(Point(r, i));
            }
            if (matchLen == 4) {
              overchargeSpawnCoords.add(Point(r, startC + 1));
            } else if (matchLen >= 5) {
              quantumSpawnCoords.add(Point(r, startC + 2));
            }
          }
          matchLen = 1;
        }
      }
    }

    // 2. Vertical Matches
    for (int c = 0; c < GameConstants.gridCols; c++) {
      int matchLen = 1;
      for (int r = 0; r < GameConstants.gridRows; r++) {
        bool isMatch = false;
        if (r < GameConstants.gridRows - 1) {
          DataNode? curr = newGrid[r][c];
          DataNode? next = newGrid[r + 1][c];
          if (curr != null &&
              next != null &&
              curr.type != NodeType.firewall &&
              next.type != NodeType.firewall &&
              curr.colorIndex == next.colorIndex) {
            isMatch = true;
          }
        }

        if (isMatch) {
          matchLen++;
        } else {
          if (matchLen >= 3) {
            int startR = r - matchLen + 1;
            for (int i = startR; i <= r; i++) {
              matchedCoords.add(Point(i, c));
            }
            if (matchLen == 4) {
              overchargeSpawnCoords.add(Point(startR + 1, c));
            } else if (matchLen >= 5) {
              quantumSpawnCoords.add(Point(startR + 2, c));
            }
          }
          matchLen = 1;
        }
      }
    }

    if (matchedCoords.isEmpty) {
      return MatchResult(newGrid: newGrid, matchedNodeCount: 0);
    }

    // 3. Process Special Tile Detonations in matched set
    Set<Point<int>> additionalClears = {};
    for (var pt in matchedCoords) {
      DataNode? node = newGrid[pt.x][pt.y];
      if (node != null) {
        if (node.type == NodeType.overcharge) {
          overchargeTriggered = true;
          // Clear entire cross axis (row + col)
          for (int c = 0; c < GameConstants.gridCols; c++) {
            additionalClears.add(Point(pt.x, c));
          }
          for (int r = 0; r < GameConstants.gridRows; r++) {
            additionalClears.add(Point(r, pt.y));
          }
        } else if (node.type == NodeType.quantumSingularity) {
          quantumTriggered = true;
          int targetColor = node.colorIndex;
          for (int r = 0; r < GameConstants.gridRows; r++) {
            for (int c = 0; c < GameConstants.gridCols; c++) {
              if (newGrid[r][c]?.colorIndex == targetColor) {
                additionalClears.add(Point(r, c));
              }
            }
          }
        }
      }
    }
    matchedCoords.addAll(additionalClears);

    // 4. Firewall Damage Logic: check surrounding cells of matched set for Firewalls
    int firewallsDestroyed = 0;
    Set<Point<int>> firewallsToDamage = {};
    for (var pt in matchedCoords) {
      // Check 4 orthogonal adjacent neighbors
      final dirs = [
        Point(pt.x - 1, pt.y),
        Point(pt.x + 1, pt.y),
        Point(pt.x, pt.y - 1),
        Point(pt.x, pt.y + 1),
      ];
      for (var d in dirs) {
        if (d.x >= 0 &&
            d.x < GameConstants.gridRows &&
            d.y >= 0 &&
            d.y < GameConstants.gridCols) {
          if (newGrid[d.x][d.y]?.type == NodeType.firewall) {
            firewallsToDamage.add(d);
          }
        }
      }
    }

    for (var fwPt in firewallsToDamage) {
      DataNode? fwNode = newGrid[fwPt.x][fwPt.y];
      if (fwNode != null) {
        int newHp = fwNode.firewallHealth - 1;
        if (newHp <= 0) {
          newGrid[fwPt.x][fwPt.y] = null;
          firewallsDestroyed++;
        } else {
          newGrid[fwPt.x][fwPt.y] = fwNode.copyWith(firewallHealth: newHp);
        }
      }
    }

    // 5. Clear matched non-firewall nodes
    for (var pt in matchedCoords) {
      DataNode? node = newGrid[pt.x][pt.y];
      if (node != null && node.type != NodeType.firewall) {
        newGrid[pt.x][pt.y] = null;
      }
    }

    // 6. Spawn Special Nodes at target positions
    for (var pt in overchargeSpawnCoords) {
      newGrid[pt.x][pt.y] = DataNode(
        id: 'node_overcharge_${pt.x}_${pt.y}_${DateTime.now().microsecondsSinceEpoch}',
        colorIndex: _random.nextInt(GameConstants.baseColorCount),
        type: NodeType.overcharge,
        row: pt.x,
        col: pt.y,
      );
    }

    for (var pt in quantumSpawnCoords) {
      newGrid[pt.x][pt.y] = DataNode(
        id: 'node_quantum_${pt.x}_${pt.y}_${DateTime.now().microsecondsSinceEpoch}',
        colorIndex: _random.nextInt(GameConstants.baseColorCount),
        type: NodeType.quantumSingularity,
        row: pt.x,
        col: pt.y,
      );
    }

    return MatchResult(
      newGrid: newGrid,
      matchedNodeCount: matchedCoords.length,
      hasOverchargeTriggered: overchargeTriggered,
      hasQuantumTriggered: quantumTriggered,
      firewallsDestroyed: firewallsDestroyed,
    );
  }

  /// Apply Gravity Cascade: empty spaces fill by nodes falling down, and top row spawns new nodes
  static List<List<DataNode?>> applyGravityCascade(List<List<DataNode?>> grid) {
    List<List<DataNode?>> newGrid = _deepCopyGrid(grid);

    for (int c = 0; c < GameConstants.gridCols; c++) {
      // Pull down existing nodes
      for (int r = GameConstants.gridRows - 1; r >= 0; r--) {
        if (newGrid[r][c] == null) {
          // Find first non-null node above
          for (int aboveR = r - 1; aboveR >= 0; aboveR--) {
            if (newGrid[aboveR][c] != null && !newGrid[aboveR][c]!.isImmobile) {
              newGrid[r][c] = newGrid[aboveR][c]!.copyWith(row: r, col: c);
              newGrid[aboveR][c] = null;
              break;
            }
          }
        }
      }

      // Fill remaining null spaces at top with new randomized nodes
      for (int r = 0; r < GameConstants.gridRows; r++) {
        if (newGrid[r][c] == null) {
          newGrid[r][c] = DataNode(
            id: 'node_${r}_${c}_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1000)}',
            colorIndex: _random.nextInt(GameConstants.baseColorCount),
            type: NodeType.base,
            row: r,
            col: c,
            isFalling: true,
          );
        }
      }
    }

    return newGrid;
  }

  /// Execute full recursive cascade resolution loop
  static CascadeResult processFullCascade(List<List<DataNode?>> initialGrid) {
    List<List<DataNode?>> currentGrid = _deepCopyGrid(initialGrid);
    int totalCleared = 0;
    int totalFirewallsDestroyed = 0;
    int combo = 0;
    int scoreEarned = 0;

    while (hasAnyMatches(currentGrid)) {
      combo++;
      int multiplier = combo == 1
          ? 1
          : combo == 2
              ? 2
              : combo == 3
                  ? 3
                  : 5;

      MatchResult matchRes = resolveMatches(currentGrid);
      totalCleared += matchRes.matchedNodeCount;
      totalFirewallsDestroyed += matchRes.firewallsDestroyed;
      scoreEarned += (matchRes.matchedNodeCount * GameConstants.baseMatch3Score * multiplier);

      currentGrid = applyGravityCascade(matchRes.newGrid);
    }

    return CascadeResult(
      grid: currentGrid,
      totalClearedNodes: totalCleared,
      totalFirewallsDestroyed: totalFirewallsDestroyed,
      comboReached: combo,
      pointsEarned: scoreEarned,
    );
  }

  /// Check if grid contains any 3-matches
  static bool hasAnyMatches(List<List<DataNode?>> grid) {
    for (int r = 0; r < GameConstants.gridRows; r++) {
      for (int c = 0; c < GameConstants.gridCols; c++) {
        DataNode? curr = grid[r][c];
        if (curr == null || curr.isImmobile) continue;

        // Check Horizontal
        if (c < GameConstants.gridCols - 2) {
          DataNode? n1 = grid[r][c + 1];
          DataNode? n2 = grid[r][c + 2];
          if (n1 != null &&
              n2 != null &&
              !n1.isImmobile &&
              !n2.isImmobile &&
              curr.colorIndex == n1.colorIndex &&
              curr.colorIndex == n2.colorIndex) {
            return true;
          }
        }

        // Check Vertical
        if (r < GameConstants.gridRows - 2) {
          DataNode? n1 = grid[r + 1][c];
          DataNode? n2 = grid[r + 2][c];
          if (n1 != null &&
              n2 != null &&
              !n1.isImmobile &&
              !n2.isImmobile &&
              curr.colorIndex == n1.colorIndex &&
              curr.colorIndex == n2.colorIndex) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// Scan if any valid move exists on the grid. If false, grid should be reshuffled.
  static bool hasValidMoves(List<List<DataNode?>> grid) {
    for (int r = 0; r < GameConstants.gridRows; r++) {
      for (int c = 0; c < GameConstants.gridCols; c++) {
        // Try swap right
        if (c < GameConstants.gridCols - 1) {
          if (isValidSwap(grid, r, c, r, c + 1)) return true;
        }
        // Try swap down
        if (r < GameConstants.gridRows - 1) {
          if (isValidSwap(grid, r, c, r + 1, c)) return true;
        }
      }
    }
    return false;
  }

  /// Deep copy 2D grid matrix
  static List<List<DataNode?>> _deepCopyGrid(List<List<DataNode?>> grid) {
    return List.generate(
      grid.length,
      (r) => List.generate(
        grid[r].length,
        (c) => grid[r][c],
      ),
    );
  }
}
