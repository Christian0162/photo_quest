import 'package:flutter/material.dart';
import '../../../../config/constant/app_spacing.dart';

/// Lays tiles out in even columns that fit the width (3 on most phones).
class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.children});

  final List<Widget> children;

  static const _maxTileWidth = 128.0;
  static const _gap = AppSpacing.ms;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + _gap) / (_maxTileWidth + _gap))
            .ceil()
            .clamp(2, 6);
        final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final child in children)
              SizedBox(key: child.key, width: width, child: child),
          ],
        );
      },
    );
  }
}
