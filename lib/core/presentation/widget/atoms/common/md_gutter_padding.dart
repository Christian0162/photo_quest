import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';

class MdGutterPadding extends StatelessWidget {
  const MdGutterPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: child,
    );
  }
}
