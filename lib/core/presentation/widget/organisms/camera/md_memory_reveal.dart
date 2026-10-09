import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_shadows.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../utils/app_haptics.dart';
import '../../../types/camera/memory_reveal_result.dart';
import '../../../types/memories/keepsake_design.dart';
import '../../atoms/common/md_appear_transition.dart';
import '../../atoms/common/md_confetti_burst.dart';
import '../../atoms/common/md_sticker.dart';
import '../../atoms/camera/md_developing_print.dart';
import '../../atoms/common/md_local_photo.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../organisms/memories/md_keepsake_canvas.dart';
import '../../organisms/memories/md_keepsake_snapshot.dart';

class MdMemoryReveal extends StatefulWidget {
  const MdMemoryReveal({
    super.key,
    required this.result,
    required this.keepsake,
    required this.onKeep,
    required this.onDecorate,
  });

  final MemoryRevealResult result;
  final KeepsakeDesign? keepsake;
  final ValueChanged<Future<Uint8List?> Function()> onKeep;
  final VoidCallback onDecorate;

  @override
  State<MdMemoryReveal> createState() => _MdMemoryRevealState();
}

class _MdMemoryRevealState extends State<MdMemoryReveal>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2200);

  final _snapshot = MdKeepsakeSnapshotController();

  /// True while saving: the print shows stills, since moving clips can't
  /// be captured into an image.
  bool _capturing = false;

  Future<Uint8List?> _render() async {
    setState(() => _capturing = true);
    try {
      return await _snapshot.toPng();
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  // One timeline: the print rises, then develops, then the words arrive.
  late final _rise = _interval(0, 0.3, AppMotion.emphasized);
  late final _develop = _interval(0.15, 0.85, Curves.easeInOut);
  late final _heading = _interval(0.05, 0.3, AppMotion.standard);
  late final _details = _interval(0.6, 0.85, AppMotion.standard);
  late final _action = _interval(0.75, 1, AppMotion.standard);

  Animation<double> _interval(double begin, double end, Curve curve) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controller.isDismissed) return;
    AppHaptics.success();
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final names = result.people.map((p) => p.name).join(' · ');

    return Stack(
      children: [
        _content(result, names),
        // Over everything, bursting as the print rises.
        const Positioned.fill(
          child: MdConfettiBurst(
            origin: Alignment(0, -0.55),
            delay: Duration(milliseconds: 350),
          ),
        ),
      ],
    );
  }

  Widget _content(MemoryRevealResult result, String names) {
    // The print takes whatever height the words and buttons leave. When even
    // the minimum doesn't fit (small phone, big text) the page scrolls.
    return LayoutBuilder(
      builder: (context, box) {
        final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final printHeight = math.max(260.0, box.maxHeight - 380 * textScale);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.md,
          ),
          child: Column(
            children: [
              MdAppearTransition(
                animation: _heading,
                child: Column(
                  children: [
                    const MdSticker(
                      label: 'Quest complete!',
                      icon: Icons.auto_awesome_rounded,
                      tilt: -0.07,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        result.people.isEmpty
                            ? 'You made a memory.'
                            : 'You made a memory together.',
                        textAlign: TextAlign.center,
                        style: AppTypography.display,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: printHeight,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Opacity(
                      opacity: _rise.value.clamp(0, 1),
                      child: Transform.translate(
                        offset: Offset(0, (1 - _rise.value) * AppSpacing.jumbo),
                        child: MdDevelopingPrint(
                          progress: _develop.value,
                          child: child!,
                        ),
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        boxShadow: AppShadows.print,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: widget.keepsake == null
                            ? MdLocalPhoto(
                                path: result.stripPath,
                                fit: BoxFit.contain,
                                semanticLabel:
                                    'Your photo strip for ${result.title}',
                              )
                            : Semantics(
                                image: true,
                                label: 'Your photo strip for ${result.title}',
                                excludeSemantics: true,
                                child: MdKeepsakeSnapshot(
                                  controller: _snapshot,
                                  child: MdKeepsakeCanvas(
                                    design: widget.keepsake!,
                                    live: !_capturing,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              MdAppearTransition(
                animation: _details,
                child: Column(
                  children: [
                    Text(
                      result.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.heading2,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      [
                        if (names.isNotEmpty) names,
                        DateFormat.yMMMMd().format(result.capturedAt),
                      ].join('  ·  '),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              MdAppearTransition(
                animation: _action,
                child: Column(
                  children: [
                    MdPrimaryButton(
                      label: 'Keep this memory',
                      icon: Icons.favorite_rounded,
                      loading: widget.keepsake?.isSaving ?? false,
                      onPressed: () => widget.onKeep(_render),
                    ),
                    if (widget.keepsake != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      MdSecondaryButton(
                        label: 'Decorate your print',
                        icon: Icons.auto_awesome_rounded,
                        onPressed: widget.onDecorate,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
