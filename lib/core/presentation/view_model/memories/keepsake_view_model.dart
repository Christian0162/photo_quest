import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/service_providers.dart';
import '../../../domain/memories/enum/keepsake_layout.dart';
import '../../../domain/memories/enum/keepsake_frame.dart';
import '../../../domain/memories/enum/sticker_type.dart';
import '../../types/memories/placed_sticker.dart';
import '../../types/memories/keepsake_design.dart';

part 'keepsake_view_model.g.dart';

/// Designs the printed keepsake for a Memory — layout, paper, stickers —
/// and saves it as an image file. Shared by the reveal and the designer
/// screen so both show the same design. See CLAUDE.md §36-37.
@riverpod
class KeepsakeViewModel extends _$KeepsakeViewModel {
  int _nextStickerId = 0;

  @override
  Future<KeepsakeDesign> build(String memoryId) async {
    final memoryRepo = ref.watch(memoryRepositoryProvider);
    final memory = await memoryRepo.getMemory(memoryId);
    if (memory == null) throw StateError('Memory $memoryId was not found.');
    final design = KeepsakeDesign(
      memoryId: memoryId,
      title: memory.title,
      capturedAt: memory.capturedAt,
      shots: await memoryRepo.getPhotos(memoryId),
    );
    final saved = await memoryRepo.getKeepsakeDesign(memoryId);
    return saved == null ? design : design.withSaved(saved);
  }

  void _update(KeepsakeDesign Function(KeepsakeDesign) change) {
    final current = state.value;
    if (current == null || current.isSaving) return;
    state = AsyncData(change(current));
  }

  void setLayout(KeepsakeLayout layout) =>
      _update((d) => d.copyWith(layout: layout));

  void setFrame(KeepsakeFrame frame) =>
      _update((d) => d.copyWith(frame: frame));

  /// Drops a new sticker near the middle, nudged so several added in a row
  /// don't stack exactly on top of each other. Selects it.
  void addSticker(StickerType type) {
    _update((d) {
      if (!d.canAddSticker) return d;
      final id = 'sticker-${_nextStickerId++}';
      final nudge = (d.stickers.length % 5 - 2) * 0.06;
      final sticker = PlacedSticker(
        id: id,
        type: type,
        x: 0.5 + nudge,
        y: 0.4 + nudge / 2,
        rotation: nudge,
      );
      return d.copyWith(
        stickers: [...d.stickers, sticker],
        selectedStickerId: id,
      );
    });
  }

  void selectSticker(String? id) => _update(
    (d) => id == null
        ? d.copyWith(clearSelection: true)
        : d.copyWith(selectedStickerId: id),
  );

  /// Moves, resizes and rotates a sticker. Position stays on the keepsake
  /// and size within a sensible range.
  void transformSticker(
    String id, {
    required double x,
    required double y,
    required double scale,
    required double rotation,
  }) {
    _update(
      (d) => d.copyWith(
        stickers: [
          for (final s in d.stickers)
            s.id == id
                ? s.copyWith(
                    x: x.clamp(0, 1),
                    y: y.clamp(0, 1),
                    scale: scale.clamp(0.5, 3),
                    rotation: rotation,
                  )
                : s,
        ],
      ),
    );
  }

  void removeSticker(String id) => _update(
    (d) => d.copyWith(
      stickers: [
        for (final s in d.stickers)
          if (s.id != id) s,
      ],
      clearSelection: d.selectedStickerId == id,
    ),
  );

  /// Saves the rendered keepsake ([pngBytes]) as this memory's print, and
  /// the design itself so it can be re-opened and played live. Returns the
  /// print's path. Throws if it couldn't be saved.
  Future<String> save(Uint8List pngBytes) async {
    final current = state.value;
    if (current == null) throw StateError('Nothing to save yet.');
    state = AsyncData(current.copyWith(isSaving: true, clearSelection: true));
    try {
      final jpg = await ref
          .read(imageProcessingServiceProvider)
          .encodeKeepsake(pngBytes);
      final path = await ref
          .read(photoStorageServiceProvider)
          .savePhotoStrip(current.memoryId, jpg);
      await ref
          .read(memoryRepositoryProvider)
          .saveKeepsakeDesign(current.memoryId, current.toJson());
      if (ref.mounted) {
        state = AsyncData(state.value!.copyWith(isSaved: true));
      }
      return path;
    } catch (error, stack) {
      developer.log(
        'Saving keepsake failed',
        name: 'photoquest.keepsake',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    } finally {
      if (ref.mounted) {
        state = AsyncData(state.value!.copyWith(isSaving: false));
      }
    }
  }
}
