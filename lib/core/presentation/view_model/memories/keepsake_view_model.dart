import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/services/service_providers.dart';
import '../../../domain/memories/entities/photo.dart';

part 'keepsake_view_model.g.dart';

/// How the shots are laid out on the printed keepsake. See CLAUDE.md §36.
enum KeepsakeLayout {
  /// The classic tall photobooth strip.
  strip('Strip'),

  /// A two-column collage.
  grid('Grid'),

  /// One big instant print of the first shot.
  polaroid('Polaroid');

  const KeepsakeLayout(this.label);
  final String label;
}

/// The paper the keepsake is printed on.
enum KeepsakeFrame {
  cream('Classic'),
  film('Film'),
  coral('Coral'),
  sunny('Sunny'),
  mint('Mint');

  const KeepsakeFrame(this.label);
  final String label;
}

/// Stickers and props that can be placed on a keepsake. Icon stickers use
/// the app's icon set, stamps use the handwriting face — never emoji.
enum StickerType {
  heart('Heart'),
  star('Star'),
  sparkle('Sparkle'),
  sun('Sun'),
  flower('Flower'),
  camera('Camera'),
  party('Party popper'),
  crown('Crown'),
  paw('Paw print'),
  music('Music note'),
  bestDay('"Best day ever" stamp', stamp: 'Best day ever'),
  together('"Together" stamp', stamp: 'Together'),
  squad('"Squad" stamp', stamp: 'Squad'),
  love('"Love you" stamp', stamp: 'Love you');

  const StickerType(this.label, {this.stamp});

  /// Name read out by screen readers.
  final String label;

  /// The words on a text stamp, or null for an icon sticker.
  final String? stamp;

  bool get isStamp => stamp != null;
}

/// One sticker placed on the keepsake. Position and size are relative to
/// the keepsake, so the design renders identically at any size.
class PlacedSticker {
  const PlacedSticker({
    required this.id,
    required this.type,
    this.x = 0.5,
    this.y = 0.4,
    this.scale = 1,
    this.rotation = 0,
  });

  final String id;
  final StickerType type;

  /// Center, as a fraction of the keepsake's width (x) and height (y).
  final double x;
  final double y;

  /// 1 = the default size.
  final double scale;

  /// Radians, clockwise.
  final double rotation;

  PlacedSticker copyWith({
    double? x,
    double? y,
    double? scale,
    double? rotation,
  }) {
    return PlacedSticker(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}

/// A keepsake being designed: the shots, and how they're printed.
class KeepsakeDesign {
  const KeepsakeDesign({
    required this.memoryId,
    required this.title,
    required this.capturedAt,
    required this.shots,
    this.layout = KeepsakeLayout.strip,
    this.frame = KeepsakeFrame.cream,
    this.stickers = const [],
    this.selectedStickerId,
    this.isSaving = false,
    this.isSaved = false,
  });

  /// Most stickers on one keepsake — keeps the print about the people.
  static const maxStickers = 12;

  final String memoryId;
  final String title;
  final DateTime capturedAt;

  /// Every shot, in order. The print shows their stills; a live print
  /// plays GIFs, boomerangs and 360° clips in place.
  final List<Photo> shots;
  final KeepsakeLayout layout;
  final KeepsakeFrame frame;
  final List<PlacedSticker> stickers;
  final String? selectedStickerId;
  final bool isSaving;

  /// Whether this design was saved with the memory. Prints kept before
  /// designs were saved only have their image, so they're shown as that
  /// image rather than redrawn from a default design.
  final bool isSaved;

  bool get canAddSticker => stickers.length < maxStickers;

  /// The design choices only — layout, paper, stickers — as saved JSON.
  String toJson() => jsonEncode({
    'layout': layout.name,
    'frame': frame.name,
    'stickers': [
      for (final s in stickers)
        {
          'type': s.type.name,
          'x': s.x,
          'y': s.y,
          'scale': s.scale,
          'rotation': s.rotation,
        },
    ],
  });

  /// This design with the choices from saved [json]. Anything unreadable
  /// (e.g. from a newer version) is skipped rather than failing.
  KeepsakeDesign withSaved(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      T? byName<T extends Enum>(List<T> values, Object? name) =>
          values.where((v) => v.name == name).firstOrNull;
      final saved = <PlacedSticker>[];
      for (final (i, raw) in (data['stickers'] as List? ?? []).indexed) {
        final type = byName(StickerType.values, raw['type']);
        if (type == null) continue;
        saved.add(
          PlacedSticker(
            id: 'saved-$i',
            type: type,
            x: (raw['x'] as num).toDouble(),
            y: (raw['y'] as num).toDouble(),
            scale: (raw['scale'] as num).toDouble(),
            rotation: (raw['rotation'] as num).toDouble(),
          ),
        );
      }
      return copyWith(
        layout: byName(KeepsakeLayout.values, data['layout']),
        frame: byName(KeepsakeFrame.values, data['frame']),
        stickers: saved,
        isSaved: true,
      );
    } catch (_) {
      return this;
    }
  }

  KeepsakeDesign copyWith({
    KeepsakeLayout? layout,
    KeepsakeFrame? frame,
    List<PlacedSticker>? stickers,
    String? selectedStickerId,
    bool clearSelection = false,
    bool? isSaving,
    bool? isSaved,
  }) {
    return KeepsakeDesign(
      memoryId: memoryId,
      title: title,
      capturedAt: capturedAt,
      shots: shots,
      layout: layout ?? this.layout,
      frame: frame ?? this.frame,
      stickers: stickers ?? this.stickers,
      selectedStickerId: clearSelection
          ? null
          : selectedStickerId ?? this.selectedStickerId,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

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
