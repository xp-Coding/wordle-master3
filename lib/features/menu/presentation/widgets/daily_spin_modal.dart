import 'package:flutter/material.dart';
import '../../widgets/lucky_spin_dialog.dart';

export '../../widgets/lucky_spin_dialog.dart';

/// Legacy DailySpinModal adapter that renders the upgraded LuckySpinDialog
class DailySpinModal extends StatelessWidget {
  final VoidCallback onRewardClaimed;

  const DailySpinModal({
    super.key,
    required this.onRewardClaimed,
  });

  @override
  Widget build(BuildContext context) {
    return LuckySpinDialog(onRewardClaimed: onRewardClaimed);
  }
}
