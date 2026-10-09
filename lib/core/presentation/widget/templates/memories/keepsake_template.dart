import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../domain/memories/enum/keepsake_frame.dart';
import '../../../../domain/memories/enum/keepsake_layout.dart';
import '../../../../domain/memories/enum/sticker_type.dart';
import '../../../types/memories/keepsake_design.dart';
import '../../atoms/common/md_loading_indicator.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/memories/md_keepsake_canvas.dart';
import '../../organisms/memories/md_keepsake_snapshot.dart';
import '../../molecules/memories/md_keepsake_tray_tabs.dart';
import '../../molecules/memories/md_keepsake_layout_tray.dart';
import '../../molecules/memories/md_keepsake_paper_tray.dart';
import '../../molecules/memories/md_keepsake_sticker_tray.dart';

/// Makes the printed keepsake yours: pick a layout (strip, grid, polaroid),
/// a paper, and add stickers you drag, pinch and turn. The print stays in
/// view the whole time; one tidy tray changes it. Not a photo editor — just
/// the fun of decorating a photobooth print.
class KeepsakeTemplate extends StatefulWidget {
  const KeepsakeTemplate({
    super.key,
    required this.design,
    required this.doneLabel,
    required this.onClose,
    required this.onRetry,
    required this.onDone,
    required this.onLayoutChanged,
    required this.onFrameChanged,
    required this.onAddSticker,
    required this.onSelectSticker,
    required this.onTransformSticker,
    required this.onRemoveSticker,
  });

  final AsyncValue<KeepsakeDesign> design;

  final String doneLabel;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  final ValueChanged<Future<Uint8List?> Function()> onDone;
  final ValueChanged<KeepsakeLayout> onLayoutChanged;
  final ValueChanged<KeepsakeFrame> onFrameChanged;
  final ValueChanged<StickerType> onAddSticker;
  final ValueChanged<String?> onSelectSticker;
  final void Function(
    String id, {
    required double x,
    required double y,
    required double scale,
    required double rotation,
  })
  onTransformSticker;
  final ValueChanged<String> onRemoveSticker;

  @override
  State<KeepsakeTemplate> createState() => _KeepsakeTemplateState();
}

class _KeepsakeTemplateState extends State<KeepsakeTemplate> {
  final _snapshot = MdKeepsakeSnapshotController();
  var _tray = KeepsakeTray.layout;

  bool _capturing = false;

  Future<Uint8List?> _render() async {
    setState(() => _capturing = true);
    try {
      return await _snapshot.toPng();
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = widget.design.value;

    return MdAppScaffold(
      showAppBar: true,
      title: 'Make it yours',
      leading: IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.close_rounded),
        onPressed: widget.onClose,
      ),
      bottomAction: design == null
          ? null
          : MdPrimaryButton(
              label: widget.doneLabel,
              icon: Icons.check_rounded,
              loading: design.isSaving,
              onPressed: () => widget.onDone(_render),
            ),
      body: widget.design.when(
        loading: () =>
            const MdLoadingIndicator(message: 'Laying out your print…'),
        error: (error, stack) => MdEmptyState.error(
          title: "We couldn't open this keepsake",
          onRetry: widget.onRetry,
        ),
        data: (design) => Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: AppSpacing.sm,
                ),
                child: Center(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 16),
                      ],
                    ),
                    child: MdKeepsakeSnapshot(
                      controller: _snapshot,
                      child: MdKeepsakeCanvas(
                        design: design,
                        editable: !_capturing && !design.isSaving,
                        onSelectSticker: widget.onSelectSticker,
                        onTransformSticker: widget.onTransformSticker,
                        onRemoveSticker: widget.onRemoveSticker,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            MdKeepsakeTrayTabs(
              selected: _tray,
              onChanged: (tray) => setState(() => _tray = tray),
            ),
            SizedBox(
              height: 128,
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.short),
                child: KeyedSubtree(
                  key: ValueKey(_tray),
                  child: switch (_tray) {
                    KeepsakeTray.layout => MdKeepsakeLayoutTray(
                      selected: design.layout,
                      onChanged: widget.onLayoutChanged,
                    ),
                    KeepsakeTray.paper => MdKeepsakePaperTray(
                      selected: design.frame,
                      onChanged: widget.onFrameChanged,
                    ),
                    KeepsakeTray.stickers => MdKeepsakeStickerTray(
                      canAdd: design.canAddSticker,
                      onAdd: widget.onAddSticker,
                    ),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
