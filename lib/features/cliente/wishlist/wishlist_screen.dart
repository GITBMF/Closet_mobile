import 'package:flutter/material.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: Center(
        child: Text('Wishlist Screen', style: ClosetTextStyles.titreEcran),
      ),
    );
  }
}
