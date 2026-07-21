import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/closet_colors.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ClosetApp(),
    ),
  );
}

class ClosetApp extends ConsumerWidget {
  const ClosetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ClosET - L\'élégance durable',
      theme: AppTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: ClosetColors.beige,
        colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
          surface: ClosetColors.creme,
        ),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
