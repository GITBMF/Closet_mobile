import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();

    // Navigation conditionnée à la fin de l'animation (pas de délai fixe)
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Petite pause pour que l'utilisateur voie le logo terminé
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) context.go('/onboarding');
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.vert, // Vert profond — écran immersif
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo officiel sur fond vert
                    Image.asset(
                      'assets/logo_fond_vert.png',
                      width: 130,
                      height: 130,
                      errorBuilder: (_, _, _) => Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ClosetColors.creme.withValues(alpha: 0.08),
                          border: Border.all(
                            color: ClosetColors.doreClair,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'C',
                            style: ClosetTextStyles.display.copyWith(
                              fontSize: 64,
                              color: ClosetColors.doreClair,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Nom de marque — Boldonse (charte §4 Typographie)
                    Text(
                      'ClosET',
                      style: ClosetTextStyles.display.copyWith(
                        fontSize: 40,
                        color: ClosetColors.doreClair,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Baseline — Lato capitals espacées (charte §4)
                    Text(
                      'L\'ÉLÉGANCE DURABLE',
                      style: ClosetTextStyles.labelChamp.copyWith(
                        color: ClosetColors.creme.withValues(alpha: 0.72),
                        letterSpacing: 4.5,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
