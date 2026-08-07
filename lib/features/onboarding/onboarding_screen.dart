import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock status bar color style for immersive feel
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: ClosetColors.vertFonce,
      body: Stack(
        children: [
          // 1. Background image (the luxury dressing room)
          Positioned.fill(
            child: Image.asset(
              'assets/landing_image.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback elegant color if image fails to load
                return Container(color: ClosetColors.vertFonce);
              },
            ),
          ),

          // 2. Dark elegant overlay for maximum legibility and contrast
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // 3. Main layout content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Top: Brand identity
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Official Closet Icon
                    Image.asset(
                      'assets/logo.png',
                      width: 90,
                      height: 90,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ClosetColors.doreClair,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.checkroom,
                              color: ClosetColors.doreClair,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Brand Name
                    Text(
                      'ClosET',
                      style: ClosetTextStyles.display.copyWith(
                        fontSize: 40,
                        color: ClosetColors.doreClair,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Brand Tagline / Baseline
                    Text(
                      "L'ÉLÉGANCE DURABLE",
                      style: ClosetTextStyles.labelChamp.copyWith(
                        color: ClosetColors.creme.withValues(alpha: 0.85),
                        letterSpacing: 4.5,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 3),

                // Bottom Content inside the iconic brand arch shape
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        color: ClosetColors.vert.withValues(alpha: 0.94),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(80),
                          topRight: Radius.circular(80),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(
                          color: ClosetColors.dore.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Welcome header in EB Garamond
                          Text(
                            'Votre Dressing Privé',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ebGaramond(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: ClosetColors.creme,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtitle description in Cormorant
                          Text(
                            'Une expérience de mode circulaire exclusive, alliant luxe et durabilité au quotidien.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorant(
                              fontSize: 16,
                              color: ClosetColors.creme.withValues(alpha: 0.85),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // CTA Button in Lato
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context.go('/home');
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: ClosetColors.creme,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: ClosetColors.dore,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'DÉCOUVRIR',
                                  style: GoogleFonts.lato(
                                    color: ClosetColors.vert,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
