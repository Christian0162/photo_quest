import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/empty_states/empty_state.dart';
import '../../../../core/widgets/loading/loading_indicator.dart';
import '../view_models/memory_detail_view_model.dart';

/// Memory title, date, people, photos, and the "Do This Again" bridge to a
/// new Quest session. See CLAUDE.md §39.
class MemoryDetailScreen extends ConsumerWidget {
  const MemoryDetailScreen({super.key, required this.memoryId});

  final String memoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(memoryDetailProvider(memoryId));

    return Scaffold(
      appBar: AppBar(),
      body: detail.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: "Couldn't load this memory",
          message: 'Please go back and try again.',
        ),
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(data.memory.title, style: AppTypography.heading1),
              const SizedBox(height: AppSpacing.xs),
              Text(
                DateFormat.yMMMMd().format(data.memory.capturedAt),
                style: AppTypography.bodyMuted,
              ),
              if (data.people.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final person in data.people)
                      Chip(label: Text(person.name)),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (data.photos.isEmpty)
                const EmptyState(
                  icon: Icons.photo_rounded,
                  title: 'No photos yet',
                  message: 'Photos from this Quest will show up here.',
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                  ),
                  itemCount: data.photos.length,
                  itemBuilder: (context, index) {
                    final photo = data.photos[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      child: Image.file(
                        File(photo.thumbnailPath),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              if (data.memory.note != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(data.memory.note!, style: AppTypography.body),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (data.questId != null)
                PrimaryButton(
                  label: 'Do This Again',
                  icon: Icons.replay_rounded,
                  onPressed: () => context.push('/quests/${data.questId}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
