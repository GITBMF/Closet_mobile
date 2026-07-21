import 'package:flutter/material.dart';

import 'core/theme/closet_colors.dart';
import 'features/main_layout.dart';

void main() {
  runApp(const ClosetApp());
}

class ClosEtApp extends ConsumerWidget {
  const ClosEtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ClosET - L\'élégance durable',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: ClosetColors.ivoire,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ClosetColors.vert,
          surface: ClosetColors.ivoire,
        ),
      ),
      home: const MainLayout(),
    );
  }
}
