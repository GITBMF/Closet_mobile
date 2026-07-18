import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  // S'assurer que le binding Flutter est initialisé
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le fichier .env
  await dotenv.load(fileName: ".env");

  // Lancer l'application enveloppée dans un ProviderScope pour Riverpod
  runApp(
    const ProviderScope(
      child: ClosEtApp(),
    ),
  );
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
    );
  }
}
