import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/closet_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Le Dressing Privé\nde vos Rêves',
      'subtitle': 'Une expérience de mode circulaire exclusive, alliant luxe et durabilité au quotidien.',
      'icon': LucideIcons.gem,
    },
    {
      'title': 'L\'Élégance\nDurable',
      'subtitle': 'Une sélection rigoureuse de pièces uniques de collection, expertisées avec le plus grand soin.',
      'icon': LucideIcons.leaf,
    },
    {
      'title': 'L\'Atelier\ndes Sourceurs',
      'subtitle': 'Confiez vos pièces d\'exception à notre comité et suivez vos ventes en toute transparence.',
      'icon': LucideIcons.sparkles,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      HapticFeedback.mediumImpact();
      context.go('/home');
    }
  }

  void _onSkip() {
    HapticFeedback.mediumImpact();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton Passer en haut à droite
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    'PASSER',
                    style: GoogleFonts.lato(
                      color: ClosetColors.texteSecondaire,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            
            // Carousel de slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cercle Icône Stylisé
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ClosetColors.creme,
                            border: Border.all(
                              color: ClosetColors.dore.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _pages[index]['icon'] as IconData,
                              size: 44,
                              color: ClosetColors.vert,
                            ),
                          ),
                        ),
                        const SizedBox(height: 54),
                        // Titre en EB Garamond
                        Text(
                          _pages[index]['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ebGaramond(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: ClosetColors.noir,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Description en Cormorant
                        Text(
                          _pages[index]['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorant(
                            fontSize: 16,
                            color: ClosetColors.noir.withValues(alpha: 0.72),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Barre de contrôle du bas (indicateurs + bouton)
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicateurs circulaires animés
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? ClosetColors.vert
                              : ClosetColors.dore.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Bouton Suivant / Commencer Premium
                  GestureDetector(
                    onTap: _onNext,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: ClosetColors.vert,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: ClosetColors.dore.withValues(alpha: 0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ClosetColors.vert.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Commencer'
                                : 'Suivant',
                            style: GoogleFonts.lato(
                              color: ClosetColors.creme,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          if (_currentPage != _pages.length - 1) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: ClosetColors.creme,
                              size: 15,
                            ),
                          ],
                        ],
                      ),
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
