import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/cliente/collections/collections_screen.dart';
import '../../features/cliente/dressing/dressing_screen.dart';
import '../../features/cliente/espace/espace_screen.dart';
import '../../features/cliente/espace/espace_sub_screens.dart';
import '../../features/cliente/product/product_screen.dart';
import '../../features/cliente/selection/selection_screen.dart';
import '../../features/cliente/wishlist/wishlist_screen.dart';
import '../../features/main_layout.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/sourceur/atelier/sourceur_atelier_screen.dart';
import '../../features/sourceur/inscription/sourceur_inscription_screen.dart';
import '../../features/sourceur/nouvelle/sourceur_nouvelle_piece_screen.dart';
import '../../features/sourceur/pieces/sourceur_pieces_screen.dart';
import '../../features/sourceur/revenus/sourceur_revenus_screen.dart';
import '../../features/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final loc = state.matchedLocation;
      if (!isAuthenticated &&
          (loc == '/checkout' ||
              loc.startsWith('/sourceur'))) {
        return '/auth';
      }
      return null;
    },
    routes: [
      // ── Splash ──────────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Onboarding ───────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Auth (outside shell — no bottom nav) ────────────────────────
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/auth',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // ── Product Detail (outside shell — full screen) ────────────────
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/product/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductScreen(articleId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // ── Checkout (outside shell) ────────────────────────────────────
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/checkout',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CheckoutScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // ── Sourceur (outside shell) ────────────────────────────────────
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/inscription',
        builder: (context, state) => const SourceurInscriptionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/nouvelle',
        builder: (context, state) => const SourceurNouvellePieceScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/pieces',
        builder: (context, state) => const SourceurPiecesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/revenus',
        builder: (context, state) => const SourceurRevenusScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/atelier',
        builder: (context, state) => const SourceurAtelierScreen(nomAtelier: 'Mon Atelier', ville: 'Yaoundé'),
      // ── Sourceur (outside shell — full screen stack) ────────────────
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SourceurAtelierScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
        routes: [
          GoRoute(
            path: 'inscription',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SourceurInscriptionScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          GoRoute(
            path: 'pieces',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SourceurPiecesScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          GoRoute(
            path: 'revenus',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SourceurRevenusScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
          GoRoute(
            path: 'nouvelle',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SourceurNouvellePieceScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
          ),
        ],
      ),

      // ── Shell with bottom nav ───────────────────────────────────────
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // 0 — DRESSING
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DressingScreen(),
              ),
            ],
          ),
          // 1 — COLLECTIONS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collections',
                builder: (context, state) => const CollectionsScreen(),
              ),
            ],
          ),
          // 2 — WISHLIST
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          // 3 — SÉLECTION
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/selection',
                builder: (context, state) => const SelectionScreen(),
              ),
            ],
          ),
          // 4 — ESPACE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/espace',
                builder: (context, state) => const EspaceScreen(),
                routes: [
                  GoRoute(
                    path: 'infos',
                    builder: (context, state) => const EspaceInfoScreen(),
                  ),
                  GoRoute(
                    path: 'adresses',
                    builder: (context, state) => const EspaceAdressesScreen(),
                  ),
                  GoRoute(
                    path: 'paiements',
                    builder: (context, state) => const EspacePaiementsScreen(),
                  ),
                  GoRoute(
                    path: 'alertes',
                    builder: (context, state) => const EspaceAlertesScreen(),
                  ),
                  GoRoute(
                    path: 'faq',
                    builder: (context, state) => const EspaceFaqScreen(),
                  ),
                  GoRoute(
                    path: 'contact',
                    builder: (context, state) => const EspaceContactScreen(),
                  ),
                  GoRoute(
                    path: 'confidentialite',
                    builder: (context, state) => const EspaceConfidentialiteScreen(),
                  ),
                  GoRoute(
                    path: 'evaluation',
                    builder: (context, state) => const EspaceEvaluationScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
    router.refresh();
  });

  return router;
});
