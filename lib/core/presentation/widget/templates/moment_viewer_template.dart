import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/moments/entities/day_moment.dart';
import '../../types/moment_time_label.dart';
import '../atoms/md_camera_edge_scrims.dart';
import '../atoms/md_camera_icon_button.dart';
import '../atoms/md_local_photo.dart';
import '../organisms/md_app_scaffold.dart';

/// "Your Day" one moment at a time, full screen: swipe for the next, see
/// how long it has left, or let it go early. See CLAUDE.md §54A.
class MomentViewerTemplate extends StatefulWidget {
  const MomentViewerTemplate({
    super.key,
    required this.moments,
    required this.initialIndex,
    required this.now,
    required this.onClose,
    required this.onDelete,
  });

  final List<DayMoment> moments;
  final int initialIndex;
  final DateTime now;
  final VoidCallback onClose;
  final ValueChanged<DayMoment> onDelete;

  @override
  State<MomentViewerTemplate> createState() => _MomentViewerTemplateState();
}

class _MomentViewerTemplateState extends State<MomentViewerTemplate> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _current = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moments = widget.moments;
    final index = _current.clamp(0, moments.length - 1);
    final moment = moments[index];

    return MdAppScaffold(
      backgroundColor: AppColors.camera,
      safeArea: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: moments.length,
            onPageChanged: (page) => setState(() => _current = page),
            itemBuilder: (context, i) => MdLocalPhoto(
              path: moments[i].photoPath,
              semanticLabel: moments[i].caption ?? 'A moment from your day',
            ),
          ),
          const MdCameraEdgeScrims(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                children: [
                  Row(
                    children: [
                      MdCameraIconButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Close',
                        onPressed: widget.onClose,
                      ),
                      const Spacer(),
                      MdCameraIconButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Remove this moment',
                        onPressed: () => widget.onDelete(moment),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (moment.caption != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        moment.caption!,
                        textAlign: TextAlign.center,
                        style: AppTypography.heading2.copyWith(
                          color: AppColors.onCamera,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    moment.timeLeftLabel(widget.now),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onCameraMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
