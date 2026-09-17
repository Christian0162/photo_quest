import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/empty_states/empty_state.dart';
import '../../../../core/widgets/loading/loading_indicator.dart';
import '../view_models/memory_reveal_view_model.dart';

/// The satisfying payoff after finishing a Quest. See CLAUDE.md §37.
class MemoryRevealScreen extends ConsumerWidget {
  const MemoryRevealScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reveal = ref.watch(memoryRevealProvider(sessionId));

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: reveal.when(
          loading: () => const LoadingIndicator(),
          error: (error, stack) => const EmptyState(
            icon: Icons.error_outline_rounded,
            title: "Couldn't finish this memory",
            message: 'Please try again.',
          ),
          data: (result) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Text('Quest Complete ✨', style: AppTypography.heading2),
                const SizedBox(height: AppSpacing.xs),
                const Text('You made a memory.', style: AppTypography.body),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    child: Image.file(
                      File(result.stripPath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Keep This Memory',
                  onPressed: () => context.go('/memory/${result.memoryId}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
