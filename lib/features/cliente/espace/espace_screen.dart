import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../selection/confirmation_screen.dart';

class EspaceScreen extends StatelessWidget {
  const EspaceScreen({super.key});

  Widget _buildAppBarAction(
    IconData icon, {
    int badgeCount = 0,
    Color? badgeColor,
    Color badgeTextColor = Colors.white,
  }) {
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
            onPressed: () {},
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

  Widget _buildStatBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ClosetColors.ligne),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 8,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                color: ClosetColors.taupe,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: ClosetColors.vertFonce,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String name,
    required String date,
    required String status,
    required Color statusColor,
    required Color statusDotColor,
    required String price,
    required String details,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ClosetColors.ligne),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                date,
                style: const TextStyle(fontSize: 10, color: ClosetColors.taupe),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: (statusColor == ClosetColors.vertFonce)
                            ? Colors.white
                            : ClosetColors.vertFonce,
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
          const SizedBox(height: 12),
          Text(
            details,
            style: const TextStyle(fontSize: 10, color: ClosetColors.taupe),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, {IconData icon = Icons.chevron_right}) {
    return Container(
      decoration: BoxDecoration(
        color: ClosetColors.creme,
        border: Border(
          bottom: BorderSide(color: ClosetColors.ligne.withValues(alpha: 0.5)),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: ClosetColors.vertFonce,
          ),
        ),
        trailing: Icon(icon, size: 20, color: ClosetColors.vertFonce),
        onTap: () {},
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
                  'Mon Espace',
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
        actions: [
          _buildAppBarAction(Icons.search),
          _buildAppBarAction(
            Icons.favorite_border,
            badgeCount: 2,
            badgeColor: ClosetColors.erreur,
          ),
          _buildAppBarAction(Icons.shopping_bag_outlined),
          _buildAppBarAction(
            Icons.notifications_none,
            badgeCount: 3,
            badgeColor: ClosetColors.doreClair,
            badgeTextColor: ClosetColors.vertFonce,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: ClosetColors.vertFonce,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'AD',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: ClosetColors.doreClair,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Awa Diallo',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'MEMBRE DEPUIS 2024',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: ClosetColors.taupe,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2C26), // Darker green
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: ClosetColors.doreClair,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'CERCLE PRIVILÈGE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                            color: ClosetColors.doreClair,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildStatBox('ADOPTIONS', '3'),
                  const SizedBox(width: 8),
                  _buildStatBox('POINTS', '480'),
                  const SizedBox(width: 8),
                  _buildStatBox('WISHLIST', '2'),
                  const SizedBox(width: 8),
                  _buildStatBox('SÉLECTION', '0'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sourceur Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  color: ClosetColors.vertFonce,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                    topRight: Radius.circular(80),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ClosetColors.doreClair,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: ClosetColors.vertFonce,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'NOUVEAU',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              color: ClosetColors.vertFonce,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Devenir Sourceur Clos ET',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Confiez vos pièces d'exception et rejoignez notre cercle privé de curatrices.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFC7A87D,
                        ), // Gold color matches image
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'REJOINDRE LE CERCLE',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Historique Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: ClosetColors.doreEncre,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'HISTORIQUE',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.doreEncre,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mes commandes',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Orders list
                  _buildOrderCard(
                    name: 'Robe Élégance Durable +1',
                    date: '23 juillet',
                    status: 'En préparation',
                    statusColor: const Color(0xFFE5E2D9),
                    statusDotColor: ClosetColors.vertFonce,
                    price: '66 500 FCFA',
                    details: 'CE-2026-0145 · Orange Money',
                  ),
                  _buildOrderCard(
                    name: 'Sac Cuir Camel',
                    date: '28 février',
                    status: 'Expédiée',
                    statusColor: const Color(0xFFE5EEF3), // Light blue
                    statusDotColor: const Color(0xFF4A7B9D), // Darker blue dot
                    price: '34 500 FCFA',
                    details: 'CE-2026-0128 · MTN MoMo',
                  ),
                  _buildOrderCard(
                    name: 'Blouse Ivoire Fluide',
                    date: '14 février',
                    status: 'Livrée',
                    statusColor: const Color(0xFF1C2C26),
                    statusDotColor: ClosetColors.doreClair,
                    price: '22 000 FCFA',
                    details: 'CE-2026-0091 · Orange Money',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ClosetColors.creme,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ClosetColors.ligne),
                ),
                child: Column(
                  children: [
                    _buildMenuItem('Mes informations'),
                    _buildMenuItem('Adresses de livraison'),
                    _buildMenuItem('Préférences de taille'),
                    _buildMenuItem('Notifications WhatsApp'),
                    _buildMenuItem('Aide & conciergerie'),
                    Container(
                      decoration: const BoxDecoration(
                        color: ClosetColors.creme,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        title: Text(
                          'Se déconnecter',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: ClosetColors.vertFonce,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Footer
            const Text(
              "CLOS ET · L'ÉLÉGANCE DURABLE",
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w700,
                color: ClosetColors.taupe,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfirmationScreen(),
                    ),
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
                    'VOIR MON DERNIER SUIVI',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: ClosetColors.vertFonce,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
