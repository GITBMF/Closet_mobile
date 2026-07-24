import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_header.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../main_layout.dart';

enum NotificationType { commande, nouveaute, avantage, livraison }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final String time;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.commande,
      title: 'Commande confirmée',
      description: 'CE-2026-0148 — votre écrin est en préparation.',
      time: 'À l\'instant',
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.commande,
      title: 'Commande confirmée',
      description: 'CE-2026-0147 — votre écrin est en préparation.',
      time: 'À l\'instant',
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.commande,
      title: 'Commande confirmée',
      description: 'CE-2026-0146 — votre écrin est en préparation.',
      time: 'À l\'instant',
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.commande,
      title: 'Commande confirmée',
      description: 'CE-2026-0145 — votre écrin est en préparation.',
      time: 'À l\'instant',
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.nouveaute,
      title: 'Nouveauté du dressing',
      description: 'Une soie ivoire vient d\'entrer — taille S.',
      time: 'il y a 20 min',
    ),
    NotificationItem(
      id: '6',
      type: NotificationType.avantage,
      title: 'Avantage exclusif',
      description: 'Cercle Privilège — 10% sur les vestes ce week-end.',
      time: 'Hier',
    ),
    NotificationItem(
      id: '7',
      type: NotificationType.livraison,
      title: 'Votre pièce est en route ✨',
      description: 'Commande CE-2026-0128 expédiée.',
      time: 'Il y a 2 jours',
      isRead: true, // In the image, the last one is read
    ),
  ];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.commande:
        return Icons.shopping_bag_outlined;
      case NotificationType.nouveaute:
        return Icons.auto_awesome;
      case NotificationType.avantage:
        return Icons.local_offer_outlined;
      case NotificationType.livraison:
        return Icons.local_shipping_outlined;
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
      }
    });
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return GestureDetector(
      onTap: () => _markAsRead(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? ClosetColors.creme : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead ? ClosetColors.ligne : ClosetColors.doreClair,
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: item.isRead
              ? []
              : [
                  BoxShadow(
                    color: ClosetColors.doreClair.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: ClosetColors.vertFonce,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(item.type),
                size: 20,
                color: ClosetColors.doreClair,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ClosetColors.noir,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ClosetColors.taupe,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isRead)
              const Icon(Icons.check, size: 16, color: ClosetColors.taupe)
            else
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: ClosetColors.dore,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ClosetHeader(
              titre: 'Notifications',
              sousTitre: '$unreadCount NON LUES',
              wishlistCount: 2,
              panierCount: 0,
              notificationsCount: unreadCount,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FIL DU DRESSING',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w800,
                        color: ClosetColors.doreEncre,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vos alertes',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        color: ClosetColors.vertFonce,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Commandes, nouveautés et avantages exclusifs — au calme.',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: ClosetColors.taupe,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...notifications.map((item) => _buildNotificationCard(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClosetPrimaryButton(
          label: 'DÉCOUVRIR LES NOUVEAUTÉS',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainLayout(initialIndex: 1),
              ),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
