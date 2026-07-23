import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/closet_colors.dart';

class HeroArche extends StatelessWidget {
  const HeroArche({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: const BoxDecoration(
        color: ClosetColors.vertFonce,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(120),
          topRight: Radius.circular(120),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome, // Or a 4-point star icon
                color: ClosetColors.doreClair,
                size: 14,
              ),
              const SizedBox(width: 8),
              const Text(
                'PIÈCE DE LA SEMAINE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.doreClair,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Robe Élégance Durable',
            style: GoogleFonts.cormorantGaramond(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: ClosetColors.creme,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sandro · Soie · T. 38 · Unique',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ClosetColors.creme.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: ClosetColors.doreClair,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Découvrir — 38 500 FCFA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: ClosetColors.vertFonce,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
