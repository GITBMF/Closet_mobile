import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/piece_card.dart';
import 'widgets/hero_arche.dart';

class DressingScreen extends StatelessWidget {
  const DressingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.creme,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BONJOUR AÏCHA',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.taupe,
                ),
              ),
              Text(
                'Mon dressing',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: ClosetColors.vertFonce,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: ClosetColors.vertFonce,
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 18, left: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: ClosetColors.vertFonce,
                size: 22,
              ),
              onPressed: () {},
            ),
          ),
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
            // Pièce de la semaine
            Text(
              'PIÈCE DE LA SEMAINE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: ClosetColors.taupe,
              ),
            ),
            const SizedBox(height: 8),
            const HeroArche(),

            const SizedBox(height: 24),

            // Nouveautés
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Nouveautés du dressing',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.noir,
                  ),
                ),
                const Text(
                  'Découvrir →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: PieceCard(
                    maison: 'Sézane',
                    nom: 'Veste Héritage',
                    prix: '24 000 F',
                    imageUrl:
                        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=400',
                    isImageArche: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: PieceCard(
                    maison: 'Ba&sh',
                    nom: 'Sac Rive Gauche',
                    prix: '31 500 F',
                    imageUrl:
                        'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80&w=400',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Univers
            Text(
              'Univers',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ClosetColors.noir,
              ),
            ),
            const SizedBox(height: 12),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  ClosetChip(label: 'Robes'),
                  SizedBox(width: 8),
                  ClosetChip(label: 'Vestes'),
                  SizedBox(width: 8),
                  ClosetChip(label: 'Sacs'),
                  SizedBox(width: 8),
                  ClosetChip(label: 'Chaussures'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sponsors
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: ClosetColors.creme,
                border: Border.all(color: ClosetColors.ligne),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Text(
                    'NOS MAISONS PARTENAIRES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: ClosetColors.taupe,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Hôtel Hilton ·',
                          style: GoogleFonts.cormorantGaramond(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: ClosetColors.taupe,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Galerie M.',
                          style: GoogleFonts.cormorantGaramond(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: ClosetColors.taupe,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
