import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../main_layout.dart';
import 'payment_screen.dart';
import '../../main_layout.dart';
import '../espace/notifications_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  Widget _buildAppBarAction(IconData icon, {int badgeCount = 0, Color? badgeColor, Color badgeTextColor = Colors.white, VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: ClosetColors.ligne),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(icon, color: ClosetColors.vertFonce, size: 20),
            onPressed: onPressed ?? () {},
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor ?? ClosetColors.erreur,
                  shape: BoxShape.circle,
                  border: Border.all(color: ClosetColors.creme, width: 1.5),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String label, {bool isActive = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isActive ? ClosetColors.vertFonce : Colors.transparent,
            shape: BoxShape.circle,
            border: isActive ? null : Border.all(color: ClosetColors.taupe.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: isActive ? Colors.white : ClosetColors.taupe,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 1.0,
            color: isActive ? ClosetColors.vertFonce : ClosetColors.taupe,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem({
    required String image,
    required String maison,
    required String name,
    required String price,
    required String badge,
    required String size,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ClosetColors.creme,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClosetColors.ligne),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Image.network(
              image,
              width: 90,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      maison.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.doreEncre,
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
                const SizedBox(height: 4),
                Text(
                  name,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6E4DF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.vert,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      size,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ClosetColors.taupe,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 16, color: ClosetColors.taupe),
                    const SizedBox(width: 4),
                    const Text(
                      'RETIRER',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.taupe,
                      ),
                    ),
                  ],
                ),
              ],
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ClosetColors.ligne),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.chevron_left, color: ClosetColors.vertFonce),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ma sélection',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const Text(
                  'ÉTAPE 1 / 3',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.taupe,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _buildAppBarAction(Icons.search, onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 1)), (route) => false)),
          _buildAppBarAction(Icons.favorite_border, badgeCount: 2, badgeColor: ClosetColors.erreur, onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 2)), (route) => false)),
          _buildAppBarAction(Icons.shopping_bag_outlined, onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 1)), (route) => false)),
          _buildAppBarAction(Icons.notifications_none, badgeCount: 6, badgeColor: ClosetColors.doreClair, badgeTextColor: ClosetColors.vertFonce, onPressed: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => const NotificationsScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 12.0, bottom: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStep('1', 'SÉLECTION', isActive: true),
                const SizedBox(width: 8),
                Container(width: 24, height: 1, color: ClosetColors.taupe.withValues(alpha: 0.2)),
                const SizedBox(width: 8),
                _buildStep('2', 'LIVRAISON'),
                const SizedBox(width: 8),
                Container(width: 24, height: 1, color: ClosetColors.taupe.withValues(alpha: 0.2)),
                const SizedBox(width: 8),
                _buildStep('3', 'PAIEMENT'),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Header text
            const Text(
              'RÉCAPITULATIF',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w700,
                color: ClosetColors.doreEncre,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ma sélection',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: ClosetColors.vertFonce,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Votre sélection est vide.',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: ClosetColors.taupe,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Empty State Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                // Using solid border since dashed requires custom painting
                border: Border.all(
                  color: ClosetColors.ligne,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 32,
                    color: ClosetColors.doreEncre,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Explorez le dressing pour composer votre écrin.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: ClosetColors.taupe,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 1)),
                        (route) => false,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2C26),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'EXPLORER',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

