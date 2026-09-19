import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/closet_l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/spotlight_showcase.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../cliente/dressing/dressing_screen.dart';

/// Itinéraire de la visite guidée : l'app entière, écran par écran.
///
/// L'ordre suit le parcours réel d'une cliente — découvrir, chercher, choisir,
/// commander — plutôt que l'ordre des fichiers. Chaque étape sait comment
/// atteindre son écran ([SpotlightStep.aller]) et quand elle n'a pas lieu
/// d'être jouée ([SpotlightStep.disponible]), ce qui laisse la visite complète
/// se dérouler même sur un compte vide.
List<SpotlightStep> visiteGuidee(ClosetL10n l10n) => [
  // ── Mon dressing ────────────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.accueilKey,
    ecran: l10n.tourEcranBienvenue,
    title: l10n.tourBienvenueTitre,
    description: l10n.tourBienvenueCorps,
    borderRadius: 16,
    aller: (_, ref) => ref.read(appRouterProvider).go('/home'),
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.pieceSemaineKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranDressing,
    title: l10n.tourPieceSemaineTitre,
    description: l10n.tourPieceSemaineCorps,
    borderRadius: 16,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.decouvrirKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranDressing,
    title: l10n.tourDecouvrirTitre,
    description: l10n.tourDecouvrirCorps,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.grilleKey,
    geste: GesteVisite.defiler,
    ecran: l10n.tourEcranDressing,
    title: l10n.tourGrilleTitre,
    description: l10n.tourGrilleCorps,
    borderRadius: 12,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.selectionKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranDressing,
    title: l10n.tourSelectionTitre,
    description: l10n.tourSelectionCorps,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.notificationsKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranDressing,
    title: l10n.tourNotificationsTitre,
    description: l10n.tourNotificationsCorps,
  ),

  // ── Barre de navigation ─────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.dressingNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranNavigation,
    title: l10n.tourNavDressingTitre,
    description: l10n.tourNavDressingCorps,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.collectionsNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranNavigation,
    title: l10n.tourNavCollectionsTitre,
    description: l10n.tourNavCollectionsCorps,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.wishlistNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranNavigation,
    title: l10n.tourNavFavorisTitre,
    description: l10n.tourNavFavorisCorps,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.selectionNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranNavigation,
    title: l10n.tourNavSelectionTitre,
    description: l10n.tourNavSelectionCorps,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.espaceNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranNavigation,
    title: l10n.tourNavEspaceTitre,
    description: l10n.tourNavEspaceCorps,
  ),

  // ── Collections ─────────────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.rechercheKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranCollections,
    title: l10n.tourRechercheTitre,
    description: l10n.tourRechercheCorps,
    borderRadius: 12,
    aller: (_, ref) => ref.read(appRouterProvider).go('/collections'),
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.universKey,
    geste: GesteVisite.glisser,
    ecran: l10n.tourEcranCollections,
    title: l10n.tourUniversTitre,
    description: l10n.tourUniversCorps,
    borderRadius: 12,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.filtresKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranCollections,
    title: l10n.tourFiltresTitre,
    description: l10n.tourFiltresCorps,
  ),

  // ── Fiche de la pièce ───────────────────────────────────────────────────
  // La visite ouvre une vraie fiche : celle de la pièce mise en avant sur
  // l'accueil, seule pièce dont l'identifiant est connu à coup sûr.
  SpotlightStep(
    targetKey: ClosetTourKeys.produitCarrouselKey,
    geste: GesteVisite.glisser,
    ecran: l10n.tourEcranPiece,
    title: l10n.tourCarrouselTitre,
    description: l10n.tourCarrouselCorps,
    borderRadius: 0,
    disponible: _pieceVedette,
    aller: (_, ref) {
      final id = _idPieceVedette(ref);
      if (id != null) ref.read(appRouterProvider).push('/product/$id');
    },
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.produitFavoriKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranPiece,
    title: l10n.tourProduitFavoriTitre,
    description: l10n.tourProduitFavoriCorps,
    disponible: _pieceVedette,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.produitAjoutKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranPiece,
    title: l10n.tourProduitAjoutTitre,
    description: l10n.tourProduitAjoutCorps,
    disponible: _pieceVedette,
  ),

  // ── Mes favoris ─────────────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.wishlistAjoutKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranFavoris,
    title: l10n.tourFavorisAjoutTitre,
    description: l10n.tourFavorisAjoutCorps,
    disponible: (ref) => ref.read(wishlistListProvider).isNotEmpty,
    aller: (_, ref) => ref.read(appRouterProvider).go('/wishlist'),
  ),

  // ── Ma sélection ────────────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.finaliserKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranSelection,
    title: l10n.tourFinaliserTitre,
    description: l10n.tourFinaliserCorps,
    disponible: (ref) => ref.read(cartListProvider).isNotEmpty,
    aller: (_, ref) => ref.read(appRouterProvider).go('/selection'),
  ),

  // ── Livraison ───────────────────────────────────────────────────────────
  // Le tunnel de commande engage de l'argent : le routeur le réserve aux
  // comptes connectés, donc ces étapes ne se jouent qu'une fois la session
  // ouverte (voir la garde de app_router.dart).
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutNomKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranLivraison,
    title: l10n.tourLivraisonNomTitre,
    description: l10n.tourLivraisonNomCorps,
    borderRadius: 12,
    disponible: _connectee,
    aller: (_, ref) => ref.read(appRouterProvider).go('/checkout'),
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutTelKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranLivraison,
    title: l10n.tourLivraisonTelTitre,
    description: l10n.tourLivraisonTelCorps,
    borderRadius: 12,
    disponible: _connectee,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutVilleKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranLivraison,
    title: l10n.tourLivraisonVilleTitre,
    description: l10n.tourLivraisonVilleCorps,
    borderRadius: 12,
    disponible: _connectee,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutQuartierKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranLivraison,
    title: l10n.tourLivraisonQuartierTitre,
    description: l10n.tourLivraisonQuartierCorps,
    borderRadius: 12,
    disponible: _connectee,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutDetailleeKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranLivraison,
    title: l10n.tourLivraisonDetailleeTitre,
    description: l10n.tourLivraisonDetailleeCorps,
    borderRadius: 6,
    disponible: _connectee,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutSuivantKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranLivraison,
    title: l10n.tourLivraisonSuivantTitre,
    description: l10n.tourLivraisonSuivantCorps,
    disponible: _connectee,
  ),

  // ── Paiement ────────────────────────────────────────────────────────────
  // L'étape paiement du checkout n'est atteignable qu'après validation des
  // coordonnées : la visite l'ouvre directement, en lecture, via `etape`.
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutMoyensKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranPaiement,
    title: l10n.tourMoyensTitre,
    description: l10n.tourMoyensCorps,
    borderRadius: 12,
    disponible: _connectee,
    aller: (_, ref) =>
        ref.read(appRouterProvider).go('/checkout?etape=paiement'),
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutRecapKey,
    ecran: l10n.tourEcranPaiement,
    title: l10n.tourRecapTitre,
    description: l10n.tourRecapCorps,
    borderRadius: 12,
    disponible: _connectee,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.checkoutPayerKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranPaiement,
    title: l10n.tourPayerTitre,
    description: l10n.tourPayerCorps,
    disponible: _connectee,
  ),

  // ── Mon espace ──────────────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.espaceProfilKey,
    ecran: l10n.tourEcranEspace,
    title: l10n.tourProfilTitre,
    description: l10n.tourProfilCorps,
    borderRadius: 12,
    aller: (_, ref) => ref.read(appRouterProvider).go('/espace'),
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.espaceSourceurKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranEspace,
    title: l10n.tourSourceurTitre,
    description: l10n.tourSourceurCorps,
    borderRadius: 12,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.espaceCommandesKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranEspace,
    title: l10n.tourCommandesTitre,
    description: l10n.tourCommandesCorps,
    borderRadius: 12,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.espaceLangueKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranEspace,
    title: l10n.tourLangueTitre,
    description: l10n.tourLangueCorps,
    borderRadius: 12,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.espaceVisiteKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranEspace,
    title: l10n.tourRevoirTitre,
    description: l10n.tourRevoirCorps,
    borderRadius: 12,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.dressingNavKey,
    ecran: l10n.tourEcranFin,
    title: l10n.tourFinTitre,
    description: l10n.tourFinCorps,
    geste: GesteVisite.appui,
    aller: (_, ref) => ref.read(appRouterProvider).go('/home'),
  ),
];

bool _connectee(WidgetRef ref) => ref.read(currentUserProvider) != null;

String? _idPieceVedette(WidgetRef ref) =>
    ref.read(dressingDataProvider).value?.pieceDeLaSemaine?.id;

bool _pieceVedette(WidgetRef ref) => _idPieceVedette(ref) != null;
