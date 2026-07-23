import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../main_layout.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final List<Map<String, dynamic>> _wishlistItems = [
    {
      'id': '1',
      'maison': 'SÉZANE',
      'nom': 'Sac Cuir Camel',
      'prix': '31 000 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&q=80&w=400',
      'statusBadgeText': 'Très bon',
      'subtitle': 'T. Porté épaule',
    },
    {
      'id': '2',
      'maison': 'RUE SEREINE',
      'nom': 'Blouse Ivoire Fluide',
      'prix': '18 500 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80&w=400',
      'statusBadgeText': 'Très bon',
      'subtitle': 'T. S',
    },
  ];

  Widget _buildAppBarAction(IconData icon, {int badgeCount = 0, Color? badgeColor, Color badgeTextColor = Colors.white}) {
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

  Color _getBadgeColor(String text) {
    if (text.toLowerCase() == 'excellent') {
      return const Color(0xFFE0ECE5); // Light mint
    }
    return const Color(0xFFF3EAD7); // Light beige for Très bon
  }

  Widget _buildWishlistCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClosetColors.ligne),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 100,
            height: 120,
            decoration: const BoxDecoration(
              color: ClosetColors.creme,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.network(
                item['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['maison'],
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.doreEncre,
                      ),
                    ),
                    const Icon(Icons.favorite, color: Color(0xFF8B2516), size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['nom'],
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item['statusBadgeText'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(item['statusBadgeText']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['statusBadgeText'],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      item['subtitle'],
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: ClosetColors.taupe,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['prix'],
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: const [
                          Icon(Icons.shopping_bag_outlined, size: 14, color: ClosetColors.vertFonce),
                          SizedBox(width: 4),
                          Text(
                            'AJOUTER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: ClosetColors.vertFonce,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline, size: 14, color: ClosetColors.taupe),
                          SizedBox(width: 4),
                          Text(
                            'RETIRER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: ClosetColors.taupe,
                            ),
                          ),
                        ],
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: ClosetColors.ligne),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.chevron_left, color: ClosetColors.vertFonce, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ma wishlist',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const Text(
                  "COUPS DE CŒUR",
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
          _buildAppBarAction(Icons.search),
          _buildAppBarAction(Icons.favorite_border, badgeCount: 2, badgeColor: ClosetColors.erreur),
          _buildAppBarAction(Icons.shopping_bag_outlined),
          _buildAppBarAction(Icons.notifications_none, badgeCount: 6, badgeColor: ClosetColors.doreClair, badgeTextColor: ClosetColors.vertFonce),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VOS COUPS DE CŒUR',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.doreEncre,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ma wishlist',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: ClosetColors.vertFonce,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chaque pièce est unique — nous vous préviendrons si elle risque de partir.',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: ClosetColors.taupe,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    ..._wishlistItems.map((item) => _buildWishlistCard(item)),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 3)),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2C26),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PASSER À MA SÉLECTION',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
