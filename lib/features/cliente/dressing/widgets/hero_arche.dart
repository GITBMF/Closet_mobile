import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/closet_colors.dart';
import '../../../../core/widgets/status_badge.dart';

class HeroArche extends StatelessWidget {
  const HeroArche({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Beige Background shape
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: ClosetColors.beige,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(150),
                  topRight: Radius.circular(150),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),

          // Silhouette Image Center
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(90),
                  topRight: Radius.circular(90),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&q=80&w=400',
                  width: 180,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Dégradé et textes
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 40),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    ClosetColors.vertFonce.withValues(alpha: 0.82),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MAISON SAINT-HONORÉ',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                      color: ClosetColors.doreClair,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Robe Élégance Durable',
                    style: GoogleFonts.cormorantGaramond(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: ClosetColors.creme,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '38 500 FCFA',
                    style: GoogleFonts.cormorantGaramond(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: ClosetColors.doreClair,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Badge et Coeur
          const Positioned(
            top: 24,
            left: -4,
            child: StatusBadge(
              text: 'TRÈS BON ÉTAT',
              backgroundColor: ClosetColors.vertFonce,
              textColor: ClosetColors.doreClair,
            ),
          ),
          Positioned(
            top: 24,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_border,
                color: ClosetColors.vertFonce,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
