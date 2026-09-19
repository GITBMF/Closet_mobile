import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/services/premiere_utilisation_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/widgets/choix_langue.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../core/widgets/spotlight_showcase.dart';

/// Accueil de première utilisation — transcription des maquettes `5:1279`,
/// `5:1342`, `5:1371`, adaptée en un seul écran (langue + démo/passer).
///
/// Affiché une seule fois, sans compte, juste après le splash. « Voir la
/// démo » ouvre directement « Mon dressing » et y lance la visite guidée
/// (spotlight sur les boutons clés) ; « Passer » y va sans visite. Dans les
/// deux cas, se connecter reste possible à tout moment depuis l'onglet
/// Espace — l'app ne bloque jamais sur un écran de connexion forcée.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _passer(BuildContext context) async {
    unawaited(HapticFeedback.mediumImpact());
    await PremiereUtilisationService.marquerVue();
    if (context.mounted) context.go('/home');
  }

  Future<void> _voirLaDemo(BuildContext context, WidgetRef ref) async {
    unawaited(HapticFeedback.lightImpact());
    await PremiereUtilisationService.marquerVue();
    if (!context.mounted) return;
    // La visite rejoint elle-même chaque écran de son itinéraire, en
    // commençant par « Mon dressing » (voir visite_guidee.dart).
    ref.read(spotlightTourProvider.notifier).startTour();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo_fond_vert.png',
                  width: 180,
                  height: 102,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const SizedBox(width: 180, height: 102),
                ),
              ),
              const SizedBox(height: AppSpacing.p32),
              Text(
                l10n.onboardingBienvenue,
                textAlign: TextAlign.center,
                style: ClosetTextStyles.titreEcran.copyWith(
                  fontSize: 30,
                  height: 1.2,
                  color: ClosetColors.neutre200,
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              Text(
                l10n.onboardingSousTitre,
                textAlign: TextAlign.center,
                style: ClosetTextStyles.corps.copyWith(
                  fontSize: 17,
                  height: 1.4,
                  color: ClosetColors.beige,
                ),
              ),
              const SizedBox(height: AppSpacing.p32),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: () => afficherChoixLangue(context, ref),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.cercle),
                        border: Border.all(color: ClosetColors.fond300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.p16,
                          vertical: AppSpacing.p8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              locale.languageCode == 'en' ? '🇬🇧' : '🇫🇷',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: AppSpacing.p8),
                            Text(
                              libelleLangueCourante(locale, l10n),
                              style: ClosetTextStyles.libelle.copyWith(
                                color: ClosetColors.fond300,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.p4),
                            const Icon(
                              Icons.expand_more,
                              size: 16,
                              color: ClosetColors.fond300,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p40),
              ClosetPrimaryButton(
                label: l10n.onboardingVoirDemo,
                dore: true,
                hauteur: 44,
                onPressed: () => _voirLaDemo(context, ref),
              ),
              const SizedBox(height: AppSpacing.p16),
              Center(
                child: TextButton(
                  onPressed: () => _passer(context),
                  child: Text(
                    l10n.onboardingPasser,
                    style: ClosetTextStyles.bouton.copyWith(
                      color: ClosetColors.beige,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
