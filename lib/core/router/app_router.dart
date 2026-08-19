import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/sourceur_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/paiement_flow_screen.dart';
import '../../features/cliente/collections/collections_screen.dart';
import '../../features/cliente/dressing/dressing_screen.dart';
import '../../features/cliente/espace/deconnexion_screen.dart';
import '../../features/cliente/espace/detail_commande_screen.dart';
import '../../features/cliente/espace/espace_screen.dart';
import '../../features/cliente/espace/espace_sub_screens.dart';
import '../../features/cliente/espace/mes_adresses_screen.dart';
import '../../features/cliente/espace/mes_commandes_screen.dart';
import '../../features/cliente/espace/modifier_profil_screen.dart';
import '../../features/cliente/espace/suivi_commande_screen.dart';
import '../../features/cliente/product/product_screen.dart';
import '../../features/cliente/selection/selection_screen.dart';
import '../../features/cliente/wishlist/wishlist_screen.dart';
import '../../features/main_layout.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/sourceur/devenir/devenir_sourceur_screen.dart';
import '../../features/sourceur/espace/sourceur_espace_screen.dart';
import '../../features/sourceur/identification/identification_sourceur_screen.dart';
import '../../features/sourceur/inscription/adhesion_approuvee_screen.dart';
import '../../features/sourceur/inscription/sourceur_adhesion_screen.dart';
import '../../features/sourceur/inscription/sourceur_inscription_screen.dart';
import '../../features/sourceur/nouvelle/sourceur_nouvelle_piece_screen.dart';
import '../../features/sourceur/pieces/sourceur_pieces_screen.dart';
import '../../features/sourceur/revenus/sourceur_revenus_screen.dart';
import '../../features/sourceur/sourceur_layout.dart';
import '../../features/sourceur/suivi/inspection_piece_screen.dart';
import '../../features/sourceur/suivi/suivi_piece_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/transaction/transaction_flow_screen.dart';
import '../../features/transaction/transaction_models.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final loc = state.matchedLocation;

      // Entrées publiques du programme sourceur : une visiteuse doit pouvoir
      // découvrir le programme et se connecter sans être déjà authentifiée.
      // Sans cette exception, la landing et l'écran de connexion sourceur
      // renverraient vers /auth — donc seraient inatteignables.
      const sourceurPublic = {
        '/sourceur/devenir',
        '/sourceur/identification',
      };

      // Routes engageant de l'argent ou l'identité : authentification requise.
      // `/transaction` en fait partie — il débite ou reverse des fonds.
      const routesProtegees = {'/checkout', '/transaction'};
      if (!isAuthenticated &&
          !sourceurPublic.contains(loc) &&
          (routesProtegees.contains(loc) ||
              loc.startsWith('/checkout/') ||
              loc.startsWith('/sourceur'))) {
        return '/auth';
      }

      // Un compte non encore partenaire est ramené sur la fiche d'adhésion,
      // sauf sur les écrans qui composent justement ce parcours d'entrée.
      const parcoursAdhesion = {
        '/sourceur/inscription',
        '/sourceur/adhesion',
        '/sourceur/adhesion/approuvee',
      };
      if (isAuthenticated &&
          loc.startsWith('/sourceur') &&
          !parcoursAdhesion.contains(loc) &&
          !sourceurPublic.contains(loc)) {
        final sourceurRepo = ref.read(sourceurRepositoryProvider);
        if (!sourceurRepo.estInscrit) {
          return '/sourceur/inscription';
        }
        // « Le dépôt s'ouvrira après validation » (`27:1970`) : tant que
        // l'adhésion est à l'étude, l'espace sourceuse reste fermé et la fiche
        // de suivi tient lieu d'accueil.
        if (sourceurRepo.adhesion?.estValidee == false) {
          return '/sourceur/adhesion';
        }
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

      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/checkout/paiement',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: PaiementFlowScreen(
            args: state.extra is PaiementFlowArgs
                ? state.extra as PaiementFlowArgs
                : null,
          ),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),

      // ── Tunnel de transaction (hors shell, sans retour arrière) ─────
      // Les 4 étapes (PIN → traitement → succès → reçu) vivent dans une
      // seule route : voir TransactionFlowScreen.
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/transaction',
        pageBuilder: (context, state) {
          final demande = state.extra as DemandeTransaction?;
          if (demande == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const Scaffold(
                body: Center(child: Text('Transaction introuvable')),
              ),
              transitionsBuilder: (context, animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child: TransactionFlowScreen(
              demande: demande,
              executer: ref.read(transactionExecuteurProvider),
            ),
            transitionsBuilder: (context, animation, _, child) {
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
          );
        },
      ),

      // ── Sourceur Shell with bottom nav ───────────────────────────────
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return SourceurLayout(navigationShell: navigationShell);
        },
        branches: [
          // 0 — ESPACE (`31:109`), accueil de l'espace sourceuse
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sourceur/espace',
                builder: (context, state) => const SourceurEspaceScreen(),
              ),
            ],
          ),
          // 1 — DÉPÔTS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sourceur/pieces',
                builder: (context, state) => const SourceurPiecesScreen(),
              ),
            ],
          ),
          // 2 — CONFIER
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sourceur/nouvelle',
                builder: (context, state) => const SourceurNouvellePieceScreen(),
              ),
            ],
          ),
          // 3 — GAINS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sourceur/revenus',
                builder: (context, state) => const SourceurRevenusScreen(),
              ),
            ],
          ),
        ],
      ),

      // `/sourceur` servait un tableau de bord « Atelier » absent de la
      // maquette, qui doublait `31:109` en affichant des compteurs figés à zéro.
      // L'adresse reste valide et mène désormais à l'espace lui-même.
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur',
        redirect: (context, state) => '/sourceur/espace',
      ),

      // Suivi d'une piece confiee (hors shell)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/piece/:id',
        builder: (context, state) => InspectionPieceScreen(
          pieceId: state.pathParameters['id'],
        ),
        routes: [
          GoRoute(
            path: 'suivi',
            builder: (context, state) => SuiviPieceScreen(
              pieceId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // Parcours d'entree sourceur (hors shell)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/devenir',
        builder: (context, state) => const DevenirSourceurScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/identification',
        builder: (context, state) => const IdentificationSourceurScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/adhesion/approuvee',
        builder: (context, state) => const AdhesionApprouveeScreen(),
      ),

      // Statut d'adhesion (hors shell) — affiche l'avancement, ne collecte rien
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/adhesion',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SourceurAdhesionScreen(),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),

      // Inscription (outside shell)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/sourceur/inscription',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SourceurInscriptionScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
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
                routes: [
                  GoRoute(
                    path: 'infos',
                    builder: (context, state) =>
                        const ModifierProfilScreen(),
                  ),
                  GoRoute(
                    path: 'commandes',
                    builder: (context, state) => const MesCommandesScreen(),
                    routes: [
                      GoRoute(
                        path: ':numero',
                        builder: (context, state) => DetailCommandeScreen(
                          numero: state.pathParameters['numero']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'suivi',
                            builder: (context, state) => SuiviCommandeScreen(
                              numero: state.pathParameters['numero']!,
                              depuisPaiement: state.extra == true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'deconnexion',
                    builder: (context, state) => const DeconnexionScreen(),
                  ),
                  GoRoute(
                    path: 'adresses',
                    builder: (context, state) => const MesAdressesScreen(),
                  ),
                  GoRoute(
                    path: 'paiements',
                    builder: (context, state) => const EspacePaiementsScreen(),
                  ),
                  GoRoute(
                    path: 'alertes',
                    parentNavigatorKey: rootNavigatorKey,
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
