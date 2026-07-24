import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


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
    final router = ref.watch<GoRouter>(appRouterProvider);
    final themeMode = ref.watch<ThemeMode>(themeModeProvider);

    return MaterialApp.router(
      title: 'ClosET - L\'élégance durable',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
