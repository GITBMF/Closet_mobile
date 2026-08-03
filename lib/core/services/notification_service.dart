import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Type de notification
enum NotificationType { info, success, error }

/// Représente une notification poussée / in-app.
class ClosetNotification {
  final String title;
  final String message;
  final NotificationType type;

  const ClosetNotification({
    required this.title,
    required this.message,
    this.type = NotificationType.info,
  });
}

/// Gère l'état de la notification active avec auto-suppression et retour haptique.
class NotificationNotifier extends Notifier<ClosetNotification?> {
  @override
  ClosetNotification? build() {
    return null;
  }

  Timer? _dismissTimer;

  void show(String title, String message, {NotificationType type = NotificationType.info}) {
    _dismissTimer?.cancel();
    
    // Déclenche le retour haptique léger lors de l'apparition
    HapticFeedback.lightImpact();
    
    state = ClosetNotification(title: title, message: message, type: type);

    // Auto-fermeture après 4 secondes
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      dismiss();
    });
  }

  void dismiss() {
    _dismissTimer?.cancel();
    state = null;
  }

  void showSuccess(String title, String message) {
    show(title, message, type: NotificationType.success);
  }

  void showError(String title, String message) {
    show(title, message, type: NotificationType.error);
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, ClosetNotification?>(() {
  return NotificationNotifier();
});
