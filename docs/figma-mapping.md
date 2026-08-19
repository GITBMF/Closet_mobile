# Phase 1 — Cartographie de la maquette Figma

**Fichier** : « ClosEt App », clé `VmP4xqjT7R9FVcPT3tQsWg`, `lastModified` 2026-08-06, 28 511 calques.
**Source exploitée** : `design/figma_specs.json` (dump REST complet), interrogé via `tools/figma_specs.py`.
**Relevés bruts** (`design/raw/`, régénérables) :
- `figma_context.txt` — tokens agrégés, un bloc par écran
- `figma_textes.txt` — libellés dans l'ordre vertical
- `nav_styles.txt` — relevé calque par calque de la barre de navigation
- `color_system.txt`, `figma_frames.txt` — planche de couleurs et inventaire des frames

> **Le lien fourni dans la mission (`Echo68Mu5LH6P4FPCcY0Zs`) ne contient pas la maquette** : une page vide avec un unique vecteur orphelin. Le vrai fichier est `VmP4xqjT7R9FVcPT3tQsWg`, inaccessible en MCP faute de siège éditeur. Voir `docs/audit-code-existant.md` §12.

---

## 1. Structure du document

| Page | ID | Contenu |
|---|---|---|
| Page 1 | `0:1` | vide |
| **Visualization** | `1:3` | **89 frames de premier niveau** — tous les écrans, composants et parcours |
| Export | `1:1175` | `1:1471` Color Export Sheet — la planche de tokens de référence |

La page `Export` **ne figurait pas dans l'inventaire fourni**. Elle contient la planche d'export des couleurs, plus lisible que `1:830` car elle nomme chaque rampe et son hex.

Les 89 frames de `Visualization` se répartissent en quatre natures qu'il faut distinguer :

| Nature | Nombre | Traitement |
|---|---|---|
| Écrans (`FRAME` 390×N) | 54 | à implémenter |
| Planches de design system | 2 | `1:830`, `1:1471` → tokens |
| Composants et jeux d'états (`SECTION` petits) | 5 | à factoriser en widgets |
| Parcours / userflows (`SECTION` géants) | 22 | **documentation de navigation, rien à implémenter** |
| Résidus | 6 | `9:2199` Frame 1 (19×18), `52:11399` Section 1, doublons |

### Les userflows ne sont pas des écrans

Les 22 `SECTION` géantes (jusqu'à 16 763 × 3 317 px) sont des planches de parcours qui **réutilisent des copies des écrans** pour montrer l'enchaînement. Elles sont précieuses comme spécification de navigation, mais ne doivent générer aucun code :

| Section | ID | Parcours documenté |
|---|---|---|
| Parcours User Invité - Souscripteur - Achat & Suivi | `38:6292` | visiteuse → inscription → achat → suivi |
| Parcours User Inscris Scroll barre de navigation | `38:6293` | navigation inscrite |
| Parcours User Invité Scroll barre de navigation | `38:7608` | navigation invitée |
| Inscription Sourceur et Adhésion | `39:110` | adhésion sourceur complète |
| Authentification Sourceur → Retrait → Reçu | `39:784` | retrait d'argent sourceur |
| Confier une pièce → Réception → Analyse → Suivi | `39:1262` | dépôt de pièce |
| Soumission avec refus | `39:1438` | branche refus |
| Soumission avec acceptation | `39:1439` | branche acceptation |
| Retrait d'argent avec reçu | `39:2142` | retrait + reçu |
| Espace sourceur - Mes dépôts | `39:2358`, `39:3600` | dépôts |
| Espace Sourceur - Historique de transaction | `39:3599` | historique |
| Mon Espace - Editer mon profil | `39:5331` | profil |
| Mon Espace - Mes favoris | `39:5799` | favoris |
| Mon Espace - Mes commandes | `39:6050` | commandes |
| Mon Espace - Mes adresses | `39:6301` | adresses |
| Sélection → Paiement → Méthode → Confirmation | `39:3183` | **tunnel de paiement complet** |
| Userflow complet + déconnexion | `39:11341` | vue d'ensemble |

---

## 2. Élucidation des frames homonymes `162:xxxx`

L'inventaire fourni signalait des noms dupliqués sous `162:xxxx` en supposant des variantes vide/rempli. **Ce n'est pas le cas**, et la distinction est structurante.

### Axe 1 — deux métiers sur un même gabarit

Les écrans de fin de transaction existent en deux déclinaisons : `32:xxx` pour le **retrait sourceur**, `162:xxxx` pour le **paiement acheteuse**. Comparaison des contenus réels :

| Gabarit | `32:xxx` — retrait sourceur | `162:xxxx` — paiement acheteuse |
|---|---|---|
| Traitement | `32:756` « Traitement en cours », sans frise | `162:5220` / `162:5273` « Paiement en cours » **+ frise 3 étapes** |
| Succès | `32:813` « Transaction reussie ! » / « Votre opération a été effectuée » | `162:3351` / `162:3412` « Paiement reussi » + « Commande N° ce-2641 » + « Confirmation envoyée sur WhatsApp » + frise |
| Reçu | `32:865` « Mode de Retrait », « Compte Numéro », « Nom du receveur », « Total retiré », CTA « Retour dans Mon Espace » | `162:3473` / `162:3535` « Marque de la pièce », « Catégorie », « Taille », « Etat de la pièce », « Mode de paiement », « Livraison », CTA « Poursuivre ma visite » |

**Conséquence d'implémentation** : un seul composant de reçu, paramétré par une liste de lignes et un couple de CTA. Pas deux écrans.

### Axe 2 — storyboard d'interaction d'un seul écran

Les 14 frames « Ma sélection E1 » sont les états successifs de **l'étape 1/3 du tunnel de paiement**, pas 14 écrans :

| Frames | État capturé |
|---|---|
| `56:11462` | formulaire replié (nom, téléphone, résumé livraison, méthode de paiement) |
| `162:3597` | champs Département / Région / Quartier dépliés |
| `162:3709` | liste **Région** ouverte — 10 régions du Cameroun |
| `162:3844` | liste **Département** ouverte — 10 départements du Centre |
| `162:4002` | quartier saisi (« Newton- Collège Saint Coeur de Marie ») |
| `162:4162` | adresse résumée en une ligne |
| `162:4255`, `162:4451` | feuille **méthode de paiement** ouverte (Orange Money, MTN Mobile Money, `**** 4864`) |
| `162:4647` | MTN sélectionné → champ « Numéro de téléphone » apparaît |
| `162:4741` | MTN validé |
| `162:4834`, `162:4927`, `162:5023` | Visa Card sélectionnée |
| `162:5427` | Visa → champs Cardholder Name, Card Number, CVV, Expiration MM/YY |
| `162:5119`, `162:5326` | bloc récapitulatif : « sous-total + livraison », « Total à régler », « Paiement chiffré. Votre pièce est réservée pendant 15 minutes » |
| `162:5536` | variante sélection de **ville** (Yaoundé / Douala / Autre, « Livraison à domicile 24h-48h », « A determiner ») |

**Conséquence d'implémentation** : un écran, avec listes en cascade, feuille de méthode de paiement et champs conditionnels. Aucune duplication.

### Écran distinct découvert

`162:5657` « Page suivie de pièce » n'est pas un doublon : c'est le **suivi de commande côté acheteuse** (« COMMANDE #CE-2641 », « Voyage de votre pièce », 5 jalons : Sélection confirmée → Paiement confirmé → Préparée avec soin → En route pour livraison → Dans votre dressing, CTA « Laissez-nous un message »). Il est distinct du suivi de pièce sourceur (`34:1578` / `34:1710`).

---

## 3. Tokens de design system

### 3.1 Couleurs — `1:830` et `1:1471`

11 rampes, 36 tokens. **Vérifiés un par un contre `closet_colors.dart` : correspondance exacte.**

| Rampe | Niveaux | Hex |
|---|---|---|
| Application Background | 100→500 | `#f3ebdd` `#e0cba7` `#cdab71` `#b58a40` `#7f612d` |
| Emerald Green | 100→500 | `#a0d0bd` `#71b89c` `#4b9779` `#346753` `#1c382d` |
| Neutral | 100→1000 | `#fbf7ef` `#efe2c9` `#e1cda6` `#d0b685` `#bc9f67` `#a08550` `#7a6844` `#564b36` `#353025` `#171512` |
| Red | 100→200 | `#fb3748` `#d00416` |
| Yellow | 100→200 | `#ffdb43` `#dfb400` |
| Green | 100→200 | `#84ebb4` `#1fc16b` |
| Terre Brûlée | 100→200 | `#d06c60` `#9b3a2e` |
| Night Green | 100→200 | `#45896f` `#12241d` |
| Doré Lumière | 100→200 | `#c6a24b` `#91742e` |
| Doré Encre | 100→200 | `#d4a73d` `#7e611c` |
| Gris Taupe | 100→200 | `#a49680` `#6b5f4c` |

### 3.2 Couleurs hors rampes réellement employées

Relevées sur les écrans, absentes des planches. Celles déjà déclarées dans `closet_colors.dart` sont marquées ✓.

| Hex | Usage constaté | Statut |
|---|---|---|
| `#FFFFFF` | omniprésent (14× sur le splash, 4× sur l'accueil, 28× en trait sur la nav) | **manquant** — aucun token blanc |
| `#F3F3F3` | fond des cartes produit (21× sur l'accueil) | ✓ `carteFond` |
| `#E6E6E6` | bordure des cartes produit | ✓ `carteBordure` |
| `#656565` | libellé de puce inactive | ✓ `chipTexteInactif` |
| `#F3F7FB` `#D4D7E3` `#8897AD` `#CFDFE2` | champs de l'écran de connexion | ✓ |
| `#FFC0C6` `#B73642` | badge « refusé » | ✓ `refusFond` / `refusTexte` |
| `#E3E3E3` | séparateur de liste déroulante | ✓ `separateur` |
| `#F0F0F0` `#707070` | cases de code PIN | ✓ `caseVide` / `pinTexte` |
| `#828282` `#B4B4B4` | zone de dépôt photo, bouton clair | ✓ |
| `#000000` | 22× sur l'accueil (vecteurs, ombres, gabarits d'image) | **manquant** — distinct de `noir` `#171512` |
| `#B3914D` | splash, connexion, accueil (4× chacun) | **manquant** — proche de `fond400` `#B58A40` |
| `#103A2D` | splash et connexion | **manquant** — proche de `emeraude500` `#1C382D` |
| `#E5E5E5` | gabarits d'image (8× sur l'accueil) | **manquant** |
| `#D9D9D9` | gabarits d'image | **manquant** |
| `#444444` | fond des planches de composants | non applicable (habillage Figma) |
| `#0C1421` `#122B31` | textes de l'écran de connexion | **manquant** |
| `#98C1B0` `#C49A6C` | — | déjà en dur dans le code, sans origine Figma identifiée |

**Arbitrage retenu** : `#B3914D` et `#103A2D` sont des dérives de maquette à 1–2 points des tokens `fond400` et `emeraude500`. Elles seront rattachées aux tokens. `#FFFFFF`, `#000000`, `#E5E5E5` et `#D9D9D9` sont des valeurs structurelles (blanc de surface, gabarits d'image) et méritent des tokens explicites.

### 3.3 Rayons — conformes à `AppRadius`

Mesures sur l'accueil `11:30` (176 calques), rapportées aux constantes existantes :

| Rayon Figma | Occurrences | Constante | Usage |
|---|---|---|---|
| 8.0 | 15 | `AppRadius.carte` ✓ | cartes, champs |
| 36.67 | 12 | `AppRadius.carteProduit` (36.7) ✓ | cartes produit, pastilles de nav |
| 50.0 | 12 | `AppRadius.bouton` ✓ | boutons pleins |
| 9.5 | 5 | `AppRadius.vignette` ✓ | **badges de statut** |
| 32.0 | 2 | `AppRadius.surface` ✓ | grandes images en arche |
| 100.0 | 5 | `AppRadius.cercle` ✓ | avatars |
| 20.0 | — | `AppRadius.bloc` ✓ | feuilles modales |

### 3.4 Espacements — conformes à `AppSpacing`

| Valeur | Occurrences sur `11:30` | Constante |
|---|---|---|
| padding 11.0 | 28 (et 100 sur la nav) | `AppSpacing.gouttiere` ✓ |
| padding 8.0 | 32 | `p8` ✓ |
| padding 16.0 | 16 | `p16` ✓ |
| itemSpacing 7.0 | 13 | `gapChip` ✓ |
| itemSpacing 9.17 | 6 (20 sur la nav) | `gapListe` (9.2) ✓ |

### 3.5 Typographies — conformes à `ClosetTextStyles`

Relevé sur l'accueil `11:30`, chaque style trouvant son équivalent exact :

| Figma | Constante |
|---|---|
| Lato 400 / 12pt / lh 14.4 / ls −0.24 | `corps` ✓ |
| Lato 500 / 12pt / lh 17.4 | `bouton` ✓ |
| Lato 400 / 10pt / lh 12 / ls 2.0 | `meta` ✓ |
| Lato 400 / 9pt / lh 10.8 / ls 2.07 | `badgePill` ✓ |
| Lato 400 / 8pt / lh 9.6 / ls −0.16 | `attribut` ✓ |
| Lato 400 / 8pt / lh 9.6 / ls 1.84 | `surtitre` ✓ |
| Lato 400 / 7pt / lh 8.4 / ls 0.28 | `microLegende` ✓ |
| Lato 400 / 6pt / lh 7.2 / ls 0.24 | `micro` ✓ |
| EB Garamond 500 / 14pt / lh 18.3 / ls −0.28 | `prix` ✓ |
| EB Garamond 600 / 22pt / lh 28.7 / ls 0.44 | `titreEcran` ✓ |
| Cormorant Garamond 700 / 12pt / lh 14.5 / ls −0.24 | `nomProduit` ✓ |
| Cormorant 600 / 18pt / lh 21.8 / ls 0.36 | `accroche` ✓ |
| Cormorant 600 / 15pt / lh 18.2 / ls −0.3 | `titreBloc` ✓ |

`Manrope 500 / 12pt` apparaît sur les libellés de navigation, `Roboto` et `SF Pro Display` sur l'écran de connexion : ce sont les polices par défaut de Figma et d'iOS sur des calques non stylés, pas un choix de design. Elles se mappent sur Lato, comme le documente déjà `closet_text_styles.dart`.

**Conclusion sur le design system** : `closet_colors.dart`, `closet_text_styles.dart`, `app_spacing.dart` sont des transcriptions fidèles et mesurées de la maquette. C'est `typography.dart` / `AppTypography` qui est l'intrus, avec des valeurs qui ne viennent pas de la maquette (corps 16, bouton 14 bold, display 32).

---

## 4. Composants et jeux d'états

| Composant Figma | ID | Tokens relevés | Équivalent code |
|---|---|---|---|
| **Bottom Navigation** | `13:1182` | fond `#1C382D` (emeraude500), pastille active `#CDAB71` (fond300) et `#B58A40` (fond400), rayon **36.67**, padding 11, itemSpacing 9.17, libellé 12pt w500 | `ClosetBottomNav` |
| **Statut de commande** | `26:1255` | rayon **9.5**, padding 12/4, Lato 8pt ls −0.16 ; 3 états : Livrée `#A0D0BD`, EN route `#E1CDA6`/`#564B36`, Préparation `#E0CBA7`/`#353025` | `StatusBadge.livree/enRoute/preparation` |
| **Statut Pièce sourceur** | `36:2063` | rayon **9.5**, padding 12/4, Lato 8pt ; 5 états : Mis en vente, En cours d'analyse, dépôt reçu, refusé `#FFC0C6`/`#B73642`, Retourné | `StatusBadge.miseEnVente/enAnalyse/depotRecu/refusee/retournee` |
| **Input — liste Région** | `61:12575` | 161×407, 10 régions du Cameroun | `ClosetSelectField` |
| **Input — liste Département** | `61:12788` | 161×407, 10 départements du Centre | `ClosetSelectField` |

### Données géographiques de la maquette

`61:12575` — **Régions** : Adamaoua, Centre, Extrême-Nord, Est, Littoral, Nord Ouest, Ouest, Sud, Sud-Ouest, Nord.
`61:12788` — **Départements du Centre** : Haute Sanaga, Lekié, Mbam-et-Inoubou, Mbam-et-Kim, Méfou-et-Afamba, Méfou-et-Akono, Mfoundi, Nyong-et-Kéllé, Nyong-et-Mfoumou, Mbalmayo.
`162:5536` — **Villes** : Yaoundé, Douala, Autre — avec délai « Livraison à domicile 24h-48h » et « A determiner » pour Autre.

Ces listes correspondent exactement aux endpoints `GET /geo/regions`, `GET /geo/regions/{id}/divisions`, `GET /geo/cities` du backend. Les mocks seront donc structurés pour être remplacés sans changement d'interface.

---

## 5. Inventaire des écrans à implémenter

Rôle dans le parcours, et correspondance backend quand elle existe.

### 5.1 Design system

| Écran | ID | Rôle |
|---|---|---|
| Color System | `1:830` | tokens de couleur |
| Color Export Sheet | `1:1471` | tokens de couleur, version annotée |

### 5.2 Ouverture et authentification

| Écran | ID | Rôle | Backend |
|---|---|---|---|
| Page d'ouverture | `5:1210` | splash, 37 calques, dégradé `#FFFFFF → #E1CDA6`, rayons 32 et 100 | — |
| Acceuil Interface 1 | `5:1279` | onboarding 1/3 — « Le dressing privé » | — |
| Acceuil Interface 2 | `5:1342` | onboarding 2/3 — « L'élégance durable » | — |
| Acceuil Interface 3 | `5:1371` | onboarding 3/3 — « Le cercle privilège » + « J'AI DÉJÀ UN COMPTE » | — |
| Page de Connexion/Inscription | `5:1304` | login et inscription, Google, « Continuer en invitée », mot de passe oublié | `POST /auth/login`, `POST /auth/register`, `POST /auth/forgot-password` |

### 5.3 Découverte et catalogue

| Écran | ID | Rôle | Backend |
|---|---|---|---|
| Page d'acceuil | `11:30` | dressing : pièce de la semaine, univers, nouveautés, coup de cœur, maison du moment | `GET /showcasing/home`, `GET /pieces`, `GET /universes` |
| Page d'acceuil 2 | `11:250` | même écran déroulé (1270 px) — **variante de scroll, pas un écran** | — |
| Page collection | `14:1281` | catalogue : « Toutes les pièces », recherche, univers, grille | `GET /pieces` |
| Page Collection 2 | `13:1032` | même écran déroulé (1197 px) — **variante de scroll** | — |
| Page collection avec Filtre | `16:2260` | résultats filtrés : « Filtres.3 », puces retirables « Neuf × / Robes × / Taille M × », « 18 pièces. triées par nouveautés » | `GET /pieces/search` |
| Page collection avec Filtre 2 | `16:1954` | même écran déroulé (2239 px) — **variante de scroll** | — |
| Filtre | `14:1514` | feuille de filtres : univers, taille (XS→XL), état, budget 10 000–45 000, « Voir 18 pièces », « tout réinitialiser » | `GET /pieces/search` |
| Page Article 1 | `16:3328` | fiche produit : état, taille et coupe, matière, entretien, récit, packaging | `GET /pieces/{id}` |
| Page Article 2 | `16:3063` | même fiche déroulée (1229 px) — **variante de scroll** | — |

### 5.4 Sélection et tunnel de paiement

| Écran | ID | Rôle | Backend |
|---|---|---|---|
| Page Ma sélection | `16:3448` | panier : lignes, code privilège, sous-total, livraison, total, « Finaliser Ma sélection » | `GET /delivery/quote` |
| Ma sélection E1 | `56:11462` + 13 états `162:xxxx` | **étape 1/3** : livraison (nom, WhatsApp, Région → Département → Quartier) + méthode de paiement | `GET /geo/*`, `POST /orders` |
| Traitement de transaction | `162:5220` | **étape 2/3** : « Paiement en cours » + frise | `POST /payments/initiate` |
| Transaction reussie | `162:3351` | **étape 3/3** : « Paiement reussi », « Commande N° ce-2641 », WhatsApp | `GET /payments/{id}` |
| Reçu de transaction | `162:3473` | reçu acheteuse : marque, catégorie, taille, état, mode de paiement, livraison | `GET /orders/{order_number}` |
| Page suivie de pièce | `162:5657` | suivi de commande : 5 jalons, « Laissez-nous un message » | `GET /orders/{order_number}` |

### 5.5 Espace utilisateur

| Écran | ID | Rôle | Backend |
|---|---|---|---|
| Page Mon espace | `24:39` | hub : profil, carte « Devenir Sourceur », 6 entrées compte | `GET /me` |
| Modifier mon profil | `25:710` | nom, email, WhatsApp, « Mettre à jour » | `PATCH /me` |
| Mes favoris | `25:924` | wishlist avec « Ajouter au panier » par ligne | `GET /wishlist` |
| Mes commandes | `25:1089` | 3 commandes avec badges de statut et estimation | `GET /orders` |
| Détails de la commande | `26:1262` | statut, adresse, lignes, récap, réservation 15 min | `GET /orders/{order_number}` |
| Mes adresses | `26:1588` | 4 adresses typées, une par défaut | `AddressIn` (pas d'endpoint dédié) |
| Se déconnecter | `36:2064` | confirmation « Par ici la sortie Mme » | `POST /auth/logout` |
| Deconnexion reussie | `36:2113` | « Ce n'est qu'un au revoir ! » + redirection auto | — |

### 5.6 Espace Sourceur

| Écran | ID | Rôle | Backend |
|---|---|---|---|
| Devenir Sourceur | `26:1771` | landing programme : curation, suivi 6 statuts, vente directe ou dépôt-vente | — |
| Identification Espace Sourceur | `26:1877` | connexion sourceur dédiée | `POST /auth/login` |
| Mon adhésion sourceur | `27:1970` | statut « En cours d'étude », frise 4 jalons, délai 48 h | `GET /sourcing/me` |
| Adhésion approuvée | `29:46` | « Vérification approuvée ! » + WhatsApp | `GET /sourcing/me` |
| Mon Espace Sourceur | `31:109` | solde 52 000 FCFA, « vérifié », pièces en vente, à reverser, 4 actions, menu | `GET /sourcing/payouts` |
| Mon Espace Sourceur (Confier) | `33:1389` | **étape 2/4** du dépôt : type, marque, taille, état, prix souhaité, photos | `POST /sourcing/submissions` |
| Mes dépôts | `35:1895` | 3 pièces avec statuts, totaux, filtres « Toutes. 6 » | `GET /sourcing/submissions` |
| Methode de retrait | `32:511` | Orange Money / MTN Mobile Money / `**** 4864` | `GET /sourcing/payouts` |
| Ajout du code PIN | `32:704` | 4 cases PIN, « Valider le Numéro PIN » | — (sécurité locale) |
| Traitement de transaction | `32:756` | « Traitement en cours », sans frise | — |
| Transaction reussie | `32:813` | « Transaction reussie ! » | — |
| Reçu de transaction | `32:865` | reçu de retrait : mode, compte, receveur, total retiré | — |
| Historique de Transaction | `32:1223` | 4 retraits approuvés, « Effectuer une transaction » | `GET /sourcing/payouts` |
| Inspection et Analyse | `34:1534` | « Pièce bien reçue ! » | `GET /sourcing/submissions/{id}` |
| Suivre ma pièce (refus) | `34:1578` | frise avec « Article Refusé » + « Retour de l'article » | `SubmissionStatus.refused` |
| Suivre ma pièce (acceptation) | `34:1710` | frise avec « Article Accepté » + « Article Mise en Vente » | `SubmissionStatus.accepted` |

**Total : 40 écrans réels à implémenter** — les 14 frames restantes étant des variantes de scroll ou des états d'interaction déjà rattachés.

---

## 6. Correspondance des statuts maquette ↔ backend

Point important pour la Phase 4 : les statuts de la maquette et les énumérations du backend ne se recouvrent pas exactement.

### Commande

| Maquette (`26:1255`) | `OrderStatus` backend |
|---|---|
| Préparation | `preparing`, `ready` |
| EN route | `delivering` |
| Livrée | `completed` |
| — | `pending`, `paid`, `cancelled`, `quote_required` **non représentés dans la maquette** |

`quote_required` est notable : il correspond au cas « Autre » de la sélection de ville (`162:5536`, « A determiner »), où le tarif de livraison doit être devisé manuellement.

### Pièce sourceur

| Maquette (`36:2063`) | `SubmissionStatus` backend |
|---|---|
| dépôt reçu | `submitted` |
| En cours d'analyse | `in_review` |
| — | `accepted` |
| Mis en vente | `catalogued` |
| refusé | `refused` |
| Retourné | **absent du backend** |

La maquette annonce « Six statuts, notifiés à chaque étape » sur `26:1771`, et en montre bien 5 dans le jeu d'états plus « Retourné ». Le backend n'a pas d'état de retour physique.

### Condition de pièce

| Maquette | `PieceCondition` |
|---|---|
| Neuf | `new` |
| Excellent / Très bon état | `very_good` |
| Bon état | `good` |
| Etat correcte (`33:1389`) | **absent du backend** |

---

## 7. Enseignements structurants pour la suite

1. **Le tunnel de paiement est en 3 étapes** (`livraison → paiement → confirmation`), avec frise visible sur chaque écran, y compris pendant le traitement et sur l'écran de succès. Le dépôt sourceur est en **4 étapes** (`33:1389` affiche « Etape 2/4 »).

2. **Le paiement acheteuse passe par un fournisseur externe.** `POST /payments/initiate` renvoie un `payment_url` (CinetPay) et un `operator`. L'écran de code PIN `32:704` appartient au **retrait sourceur**, pas au paiement. Le tunnel actuel du code, qui impose un PIN avant tout paiement, ne correspond donc ni à la maquette ni au backend.

3. **La livraison est devisée, pas fixe.** `GET /delivery/quote` renvoie un montant selon `city_id` ou `region_id`, avec un `quote_required` pour les zones non tarifées. Les 3 500 FCFA en dur du code sont une valeur d'illustration de la maquette.

4. **Les slots de mise en avant du backend collent à l'accueil** : `FeaturedSlotType` vaut `piece_of_the_week`, `favourite`, `hero` — soit « pièce de la semaine », « Coup de cœur Clos ET » et le visuel à la une de `11:30`.

5. **Les prix sont des chaînes décimales côté backend** (`price: string`, `currency`), pas des `double`. Le modèle `Article` devra en tenir compte pour éviter les erreurs d'arrondi sur des montants en FCFA.

6. **Les identifiants sont des UUID** côté pièces, commandes, utilisateurs, et des entiers côté géographie. Le modèle actuel utilise des `String` partout, ce qui reste compatible.
