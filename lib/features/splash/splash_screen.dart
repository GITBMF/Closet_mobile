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
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _glowAnim = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    _animController.forward();

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              ClosetColors.vert,
              Color(0xFF071B10), // Vert noir très profond pour effet haute couture
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: Center(
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
                      // Logo officiel avec halo lumineux doré
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: _glowAnim.value,
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    ClosetColors.doreClair.withValues(alpha: 0.22),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
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
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Nom de marque — Boldonse (charte §4 Typographie)
                      Text(
                        'ClosET',
                        style: ClosetTextStyles.display.copyWith(
                          fontSize: 42,
                          color: ClosetColors.doreClair,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Baseline — Lato capitals espacées (charte §4)
                      Text(
                        'L\'ÉLÉGANCE DURABLE',
                        style: ClosetTextStyles.labelChamp.copyWith(
                          color: ClosetColors.creme.withValues(alpha: 0.75),
                          letterSpacing: 5.5,
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
      ),
    );
  }
}
