import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import 'closet_bottom_nav.dart';

/// Snackbar global, compact, au-dessus de la barre de navigation.
class TopNotificationOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const TopNotificationOverlay({super.key, required this.child});

  @override
  ConsumerState<TopNotificationOverlay> createState() =>
      _TopNotificationOverlayState();
}

class _TopNotificationOverlayState extends ConsumerState<TopNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  ClosetNotification? _cachedNotification;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _margeBasse(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    return inset +
        ClosetBottomNav.hauteurOnglets +
        AppSpacing.p4 * 2 +
        AppSpacing.p8;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ClosetNotification?>(notificationProvider, (previous, next) {
      if (next != null) {
        setState(() {
          _cachedNotification = next;
        });
        _controller.forward(from: 0);
      } else {
        _controller.reverse().then((_) {
          if (mounted &&
              ref.read<ClosetNotification?>(notificationProvider) == null) {
            setState(() {
              _cachedNotification = null;
            });
          }
        });
      }
    });

    final notification = _cachedNotification;

    return Stack(
      children: [
        widget.child,
        if (notification != null)
          Positioned(
            left: AppSpacing.p16,
            right: AppSpacing.p16,
            bottom: _margeBasse(context),
            child: SlideTransition(
              position: _offsetAnimation,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read<NotificationNotifier>(
                          notificationProvider.notifier,
                        )
                        .dismiss();
                  },
                  onVerticalDragUpdate: (details) {
                    if ((details.primaryDelta ?? 0) > 5) {
                      ref
                          .read<NotificationNotifier>(
                            notificationProvider.notifier,
                          )
                          .dismiss();
                    }
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(notification.type),
                      borderRadius: BorderRadius.circular(AppRadius.carte),
                      border: Border.all(
                        color: _getBorderColor(notification.type),
                        width: AppStroke.fin,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(notification.type),
                            color: _getIconColor(notification.type),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _texte(notification),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ClosetTextStyles.detail.copyWith(
                                color: _getTextColor(notification.type),
                                fontWeight: FontWeight.w500,
                                height: 1.25,
                              ),
                            ),
                          ),
                          if (notification.actionLabel != null)
                            TextButton(
                              onPressed: () {
                                final action = notification.onAction;
                                ref
                                    .read<NotificationNotifier>(
                                      notificationProvider.notifier,
                                    )
                                    .dismiss();
                                action?.call();
                              },
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                minimumSize: const Size(44, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                notification.actionLabel!,
                                style: ClosetTextStyles.actionPetite.copyWith(
                                  color: _getTextColor(notification.type),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _texte(ClosetNotification n) {
    final titre = n.title.trim();
    final message = n.message.trim();
    if (message.isEmpty || message == titre) return titre;
    return '$titre — $message';
  }

  Color _getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return ClosetColors.fondsSucces;
      case NotificationType.error:
        return ClosetColors.fondsErreur;
      case NotificationType.info:
        return ClosetColors.vert;
    }
  }

  Color _getBorderColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return ClosetColors.succes.withValues(alpha: 0.35);
      case NotificationType.error:
        return ClosetColors.erreur.withValues(alpha: 0.35);
      case NotificationType.info:
        return ClosetColors.dore.withValues(alpha: 0.45);
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return ClosetColors.succes;
      case NotificationType.error:
        return ClosetColors.erreur;
      case NotificationType.info:
        return ClosetColors.doreClair;
    }
  }

  Color _getTextColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return ClosetColors.succes;
      case NotificationType.error:
        return ClosetColors.erreur;
      case NotificationType.info:
        return ClosetColors.creme;
    }
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }
}
