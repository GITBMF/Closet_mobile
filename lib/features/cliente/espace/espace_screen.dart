import 'package:flutter/material.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

class EspaceScreen extends StatelessWidget {
  const EspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: Center(
        child: Text('Espace Screen', style: ClosetTextStyles.titreEcran),
      ),
    );
  }
}
