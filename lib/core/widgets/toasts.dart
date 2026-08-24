import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/api_exception.dart';
import '../../data/models/article.dart';
import '../../data/repositories/wishlist_repository.dart';
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

void toastErreur(WidgetRef ref, Object erreur, {String titre = 'Erreur'}) {
  final texte = messageMelange(
    local: titre,
    backend: messageErreur(erreur),
  );
  ref
      .read<NotificationNotifier>(notificationProvider.notifier)
      .showError(titre, texte);
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

/// Fenêtre d'erreur : titre local, corps = message serveur ou le titre.
Future<void> dialogueErreur(
  BuildContext context,
  Object erreur, {
  String titre = 'Une erreur est survenue',
}) {
  return ClosetDialogue.resultat(
    context,
    succes: false,
    titre: titre,
    message: messageMelange(local: titre, backend: messageErreur(erreur)),
  );
}
