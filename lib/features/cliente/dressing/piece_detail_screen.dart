import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';

class PieceDetailScreen extends StatelessWidget {
  final String maison;
  final String nom;
  final String prix;
  final String imageUrl;

  const PieceDetailScreen({
    super.key,
    required this.maison,
    required this.nom,
    required this.prix,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.creme,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Space for sticky bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image Area
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                      // Floating icon at bottom left
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ClosetColors.noir.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.wb_iridescent, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Metadata Section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand and Status
                      Row(
                        children: [
                          Text(
                            maison.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: Color(0xFF8B6C3F), // doreEncre
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2EFEA), // Light mint green
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Excellent',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Name
                      Text(
                        nom,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Price
                      Text(
                        prix,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Specifications Grid
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: ClosetColors.ligne),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildSpecItem('TAILLE & COUPE', 'T. 36'),
                                _buildSpecItem('MATIÈRE', 'Laine · Tweed'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _buildSpecItem('UNIVERS', 'Vestes'),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'AUTHENTICITÉ',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                          color: Color(0xFF8B6C3F),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.verified_outlined, size: 16, color: ClosetColors.vertFonce),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Vérifiée',
                                            style: GoogleFonts.cormorantGaramond(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: ClosetColors.vertFonce,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // About Section
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF8B6C3F)),
                          const SizedBox(width: 8),
                          const Text(
                            'À PROPOS DE CETTE PIÈCE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: Color(0xFF8B6C3F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '« Une coupe crop signée d\'une maison parisienne réputée pour son sens du geste couture. Un tweed écru rehaussé de fils dorés — une pièce d\'architecture pour le vestiaire de jour. »',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Delivery Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F0E6), // Light beige
                          border: Border.all(color: const Color(0xFFE4D5BE)), // Dore border
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.local_shipping_outlined, size: 20, color: Color(0xFF8B6C3F)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: ClosetColors.vertFonce,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Livraison délicate — ', style: TextStyle(fontWeight: FontWeight.w700)),
                                    const TextSpan(text: 'Yaoundé sous 24h, expédition internationale sous 5 jours ouvrés, écrin Clos ET inclus.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Floating App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 18,
            right: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingButton(Icons.chevron_left, () => Navigator.pop(context)),
                _buildFloatingButton(Icons.favorite_border, () {}), // Heart on right
              ],
            ),
          ),
          
          // Sticky Bottom Action Bar
          Positioned(
            bottom: 20,
            left: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ClosetColors.vertFonce,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ClosetColors.vertFonce.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left side text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'À ADOPTER',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Color(0xFFC7B393), // Goldish taupe
                          ),
                        ),
                        Text(
                          prix,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Right side button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC69C5C), // Gold color
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 16, color: ClosetColors.vertFonce),
                        const SizedBox(width: 8),
                        const Text(
                          'DÉJÀ DANS MA SÉLECTION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: ClosetColors.vertFonce, size: 24),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF8B6C3F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ClosetColors.vertFonce,
            ),
          ),
        ],
      ),
    );
  }
}
