import '../../core/l10n/closet_l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/spotlight_showcase.dart';

/// Itinéraire de la visite guidée sourceur : dépôts, confier une pièce,
/// gains puis espace — le même principe que [visiteGuidee], côté vendeur.
List<SpotlightStep> visiteGuideeSourceur(ClosetL10n l10n) => [
  // ── Mon espace sourceur ─────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurFicheKey,
    ecran: l10n.tourEcranEspaceSourceur,
    title: l10n.tourSourceurFicheTitre,
    description: l10n.tourSourceurFicheCorps,
    borderRadius: 16,
    aller: (_, ref) => ref.read(appRouterProvider).go('/sourceur/espace'),
  ),

  // ── Mes dépôts ──────────────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurDepotsNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranEspaceSourceur,
    title: l10n.tourSourceurDepotsNavTitre,
    description: l10n.tourSourceurDepotsNavCorps,
    aller: (_, ref) => ref.read(appRouterProvider).go('/sourceur/pieces'),
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurTableauBordKey,
    ecran: l10n.tourEcranDepots,
    title: l10n.tourSourceurTableauBordTitre,
    description: l10n.tourSourceurTableauBordCorps,
    borderRadius: 16,
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurFiltresKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranDepots,
    title: l10n.tourSourceurFiltresTitre,
    description: l10n.tourSourceurFiltresCorps,
  ),

  // ── Confier une pièce ───────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurConfierNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranDepots,
    title: l10n.tourSourceurConfierNavTitre,
    description: l10n.tourSourceurConfierNavCorps,
    aller: (_, ref) => ref.read(appRouterProvider).go('/sourceur/nouvelle'),
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurEtapesKey,
    ecran: l10n.tourEcranConfier,
    title: l10n.tourSourceurEtapesTitre,
    description: l10n.tourSourceurEtapesCorps,
    borderRadius: 12,
  ),

  // ── Mes gains ───────────────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurGainsNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranConfier,
    title: l10n.tourSourceurGainsNavTitre,
    description: l10n.tourSourceurGainsNavCorps,
    aller: (_, ref) => ref.read(appRouterProvider).go('/sourceur/revenus'),
  ),
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurSoldeKey,
    ecran: l10n.tourEcranGains,
    title: l10n.tourSourceurSoldeTitre,
    description: l10n.tourSourceurSoldeCorps,
    borderRadius: 16,
  ),

  // ── Fin ─────────────────────────────────────────────────────────────────
  SpotlightStep(
    targetKey: ClosetTourKeys.sourceurEspaceNavKey,
    geste: GesteVisite.appui,
    ecran: l10n.tourEcranFin,
    title: l10n.tourSourceurFinTitre,
    description: l10n.tourSourceurFinCorps,
    aller: (_, ref) => ref.read(appRouterProvider).go('/sourceur/espace'),
  ),
];
