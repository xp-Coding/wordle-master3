import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/board_matrix.dart';
import '../../domain/models/node_model.dart';
import '../../../../core/theme/neon_colors.dart';
import '../../../../core/constants/game_constants.dart';

class CyberBoardCanvas extends StatefulWidget {
  final BoardMatrix boardMatrix;
  final Function(int r1, int c1, int r2, int c2) onSwap;
  final String equippedSkin;

  const CyberBoardCanvas({
    super.key,
    required this.boardMatrix,
    required this.onSwap,
    required this.equippedSkin,
  });

  @override
  State<CyberBoardCanvas> createState() => _CyberBoardCanvasState();
}

class _CyberBoardCanvasState extends State<CyberBoardCanvas> {
  int? selectedRow;
  int? selectedCol;
  Offset? dragStartPos;

  void _handleTapDown(TapDownDetails details, Size boxSize) {
    double cellSize = boxSize.width / GameConstants.gridCols;
    int col = (details.localPosition.dx / cellSize).floor();
    int row = (details.localPosition.dy / cellSize).floor();

    if (row >= 0 && row < GameConstants.gridRows && col >= 0 && col < GameConstants.gridCols) {
      if (selectedRow == null) {
        setState(() {
          selectedRow = row;
          selectedCol = col;
        });
      } else {
        // If second tap is adjacent, swap
        int r1 = selectedRow!;
        int c1 = selectedCol!;
        int r2 = row;
        int c2 = col;

        setState(() {
          selectedRow = null;
          selectedCol = null;
        });

        widget.onSwap(r1, c1, r2, c2);
      }
    }
  }

  void _handlePanStart(DragStartDetails details) {
    dragStartPos = details.localPosition;
  }

  void _handlePanEnd(DragEndDetails details, Size boxSize) {
    if (dragStartPos == null) return;
    double cellSize = boxSize.width / GameConstants.gridCols;
    int startCol = (dragStartPos!.dx / cellSize).floor();
    int startRow = (dragStartPos!.dy / cellSize).floor();

    if (startRow < 0 || startRow >= GameConstants.gridRows || startCol < 0 || startCol >= GameConstants.gridCols) {
      return;
    }

    Offset velocity = details.velocity.pixelsPerSecond;
    int targetRow = startRow;
    int targetCol = startCol;

    if (velocity.dx.abs() > velocity.dy.abs()) {
      // Horizontal swipe
      if (velocity.dx > 100) targetCol = startCol + 1;
      if (velocity.dx < -100) targetCol = startCol - 1;
    } else {
      // Vertical swipe
      if (velocity.dy > 100) targetRow = startRow + 1;
      if (velocity.dy < -100) targetRow = startRow - 1;
    }

    if (targetRow != startRow || targetCol != startCol) {
      widget.onSwap(startRow, startCol, targetRow, targetCol);
    }

    dragStartPos = null;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          Size boxSize = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onTapDown: (details) => _handleTapDown(details, boxSize),
            onPanStart: _handlePanStart,
            onPanEnd: (details) => _handlePanEnd(details, boxSize),
            child: CustomPaint(
              size: boxSize,
              painter: GridPainter(
                boardMatrix: widget.boardMatrix,
                selectedRow: selectedRow,
                selectedCol: selectedCol,
                equippedSkin: widget.equippedSkin,
              ),
            ),
          );
        },
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final BoardMatrix boardMatrix;
  final int? selectedRow;
  final int? selectedCol;
  final String equippedSkin;

  GridPainter({
    required this.boardMatrix,
    this.selectedRow,
    this.selectedCol,
    required this.equippedSkin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cellSize = size.width / GameConstants.gridCols;
    double padding = 4.0;

    // Draw grid background frame
    Paint bgPaint = Paint()
      ..color = NeonColors.cardSurface
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)),
      bgPaint,
    );

    Paint borderPaint = Paint()
      ..color = NeonColors.cyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)),
      borderPaint,
    );

    // Draw grid cells and nodes
    for (int r = 0; r < GameConstants.gridRows; r++) {
      for (int c = 0; c < GameConstants.gridCols; c++) {
        Rect cellRect = Rect.fromLTWH(
          c * cellSize + padding,
          r * cellSize + padding,
          cellSize - (padding * 2),
          cellSize - (padding * 2),
        );

        // Draw empty slot grid lines
        Paint slotPaint = Paint()
          ..color = NeonColors.surfaceBorder.withOpacity(0.5)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(cellRect, const Radius.circular(10)), slotPaint);

        DataNode? node = boardMatrix.grid[r][c];
        if (node != null) {
          _drawNode(canvas, cellRect, node, r == selectedRow && c == selectedCol);
        }
      }
    }
  }

  void _drawNode(Canvas canvas, Rect rect, DataNode node, bool isSelected) {
    Color baseColor = NeonColors.getColorByIndex(node.colorIndex);
    if (node.type == NodeType.firewall) baseColor = NeonColors.firewallBarrier;
    if (node.type == NodeType.overcharge) baseColor = NeonColors.overchargeNode;
    if (node.type == NodeType.quantumSingularity) baseColor = NeonColors.quantumSingularity;

    // Selection Glow
    if (isSelected) {
      Paint glowPaint = Paint()
        ..color = baseColor.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), glowPaint);
    }

    // Node body paint
    Paint bodyPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    Paint borderPaint = Paint()
      ..color = isSelected ? Colors.white : baseColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 1.5;

    // Render node according to skin setting
    if (equippedSkin == 'skin_hexagon') {
      Path path = Path();
      double cx = rect.center.dx;
      double cy = rect.center.dy;
      double r = rect.width / 2;
      for (int i = 0; i < 6; i++) {
        double angle = (i * 60) * pi / 180;
        double x = cx + r * cos(angle);
        double y = cy + r * sin(angle);
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, bodyPaint);
      canvas.drawPath(path, borderPaint);
    } else if (equippedSkin == 'skin_orb') {
      canvas.drawCircle(rect.center, rect.width / 2.2, bodyPaint);
      canvas.drawCircle(rect.center, rect.width / 2.2, borderPaint);
    } else {
      // Default Data Chip (Rounded Rectangle)
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), bodyPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), borderPaint);
    }

    // Draw Node Special Overlay Icons
    if (node.type == NodeType.overcharge) {
      Paint iconPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      // Draw cross axis indicator
      canvas.drawLine(
        Offset(rect.center.dx - 10, rect.center.dy),
        Offset(rect.center.dx + 10, rect.center.dy),
        iconPaint,
      );
      canvas.drawLine(
        Offset(rect.center.dx, rect.center.dy - 10),
        Offset(rect.center.dx, rect.center.dy + 10),
        iconPaint,
      );
    } else if (node.type == NodeType.quantumSingularity) {
      Paint starPaint = Paint()..color = Colors.purpleAccent;
      canvas.drawCircle(rect.center, 8, starPaint);
    } else if (node.type == NodeType.firewall) {
      TextSpan span = TextSpan(
        text: 'FW [${node.firewallHealth}]',
        style: GoogleFonts.orbitron(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      );
      TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
    } else if (node.type == NodeType.glitchedTimer) {
      TextSpan span = TextSpan(
        text: '⏱${node.timerRemaining}',
        style: GoogleFonts.orbitron(color: Colors.yellowAccent, fontSize: 12, fontWeight: FontWeight.bold),
      );
      TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => true;
}
