import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/camera/capture_state.dart';

/// While a GIF burst is being taken: which photo we're on.
class MdCapturingControls extends StatelessWidget {
  const MdCapturingControls({super.key, required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            '${state.burstFrame} of ${CaptureState.gifFrames}',
            textAlign: TextAlign.center,
            style: AppTypography.heading1.copyWith(color: AppColors.onCamera),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          state.burstFrame < CaptureState.gifFrames
              ? 'New pose!'
              : 'Last one — hold it!',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: AppColors.onCameraMuted),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
