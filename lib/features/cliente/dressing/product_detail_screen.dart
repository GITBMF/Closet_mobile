import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../selection/selection_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String maison;
  final String nom;
  final String prix;
  final String imageUrl;
  final String badgeText;

  const ProductDetailScreen({
    super.key,
    required this.maison,
    required this.nom,
    required this.prix,
    required this.imageUrl,
    required this.badgeText,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section with back button and heart
                Stack(
                  children: [
                    Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ClosetColors.creme,
                        image: DecorationImage(
                          image: NetworkImage(widget.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: ClosetColors.vertFonce,
                                  size: 24,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: _isFavorite ? ClosetColors.erreur : ClosetColors.vertFonce,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.maison.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w700,
                              color: ClosetColors.doreEncre,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6E4DF), // Light green tint as seen in image
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.badgeText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ClosetColors.vert,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.nom,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.prix,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Details Block
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ClosetColors.creme,
                          border: Border.all(color: ClosetColors.ligne),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TAILLE & COUPE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: ClosetColors.taupe,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'T. 38',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: ClosetColors.vertFonce,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'UNIVERS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: ClosetColors.taupe,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Robes',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: ClosetColors.vertFonce,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'MATIÈRE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: ClosetColors.taupe,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Soie',
                                    style: GoogleFonts.cormorantGaramond(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: ClosetColors.vertFonce,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'AUTHENTICITÉ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: ClosetColors.taupe,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.verified_user_outlined, size: 16, color: ClosetColors.succes),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Vérifiée',
                                        style: GoogleFonts.cormorantGaramond(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: ClosetColors.succes,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // About this piece
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: ClosetColors.doreEncre, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'À PROPOS DE CETTE PIÈCE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              color: ClosetColors.doreEncre,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '« Cette pièce a été soigneusement sélectionnée pour son élégance intemporelle. Une soie mate qui capte la lumière, une coupe drapée qui célèbre le mouvement — un vestiaire de soirée qui traverse les saisons. »',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: ClosetColors.vertFonce,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      // Delivery info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ClosetColors.creme,
                          border: Border.all(color: ClosetColors.doreClair),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.local_shipping_outlined, color: ClosetColors.taupe, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ClosetColors.taupe,
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Livraison délicate — ',
                                      style: TextStyle(fontWeight: FontWeight.w700, color: ClosetColors.vertFonce),
                                    ),
                                    const TextSpan(
                                      text: 'Yaoundé sous 24h, expédition internationale sous 5 jours ouvrés, écrin Clos ET inclus.',
                                    ),
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
          
          // Floating Bottom Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: ClosetColors.vertFonce,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'À ADOPTER',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                            color: ClosetColors.doreClair,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.prix.split(' ')[0] + ' ' + widget.prix.split(' ')[1], // e.g., '38 500'
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'FCFA',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectionScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: ClosetColors.doreClair,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: ClosetColors.vertFonce, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'DÉJÀ DANS MA SÉLECTION',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w800,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
