import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_exception.dart';
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
  });

  final IconData icone;
  final String titre;
  final String message;
  final VoidCallback? action;
  final String? libelleAction;
  final bool enChargement;

  /// Attente d'une réponse serveur.
  const EtatEcran.chargement({
    super.key,
    this.message = 'Chargement…',
  })  : icone = Icons.hourglass_empty_rounded,
        titre = 'Un instant',
        action = null,
        libelleAction = null,
        enChargement = true;

  factory EtatEcran.horsLigne({Key? key, VoidCallback? onRetry}) {
    return EtatEcran(
      key: key,
      icone: Icons.wifi_off_rounded,
      titre: 'Hors connexion',
      message:
          'Impossible de joindre ClosET. Vérifiez votre réseau puis réessayez.',
      action: onRetry,
      libelleAction: 'Réessayer',
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
      titre: 'Une erreur est survenue',
      message: messageMelange(
        local: 'Veuillez réessayer.',
        backend: messageErreur(erreur ?? ''),
      ),
      action: onRetry,
      libelleAction: 'Réessayer',
    );
  }

  factory EtatEcran.vide({
    Key? key,
    IconData icone = Icons.inbox_outlined,
    String titre = 'Liste vide',
    String message = 'Aucune donnée pour le moment.',
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
              titre,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreSection,
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.citation.copyWith(
                color: ClosetColors.taupe,
              ),
            ),
            if (action != null && libelleAction != null) ...[
              const SizedBox(height: AppSpacing.p24),
              ClosetPrimaryButton(
                label: libelleAction!,
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
