import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import '../theme/locale_provider.dart';

/// Libellé de la langue active pour l'affichage dans les menus.
String libelleLangueCourante(Locale locale, ClosetL10n l10n) {
  return locale.languageCode == 'en' ? 'English' : 'Français';
}

/// Ouvre la bottom-sheet de choix de langue.
void afficherChoixLangue(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ChoixLangueSheet(ref: ref),
  );
}

class _ChoixLangueSheet extends StatelessWidget {
  const _ChoixLangueSheet({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final localeActuelle = ref.watch(localeProvider);
    final l10n = ClosetL10n.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p24,
        AppSpacing.p20,
        AppSpacing.p24,
        AppSpacing.p32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.p20),
              decoration: BoxDecoration(
                color: ClosetColors.carteBordure,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            l10n.langue,
            style: ClosetTextStyles.titreSection,
          ),
          const SizedBox(height: AppSpacing.p20),
          _TuileLangue(
            drapeau: '🇫🇷',
            libelle: 'Français',
            actif: localeActuelle.languageCode == 'fr',
            onTap: () {
              ref
                  .read(localeProvider.notifier)
                  .setLocale(const Locale('fr'));
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: AppSpacing.p12),
          _TuileLangue(
            drapeau: '🇬🇧',
            libelle: 'English',
            actif: localeActuelle.languageCode == 'en',
            onTap: () {
              ref
                  .read(localeProvider.notifier)
                  .setLocale(const Locale('en'));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _TuileLangue extends StatelessWidget {
  const _TuileLangue({
    required this.drapeau,
    required this.libelle,
    required this.actif,
    required this.onTap,
  });

  final String drapeau;
  final String libelle;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: actif ? ClosetColors.emeraude100 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.carte),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.carte),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p14,
          ),
          child: Row(
            children: [
              Text(drapeau, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.p16),
              Expanded(
                child: Text(libelle, style: ClosetTextStyles.libelle),
              ),
              if (actif)
                const Icon(
                  Icons.check_circle,
                  color: ClosetColors.vert,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
