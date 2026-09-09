# Phase 3 — Plan de travail priorisé

Établi à partir de `docs/gap-analysis.md`, et consolidé avec la spec du backend
(`design/openapi.json`).

**Baseline de non-régression** : `dart analyze` 0 problème · `flutter test` 30 ✅ / 2 skip.

---

## Principe de priorisation

L'ordre suggéré par la mission (auth → catalogue → panier → profil → sourceur) suppose un projet peu avancé. **L'audit montre l'inverse** : les 40 écrans de la maquette sont déjà routés, 18 sont conformes, un seul manque totalement. Deux réordonnancements s'imposent :

1. **L'authentification n'est pas bloquante.** Elle fonctionne et `auth_repository.dart` appelle déjà le backend réel (`POST /auth/register`, `POST /auth/login`). Elle est rétrogradée.
2. **Le design system passe en premier.** Corriger les tokens fait converger une dizaine d'écrans d'un coup ; le faire en dernier obligerait à repasser sur tout ce qui aura été écrit entre-temps.

Le backend n'est pas branché à ce stade — c'est l'étape suivante convenue. Mais **chaque mock est structuré d'après `design/openapi.json`**, pour que le remplacement soit mécanique.

---

## Lot 1 — Fondation du design system ✅

| Tâche | État |
|---|---|
| Tokens manquants : `blanc`, `noirPur`, `gabaritImage` `#D9D9D9`, `gabaritImageClair` `#E5E5E5`, `champTitre` `#0C1421`, `champLibelle` `#122B31` | fait |
| `AppTypography` dérivé de `ClosetTextStyles` — fin de la double échelle | fait |
| `AppTheme` : suppression des 3 couleurs en dur et des 8 alias morts ; appBar, chip, nav alignés sur les widgets réels | fait |
| `ClosetBottomNav` refondu au relevé `13:1182` et **branché** dans les deux shells | fait |
| Suppression des deux `_NavItem` dupliqués | fait |
| Casse exacte des badges : « EN route », « dépôt reçu », « refusé » | fait |
| Analyse ramenée à 0 problème | fait |

**Constat en cours de route** : `StatusBadge` était **déjà exact** aux 8 statuts près — la gap analysis se trompait en lui attribuant des couleurs hors palette (confusion avec les badges de *condition*). Et `ClosetBottomNav`, écrit mais orphelin, était masqué par deux barres dupliquées non conformes.

---

## Lot 2 — Tunnel de paiement

Le cœur commerçant, aujourd'hui inatteignable : l'exécuteur de transaction lève systématiquement.

| Tâche | Écrans Figma | Endpoint cible |
|---|---|---|
| Paramétrer le tunnel par type d'opération — **deux corps de reçu**, pas seulement des libellés | `162:3473` vs `32:865` | — |
| Découpler le code PIN du paiement acheteuse | `32:704` appartient au retrait sourceur | — |
| Exécuteur de transaction produisant commande et reçu | `app_router.dart` | `POST /orders`, `POST /payments/initiate` |
| Traitement cliente avec frise 3 étapes | `162:5220` | — |
| « Paiement réussi » : n° de commande, mention WhatsApp, frise | `162:3351` | `GET /payments/{id}` |
| Reçu d'achat : Marque, Catégorie, Taille, État, Mode de paiement, Livraison | `162:3473` | `GET /orders/{order_number}` |
| Création de commande et vidage du panier | — | `POST /orders` |

---

## Lot 3 — Checkout, étape 1/3

Le plus gros écart de fidélité du projet. **Un seul écran à états**, pas 14 (cf. `docs/figma-mapping.md` §2).

| Tâche | Écrans Figma | Endpoint cible |
|---|---|---|
| Liste déroulante réutilisable (séparateur `#E3E3E3`, rayon 8) | `61:12575` | — |
| Sélecteur Région — 10 régions du Cameroun | `162:3709` | `GET /geo/regions` |
| Sélecteur Département dépendant de la région | `162:3844` | `GET /geo/regions/{id}/divisions` |
| Champ Quartier et résumé replié | `162:4002`, `162:4162` | `GET /geo/cities/{id}/neighbourhoods` |
| Variante ville — Yaoundé / Douala / Autre, avec délais | `162:5536` | `GET /geo/cities` |
| Feuille de méthode de paiement, masque « **** 4864 » | `162:4255`, `162:4647` | `InitiateIn.operator` |
| Formulaire carte : Cardholder, Number, CVV, MM/AA | `162:5427` | — |
| Récapitulatif dépliable, « réservée pendant 15 minutes » | `162:5119` | — |
| Devis de livraison au lieu des 3 500 en dur | `16:3448` | `GET /delivery/quote` |
| Code privilège appliqué | `16:3448` | `CheckoutIn.privilege_code` |

---

## Lot 4 — Catalogue et fiche produit

| Tâche | Écrans Figma |
|---|---|
| Carte produit : rayon 36.67, gabarits tokenisés, badges de condition branchés | `11:30` |
| Accueil : état vide, bascule wishlist sur la pièce à la une | `11:30` |
| Collections : bloc « Nouveauté du dressing », tri réel, compteur « N pièces » | `14:1281`, `16:2260` |
| Feuille Filtre : filtre par maison, CTA « Voir N pièces » | `14:1514` |
| Fiche produit : section Entretien, détails enrichis | `16:3328` |
| Modèle `Article` : `entretien`, `coupe`, `composition`, `usage` | `data/models/article.dart` |
| Brancher `AppSpacing.gouttiere` (11) à la place des 19/20/21 en dur | écrans de liste |

---

## Lot 5 — Mocks conformes à la maquette

Remonté avant les lots 6 et 7 : sans données seedées, « Mes dépôts » et « Mes favoris » s'affichent vides et ne peuvent pas être comparés à la maquette en Phase 5.

| Repository | Seed attendu |
|---|---|
| `catalog_repository` | marques et prix de la maquette (coco chanel, zara, louboutin, massimo dutti…) |
| `wishlist_repository` | les 4 pièces de `25:924` |
| `commande_repository` | 2ᵉ article sur CE-2641 (Sac Cuir Chanel, 31 000) |
| `sourceur_repository` | solde 52 000, à reverser 27 300, 3 pièces aux statuts distincts |
| *(nouveau)* `geo_repository` | régions et départements du Cameroun, structuré comme `RegionOut` / `DivisionOut` |

---

## Lot 6 — Espace cliente

| Tâche | Écrans Figma | Endpoint cible |
|---|---|---|
| Enregistrement du profil | `25:710` | `PATCH /me` |
| Ajout et édition d'adresse | `26:1588` | `AddressIn` |
| Suivi de commande acheteuse — 5 jalons nommés, « Laissez-nous un message » | `162:5657` | `GET /orders/{order_number}` |
| Détail commande : 2ᵉ article, CTA « Ajouter à mon dressing » | `26:1262` | — |
| Titres serif : EB Garamond au lieu de Cormorant | `16:3448`, `24:39`, `25:710` | — |
| Favoris : rayon 36.67 | `25:924` | — |

---

## Lot 7 — Espace sourceur

| Tâche | Écrans Figma | Endpoint cible |
|---|---|---|
| Statut d'adhésion depuis le dépôt au lieu de `enEtude` en dur | `27:1970` | `GET /sourcing/me` |
| Corriger le texte d'« Adhésion approuvée » (parle d'expédition) | `29:46` | — |
| Résumé de solde sur l'historique de transaction | `32:1223` | `GET /sourcing/payouts` |
| Mes dépôts : double badge « Retourné » + « refusé » | `35:1895` | `GET /sourcing/submissions` |
| Confier une pièce : libellés de la zone photo, étapes 1/3/4 | `33:1389` | `POST /sourcing/submissions` |
| Textes tronqués (« Deux formules », WhatsApp + 48 h) | `26:1771`, `27:1970` | — |

---

## Lot 8 — Dette et hygiène

| Tâche |
|---|
| Supprimer les 2 écrans morts (`EspaceInfoScreen`, `EspaceAdressesScreen`) |
| Casser le couplage `checkout_screen` → `moyensRetrait` du module sourceur |
| Brancher l'Atelier sourceur sur ses providers (affiche zéro alors que les données existent) |
| Dédupliquer `_BoutonDore` → `ClosetPrimaryButton` |
| Factoriser le motif d'arche (5 copies) |
| Unifier les 3 en-têtes (`_EnTeteRetour`, `_EnTeteCentre`, `SourceurHeader`) |
| Compléter les états vide / chargement / erreur manquants |
| `.env.example` et README |
| Tests sur le parcours cliente, et intégration continue |

---

## Ordre d'exécution

```
Lot 1 (socle) ✅ → Lot 2 (transaction) → Lot 3 (checkout) → Lot 4 (catalogue)
   → Lot 5 (mocks) → Lot 6 (espace) → Lot 7 (sourceur) → Lot 8 (dette)
```

Commits atomiques par lot, ou par écran pour les lots 4 à 7.
`dart analyze` et `flutter test` après chaque lot.

---

## Décisions prises

Le contrôle m'ayant été confié, voici les arbitrages retenus et leur raison.

| Sujet | Décision | Raison |
|---|---|---|
| Token blanc | Ajouter `blanc = #FFFFFF` plutôt que rabattre sur `creme` | la maquette emploie du blanc pur, distinct de `creme #FBF7EF` ; le rabattre changerait le rendu |
| `AppTypography` | Conservé mais **dérivé** de `ClosetTextStyles` | supprime la divergence sans casser les widgets Material qui lisent le `textTheme` |
| Rôle `dore` | **Non remappé** sur `fond300` | `doreLumiere100` est une rampe légitime de la planche `1:830` ; les écarts constatés sont des usages ponctuels, à corriger un par un plutôt que par un remap global à fort impact |
| Barre de navigation | Composant unique pour les deux shells | la maquette ne décrit qu'une barre ; en entretenir deux était la cause de la dérive |
| Icônes de navigation | Paires Material contour/plein | les icônes Figma viennent de 4 jeux Iconify distincts, qu'aucune librairie du projet ne couvre, et le dump ne permet pas d'exporter les SVG |
| Écrans morts | Supprimés | ils dupliquent des écrans routés et mieux faits |
| Onglet Atelier | Conservé et branché | absent de la maquette, mais le retirer changerait la navigation ; le brancher coûte moins et ne casse rien |
| `#B3914D`, `#103A2D` | Rattachés à `fond400` et `emeraude500` | dérives de maquette à 1–2 points d'un token existant |
| Code PIN | Réservé au retrait sourceur | conforme à la maquette et au backend |
| Données | Mocks complétés, structurés d'après `design/openapi.json` | le remplacement par les appels réels doit être mécanique |
| Architecture | Inchangée | rien ne le justifie, l'existant est sain |

---

## Questions ouvertes

1. **`.env` déclaré mais absent.** `pubspec.yaml` le liste en asset ; `main.dart` gère l'échec de chargement et `api_client.dart` code l'URL de base en dur. Faut-il externaliser l'URL et fournir un `.env.example` ?
2. **Statut « Retourné ».** La maquette l'affiche (`36:2063`) et annonce « six statuts », mais `SubmissionStatus` du backend n'a pas d'état de retour physique. Statut applicatif, ou évolution du backend ?
3. **« Etat correcte »** apparaît sur `33:1389` mais `PieceCondition` ne connaît que `new`, `very_good`, `good`.
4. **Paiement par carte.** La maquette montre un formulaire Visa complet, alors que `POST /payments/initiate` délègue à un `payment_url` CinetPay. Le formulaire carte est-il encore d'actualité ?
