import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/main_layout.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/cliente/dressing/dressing_screen.dart';
import '../../features/cliente/collections/collections_screen.dart';
import '../../features/cliente/wishlist/wishlist_screen.dart';
import '../../features/cliente/selection/selection_screen.dart';
import '../../features/cliente/espace/espace_screen.dart';
import '../../features/cliente/product/product_screen.dart';
import '../../features/checkout/checkout_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
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
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
