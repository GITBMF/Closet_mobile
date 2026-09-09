import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_exception.dart';
import '../l10n/closet_l10n.dart';
import '../services/notification_service.dart';
import 'closet_feedback.dart';

/// Toasts globaux — le bandeau [TopNotificationOverlay] les affiche.
void toastInfo(WidgetRef ref, String titre, [String? message]) {
  ref.read<NotificationNotifier>(notificationProvider.notifier).show(
        titre,
        message ?? titre,
      );
}

void toastSucces(WidgetRef ref, String titre, [String? message]) {
  ref
      .read<NotificationNotifier>(notificationProvider.notifier)
      .showSuccess(titre, message ?? titre);
}

/// Toast d'une action sur une pièce : le nom en titre, le résultat en corps.
void toastActionPiece(
  WidgetRef ref, {
  required String nom,
  required String resultat,
  bool succes = true,
}) {
  final l10n = ref.read(l10nProvider);
  final phrase = l10n.toastPiece(nom, resultat);
  if (succes) {
    toastSucces(ref, nom, phrase);
  } else {
    toastInfo(ref, nom, phrase);
  }
}

/// Titre prédéfini + texte serveur s’il existe, sinon le complément local.
void toastMelange(
  WidgetRef ref, {
  required String titre,
  String? local,
  String? backend,
  bool succes = false,
}) {
  final corps = messageMelange(local: local ?? titre, backend: backend);
  final notifier = ref.read<NotificationNotifier>(notificationProvider.notifier);
  if (succes) {
    notifier.showSuccess(titre, corps);
  } else {
    notifier.show(titre, corps);
  }
}

void toastErreur(WidgetRef ref, Object erreur, {String? titre}) {
  final l10n = ref.read(l10nProvider);
  final texte = l10n.messageDepuisErreur(erreur);
  ref.read<NotificationNotifier>(notificationProvider.notifier).showError(
        titre ?? l10n.erreurTitre,
        texte.isEmpty ? l10n.erreurGenerique : texte,
      );
}

/// Toast à la transition d'un [AsyncValue] : erreur backend, ou liste vide.
///
/// [context] permet d'ignorer les onglets hors écran (IndexedStack).
void signaleTransitionAsync<T>({
  required WidgetRef ref,
  required BuildContext context,
  required AsyncValue<T>? precedent,
  required AsyncValue<T> suivant,
  required String titre,
  String? messageVide,
  bool Function(T data)? estVide,
}) {
  if (!context.mounted) return;
  if (!TickerMode.valuesOf(context).enabled) return;
  suivant.whenOrNull(
    error: (e, _) {
      if (precedent?.hasError == true) return;
      toastErreur(ref, e, titre: titre);
    },
    data: (d) {
      if (messageVide == null || estVide == null || !estVide(d)) return;
      final dejaVide =
          precedent?.asData != null && estVide(precedent!.asData!.value);
      if (dejaVide) return;
      toastInfo(ref, titre, messageVide);
    },
  );
}

/// Fenêtre de succès — à utiliser pour une action aboutie (dépôt, auth…).
Future<void> dialogueSucces(
  BuildContext context, {
  required String titre,
  required String message,
  String libelle = 'OK',
}) {
  return ClosetDialogue.resultat(
    context,
    succes: true,
    titre: titre,
    message: message,
    libelle: libelle,
  );
}

/// Fenêtre d'erreur : titre local, corps compréhensible (jamais de jargon HTTP).
Future<void> dialogueErreur(
  BuildContext context,
  Object erreur, {
  String? titre,
}) {
  final l10n = ClosetL10n.of(context);
  return ClosetDialogue.resultat(
    context,
    succes: false,
    titre: titre ?? l10n.erreurTitre,
    message: l10n.messageDepuisErreur(erreur),
  );
}
