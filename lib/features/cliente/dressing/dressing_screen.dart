import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/piece_card.dart';
import 'widgets/hero_arche.dart';
import 'product_detail_screen.dart';

class DressingScreen extends StatelessWidget {
  const DressingScreen({super.key});

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

  Widget _buildInfoCard(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: ClosetColors.creme,
          border: Border.all(color: ClosetColors.ligne),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ClosetColors.doreEncre, size: 20),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: ClosetColors.vertFonce,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
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
                    'Clos ET',
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
                      color: ClosetColors.taupe,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          _buildAppBarAction(Icons.search),
          _buildAppBarAction(Icons.favorite_border, badgeCount: 2, badgeColor: ClosetColors.erreur),
          _buildAppBarAction(Icons.shopping_bag_outlined, badgeCount: 2, badgeColor: ClosetColors.vertFonce),
          _buildAppBarAction(Icons.notifications_none, badgeCount: 2, badgeColor: ClosetColors.doreClair, badgeTextColor: ClosetColors.vertFonce),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 12.0,
          bottom: 40.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeroArche(),
            const SizedBox(height: 16),
            
            // Info Cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(Icons.auto_awesome, 'AUTHENTIFIÉES'),
                const SizedBox(width: 8),
                _buildInfoCard(Icons.local_shipping_outlined, 'LIVRAISON\nDÉLICATE'),
                const SizedBox(width: 8),
                _buildInfoCard(Icons.security, 'PAIEMENT\nSÉCURISÉ'),
              ],
            ),

            const SizedBox(height: 24),

            // EXPLORER PAR UNIVERS
            const Text(
              'EXPLORER PAR UNIVERS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: ClosetColors.doreEncre,
              ),
            ),
            const SizedBox(height: 12),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  ClosetChip(label: "Tout l'univers", isActive: true),
                  SizedBox(width: 8),
                  ClosetChip(label: 'Robes'),
                  SizedBox(width: 8),
                  ClosetChip(label: 'Vestes'),
                  SizedBox(width: 8),
                  ClosetChip(label: 'Sacs'),
                  SizedBox(width: 8),
                  ClosetChip(label: 'Escarpins'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nouveautés du dressing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Nouveautés du dressing',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const Text(
                  'TOUT DÉCOUVRIR →',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PieceCard(
                    maison: 'SÉZANE',
                    nom: 'Sac Cuir Camel',
                    prix: '31 000 FCFA',
                    statusBadgeText: 'Très bon',
                    subtitle: 'T. Porté épaule - Cuir pleine fleur',
                    imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=400',
                    isImageArche: true,
                    isFavorite: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(
                            maison: 'SÉZANE',
                            nom: 'Sac Cuir Camel',
                            prix: '31 000 FCFA',
                            imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=400',
                            badgeText: 'Très bon',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: PieceCard(
                    maison: 'MAJE',
                    nom: 'Veste Tweed Crème',
                    prix: '24 500 FCFA',
                    statusBadgeText: 'Excellent',
                    subtitle: 'T. 36 - Laine - Tweed',
                    imageUrl: 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80&w=400',
                    isImageArche: true,
                    isFavorite: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(
                            maison: 'MAJE',
                            nom: 'Veste Tweed Crème',
                            prix: '24 500 FCFA',
                            imageUrl: 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80&w=400',
                            badgeText: 'Excellent',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Coup de cœur Clos ET
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Coup de cœur Clos ET',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const Text(
                  'VOIR →',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PieceCard(
                    maison: 'RUE SEREINE',
                    nom: 'Blouse Ivoire Fluide',
                    prix: '18 500 FCFA',
                    statusBadgeText: 'Très bon',
                    subtitle: 'T. S - Soie',
                    imageUrl: 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?auto=format&fit=crop&q=80&w=400',
                    isImageArche: true,
                    isFavorite: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(
                            maison: 'RUE SEREINE',
                            nom: 'Blouse Ivoire Fluide',
                            prix: '18 500 FCFA',
                            imageUrl: 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?auto=format&fit=crop&q=80&w=400',
                            badgeText: 'Très bon',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: PieceCard(
                    maison: 'MASSIMO DUTTI',
                    nom: 'Robe Plissée Sable',
                    prix: '22 000 FCFA',
                    statusBadgeText: 'Très bon',
                    subtitle: 'T. 38 - Viscose',
                    imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&q=80&w=400',
                    isImageArche: true,
                    isFavorite: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductDetailScreen(
                            maison: 'MASSIMO DUTTI',
                            nom: 'Robe Plissée Sable',
                            prix: '22 000 FCFA',
                            imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&q=80&w=400',
                            badgeText: 'Très bon',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Maisons du moment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Maisons du moment',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const Text(
                  'TOUTES →',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildMaisonChip('Sandro'),
                  const SizedBox(width: 8),
                  _buildMaisonChip('Maje'),
                  const SizedBox(width: 8),
                  _buildMaisonChip('Sézane'),
                  const SizedBox(width: 8),
                  _buildMaisonChip('Massimo Dutti'),
                  const SizedBox(width: 8),
                  _buildMaisonChip('Rue Sereine'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer Text
            const Center(
              child: Text(
                'CLOS ET · ABIDJAN — PARIS — YAOUNDÉ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: ClosetColors.taupe,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMaisonChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ClosetColors.creme,
        border: Border.all(color: ClosetColors.ligne),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          color: ClosetColors.vertFonce,
        ),
      ),
    );
  }
}
