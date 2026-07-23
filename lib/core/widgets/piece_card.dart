import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/closet_colors.dart';

class PieceCard extends StatefulWidget {
  final String maison;
  final String nom;
  final String prix;
  final String? imageUrl;
  final bool isImageArche;
  final String? statusBadgeText;
  final String? subtitle;
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
    this.subtitle,
    this.isFavorite = false,
    this.isSold = false,
    this.onFavoriteTap,
    this.onTap,
  });

  @override
  State<PieceCard> createState() => _PieceCardState();
}

class _PieceCardState extends State<PieceCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (widget.onFavoriteTap != null) {
      widget.onFavoriteTap!();
    }
  }

  Color _getBadgeColor(String text) {
    if (text.toLowerCase() == 'excellent') {
      return const Color(0xFFE0ECE5); // Light mint
    }
    return const Color(0xFFF3EAD7); // Light beige for Très bon
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: ClosetColors.ligne),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ClosetColors.creme, 
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: widget.imageUrl != null
                        ? ClipRRect(
                            borderRadius: widget.isImageArche
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(90),
                                    topRight: Radius.circular(90),
                                  )
                                : const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Opacity(
                              opacity: widget.isSold ? 0.6 : 1.0,
                              child: Image.network(
                                widget.imageUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
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
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? const Color(0xFF8B2516) : ClosetColors.vertFonce,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  if (widget.isSold)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Déjà adoptée',
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
                    widget.maison.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: ClosetColors.doreEncre,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.nom,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.vertFonce,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (widget.isSold)
                    Row(
                      children: [
                        const Icon(Icons.notifications_none, size: 14, color: ClosetColors.doreEncre),
                        const SizedBox(width: 4),
                        const Text(
                          "M'ALERTER",
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                            color: ClosetColors.doreEncre,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.prix,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                        if (widget.statusBadgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(widget.statusBadgeText!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.statusBadgeText!,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: ClosetColors.vertFonce,
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (widget.subtitle != null && !widget.isSold) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: ClosetColors.taupe,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


