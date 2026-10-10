import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_shadows.dart';
import '../../../../../config/constant/app_spacing.dart';

/// A cream drawer pinned to the bottom of the screen that the person can drag
/// up. Closed it shows only a few actions; open it rises almost to the top,
/// leaving room for the brand above. Set [expanded] to open or close it from
/// code; dragging it reports back through [onExpandedChanged].
class MdAuthSheet extends StatefulWidget {
  const MdAuthSheet({
    super.key,
    required this.expanded,
    required this.onExpandedChanged,
    required this.builder,
    required this.collapsedHeight,
    required this.expandedTopGap,
  });

  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;

  /// The drawer's content. It must be built on a scrollable that uses the
  /// given controller (see [MdAuthSheetPage]) so dragging it moves the sheet.
  final Widget Function(
    BuildContext context,
    ScrollController scrollController,
    bool expanded,
  )
  builder;

  /// How tall the drawer is when closed.
  final double collapsedHeight;

  /// The space left above the drawer when it is open.
  final double expandedTopGap;

  @override
  State<MdAuthSheet> createState() => _MdAuthSheetState();
}

class _MdAuthSheetState extends State<MdAuthSheet> {
  final _controller = DraggableScrollableController();

  double _min = 0.3;
  double _max = 0.85;
  bool _moving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MdAuthSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expanded != widget.expanded) _settle();
  }

  /// Moves the drawer to where [MdAuthSheet.expanded] says it belongs, unless
  /// a drag already has it on that side (the sheet snaps by itself on
  /// release).
  void _settle() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_controller.isAttached) return;
      final middle = (_min + _max) / 2;
      if ((_controller.size > middle) == widget.expanded) return;
      final target = widget.expanded ? _max : _min;
      if (AppMotion.reduced(context)) {
        _controller.jumpTo(target);
        return;
      }
      _moving = true;
      try {
        await _controller.animateTo(
          target,
          duration: AppMotion.medium,
          curve: AppMotion.standard,
        );
      } finally {
        _moving = false;
      }
    });
  }

  bool _onSheetMoved(DraggableScrollableNotification notification) {
    _min = notification.minExtent;
    _max = notification.maxExtent;
    if (_moving) return false;
    final expanded = notification.extent > (_min + _max) / 2;
    if (expanded != widget.expanded) {
      // Never change state in the middle of a layout pass.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && expanded != widget.expanded) {
          widget.onExpandedChanged(expanded);
        }
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final min = (widget.collapsedHeight / height).clamp(0.1, 0.9);
        final max = ((height - widget.expandedTopGap) / height).clamp(min, 1.0);
        _min = min;
        _max = max;

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: _onSheetMoved,
          child: DraggableScrollableSheet(
            controller: _controller,
            initialChildSize: widget.expanded ? max : min,
            minChildSize: min,
            maxChildSize: max,
            snap: true,
            builder: (context, scrollController) => DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.base),
                ),
                boxShadow: AppShadows.floating,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.base),
                ),
                // One scrollable at a time: the sheet's controller can only
                // drive one, so content is swapped, never cross-faded.
                child: widget.builder(
                  context,
                  scrollController,
                  widget.expanded,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One page of the drawer: a grab handle, scrolling content, and an optional
/// action pinned under it (so a submit button rides above the keyboard).
class MdAuthSheetPage extends StatelessWidget {
  const MdAuthSheetPage({
    super.key,
    required this.scrollController,
    required this.children,
    this.action,
  });

  final ScrollController scrollController;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        Expanded(
          child: AutofillGroup(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Handle(),
                  const SizedBox(height: AppSpacing.md),
                  ...children,
                ],
              ),
            ),
          ),
        ),
        if (action != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              AppSpacing.md + bottomInset,
            ),
            child: action,
          )
        else
          SizedBox(height: bottomInset),
      ],
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ExcludeSemantics(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}
