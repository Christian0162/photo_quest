import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../types/camera/memory_reveal_result.dart';
import '../../../types/memories/keepsake_design.dart';
import '../../atoms/common/md_loading_indicator.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/camera/md_memory_reveal.dart';

/// The payoff after finishing a Quest: the photo strip rises in and
/// develops like an instant print — pale and grey, then full color — before
/// who was there and when fade in. Warm, not a game victory screen. The
/// print is the live keepsake design: keeping it saves exactly what's on
/// screen, and it can be decorated first. See CLAUDE.md §36-37, design
/// system §32, §49.
class MemoryRevealTemplate extends StatelessWidget {
  const MemoryRevealTemplate({
    super.key,
    required this.reveal,
    this.keepsake,
    required this.onRetry,
    required this.onKeep,
    required this.onDecorate,
  });

  final AsyncValue<MemoryRevealResult> reveal;

  /// The keepsake design, once loaded. Until then the printed strip shows.
  final KeepsakeDesign? keepsake;
  final VoidCallback onRetry;

  /// Keeps the memory; receives a function that renders the print.
  final void Function(
    MemoryRevealResult result,
    Future<Uint8List?> Function() render,
  )
  onKeep;
  final ValueChanged<MemoryRevealResult> onDecorate;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      body: reveal.when(
        loading: () =>
            const MdLoadingIndicator(message: 'Printing your photo strip…'),
        error: (error, stack) => MdEmptyState.error(
          title: "We couldn't finish your photo strip",
          message: 'Your photos are safe. Please try again.',
          onRetry: onRetry,
        ),
        data: (result) => MdMemoryReveal(
          result: result,
          keepsake: keepsake,
          onKeep: (render) => onKeep(result, render),
          onDecorate: () => onDecorate(result),
        ),
      ),
    );
  }
}
