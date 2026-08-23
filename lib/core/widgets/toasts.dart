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

/// Ajoute ou retire une pièce des favoris, avec toast de confirmation.
Future<void> basculerFavori(WidgetRef ref, Article article) async {
  final etait = ref.read(wishlistListProvider).any((a) => a.id == article.id);
  try {
    await ref.read(wishlistProvider.notifier).toggleWishlist(article);
    if (etait) {
      toastInfo(ref, 'Retirée des favoris', article.title);
    } else {
      toastSucces(ref, 'Ajoutée à vos favoris', article.title);
    }
  } catch (e) {
    toastErreur(ref, e, titre: 'Favoris');
  }
}

void toastErreur(WidgetRef ref, Object erreur, {String titre = 'Erreur'}) {
  ref
      .read<NotificationNotifier>(notificationProvider.notifier)
      .showError(titre, messageErreur(erreur));
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

/// Fenêtre d'erreur — à utiliser pour une action échouée.
Future<void> dialogueErreur(
  BuildContext context,
  Object erreur, {
  String titre = 'Une erreur est survenue',
}) {
  return ClosetDialogue.resultat(
    context,
    succes: false,
    titre: titre,
    message: messageErreur(erreur),
  );
}
