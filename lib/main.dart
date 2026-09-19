import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/closet_l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/locale_provider.dart';
import 'core/theme/police_provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/spotlight_showcase.dart';
import 'core/widgets/top_notification_overlay.dart';
import 'core/widgets/veille_reseau.dart';
import 'features/onboarding/visite_guidee.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  runApp(const ProviderScope(child: ClosetApp()));
}

class ClosetApp extends ConsumerWidget {
  const ClosetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch<GoRouter>(appRouterProvider);
    final themeMode = ref.watch<ThemeMode>(themeModeProvider);
    final locale = ref.watch<Locale>(localeProvider);
    final police = ref.watch(policeProvider);

    return MaterialApp.router(
      title: 'ClosET',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final onSurface = Theme.of(context).colorScheme.onSurface;
        // Branche le choix FR/EN persisté (`localeProvider`) sur le système
        // de textes `ClosetL10n` : sans ce wrapper, `ClosetL10n.of(context)`
        // ne trouve jamais d'ancêtre et retombe toujours sur le français,
        // quel que soit le choix enregistré dans le sélecteur de langue.
        final systeme = MediaQuery.textScalerOf(context).scale(1);
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(systeme * police.facteur)),
          child: ClosetL10n(
            locale: locale,
            child: Builder(
              builder: (innerContext) {
                final l10n = ClosetL10n.of(innerContext);
                return DefaultTextStyle(
                  style: TextStyle(color: onSurface),
                  child: IconTheme(
                    data: IconThemeData(color: onSurface),
                    child: VeilleReseau(
                      child: TopNotificationOverlay(
                        child: SpotlightShowcase(
                          steps: visiteGuidee(l10n),
                          child: child!,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
