import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/closet_colors.dart';

class PieceCard extends StatelessWidget {
  final String maison;
  final String nom;
  final String prix;
  final String? imageUrl;
  final bool isImageArche;
  final String? statusBadgeText;
  final bool isFavorite;
  final bool isSold;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const PieceCard({
    super.key,
    required this.maison,
    required this.nom,
    required this.prix,
    this.imageUrl,
    this.isImageArche = false,
    this.statusBadgeText,
    this.isFavorite = false,
    this.isSold = false,
    this.onFavoriteTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: ClosetColors.creme,
        border: Border.all(color: ClosetColors.ligne),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ClosetColors.beige, 
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: isImageArche
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(45),
                                  topRight: Radius.circular(45),
                                )
                              : BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl!,
                            width: 90,
                            height: 110,
                            fit: BoxFit.cover,
                            color: isSold ? Colors.black.withValues(alpha: 0.5) : null,
                            colorBlendMode: isSold ? BlendMode.darken : null,
                          ),
                        )
                      : const SizedBox(),
                ),

                if (statusBadgeText != null && !isSold)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ClosetColors.vertFonce,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusBadgeText!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: ClosetColors.doreClair,
                        ),
                      ),
                    ),
                  ),

                if (!isSold)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? const Color(0xFF8B2516) : ClosetColors.vertFonce,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                if (isSold)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      color: ClosetColors.vertFonce.withValues(alpha: 0.9),
                      child: const Text(
                        'A trouvé son dressing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maison.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.taupe,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nom,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.noir,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isSold ? 'Indisponible' : prix,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSold ? ClosetColors.taupe : ClosetColors.noir,
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
