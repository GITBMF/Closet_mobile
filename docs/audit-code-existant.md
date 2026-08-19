# Phase 0 — Audit du code existant

**Date** : 19 août 2026
**Branche auditée** : `mobile_client` (arbre de travail propre, `HEAD` = `ee910ee`)
**Périmètre** : le code seul. Aucune comparaison à la maquette Figma à ce stade — c'est l'objet de la Phase 2.
**Méthode** : lecture intégrale des 84 fichiers de `lib/`, des 3 fichiers de test, de la configuration de build. `dart analyze` exécuté. Aucune modification de code.

---

## 1. Stack réelle

Le projet n'est **pas** en React Native : c'est une application **Flutter**.

| Élément | Valeur |
|---|---|
| Framework | Flutter 3.47.0 (stable), Dart 3.13.0 |
| Contrainte SDK | `^3.8.1` (`pubspec.yaml` l.22) |
| Nom du paquet | `closet`, version `1.0.0+1` |
| Plateformes présentes | android, ios, web, windows, macos, linux |
| Volume | 84 fichiers Dart, ~570 Ko de code dans `lib/` |

### Dépendances de production

| Paquet | Version | Rôle effectif dans le code |
|---|---|---|
| `flutter_riverpod` | ^3.3.2 | Gestion d'état — utilisé partout |
| `go_router` | ^17.0.0 | Navigation déclarative, 2 `StatefulShellRoute` |
| `dio` | ^5.10.0 | HTTP — utilisé uniquement par `AuthRepository` |
| `google_fonts` | ^6.3.2 | EB Garamond, Cormorant, Cormorant Garamond, Lato |
| `lucide_icons_flutter` | ^3.1.15 | Jeu d'icônes principal |
| `shared_preferences` | ^2.3.3 | Persistance panier, wishlist, tokens |
| `cached_network_image` | ^3.4.1 | Images distantes |
| `image_picker` | ^1.2.1 | Photo de dépôt sourceur |
| `flutter_dotenv` | ^6.0.1 | Chargé au démarrage mais **aucune variable lue** |
| `cupertino_icons` | ^1.0.8 | — |

### Dépendances de développement

`flutter_test`, `integration_test`, `flutter_lints` ^6.0.0, `flutter_launcher_icons` ^0.14.4.

### Polices et assets

Police locale **Boldonse** (`assets/Boldonse-Regular.ttf`), déclarée en famille. Les autres familles viennent de `google_fonts` (téléchargement à l'exécution).

`assets/` ne contient que 11 fichiers : `logo.png`, `logo_fond_sombre.png`, `logo_fond_vert.png`, `iconheader.png`, `splash_background.png`, `onboarding_1/2/3.jpg`, `mtn.png`, `orange.png`, `Boldonse-Regular.ttf`. Aucune image produit, aucun SVG d'icône exporté de Figma.

---

## 2. Santé du code et blocages d'environnement

`dart analyze` passe avec **6 remontées seulement**, ce qui est bon pour un projet de cette taille :

| Sévérité | Emplacement | Message |
|---|---|---|
| warning | `data/repositories/auth_repository.dart:48:42` | type de `post` non inférable |
| warning | `data/repositories/auth_repository.dart:80:42` | type de `post` non inférable |
| warning | `pubspec.yaml:73:7` | l'asset `.env` n'existe pas |
| info | `core/widgets/closet_field.dart:212:7` | `value` déprécié → `initialValue` |
| info | `features/cliente/espace/espace_screen.dart:497:13` | `activeColor` déprécié → `activeThumbColor` |
| info | `features/cliente/espace/espace_sub_screens.dart:621:29` | idem |

### Blocage 1 — build local impossible sur ce poste

`flutter analyze`, `flutter test` et tout `flutter build` échouent avant de démarrer :

```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

Windows exige le **Mode Développeur** pour créer les symlinks des plugins. Tant qu'il est désactivé, aucun test ni aucune capture d'écran de l'app ne peut être produit localement. `dart analyze` reste utilisable et c'est le seul garde-fou automatique disponible.

À activer via `start ms-settings:developers`.

### Blocage 2 — `.env` absent

`pubspec.yaml` l.73 déclare `.env` en asset mais le fichier n'existe pas. Conséquences réelles, mesurées :

- l'analyse remonte un warning `asset_does_not_exist` ;
- `dotenv.load()` lève au démarrage, mais `main.dart` l.13-17 attrape et journalise — **l'app ne plante pas** ;
- aucune variable n'étant jamais lue via `dotenv`, il n'y a **pas** de perte fonctionnelle.

La base URL de l'API est en dur dans le code, pas dans `.env` :

```12:12:lib/data/bff_client/api_client.dart
    const baseUrl = 'https://closet-backend-be8g.onrender.com/api/v1';
```

C'est donc un faux problème fonctionnel, mais une vraie dette : l'URL de production est figée dans le binaire, sans distinction d'environnement.

---

## 3. Architecture

Découpage **feature-first** avec un noyau transverse, cohérent et respecté :

```
lib/
├── main.dart                  ProviderScope → MaterialApp.router + TopNotificationOverlay
├── core/
│   ├── constants/vocabulary.dart
│   ├── router/app_router.dart          ← 1 seul fichier, 463 lignes, toutes les routes
│   ├── services/notification_service.dart
│   ├── theme/                          closet_colors, closet_text_styles, app_spacing,
│   │                                   app_theme, typography, theme_provider
│   └── widgets/                        13 fichiers de composants partagés
├── data/
│   ├── bff_client/api_client.dart      Dio, base URL en dur
│   ├── models/                         adresse, article, commande, user
│   ├── repositories/                   7 repositories
│   └── services/                       auth_storage, local_storage
└── features/
    ├── main_layout.dart                coque cliente (bottom nav 5 onglets)
    ├── splash/  onboarding/  auth/  checkout/  transaction/
    ├── cliente/                        dressing, collections, product, selection,
    │                                   wishlist, espace
    └── sourceur/                       layout + 12 sous-dossiers
```

### Navigation

Un `GoRouter` unique dans `app_router.dart`, avec **deux `StatefulShellRoute.indexedStack`** — un pour l'espace cliente, un pour l'espace sourceur — et des routes hors coque pour le plein écran (auth, fiche produit, checkout, tunnel de transaction).

La logique de `redirect` (l.46-85) est écrite avec soin et commentée : elle distingue les entrées publiques du programme sourceur (`/sourceur/devenir`, `/sourceur/identification`), les routes protégées engageant argent ou identité (`/checkout`, `/transaction`, tout `/sourceur`), et le parcours d'adhésion qui ne doit pas se rediriger sur lui-même. `ref.listen(isAuthenticatedProvider)` déclenche `router.refresh()`.

**Onglets cliente** : Dressing `/home`, Collections `/collections`, Wishlist `/wishlist`, Sélection `/selection`, Espace `/espace`.
**Onglets sourceur** : Atelier `/sourceur`, Dépôts `/sourceur/pieces`, Confier `/sourceur/nouvelle`, Gains `/sourceur/revenus`, Espace `/sourceur/espace`.

### Conventions

Le code est en **français** : classes (`SelectionScreen`, `PieceDeposee`), méthodes (`deposerPiece`, `_validerPin`), providers (`mesPiecesProvider`, `revenusSourceurProvider`), et commentaires. Vocabulaire métier constant : *pièce*, *dressing*, *sélection* (et non panier), *sourceur*, *confier*, *dépôt*, *à reverser*. `core/constants/vocabulary.dart` centralise une partie des libellés d'interface.

Les fichiers d'écran suivent `*_screen.dart`, les feuilles modales `*_sheet.dart`, les composants sont préfixés `Closet*` dans `core/widgets/` et `Sourceur*` dans `features/sourceur/widgets/`.

### Lint

`analysis_options.yaml` est **plus strict que le défaut**, et c'est un atout : `strict-casts`, `strict-inference`, `strict-raw-types` activés, plus une trentaine de règles explicites (`prefer_single_quotes`, `prefer_final_locals`, `always_declare_return_types`, `avoid_dynamic_calls`, `unawaited_futures`, `use_build_context_synchronously`, `only_throw_errors`, la série `prefer_const_*`). Aucune règle désactivée.

---

## 4. Design system codé

### 4.1 Ce qui est solide — les couleurs

`core/theme/closet_colors.dart` se déclare source de vérité unique et **l'est effectivement** : j'ai comparé ses 36 tokens aux planches Figma `1:830` (Color System) et `1:1471` (Color Export Sheet) extraites du dump local. **Correspondance exacte, au hex près, sur les 11 rampes** :

| Rampe Figma | Niveaux | Constantes Dart |
|---|---|---|
| Application Background | 5 | `fond100`…`fond500` |
| Emerald Green | 5 | `emeraude100`…`emeraude500` |
| Neutral | 10 | `neutre100`…`neutre1000` |
| Red | 2 | `rouge100`, `rouge200` |
| Yellow | 2 | `jaune100`, `jaune200` |
| Green | 2 | `vertVif100`, `vertVif200` |
| Terre Brûlée | 2 | `terreBrulee100`, `terreBrulee200` |
| Night Green | 2 | `vertNuit100`, `vertNuit200` |
| Doré Lumière | 2 | `doreLumiere100`, `doreLumiere200` |
| Doré Encre | 2 | `doreEncre100`, `doreEncre200` |
| Gris Taupe | 2 | `taupe100`, `taupe200` |

Le fichier ajoute une couche de **rôles sémantiques** (`vert`, `noir`, `beige`, `creme`, `dore`, `taupe`, `succes`, `alerte`, `erreur`) qui pointent sur les rampes, et documente honnêtement les couleurs relevées sur composants mais absentes de la planche (`champFond`, `champBordure`, `champPlaceholder`, `filetSeparateur`, `carteFond`, `caseVide`, `pinTexte`…) ainsi qu'une section « hors palette Figma » assumée. C'est de la bonne tenue de design system.

### 4.2 Le problème principal — deux échelles typographiques concurrentes

Il existe **deux systèmes typographiques parallèles** qui ne se parlent pas :

| | `AppTypography` (`typography.dart`) | `ClosetTextStyles` (`closet_text_styles.dart`) |
|---|---|---|
| Alimente | `ThemeData.textTheme` | Appels directs dans les widgets |
| Modèle | Slots Material (display/title/body/label) | ~25 styles sémantiques nommés d'après Figma |
| Corps | `bodyLarge` 16, `bodyMedium` 14 | `corps` **12**, `saisie` 14 |
| Display Boldonse | 32 / 28 / 24 | `display` **22** |
| Titre écran | `titleLarge` EB Garamond 22 w600, sans couleur | `titreEcran` idem + couleur `vertFonce` |
| Bouton | `labelLarge` Lato 14 **bold**, `Colors.white` | `bouton` Lato **12 w500** |
| Interlignes / letterSpacing | non définis | définis par style |

**Conséquence mesurée** : les écrans consomment `ClosetTextStyles` et ignorent `Theme.of(context).textTheme`. `AppTypography` ne pilote donc quasiment rien du rendu réel — sauf là où un widget retombe sur le thème, comme `traitement_screen.dart:147` qui utilise `titleMedium`. C'est un piège : toute correction faite dans `typography.dart` n'a aucun effet visible, et les deux échelles divergent déjà (corps 12 vs 16, bouton 12 w500 vs 14 bold).

### 4.3 Écarts thème Material ↔ widgets custom

Le `ThemeData` décrit des composants que les widgets maison contredisent :

| Élément | `AppTheme` | Widget réellement utilisé |
|---|---|---|
| Fond AppBar (clair) | `offWhite` `#F5F2EC` | `ClosetAppBar` → `ClosetColors.beige` `#F3EBDD` |
| Fond bottom nav | `ClosetColors.noir` | `ClosetBottomNav` → `ClosetColors.vertFonce` |
| Chip sélectionné | `selectedColor: noir` | `ClosetChip` actif → `ClosetColors.vert` |
| CTA primaire | `ElevatedButton` vert/crème, radius 30 | `ClosetPrimaryButton` vert **ou** doré |

### 4.4 Couleurs en dur dans `app_theme.dart`

Malgré la règle affichée par `closet_colors.dart`, cinq hex sont déclarés dans le thème et absents de la palette : `sandBeige #E5E1D9` (l.16), `offWhite #F5F2EC` (l.17), `lightSand #ECE8DF` (l.20), `surface` sombre `#182E25` (l.104), bordure de chip sombre `#223F33`. Et `typography.dart:59` impose `Colors.white` sur `labelLarge`.

### 4.5 Espacements et rayons

`app_spacing.dart` est propre et documenté : grille 4/8 (`p4`…`p64`), `minTouchTarget` 44, plus trois valeurs hors grille relevées dans la maquette avec leur nombre d'occurrences (`gouttiere` 11.0, `gapListe` 9.2, `gapChip` 7.0). `AppRadius` couvre 7 rayons (`carte` 8, `vignette` 9.5, `bloc` 20, `surface` 32, `carteProduit` 36.7, `bouton` 50, `cercle` 100) et `AppStroke` 4 épaisseurs. Chaque valeur est annotée de sa fréquence dans la maquette — ce sont bien des mesures, pas des approximations.

---

## 5. Composants réutilisables

13 fichiers dans `core/widgets/`. Distinction importante entre les composants réellement génériques et les blocs liés à un écran :

### Génériques, réutilisables tels quels

| Composant | Fichier | Variantes / paramétrage |
|---|---|---|
| `ClosetPrimaryButton` | `closet_buttons.dart` | variante `dore`, icône, hauteur, animation d'appui |
| `ClosetOutlineButton` | `closet_buttons.dart` | hauteur |
| `ClosetChip` | `closet_chip.dart` | actif/inactif, icône de fermeture |
| `ClosetField` | `closet_field.dart` | libellé en encoche, multiligne, obscurci, suffixe, validateur |
| `ClosetChampLibelle` | `closet_field.dart` | libellé au-dessus |
| `ClosetSelectField<T>` | `closet_field.dart` | dropdown génarique typé |
| `closetFieldDecoration()` | `closet_field.dart` | décoration partagée |
| `ClosetFrise` + `EtapeFrise` | `closet_frise.dart` | timeline verticale, états atteinte/échec, mode fond sombre |
| `PieceCard` | `piece_card.dart` | image en arche, badge statut, favori, épuisé |
| `BoutonCoeur` | `piece_card.dart` | taille |
| `StatusBadge` | `status_badge.dart` | **8 fabriques** : `livree`, `enRoute`, `preparation`, `miseEnVente`, `enAnalyse`, `depotRecu`, `refusee`, `retournee` |
| `ClosetSurtitre`, `ClosetEnTeteSection`, `ClosetTitreEcran` | `closet_sections.dart` | — |
| `BordurePointillee` | `bordure_pointillee.dart` | couleur, rayon |
| `TopNotificationOverlay` | `top_notification_overlay.dart` | info / succès / erreur via `notificationProvider` |

### Spécifiques à un écran ou au branding

`ClosetAppBar` (lit `cartCountProvider` et `currentUserProvider`, navigue en dur vers `/selection` et `/espace/alertes`), `ArticleCard` (wrapper `Article` → `PieceCard`), `ClosetBottomNav` (5 onglets figés), `ClosetHeader` (layout 4 actions, dont plusieurs `onTap` vides), `ClosetSignature` (texte de marque figé), et toute la famille `Spotlight*` (visite guidée).

Côté sourceur, `features/sourceur/widgets/` ajoute `SourceurAppBar`, `SourceurHeader`, `SourceurBoutonRond`, `SourceurEntree`, et `features/sourceur/inscription/widgets/` fournit `LabeledField`, `SourceurHeroCard`, `StepIndicator`.

**Constat** : le socle de composants est riche et bien pensé. Le `StatusBadge` à 8 fabriques et le `ClosetFrise` couvrent déjà les besoins de statuts et de timelines de la maquette. Il y a peu à créer, beaucoup à réutiliser.

---

## 6. Écrans implémentés

### 6.1 Parcours transversal et cliente

| Écran | Fichier | Route |
|---|---|---|
| `SplashScreen` | `features/splash/splash_screen.dart` | `/splash` |
| `OnboardingScreen` | `features/onboarding/onboarding_screen.dart` | `/onboarding` |
| `AuthScreen` | `features/auth/auth_screen.dart` | `/auth` |
| `MainLayout` | `features/main_layout.dart` | coque des 5 onglets |
| `DressingScreen` | `features/cliente/dressing/dressing_screen.dart` | `/home` |
| `CollectionsScreen` | `features/cliente/collections/collections_screen.dart` | `/collections` |
| `_FiltresSheet` | `features/cliente/collections/filtres_sheet.dart` | modale |
| `ProductScreen` | `features/cliente/product/product_screen.dart` | `/product/:id` |
| `SelectionScreen` | `features/cliente/selection/selection_screen.dart` | `/selection` |
| `WishlistScreen` | `features/cliente/wishlist/wishlist_screen.dart` | `/wishlist` |
| `EspaceScreen` | `features/cliente/espace/espace_screen.dart` | `/espace` |
| `ModifierProfilScreen` | `features/cliente/espace/modifier_profil_screen.dart` | `/espace/infos` |
| `MesCommandesScreen` | `features/cliente/espace/mes_commandes_screen.dart` | `/espace/commandes` |
| `DetailCommandeScreen` | `features/cliente/espace/detail_commande_screen.dart` | `/espace/commandes/:numero` |
| `SuiviCommandeScreen` | `features/cliente/espace/suivi_commande_screen.dart` | `…/:numero/suivi` |
| `MesAdressesScreen` | `features/cliente/espace/mes_adresses_screen.dart` | `/espace/adresses` |
| `DeconnexionScreen` | `features/cliente/espace/deconnexion_screen.dart` | `/espace/deconnexion` |
| `EspacePaiementsScreen` | `features/cliente/espace/espace_sub_screens.dart` | `/espace/paiements` |
| `EspaceAlertesScreen` | idem | `/espace/alertes` |
| `EspaceFaqScreen` | idem | `/espace/faq` |
| `EspaceContactScreen` | idem | `/espace/contact` |
| `EspaceConfidentialiteScreen` | idem | `/espace/confidentialite` |
| `EspaceEvaluationScreen` | idem | `/espace/evaluation` |
| `CheckoutScreen` | `features/checkout/checkout_screen.dart` | `/checkout` |
| `TransactionFlowScreen` | `features/transaction/transaction_flow_screen.dart` | `/transaction` |
| `PinScreen` / `TraitementScreen` / `SuccesScreen` / `RecuScreen` | `features/transaction/` | étapes internes du tunnel |

### 6.2 Espace sourceur

| Écran | Fichier | Route |
|---|---|---|
| `SourceurLayout` | `features/sourceur/sourceur_layout.dart` | coque 5 onglets |
| `SourceurAtelierScreen` | `features/sourceur/atelier/sourceur_atelier_screen.dart` | `/sourceur` |
| `SourceurPiecesScreen` | `features/sourceur/pieces/sourceur_pieces_screen.dart` | `/sourceur/pieces` |
| `SourceurNouvellePieceScreen` | `features/sourceur/nouvelle/sourceur_nouvelle_piece_screen.dart` | `/sourceur/nouvelle` |
| `SourceurRevenusScreen` | `features/sourceur/revenus/sourceur_revenus_screen.dart` | `/sourceur/revenus` |
| `SourceurEspaceScreen` | `features/sourceur/espace/sourceur_espace_screen.dart` | `/sourceur/espace` |
| `DevenirSourceurScreen` | `features/sourceur/devenir/devenir_sourceur_screen.dart` | `/sourceur/devenir` |
| `IdentificationSourceurScreen` | `features/sourceur/identification/identification_sourceur_screen.dart` | `/sourceur/identification` |
| `SourceurInscriptionScreen` | `features/sourceur/inscription/sourceur_inscription_screen.dart` | `/sourceur/inscription` |
| `SourceurAdhesionScreen` | `features/sourceur/inscription/sourceur_adhesion_screen.dart` | `/sourceur/adhesion` |
| `AdhesionApprouveeScreen` | `features/sourceur/inscription/adhesion_approuvee_screen.dart` | `/sourceur/adhesion/approuvee` |
| `InspectionPieceScreen` | `features/sourceur/suivi/inspection_piece_screen.dart` | `/sourceur/piece/:id` |
| `SuiviPieceScreen` | `features/sourceur/suivi/suivi_piece_screen.dart` | `/sourceur/piece/:id/suivi` |
| `_MethodeRetraitSheet` | `features/sourceur/retrait/methode_retrait_sheet.dart` | modale |

**Total : 40 écrans routés** plus 2 feuilles modales. La couverture d'écrans est donc déjà large.

### 6.3 Code mort identifié

`espace_sub_screens.dart` (40 Ko, le plus gros fichier du projet) contient **deux écrans jamais atteignables** :

- `EspaceInfoScreen` — le routeur mappe `/espace/infos` sur `ModifierProfilScreen` (l.392-395) ;
- `EspaceAdressesScreen` — le routeur mappe `/espace/adresses` sur `MesAdressesScreen` (l.422-423).

Ce sont des doublons d'une version antérieure. `EspaceAdressesScreen` contient d'ailleurs 4 adresses américaines fictives (« Sunbrook Park », « Meadow Valley Terra ») là où `MesAdressesScreen` lit le repository.

### 6.4 Doublon fonctionnel Atelier ↔ Espace sourceur

Deux onglets de la bottom nav sourceur se recouvrent sémantiquement (solde, dépôts, confier une pièce) avec des implémentations distinctes :

| | `SourceurAtelierScreen` (onglet 0) | `SourceurEspaceScreen` (onglet 4) |
|---|---|---|
| En-tête | `SourceurAppBar` | `SourceurHeader` |
| Bloc principal | carte identité + stats + carte revenus | carte solde + 4 actions + menu compte |
| Données | profil du repo, **stats et revenus passés en `0` littéral** (l.39-45) | `revenusSourceurProvider` et `mesPiecesProvider` avec loading/error |
| Fonctions compte | aucune | logout, infos, confidentialité, feuille de retrait |

Vérifié directement dans le code :

```39:45:lib/features/sourceur/atelier/sourceur_atelier_screen.dart
                  _buildCarteIdentite(nomAtelier, ville, depuis, 0, 0, 0),
                  const SizedBox(height: AppSpacing.p24),
                  _buildCarteRevenus(context, 0, 0, 0, theme),
                  const SizedBox(height: AppSpacing.p24),
                  _buildActionsRapides(context, 0),
                  const SizedBox(height: AppSpacing.p32),
                  _buildActivite(context, 0),
```

L'Atelier affiche donc en permanence un tableau de bord à zéro, alors que les providers nécessaires existent et fonctionnent. C'est un branchement oublié, pas une fonctionnalité manquante.

---

## 7. Couche données

### 7.1 État par repository

| Repository | Mode | Preuve |
|---|---|---|
| `AuthRepository` | **HTTP réel + doublure locale** | `POST /auth/register` (l.48-56), `POST /auth/login` (l.80-86) ; plus `_localDb` / `_localPasswords` en mémoire et `_saveToLocal` (l.122-127) |
| `CatalogRepository` | **Mock** | `_mockArticles` + `_generateArticles()`, ~56 articles, `Future.delayed` ; aucun Dio |
| `CartNotifier` | **Local persistant** | `SharedPreferences`, clé `closet_cart_v1` |
| `WishlistNotifier` | **Local persistant** | `SharedPreferences`, clé `closet_wishlist_v1` |
| `AdresseRepository` | **Mock** | `_adressesSimulees` (4 entrées), `TODO(backend)` l.16 |
| `CommandeRepository` | **Mock** | `_commandesSimulees` (3 commandes), `TODO(backend)` l.22-24 |
| `SourceurRepository` | **Mock** | `_pieces` en mémoire, `ChangeNotifier`, latence 400-800 ms, « Brancher sur HTTP quand backend Dart Frog prêt » l.137 |

**Deux endpoints réels dans tout le projet** : `POST /auth/register` et `POST /auth/login`. Tout le reste est simulé — mais simulé proprement, avec latence et structures réalistes.

### 7.2 Providers Riverpod exposés

`bffClientProvider`, `authRepositoryProvider`, `currentUserProvider`, `catalogRepositoryProvider`, `localStorageProvider`, `cartProvider`, `cartListProvider`, `cartTotalProvider`, `cartCountProvider`, `wishlistProvider`, `wishlistListProvider`, `adresseRepositoryProvider`, `mesAdressesProvider`, `commandeRepositoryProvider`, `mesCommandesProvider`, `commandeProvider` (family), `sourceurRepositoryProvider`, `mesPiecesProvider`, `revenusSourceurProvider`, `themeModeProvider`, `notificationProvider`, `spotlightTourProvider`.

### 7.3 Modèles

Tous dans `data/models/`, tous avec `fromJson` et `toJson` :

- **`Article`** — 13 champs (`id`, `title`, `description`, `brand`, `size`, `material`, `condition`, `price`, `imageUrls`, `isFeatured`, `universe`, `isSoldOut`, `isWishlisted`) + `copyWith`.
- **`Commande`** + **`LigneCommande`** — enum `StatutCommande { preparation, enRoute, livree }` avec extension `libelle`, getters calculés `sousTotal` et `total`.
- **`Adresse`** — enum `TypeAdresse { maison, bureau, appartement, autre }`, drapeau `parDefaut`.
- **`ClosetUser`** — `fromJson` tolérant, accepte `full_name`/`fullName`, `first_name`/`firstName`, `token`/`access_token`. Getter `initials`.

**Hors dossier `models/`** : `sourceur_repository.dart` définit aussi `PieceDeposee`, `RevenusSourceur`, `VenteSourceur`, `SourceurInscriptionData`, `SourceurProfile`. Seul `PieceDeposee` a une sérialisation. Ces types métier gagneraient à rejoindre `models/`.

---

## 8. États vide, chargement, erreur

C'est le point le plus inégal du projet. Les écrans branchés sur un repository asynchrone gèrent correctement les trois états via `AsyncValue.when` ; les écrans à données en dur n'en gèrent aucun.

### Complets (vide + chargement + erreur)

`CollectionsScreen`, `ProductScreen`, `MesAdressesScreen`, `MesCommandesScreen`, `DetailCommandeScreen`, `SuiviCommandeScreen`, `SourceurPiecesScreen`, `SourceurRevenusScreen`, `SuiviPieceScreen`.

### Partiels

| Écran | Manque |
|---|---|
| `DressingScreen` | chargement et erreur présents, **aucun état vide** — les sections disparaissent silencieusement si le catalogue est vide |
| `SelectionScreen` | état vide (`_SelectionVide`) mais **ni chargement ni erreur** |
| `WishlistScreen` | état vide (`_WishlistVide`) mais **ni chargement ni erreur** |
| `SourceurAtelierScreen` | état vide d'activité, mais conditionné à `depots == 0` qui est toujours vrai |
| `SourceurEspaceScreen` | loading/error sur la carte solde seulement, rien au niveau écran |
| `_MethodeRetraitSheet` | affiche `--` faute de données, pas d'état explicite |

### Aucun état

Les 7 écrans à contenu statique de `espace_sub_screens.dart` (`EspacePaiementsScreen`, `EspaceAlertesScreen`, `EspaceFaqScreen`, `EspaceContactScreen`, `EspaceConfidentialiteScreen`, `EspaceEvaluationScreen`, plus les 2 doublons morts), `ModifierProfilScreen`, `SourceurAdhesionScreen`, `AdhesionApprouveeScreen`, `InspectionPieceScreen`, `DevenirSourceurScreen`, `OnboardingScreen`.

---

## 9. Écarts au design system centralisé

L'ampleur est significative et concentrée. Recensement des valeurs qui court-circuitent `ClosetColors` / `ClosetTextStyles` :

### Couleurs en dur

`data/` est **totalement propre** : aucune couleur. Les écarts sont dans l'UI.

| Valeur | Occurrences | Emplacements principaux |
|---|---|---|
| `Colors.white` | ~70 | quasi tous les écrans |
| `Color(0xFFD9D9D9)` | 12 | `product_screen`, `selection_screen`, `wishlist_screen`, `detail_commande_screen`, `sourceur_pieces_screen` (placeholders d'image) |
| `Color(0xFFE5E5E5)` | 5 | `piece_card`, `dressing_screen` |
| `Colors.transparent` | ~7 | `closet_chip`, `closet_buttons`, `closet_bottom_nav`, `filtres_sheet`, `methode_retrait_sheet`, `sourceur_adhesion_screen` |
| `Colors.black*` | ~7 | `main_layout`, `spotlight_showcase`, `top_notification_overlay`, `selection_screen`, `recu_screen`, `sourceur_layout` |
| `Color(0xFF98C1B0)`, `Color(0xFFC49A6C)` | 2 | `espace_sub_screens` l.335, l.369 |
| `Colors.green` | 1 | `espace_sub_screens` l.756 |

Le cas `Colors.white` est nuancé : `ClosetColors` n'expose **pas** de blanc pur. Le token le plus proche est `creme` `#FBF7EF` (`neutre100`). Il faudra trancher entre déclarer un token `blanc` et remplacer les usages par `creme`.

### Typographies en dur

| Type | Volume | Concentration |
|---|---|---|
| `TextStyle(` inline | ~35 | **`espace_sub_screens.dart` en concentre ~32** |
| `GoogleFonts.*` inline | 5 | `main_layout` l.234-238, `espace_sub_screens` l.46-51, 324-327, 340-345, 354-358 |
| `fontSize:` littéral | ~45 | réparti ; valeurs 8, 8.5, 9, 10, 11, 12, 12.5, 13, 14, 15, 16, 17, 18, 19, 20, 22, 25, 27, 28, 40 |

`espace_sub_screens.dart` est nettement le foyer principal de dette de style : à lui seul il porte la majorité des `TextStyle` inline du projet, plus les deux couleurs exotiques, plus les 7 écrans sans état, plus les 2 écrans morts.

---

## 10. Actions inertes et fonctionnalités inachevées

### Bloquant pour un parcours de bout en bout

Le **tunnel de transaction ne peut pas aboutir**. Le routeur injecte volontairement un exécuteur qui échoue toujours :

```205:210:lib/core/router/app_router.dart
              // TODO(backend): brancher l'endpoint de transaction. Le tunnel
              // exige un exécuteur : il ne peut pas afficher un succès sans
              // opération réelle, et le reçu doit être émis par le serveur.
              executer: (demande, pin) => throw const TransactionRefusee(
                'Le service de transaction n’est pas encore disponible.',
              ),
```

Le choix est défendable — refuser d'afficher un faux succès de paiement — mais la conséquence est que `PinScreen` → `TraitementScreen` échoue systématiquement, et que `SuccesScreen` et `RecuScreen`, tous deux terminés côté UI, sont **inatteignables**. Le reçu dépend de l'objet `RecuTransaction` que seul `executer` peut produire.

Par ailleurs `CheckoutScreen` pousse une `DemandeTransaction` mais **ne crée aucune commande et ne vide pas le panier** (l.77-87).

### Actions sans effet réel

| Emplacement | Élément | Comportement |
|---|---|---|
| `auth_screen.dart` l.286-293 | « CONTINUER avec Google » | SnackBar « bientôt disponible » |
| `auth_screen.dart` l.260-267 | « Mot de passe oublié » | SnackBar |
| `identification_sourceur_screen.dart` l.187-194 | « Mot de passe oublié » | SnackBar |
| `selection_screen.dart` l.367-370 | « Appliquer » code privilège | SnackBar |
| `modifier_profil_screen.dart` l.50-57, 282-285 | enregistrer, changer photo | `TODO` backend + SnackBar |
| `mes_adresses_screen.dart` l.66, 88 | ajouter / éditer une adresse | SnackBar `_aVenir` |
| `espace_sub_screens.dart` l.757, 766 | WhatsApp et email de contact | `onTap: () {}` |
| `espace_sub_screens.dart` l.278 | éditer une adresse | `onEdit: () {}` |
| `dressing_screen.dart` l.298 | cœur de la pièce à la une | `actif: false` figé, pas de bascule |
| `collections_screen.dart` l.216 | pilule « Nouveautés » | ouvre les filtres au lieu de trier |
| `sourceur_revenus_screen.dart` l.36-38 | filtre | SnackBar « Filtres à venir » |
| `sourceur_nouvelle_piece_screen.dart` l.94 | upload photo | `TODO(backend)` |
| `transaction_flow_screen.dart` l.115-117 | partager le reçu | SnackBar |

### Données en dur dans l'UI

`fraisLivraison = 3500` (`selection_screen.dart` l.19), téléphone `+237 677 45 22 18` (`espace_sub_screens.dart` l.102), listes `_methods`, `_alerts`, `_faq`, `_adresses` (`espace_sub_screens.dart`), `moyensRetrait` (`methode_retrait_sheet.dart` l.34-53, importé jusque dans `checkout_screen.dart`), `_specialites` / `_moyensPaiement` / `_typesCollaboration` (`sourceur_inscription_screen.dart`), étape d'adhésion par défaut (`sourceur_adhesion_screen.dart` l.24).

---

## 11. Tests et intégration continue

### Ce qui existe — 36 cas, tous sur le sourceur

| Fichier | Cas | Objet |
|---|---|---|
| `test/data/repositories/sourceur_repository_test.dart` | 17 (15 actifs, **2 `skip`**) | inscription, profil, dépôt de pièces, calcul de revenus et commission 25 %, troncature |
| `test/features/sourceur/sourceur_inscription_screen_test.dart` | 16 `testWidgets` | les 3 étapes du formulaire, validations, préservation des saisies au retour, payload de soumission, écarts connus |
| `integration_test/sourceur_inscription_flow_test.dart` | 3 `testWidgets` | parcours d'inscription complet, redirection non-partenaire, retour arrière |

La qualité de ces tests est bonne : ils documentent explicitement des **écarts connus** (type de collaboration non transmis au repository, WhatsApp invalide accepté, spécialité et moyen de paiement non persistés) plutôt que de les masquer.

### Ce qui manque

**Aucun test** sur : tout le parcours cliente (splash, onboarding, auth, dressing, collections, produit, sélection, wishlist, espace, checkout, tunnel de transaction), `CatalogRepository`, `CartNotifier`, `WishlistNotifier`, `AuthRepository`, `AdresseRepository`, `CommandeRepository`, les 13 composants de `core/widgets/`, et 13 des 14 écrans sourceur.

### CI

**Aucune.** Pas de `.github/workflows/`, pas de `.gitlab-ci.yml`, `codemagic.yaml`, Azure Pipelines ni Bitrise. Les 36 tests existants ne sont donc jamais exécutés automatiquement. `README.md` est le gabarit Flutter par défaut, sans instruction de build ni de test.

---

## 12. Accès Figma — état des lieux

Ce point conditionne les Phases 1 à 4.

| Fichier | Clé | Résultat |
|---|---|---|
| Lien fourni dans la mission | `Echo68Mu5LH6P4FPCcY0Zs` | **Vide.** Une seule page (`0:1`), pour tout contenu un vecteur orphelin `329:30`. Aucun node-id de l'inventaire n'y existe. |
| Référencé par le code | `VmP4xqjT7R9FVcPT3tQsWg` | **Le bon fichier**, mais inaccessible : « you don't have edit access to this file ». Siège **View** sur plan Starter. |

Les outils MCP Dev Mode (`get_design_context`, `download_assets`) sont donc indisponibles.

**Contournement retenu** : le repo contient déjà `design/figma_specs.json` (54 Mo), un dump complet de l'API REST Figma du fichier « ClosEt App » — 28 511 calques, 3 pages, 7 styles nommés, `lastModified` **2026-08-06**. Plus 20 captures PNG dans `design/figma/`.

J'ai écrit `tools/figma_specs.py` pour l'exploiter comme substitut de `get_design_context` (sous-commandes `info`, `pages`, `frames`, `tree`, `context`, `text`, `digest`, `find`) et produit les relevés de référence rassemblés dans `design/raw/` : `figma_context.txt` (tokens par écran), `figma_textes.txt` (contenus texte par écran), `nav_styles.txt` (relevé calque par calque de la barre de navigation).

**Limite à garder en tête** : le dump date du 6 août, soit 13 jours avant cet audit. Toute évolution de maquette postérieure est invisible.

---

## 13. Synthèse

### Points forts

1. **Architecture saine** — feature-first cohérent, Riverpod et go_router bien employés, logique de redirection réfléchie et commentée.
2. **Palette de couleurs exacte** — les 36 tokens correspondent au hex près à la maquette. C'est vérifié, pas supposé.
3. **Lint strict** et code qui passe l'analyse avec 6 remontées mineures.
4. **Socle de composants riche** — `StatusBadge` à 8 fabriques, `ClosetFrise`, `PieceCard`, famille de champs complète.
5. **Couverture d'écrans large** — 40 écrans routés, la plupart des parcours de la maquette ont au moins une implémentation.
6. **Mocks propres** — latence simulée, structures réalistes, `TODO(backend)` explicites.
7. **Tests sourceur de bonne facture**, qui documentent leurs propres écarts.

### Points faibles, par gravité

1. **Tunnel de transaction inachevable** — l'exécuteur stub rend `SuccesScreen` et `RecuScreen` inatteignables, et le checkout ne crée pas de commande.
2. **Deux échelles typographiques concurrentes** — `AppTypography` ne pilote rien ; `ClosetTextStyles` fait tout. Divergences déjà installées.
3. **`espace_sub_screens.dart`** — 40 Ko concentrant 2 écrans morts, 7 écrans sans état, ~32 `TextStyle` inline, données en dur.
4. **~135 valeurs de style en dur** dans l'UI (couleurs et typos), dont ~70 `Colors.white` sans token équivalent dans la palette.
5. **Atelier sourceur à zéro** — stats et revenus passés en littéral alors que les providers existent.
6. **Aucune CI**, aucun test sur le parcours cliente.
7. **Build local impossible** faute de Mode Développeur Windows.
8. **`.env` déclaré mais absent**, base URL de production figée dans le code.

### Décisions assumées faute d'arbitrage

Ces choix sont réversibles ; ils sont pris pour ne pas bloquer l'avancement.

| Sujet | Décision |
|---|---|
| Source Figma | Le dump local `design/figma_specs.json` fait référence. |
| Icônes | `lucide_icons_flutter`, déjà installé, quand l'icône Figma a un équivalent exact. Les images manquantes seront listées, pas inventées. |
| Données | Compléter les mocks existants pour rendre les parcours démontrables de bout en bout, sans créer de nouvelle source. |
| Architecture | Aucune refonte structurante. Les corrections restent locales et justifiées. |

### Questions ouvertes

1. Faut-il un token `blanc` dans `ClosetColors`, ou remplacer les ~70 `Colors.white` par `creme` `#FBF7EF` ?
2. `AppTypography` et le `textTheme` Material doivent-ils être alignés sur `ClosetTextStyles`, ou retirés au profit d'une source unique ?
3. Les deux écrans morts de `espace_sub_screens.dart` doivent-ils être supprimés, ou l'un des deux doublons doit-il remplacer l'écran actuellement routé ?
4. Les onglets Atelier et Espace sourceur doivent-ils fusionner, ou garder des rôles distincts et non redondants ?
5. Le Mode Développeur Windows peut-il être activé, pour permettre tests et captures d'écran de validation en Phase 5 ?
