import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/auth/intro_view_model.dart';
import '../../widget/templates/auth/intro_template.dart';

/// The get-started pages. Design lives in [IntroTemplate].
class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntroTemplate(
      onFinished: () => ref.read(introSeenProvider.notifier).markSeen(),
    );
  }
}
