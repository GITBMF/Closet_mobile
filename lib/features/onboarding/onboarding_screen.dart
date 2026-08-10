// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // import '../../../core/theme/closet_colors.dart';
// // import '../../../core/theme/closet_text_styles.dart';

// // class OnboardingScreen extends StatelessWidget {
// //   const OnboardingScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     // Lock status bar color style for immersive feel
// //     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
// //       statusBarColor: Colors.transparent,
// //       statusBarIconBrightness: Brightness.light,
// //     ));

// //     return Scaffold(
// //       backgroundColor: ClosetColors.vertFonce,
// //       body: Stack(
// //         children: [
// //           // 1. Background image (the luxury dressing room)
// //           Positioned.fill(
// //             child: Image.asset(
// //               'assets/landing_image.png',
// //               fit: BoxFit.cover,
// //               errorBuilder: (context, error, stackTrace) {
// //                 // Fallback elegant color if image fails to load
// //                 return Container(color: ClosetColors.vertFonce);
// //               },
// //             ),
// //           ),

// //           // 2. Dark elegant overlay for maximum legibility and contrast
// //           Positioned.fill(
// //             child: DecoratedBox(
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                   colors: [
// //                     Colors.black.withValues(alpha: 0.35),
// //                     Colors.black.withValues(alpha: 0.5),
// //                     Colors.black.withValues(alpha: 0.8),
// //                   ],
// //                   stops: const [0.0, 0.4, 1.0],
// //                 ),
// //               ),
// //             ),
// //           ),

// //           // 3. Main layout content
// //           SafeArea(
// //             child: Column(
// //               children: [
// //                 const Spacer(flex: 2),

// //                 // Top: Brand identity
// //                 Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     // Official Closet Icon
// //                     Image.asset(
// //                       'assets/logo.png',
// //                       width: 90,
// //                       height: 90,
// //                       errorBuilder: (context, error, stackTrace) {
// //                         return Container(
// //                           width: 90,
// //                           height: 90,
// //                           decoration: BoxDecoration(
// //                             shape: BoxShape.circle,
// //                             border: Border.all(
// //                               color: ClosetColors.doreClair,
// //                               width: 2,
// //                             ),
// //                           ),
// //                           child: const Center(
// //                             child: Icon(
// //                               Icons.checkroom,
// //                               color: ClosetColors.doreClair,
// //                               size: 40,
// //                             ),
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                     const SizedBox(height: 16),
// //                     // Brand Name
// //                     Text(
// //                       'ClosET',
// //                       style: ClosetTextStyles.display.copyWith(
// //                         fontSize: 40,
// //                         color: ClosetColors.doreClair,
// //                         letterSpacing: 4,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     // Brand Tagline / Baseline
// //                     Text(
// //                       "L'ÉLÉGANCE DURABLE",
// //                       style: ClosetTextStyles.labelChamp.copyWith(
// //                         color: ClosetColors.creme.withValues(alpha: 0.85),
// //                         letterSpacing: 4.5,
// //                         fontSize: 11,
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 const Spacer(flex: 3),

// //                 // Bottom Content inside the iconic brand arch shape
// //                 Align(
// //                   alignment: Alignment.bottomCenter,
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                     child: Container(
// //                       width: double.infinity,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 24,
// //                         vertical: 36,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: ClosetColors.vert.withValues(alpha: 0.94),
// //                         borderRadius: const BorderRadius.only(
// //                           topLeft: Radius.circular(80),
// //                           topRight: Radius.circular(80),
// //                           bottomLeft: Radius.circular(16),
// //                           bottomRight: Radius.circular(16),
// //                         ),
// //                         border: Border.all(
// //                           color: ClosetColors.dore.withValues(alpha: 0.35),
// //                           width: 1.5,
// //                         ),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.black.withValues(alpha: 0.25),
// //                             blurRadius: 20,
// //                             offset: const Offset(0, 4),
// //                           ),
// //                         ],
// //                       ),
// //                       child: Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           // Welcome header in EB Garamond
// //                           Text(
// //                             'Votre Dressing Privé',
// //                             textAlign: TextAlign.center,
// //                             style: GoogleFonts.ebGaramond(
// //                               fontSize: 28,
// //                               fontWeight: FontWeight.w600,
// //                               color: ClosetColors.creme,
// //                               height: 1.2,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 12),
// //                           // Subtitle description in Cormorant
// //                           Text(
// //                             'Une expérience de mode circulaire exclusive, alliant luxe et durabilité au quotidien.',
// //                             textAlign: TextAlign.center,
// //                             style: GoogleFonts.cormorant(
// //                               fontSize: 16,
// //                               color: ClosetColors.creme.withValues(alpha: 0.85),
// //                               height: 1.45,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 32),
// //                           // CTA Button in Lato
// //                           GestureDetector(
// //                             onTap: () {
// //                               HapticFeedback.mediumImpact();
// //                               context.go('/home');
// //                             },
// //                             child: Container(
// //                               width: double.infinity,
// //                               padding: const EdgeInsets.symmetric(vertical: 16),
// //                               decoration: BoxDecoration(
// //                                 color: ClosetColors.creme,
// //                                 borderRadius: BorderRadius.circular(30),
// //                                 border: Border.all(
// //                                   color: ClosetColors.dore,
// //                                   width: 1.5,
// //                                 ),
// //                                 boxShadow: [
// //                                   BoxShadow(
// //                                     color: Colors.black.withValues(alpha: 0.1),
// //                                     blurRadius: 10,
// //                                     offset: const Offset(0, 4),
// //                                   ),
// //                                 ],
// //                               ),
// //                               child: Center(
// //                                 child: Text(
// //                                   'DÉCOUVRIR',
// //                                   style: GoogleFonts.lato(
// //                                     color: ClosetColors.vert,
// //                                     fontSize: 14,
// //                                     fontWeight: FontWeight.w700,
// //                                     letterSpacing: 2,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';

// import '../../../core/theme/app_spacing.dart';
// import '../../../core/theme/closet_colors.dart';
// import '../../../core/theme/closet_text_styles.dart';
// import '../../../core/widgets/closet_buttons.dart';

// /// Onboarding — transcription des maquettes `5:1279`, `5:1342`, `5:1371`.
// ///
// /// Fond vert profond, photo en arche (271 × 396, coins supérieurs à 159),
// /// sur-titre doré en capitales espacées, titre EB Garamond, corps Cormorant
// /// Garamond, indicateur à trois points et CTA doré de 312 × 44.
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _SlideOnboarding {
//   const _SlideOnboarding({
//     required this.image,
//     required this.surtitre,
//     required this.titre,
//     required this.corps,
//   });

//   final String image;
//   final String surtitre;
//   final String titre;
//   final String corps;
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _pageCourante = 0;

//   static const _slides = [
//     _SlideOnboarding(
//       image: 'assets/onboarding_1.jpg',
//       surtitre: 'Le dressing privé',
//       titre: 'Une sélection curée, pièce par pièce',
//       corps: 'Chaque entrée dans le dressing est authentifiée, restaurée et '
//           'photographiée avec soin. Ici, la seconde main devient un rituel '
//           "d'élégance.",
//     ),
//     _SlideOnboarding(
//       image: 'assets/onboarding_2.jpg',
//       surtitre: "L'élégance durable",
//       titre: 'Consommer moins, choisir mieux.',
//       corps: "Nous prolongeons la vie de pièces d'exception. Chaque "
//           'acquisition est un geste pour la planète — sans compromis sur la '
//           'beauté.',
//     ),
//     _SlideOnboarding(
//       image: 'assets/onboarding_3.jpg',
//       surtitre: 'Le cercle privilège',
//       titre: 'Un accès discret aux plus belles pièces.',
//       corps: 'Notifications privées sur les nouveautés de vos maisons '
//           'préférées, avantages exclusifs, livraison écrin. Un service à la '
//           'hauteur de vos exigences.',
//     ),
//   ];

//   bool get _derniereSlide => _pageCourante == _slides.length - 1;

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _continuer() {
//     if (!_derniereSlide) {
//       HapticFeedback.lightImpact();
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOutCubic,
//       );
//     } else {
//       HapticFeedback.mediumImpact();
//       context.go('/home');
//     }
//   }

//   void _jaiUnCompte() {
//     HapticFeedback.mediumImpact();
//     context.go('/auth');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ClosetColors.vert,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: _slides.length,
//                 onPageChanged: (i) => setState(() => _pageCourante = i),
//                 itemBuilder: (context, i) => _Slide(slide: _slides[i]),
//               ),
//             ),
//             _Indicateur(
//               total: _slides.length,
//               actif: _pageCourante,
//             ),
//             const SizedBox(height: AppSpacing.p24),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 39),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ClosetPrimaryButton(
//                   label: 'CONTINUER VOTRE VISITE',
//                   dore: true,
//                   // hauteur: 44,
//                   onPressed: _continuer,
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 44,
//               child: _derniereSlide
//                   ? Center(
//                       child: TextButton(
//                         onPressed: _jaiUnCompte,
//                         child: Text(
//                           'J’AI DÉJÀ UN COMPTE',
//                           style: ClosetTextStyles.bouton.copyWith(
//                             color: ClosetColors.fond300,
//                           ),
//                         ),
//                       ),
//                     )
//                   : null,
//             ),
//             const SizedBox(height: AppSpacing.p8),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Slide extends StatelessWidget {
//   const _Slide({required this.slide});

//   final _SlideOnboarding slide;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(159),
//             ),
//             child: Image.asset(
//               slide.image,
//               width: 271,
//               height: 396,
//               fit: BoxFit.cover,
//               errorBuilder: (_, _, _) => const SizedBox(
//                 width: 271,
//                 height: 396,
//                 child: ColoredBox(color: ClosetColors.emeraude400),
//               ),
//             ),
//           ),
//           const SizedBox(height: 36),
//           Text(
//             slide.surtitre.toUpperCase(),
//             textAlign: TextAlign.center,
//             style: ClosetTextStyles.libelle.copyWith(
//               letterSpacing: 2.52,
//               height: 16.8 / 14,
//               color: ClosetColors.fond200,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.p20),
//           Text(
//             slide.titre,
//             textAlign: TextAlign.center,
//             style: ClosetTextStyles.titreEcran.copyWith(
//               fontSize: 20,
//               fontStyle: FontStyle.italic,
//               letterSpacing: -0.40,
//               height: 26.1 / 20,
//               color: ClosetColors.fond100,
//             ),
//           ),
//           const SizedBox(height: AppSpacing.p20),
//           Text(
//             slide.corps,
//             textAlign: TextAlign.center,
//             style: ClosetTextStyles.nomProduit.copyWith(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 1.04,
//               height: 15.7 / 13,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Indicateur de page : la pastille active est un rectangle de 8 × 4,
// /// les inactives des carrés de 4 × 4 atténués.
// class _Indicateur extends StatelessWidget {
//   const _Indicateur({required this.total, required this.actif});

//   final int total;
//   final int actif;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         for (var i = 0; i < total; i++)
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 240),
//             curve: Curves.easeOut,
//             margin: const EdgeInsets.symmetric(horizontal: 3),
//             width: i == actif ? 8 : 4,
//             height: 4,
//             decoration: BoxDecoration(
//               color: ClosetColors.neutre400.withValues(
//                 alpha: i == actif ? 1.0 : 0.4,
//               ),
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';

/// Onboarding — transcription des maquettes `5:1279`, `5:1342`, `5:1371`.
///
/// Fond vert profond, photo en arche (271 × 396, coins supérieurs à 159),
/// sur-titre doré en capitales espacées, titre EB Garamond, corps Cormorant
/// Garamond, indicateur à trois points et CTA doré de 312 × 44.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _SlideOnboarding {
  const _SlideOnboarding({
    required this.image,
    required this.surtitre,
    required this.titre,
    required this.corps,
  });

  final String image;
  final String surtitre;
  final String titre;
  final String corps;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageCourante = 0;

  static const _slides = [
    _SlideOnboarding(
      image: 'assets/onboarding_1.jpg',
      surtitre: 'Le dressing privé',
      titre: 'Une sélection curée, pièce par pièce',
      corps: 'Chaque entrée dans le dressing est authentifiée, restaurée et '
          'photographiée avec soin. Ici, la seconde main devient un rituel '
          "d'élégance.",
    ),
    _SlideOnboarding(
      image: 'assets/onboarding_2.jpg',
      surtitre: "L'élégance durable",
      titre: 'Consommer moins, choisir mieux.',
      corps: "Nous prolongeons la vie de pièces d'exception. Chaque "
          'acquisition est un geste pour la planète — sans compromis sur la '
          'beauté.',
    ),
    _SlideOnboarding(
      image: 'assets/onboarding_3.jpg',
      surtitre: 'Le cercle privilège',
      titre: 'Un accès discret aux plus belles pièces.',
      corps: 'Notifications privées sur les nouveautés de vos maisons '
          'préférées, avantages exclusifs, livraison écrin. Un service à la '
          'hauteur de vos exigences.',
    ),
  ];

  bool get _derniereSlide => _pageCourante == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _continuer() {
    if (!_derniereSlide) {
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

  void _jaiUnCompte() {
    HapticFeedback.mediumImpact();
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _pageCourante = i),
                itemBuilder: (context, i) => _Slide(slide: _slides[i]),
              ),
            ),
            _Indicateur(
              total: _slides.length,
              actif: _pageCourante,
            ),
            const SizedBox(height: AppSpacing.p24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 39),
              child: SizedBox(
                width: double.infinity,
                child: ClosetPrimaryButton(
                  label: 'CONTINUER VOTRE VISITE',
                  dore: true,
                  // hauteur: 44,
                  onPressed: _continuer,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: _derniereSlide
                  ? Center(
                      child: TextButton(
                        onPressed: _jaiUnCompte,
                        child: Text(
                          'J’AI DÉJÀ UN COMPTE',
                          style: ClosetTextStyles.bouton.copyWith(
                            color: ClosetColors.fond300,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.p8),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final _SlideOnboarding slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(159),
            ),
            child: Image.asset(
              slide.image,
              width: 271,
              height: 396,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                width: 271,
                height: 396,
                child: ColoredBox(color: ClosetColors.emeraude400),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            slide.surtitre.toUpperCase(),
            textAlign: TextAlign.center,
            style: ClosetTextStyles.libelle.copyWith(
              letterSpacing: 2.52,
              height: 16.8 / 14,
              color: ClosetColors.fond200,
            ),
          ),
          const SizedBox(height: AppSpacing.p20),
          Text(
            slide.titre,
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreEcran.copyWith(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.40,
              height: 26.1 / 20,
              color: ClosetColors.fond100,
            ),
          ),
          const SizedBox(height: AppSpacing.p20),
          Text(
            slide.corps,
            textAlign: TextAlign.center,
            style: ClosetTextStyles.nomProduit.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.04,
              height: 15.7 / 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicateur de page : la pastille active est un rectangle de 8 × 4,
/// les inactives des carrés de 4 × 4 atténués.
class _Indicateur extends StatelessWidget {
  const _Indicateur({required this.total, required this.actif});

  final int total;
  final int actif;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == actif ? 8 : 4,
            height: 4,
            decoration: BoxDecoration(
              color: ClosetColors.neutre400.withValues(
                alpha: i == actif ? 1.0 : 0.4,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
