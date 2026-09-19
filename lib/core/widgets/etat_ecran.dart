import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_exception.dart';
import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import 'closet_buttons.dart';

/// Mappe un [AsyncValue] vers l'écran d'état correspondant, ou le contenu.
Widget corpsAsync<T>(
  AsyncValue<T> value, {
  required Widget Function(T data) data,
  VoidCallback? onRetry,
}) {
  return value.when(
    data: data,
    loading: () => const EtatEcran.chargement(),
    error: (e, _) => EtatEcran.erreur(erreur: e, onRetry: onRetry),
  );
}

/// États d'écran partagés : chargement, hors-ligne, erreur, vide, succès.
class EtatEcran extends StatelessWidget {
  const EtatEcran({
    super.key,
    required this.icone,
    required this.titre,
    required this.message,
    this.action,
    this.libelleAction,
    this.enChargement = false,
    this.erreurBrute,
  });

  final IconData icone;

  /// `null` = texte par défaut localisé, résolu dans [build] — les
  /// constructeurs nommés restent ainsi `const` sans dépendre du contexte.
  final String? titre;
  final String? message;
  final VoidCallback? action;
  final String? libelleAction;
  final bool enChargement;

  /// Erreur brute d'origine (`.erreur`) : le message backend n'est extrait
  /// qu'au [build], une fois la locale de l'utilisateur connue.
  final Object? erreurBrute;

  /// Attente d'une réponse serveur.
  const EtatEcran.chargement({super.key, this.message})
      : icone = Icons.hourglass_empty_rounded,
        titre = null,
        action = null,
        libelleAction = null,
        enChargement = true,
        erreurBrute = null;

  factory EtatEcran.horsLigne({Key? key, VoidCallback? onRetry}) {
    return EtatEcran(
      key: key,
      icone: Icons.wifi_off_rounded,
      titre: null,
      message: null,
      action: onRetry,
      libelleAction: null,
    );
  }

  factory EtatEcran.erreur({
    Key? key,
    Object? erreur,
    VoidCallback? onRetry,
  }) {
    if (estHorsLigne(erreur ?? '')) {
      return EtatEcran.horsLigne(key: key, onRetry: onRetry);
    }
    return EtatEcran(
      key: key,
      icone: Icons.error_outline_rounded,
      titre: null,
      message: null,
      action: onRetry,
      libelleAction: null,
      erreurBrute: erreur,
    );
  }

  factory EtatEcran.vide({
    Key? key,
    IconData icone = Icons.inbox_outlined,
    String? titre,
    String? message,
    VoidCallback? action,
    String? libelleAction,
  }) {
    return EtatEcran(
      key: key,
      icone: icone,
      titre: titre,
      message: message,
      action: action,
      libelleAction: libelleAction,
    );
  }

  factory EtatEcran.succes({
    Key? key,
    IconData icone = Icons.check_circle_outline_rounded,
    required String titre,
    required String message,
    VoidCallback? action,
    String? libelleAction,
  }) {
    return EtatEcran(
      key: key,
      icone: icone,
      titre: titre,
      message: message,
      action: action,
      libelleAction: libelleAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final erreur = erreurBrute;
    final backend = erreur == null ? null : messageErreur(erreur, l10n);
    final texteTitre = titre ??
        (enChargement
            ? l10n.unInstant
            : icone == Icons.wifi_off_rounded
                ? l10n.horsConnexionTitre
                : icone == Icons.error_outline_rounded
                    ? l10n.erreurTitre
                    : l10n.listeVideTitreCourt);
    final texteMessage = message ??
        (backend != null && backend.isNotEmpty
            ? backend
            : enChargement
                ? l10n.chargementEllipse
                : icone == Icons.wifi_off_rounded
                    ? l10n.horsConnexionMessage
                    : icone == Icons.error_outline_rounded
                        ? l10n.erreurGenerique
                        : l10n.aucuneDonneeMoment);
    final texteAction = libelleAction ?? (action != null ? l10n.retryLabel : null);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (enChargement)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.p20),
                child: CircularProgressIndicator(color: ClosetColors.dore),
              )
            else
              Icon(icone, size: 48, color: ClosetColors.fond300),
            const SizedBox(height: AppSpacing.p20),
            Text(
              texteTitre,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreSection,
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              texteMessage,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.citation.copyWith(
                color: ClosetColors.taupe,
              ),
            ),
            if (action != null && texteAction != null) ...[
              const SizedBox(height: AppSpacing.p24),
              ClosetPrimaryButton(
                label: texteAction,
                dore: true,
                hauteur: AppSpacing.minTouchTarget,
                onPressed: action,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
