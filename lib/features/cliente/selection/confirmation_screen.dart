import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../main_layout.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 12, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 40,
                color: ClosetColors.ligne,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ClosetColors.vertFonce,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: ClosetColors.taupe,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCartItem({
    required String image,
    required String name,
    required String details,
    required String price,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 10,
                    color: ClosetColors.taupe,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ClosetColors.vertFonce,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: ClosetColors.doreClair,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'C',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: ClosetColors.vertFonce,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Confirmation',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      const Text(
                        "L'ÉLÉGANCE DURABLE",
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.doreEncre,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Success Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: ClosetColors.vertFonce,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: ClosetColors.doreClair,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.auto_awesome, color: ClosetColors.vertFonce, size: 32),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'COMMANDE CONFIRMÉE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.doreClair,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Votre pièce est en route ✨',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Commande CE-2026-0145 · Merci Awa pour votre confiance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Total réglé — 66 500 FCFA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.doreClair,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ecrin Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ClosetColors.creme,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ClosetColors.ligne),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VOTRE ÉCRIN',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.doreEncre,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCartItem(
                      image: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&q=80&w=400',
                      name: 'Robe Élégance Durable',
                      details: 'Sandro · T. 38',
                      price: '38 500 FCFA',
                    ),
                    _buildCartItem(
                      image: 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80&w=400',
                      name: 'Veste Tweed Crème',
                      details: 'Maje · T. 36',
                      price: '24 500 FCFA',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Order Tracking
              const Text(
                'SUIVI DE VOTRE COMMANDE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.doreEncre,
                ),
              ),
              const SizedBox(height: 20),
              _buildTimelineStep(
                icon: Icons.check,
                title: 'Paiement reçu',
                subtitle: "À l'instant",
                iconColor: Colors.white,
                iconBgColor: ClosetColors.succes,
              ),
              _buildTimelineStep(
                icon: Icons.inventory_2_outlined,
                title: "En préparation dans l'écrin",
                subtitle: 'Sous 2h',
                iconColor: ClosetColors.vertFonce,
                iconBgColor: ClosetColors.doreClair,
              ),
              _buildTimelineStep(
                icon: Icons.local_shipping_outlined,
                title: 'Expédition — livraison délicate',
                subtitle: 'Demain',
                iconColor: ClosetColors.taupe,
                iconBgColor: Colors.white,
              ),
              _buildTimelineStep(
                icon: Icons.home_outlined,
                title: 'Livraison à votre adresse',
                subtitle: '48h',
                iconColor: ClosetColors.taupe,
                iconBgColor: Colors.white,
                isLast: true,
              ),
              const SizedBox(height: 24),

              // Notifications info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ClosetColors.ligne),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 14, color: ClosetColors.doreEncre),
                        const SizedBox(width: 8),
                        const Text(
                          'NOTIFICATIONS',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                            color: ClosetColors.doreEncre,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: ClosetColors.noir,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Vous recevrez un '),
                          const TextSpan(text: 'e-mail', style: TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: ' à '),
                          TextSpan(text: 'kongnyuylivingstone@gmail.com', style: TextStyle(fontStyle: FontStyle.italic, color: ClosetColors.taupe.withValues(alpha: 0.8))),
                          const TextSpan(text: ' et un '),
                          const TextSpan(text: 'message WhatsApp', style: TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: ' au '),
                          TextSpan(text: '+237 6 77 45 22 18', style: TextStyle(fontStyle: FontStyle.italic, color: ClosetColors.taupe.withValues(alpha: 0.8))),
                          const TextSpan(text: ' à chaque étape.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              GestureDetector(
                onTap: () {
                  // Usually, go back to a main tab like Espace or Dressing
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 4)),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: ClosetColors.vertFonce,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'SUIVRE DEPUIS MON ESPACE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 1)),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: ClosetColors.vertFonce),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'CONTINUER LA DÉCOUVERTE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: ClosetColors.vertFonce,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
