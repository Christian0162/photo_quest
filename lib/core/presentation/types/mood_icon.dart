import 'package:flutter/material.dart';

import '../../domain/people/enum/mood.dart';

/// The icon that goes with each [Mood]. Kept out of the domain layer so it
/// stays free of Flutter UI. See CLAUDE.md §61.
extension MoodIcon on Mood {
  IconData get icon => switch (this) {
    Mood.happy => Icons.sentiment_very_satisfied_rounded,
    Mood.inLove => Icons.favorite_rounded,
    Mood.excited => Icons.celebration_rounded,
    Mood.calm => Icons.spa_rounded,
    Mood.tired => Icons.bedtime_rounded,
    Mood.sad => Icons.sentiment_dissatisfied_rounded,
  };
}
