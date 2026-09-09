import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';

/// Overlay global affichant un bandeau de notification haut de gamme par-dessus le contenu.
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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ClosetNotification?>(notificationProvider, (previous, next) {
      if (next != null) {
        setState(() {
          _cachedNotification = next;
        });
        _controller.forward();
      } else {
        _controller.reverse().then((_) {
          if (mounted && ref.read<ClosetNotification?>(notificationProvider) == null) {
            setState(() {
              _cachedNotification = null;
            });
          }
        });
      }
    });

    return Stack(
      children: [
        widget.child,
        if (_cachedNotification != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _offsetAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        ref.read<NotificationNotifier>(notificationProvider.notifier).dismiss();
                      },
                      onVerticalDragUpdate: (details) {
                        if (details.primaryDelta! < -5) {
                          ref.read<NotificationNotifier>(notificationProvider.notifier).dismiss();
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getBackgroundColor(_cachedNotification!.type),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getBorderColor(_cachedNotification!.type),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _getIconBackgroundColor(_cachedNotification!.type),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconData(_cachedNotification!.type),
                                    color: _getIconColor(_cachedNotification!.type),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _cachedNotification!.title,
                                        style: ClosetTextStyles.saisie.copyWith(
                                          color: _getTextColor(_cachedNotification!.type),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _cachedNotification!.message,
                                        style: ClosetTextStyles.corps.copyWith(
                                          color: _cachedNotification!.type == NotificationType.info 
                                              ? ClosetColors.creme.withValues(alpha: 0.9)
                                              : ClosetColors.noir.withValues(alpha: 0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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
              ),
            ),
          ),
      ],
    );
  }

  Color _getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return ClosetColors.fondsSucces.withValues(alpha: 0.95);
      case NotificationType.error:
        return ClosetColors.fondsErreur.withValues(alpha: 0.95);
      case NotificationType.info:
        return ClosetColors.noir.withValues(alpha: 0.85);
    }
  }

  Color _getBorderColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return ClosetColors.succes.withValues(alpha: 0.6);
      case NotificationType.error:
        return ClosetColors.erreur.withValues(alpha: 0.6);
      case NotificationType.info:
        return ClosetColors.dore.withValues(alpha: 0.6);
    }
  }

  Color _getIconBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return ClosetColors.succes.withValues(alpha: 0.15);
      case NotificationType.error:
        return ClosetColors.erreur.withValues(alpha: 0.15);
      case NotificationType.info:
        return ClosetColors.dore.withValues(alpha: 0.15);
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
        return ClosetColors.doreClair;
    }
  }

  IconData _getIconData(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.info:
        return Icons.notifications_active_outlined;
    }
  }
}
