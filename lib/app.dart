import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/constant/app_theme.dart';
import 'config/routes/app_router.dart';
import 'core/presentation/widget/organisms/md_launch_reveal.dart';

class PhotoQuestApp extends ConsumerWidget {
  const PhotoQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Photo Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      // Plays once per cold start, over the app as it loads.
      builder: (context, child) => MdLaunchReveal(child: child!),
    );
  }
}
