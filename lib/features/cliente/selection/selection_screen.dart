import 'package:flutter/material.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: Center(
        child: Text('Selection Screen', style: ClosetTextStyles.titreEcran),
      ),
    );
  }
}
