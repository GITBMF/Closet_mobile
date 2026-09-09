# Phase 2 — Gap analysis : maquette Figma ↔ code existant

> **Ce document décrit l'état du code au moment de l'audit.** Il n'a
> volontairement pas été réécrit pendant l'implémentation, pour que la
> comparaison avant / après reste lisible. Pour les statuts **actuels**, voir
> `docs/rapport-final.md`.

Croisement de `docs/audit-code-existant.md` (Phase 0) et `docs/figma-mapping.md` (Phase 1).

**Légende**
✅ Implémenté conforme — 🟡 Implémenté avec écarts — 🟠 Implémenté mais inatteignable ou non branché — ❌ Non implémenté

---

## 1. Ouverture et authentification

| Écran Figma | Node ID | Statut | Fichier code | Écarts constatés |
|---|---|---|---|---|
| Page d'ouverture | `5:1210` | ✅ | `features/splash/splash_screen.dart` | Aucun écart bloquant. La maquette a un dégradé `#FFFFFF → #E1CDA6` et des rayons 32/100 ; le code utilise `assets/splash_background.png`, ce qui est cohérent. `Colors.white` l.151 au lieu d'un token. |
| Onboarding 1/3 | `5:1279` | ✅ | `features/onboarding/onboarding_screen.dart` | Textes conformes. `fontSize: 20` l.192 et `13` l.204 en dur au lieu de `ClosetTextStyles`. `Colors.white` l.208. |
| Onboarding 2/3 | `5:1342` | ✅ | idem | idem |
| Onboarding 3/3 | `5:1371` | ✅ | idem | Le bouton « J'AI DÉJÀ UN COMPTE » est bien présent (l.90 → `/auth`). |
| Connexion / Inscription | `5:1304` | 🟡 | `features/auth/auth_screen.dart` | **« CONTINUER avec Google » inerte** (SnackBar, l.286-293) alors que la maquette le présente comme un moyen de connexion de premier plan. **« Mot de passe oublié » inerte** (l.260-267) alors que `POST /auth/forgot-password` existe. « Continuer en invitée » présent ✓. Champs conformes aux tokens `#F3F7FB` / `#D4D7E3` / `#8897AD` ✓. |

---

## 2. Découverte et catalogue

| Écran Figma | Node ID | Statut | Fichier code | Écarts constatés |
|---|---|---|---|---|
| Page d'acceuil | `11:30` | 🟡 | `features/cliente/dressing/dressing_screen.dart` | **Aucun état vide** : si le catalogue est vide, les sections disparaissent silencieusement au lieu d'afficher un vide assumé. **Le cœur de la pièce à la une est figé** (`BoutonCoeur(actif: false)` l.298) — pas de bascule wishlist. `Color(0xFFE5E5E5)` l.267/272 en dur. Les 4 sections de la maquette (pièce de la semaine, nouveautés, coup de cœur, maison du moment) sont bien présentes ✓. |
| Page d'acceuil 2 | `11:250` | — | — | Variante de scroll du même écran, rien à implémenter. |
| Page collection | `14:1281` | 🟡 | `features/cliente/collections/collections_screen.dart` | **La pilule « Nouveautés » ouvre les filtres au lieu de trier** (l.216) : la maquette affiche « 18 pièces. triées par nouveautés », donc un vrai tri est attendu. La liste `universes` est en dur l.111-121 alors que `GET /universes` existe. États vide/chargement/erreur complets ✓. |
| Page Collection 2 | `13:1032` | — | — | Variante de scroll. |
| Collection avec Filtre | `16:2260` | 🟡 | idem | Le bandeau de puces retirables (« Neuf × / Robes × / Taille M × ») existe, mais **le compteur « Filtres.3 » et le libellé « N pièces, triées par X » ne sont pas rendus** conformément. |
| Collection avec Filtre 2 | `16:1954` | — | — | Variante de scroll. |
| Filtre | `14:1514` | 🟡 | `features/cliente/collections/filtres_sheet.dart` | **Filtre par maison absent** de la feuille alors que le provider existe côté écran et que `GET /houses` est disponible. Tailles, états, budget et « tout réinitialiser » présents ✓. Le CTA de la maquette porte le compte (« Voir 18 pièces ») — à vérifier. |
| Page Article 1 | `16:3328` | ✅ | `features/cliente/product/product_screen.dart` | Toutes les sections de la maquette sont là : état, taille et coupe, matière, entretien, récit, packaging. `Color(0xFFD9D9D9)` l.210/219/221 et `fontSize: 22` l.133 en dur. |
| Page Article 2 | `16:3063` | — | — | Variante de scroll. |

---

## 3. Sélection et tunnel de paiement — **la zone la plus en écart**

| Écran Figma | Node ID | Statut | Fichier code | Écarts constatés |
|---|---|---|---|---|
| Page Ma sélection | `16:3448` | 🟡 | `features/cliente/selection/selection_screen.dart` | **`fraisLivraison = 3500` en dur** (l.19) alors que la maquette devise la livraison et que `GET /delivery/quote` existe. **« Appliquer » du code privilège inerte** (l.367-370) alors que `CheckoutIn.privilege_code` est prévu par le backend. Ni chargement ni erreur. |
| Ma sélection E1 (étape 1/3) | `56:11462` + 13 états | 🟡 | `features/checkout/checkout_screen.dart` | **Écart majeur.** La maquette attend : cascade **Région → Département → Quartier** (listes `61:12575` / `61:12788`), une variante **sélection de ville** (Yaoundé / Douala / Autre), une **feuille de méthode de paiement** (Orange Money / MTN / Visa) avec **champs conditionnels** (numéro pour mobile money, Cardholder/Number/CVV/Expiration pour Visa), et un bloc récapitulatif avec « Votre pièce est réservée pendant 15 minutes ». Le code n'a qu'un formulaire nom + téléphone et une liste de radios `moyensRetrait` **importée du module sourceur**. De plus `_coordonneesValidees` n'est pas exigé avant de payer (l.61-87). |
| Traitement (étape 2/3) | `162:5220` | 🟠 | `features/transaction/traitement_screen.dart` | UI conforme mais **la frise 3 étapes de la maquette est absente** de cet écran. Surtout, l'étape échoue systématiquement (voir ci-dessous). |
| Transaction reussie (étape 3/3) | `162:3351` | 🟠 | `features/transaction/traitement_screen.dart` (`SuccesScreen`) | **Inatteignable.** Manquent aussi le numéro de commande (« Commande N° ce-2641 »), la mention « Confirmation envoyée sur WhatsApp » et la frise. |
| Reçu de transaction | `162:3473` | 🟠 | `features/transaction/recu_screen.dart` | **Inatteignable.** Le code n'a qu'un gabarit de reçu ; la maquette en attend **deux déclinaisons** — acheteuse (marque, catégorie, taille, état, mode de paiement, livraison, CTA « Poursuivre ma visite ») et sourceur (`32:865` : mode de retrait, compte, receveur, total retiré, CTA « Retour dans Mon Espace »). |
| Page suivie de pièce | `162:5657` | ❌ | — | **Non implémenté côté acheteuse.** `suivi_commande_screen.dart` existe et gère une frise déduite du statut, mais la maquette attend 5 jalons nommés (Sélection confirmée, Paiement confirmé, Préparée avec soin, En route pour livraison, Dans votre dressing) et un CTA « Laissez-nous un message ». |

### Le blocage central du tunnel

```205:210:lib/core/router/app_router.dart
              // TODO(backend): brancher l'endpoint de transaction. Le tunnel
              // exige un exécuteur : il ne peut pas afficher un succès sans
              // opération réelle, et le reçu doit être émis par le serveur.
              executer: (demande, pin) => throw const TransactionRefusee(
                'Le service de transaction n’est pas encore disponible.',
              ),
```

Trois conséquences :

1. `SuccesScreen` et `RecuScreen`, terminés côté UI, sont **inatteignables**.
2. `CheckoutScreen` pousse une `DemandeTransaction` mais **ne crée pas de commande et ne vide pas le panier** (l.77-87).
3. **Le tunnel impose un code PIN avant tout paiement**, ce qui ne correspond ni à la maquette ni au backend : l'écran PIN `32:704` appartient au **retrait sourceur**, et le paiement acheteuse passe par le `payment_url` de `POST /payments/initiate`.

---

## 4. Espace utilisateur

| Écran Figma | Node ID | Statut | Fichier code | Écarts constatés |
|---|---|---|---|---|
| Page Mon espace | `24:39` | ✅ | `features/cliente/espace/espace_screen.dart` | Profil, carte Sourceur, entrées compte conformes. `activeColor` déprécié l.497. `Colors.white` ×5. |
| Modifier mon profil | `25:710` | 🟠 | `features/cliente/espace/modifier_profil_screen.dart` | **L'enregistrement ne fait rien** (`TODO` l.52, SnackBar) alors que `PATCH /me` existe. Changement de photo inerte l.282-285. Aucun état. |
| Mes favoris | `25:924` | 🟡 | `features/cliente/espace/wishlist_screen.dart` | Écran conforme, « Ajouter au panier » par ligne présent ✓. Ni chargement ni erreur. |
| Mes commandes | `25:1089` | ✅ | `features/cliente/espace/mes_commandes_screen.dart` | Badges de statut et estimation conformes. États complets ✓. |
| Détails de la commande | `26:1262` | ✅ | `features/cliente/espace/detail_commande_screen.dart` | Statut, adresse, lignes, récap présents. `Color(0xFFD9D9D9)` ×3 et 5 `fontSize` en dur. |
| Mes adresses | `26:1588` | 🟠 | `features/cliente/espace/mes_adresses_screen.dart` | **Ajout et édition inertes** (SnackBar `_aVenir` l.66/88). La maquette montre 4 adresses typées avec une par défaut — le modèle `Adresse` le gère ✓. |
| Se déconnecter | `36:2064` | ✅ | `features/cliente/espace/deconnexion_screen.dart` | Confirmation puis adieu, conforme. `POST /auth/logout` non appelé (déconnexion locale seulement). |
| Deconnexion reussie | `36:2113` | ✅ | idem (étape 2) | Redirection automatique conforme ✓. |

### Écrans hors maquette et code mort

| Élément | Fichier | Constat |
|---|---|---|
| `EspaceInfoScreen` | `espace_sub_screens.dart` | **Code mort** — `/espace/infos` route vers `ModifierProfilScreen`. Téléphone en dur l.102. |
| `EspaceAdressesScreen` | idem | **Code mort** — `/espace/adresses` route vers `MesAdressesScreen`. 4 adresses américaines fictives. |
| `EspacePaiementsScreen` | idem | Hors maquette. Données en dur. Aucun état. |
| `EspaceAlertesScreen` | idem | Hors maquette. Données en dur. |
| `EspaceFaqScreen`, `EspaceContactScreen`, `EspaceConfidentialiteScreen`, `EspaceEvaluationScreen` | idem | Hors maquette, contenu statique acceptable. Contact : `onTap: () {}` l.757/766. |

Ces 7 écrans ne figurent pas dans la maquette. Ils ne sont pas des écarts de fidélité, mais ils concentrent l'essentiel de la dette de style du projet (~32 `TextStyle` inline).

---

## 5. Espace Sourceur

| Écran Figma | Node ID | Statut | Fichier code | Écarts constatés |
|---|---|---|---|---|
| Devenir Sourceur | `26:1771` | ✅ | `features/sourceur/devenir/devenir_sourceur_screen.dart` | Landing conforme. La maquette annonce « Six statuts » — cohérent avec le jeu `36:2063`. |
| Identification Sourceur | `26:1877` | 🟡 | `features/sourceur/identification/identification_sourceur_screen.dart` | « Mot de passe oublié » inerte l.187-194. |
| Mon adhésion sourceur | `27:1970` | 🟠 | `features/sourceur/inscription/sourceur_adhesion_screen.dart` | **Aucune source de données** : `EtapeAdhesion.enEtude` en dur l.24, paramètres non alimentés par le routeur. `GET /sourcing/me` renvoie `SourcerStatus` (`pending`/`approved`/`rejected`/`suspended`) — le branchement est direct. |
| Adhésion approuvée | `29:46` | 🟡 | `features/sourceur/inscription/adhesion_approuvee_screen.dart` | Le texte l.45-46 parle d'« expédition » — **copie du reçu acheteuse**, hors sujet pour une adhésion. |
| Mon Espace Sourceur | `31:109` | ✅ | `features/sourceur/espace/sourceur_espace_screen.dart` | Solde, actions, menu conformes. Branché sur les providers ✓. |
| Mon Espace Sourceur (Confier) | `33:1389` | 🟡 | `features/sourceur/nouvelle/sourceur_nouvelle_piece_screen.dart` | La maquette affiche « **Etape 2/4** » — le code affiche ce badge mais **les étapes 1, 3 et 4 n'existent pas**. Upload photo `TODO(backend)` l.94 alors que `POST /sourcing/submissions/{id}/media` existe. L'état « Etat correcte » de la maquette n'a pas d'équivalent backend. |
| Mes dépôts | `35:1895` | ✅ | `features/sourceur/pieces/sourceur_pieces_screen.dart` | Totaux, filtres, statuts conformes. États complets ✓. `Color(0xFFD9D9D9)` ×3. |
| Methode de retrait | `32:511` | 🟡 | `features/sourceur/retrait/methode_retrait_sheet.dart` | Moyens en dur l.34-53. **Cette liste est importée par `checkout_screen.dart`** — un couplage à casser : le retrait sourceur et le paiement acheteuse n'ont pas les mêmes moyens (la maquette ajoute Visa Card côté acheteuse). |
| Ajout du code PIN | `32:704` | 🟡 | `features/transaction/pin_screen.dart` | UI conforme mais **rattachée au mauvais parcours** : le PIN est un mécanisme de retrait sourceur, pas de paiement acheteuse. |
| Traitement / Réussie / Reçu (retrait) | `32:756`, `32:813`, `32:865` | 🟠 | `features/transaction/` | Inatteignables (exécuteur stub). Le reçu doit exister en variante retrait. |
| Historique de Transaction | `32:1223` | 🟡 | `features/sourceur/revenus/sourceur_revenus_screen.dart` | **Le résumé de solde en haut d'écran manque** par rapport à la maquette. Filtre inerte l.36-38. |
| Inspection et Analyse | `34:1534` | ✅ | `features/sourceur/suivi/inspection_piece_screen.dart` | Conforme. |
| Suivre ma pièce (refus) | `34:1578` | ✅ | `features/sourceur/suivi/suivi_piece_screen.dart` | Frise dérivée du statut, branche refus gérée ✓. |
| Suivre ma pièce (acceptation) | `34:1710` | ✅ | idem | Branche acceptation gérée ✓. |

### Doublon Atelier ↔ Espace

`SourceurAtelierScreen` (`/sourceur`, onglet 0) **n'a aucun équivalent dans la maquette**. La maquette ne connaît qu'un « Mon Espace Sourceur » (`31:109`), qui correspond à `SourceurEspaceScreen` (onglet 4). L'Atelier est une invention du code, et il affiche un tableau de bord à zéro :

```39:45:lib/features/sourceur/atelier/sourceur_atelier_screen.dart
                  _buildCarteIdentite(nomAtelier, ville, depuis, 0, 0, 0),
                  const SizedBox(height: AppSpacing.p24),
                  _buildCarteRevenus(context, 0, 0, 0, theme),
                  const SizedBox(height: AppSpacing.p24),
                  _buildActionsRapides(context, 0),
                  const SizedBox(height: AppSpacing.p32),
                  _buildActivite(context, 0),
```

---

## 6. Écarts transversaux de design system

| Écart | Ampleur | Détail |
|---|---|---|
| **Deux échelles typographiques** | structurel | `AppTypography` alimente le `textTheme` avec des valeurs **absentes de la maquette** (corps 16, bouton Lato 14 bold, display 32). `ClosetTextStyles` est la transcription fidèle (corps 12, bouton Lato 12 w500, display 22) et c'est elle que les écrans utilisent. `typography.dart` est donc du code trompeur. |
| **Barre de navigation dupliquée et non conforme** | structurel | `ClosetBottomNav` était écrit **mais orphelin** : la barre réellement affichée venait de deux `_NavItem` dupliqués, dans `main_layout.dart` et `sourceur_layout.dart`. Aucune des trois n'était conforme. Relevé de `13:1182` : la barre est une **pilule flottante** `#1C382D` de 58 px, `r100`, padding 8, écart 20, **largeur ajustée au contenu** ; l'onglet actif est une pilule `#F3F3F3` bordée `#CDAB71`, `r36.67`, icône `#CDAB71`, libellé `#B58A40`. Le code peignait un bandeau pleine largeur `#12241D` à coins hauts arrondis, pilule active blanche, accents dorés. Libellés « Cœurs » et « Sélection » au lieu de « Wishlist » et « Selection ». |
| **Badges de statut** | *aucun écart* | Vérification faite calque par calque sur `26:1255` et `36:2063` : les 8 fabriques de `StatusBadge` sont **exactes**, couleurs comme géométrie. Seule la casse des libellés par défaut divergeait (« En route » au lieu de « EN route », « Dépôt reçu », « Refusé »). L'écart annoncé dans une version antérieure de ce document confondait les badges de *statut* avec les badges de *condition* (`conditionNeufFond`, qui emploient bien `fondsSucces`/`succes`). |
| **AppBar** | visible | `AppTheme` : `offWhite #F5F2EC`, absent de la palette. `ClosetAppBar` : `beige #F3EBDD` ✓ conforme. |
| **Chips** | visible | `AppTheme` : `selectedColor: noir`. `ClosetChip` actif : `vert` ✓ conforme à la maquette. |
| **~70 `Colors.white`** | diffus | Aucun token blanc dans `ClosetColors` alors que la maquette emploie `#FFFFFF` massivement (14× sur le splash, 28× en trait sur la nav). |
| **~45 `fontSize` littéraux** | diffus | Valeurs de 6 à 40 pt en dur, court-circuitant l'échelle. |
| **~35 `TextStyle` inline** | concentré | dont ~32 dans `espace_sub_screens.dart`. |
| **Gabarits d'image en dur** | diffus | `#D9D9D9` (12×) et `#E5E5E5` (5×) — ce sont les placeholders de la maquette, à tokeniser. |

---

## 7. Synthèse — écrans prioritaires

### Priorité 1 — bloquant pour démontrer le produit

1. **Tunnel de paiement** (`162:5220`, `162:3351`, `162:3473`) — 🟠 inatteignable. C'est le cœur commerçant de l'app et il ne fonctionne pas. Il faut un exécuteur qui produise une commande et un reçu, et découpler le PIN sourceur du paiement acheteuse.
2. **Étape 1/3 du checkout** (`56:11462` + 13 états) — 🟡 le plus grand écart de fidélité du projet : cascade géographique, méthodes de paiement avec champs conditionnels, récapitulatif.
3. **Sélection** (`16:3448`) — 🟡 livraison en dur, code privilège inerte.

### Priorité 2 — écarts visibles sur des écrans très vus

4. **Design system** — unifier l'échelle typographique, corriger le fond de la nav et les badges de statut, ajouter les tokens manquants. Ce lot conditionne la fidélité de tous les autres.
5. **Accueil** (`11:30`) — état vide, cœur de la pièce à la une.
6. **Collections + Filtre** (`14:1281`, `16:2260`, `14:1514`) — tri réel, compteurs, filtre par maison.

### Priorité 3 — parcours secondaires incomplets

7. **Profil et adresses** (`25:710`, `26:1588`) — 🟠 formulaires qui n'enregistrent rien.
8. **Adhésion sourceur** (`27:1970`) — 🟠 statut en dur.
9. **Suivi de commande acheteuse** (`162:5657`) — ❌ non implémenté.
10. **Historique de transaction** (`32:1223`) — résumé de solde manquant.

### Priorité 4 — hygiène

11. Supprimer les 2 écrans morts, casser le couplage `checkout → moyensRetrait` du module sourceur, trancher le sort de l'onglet Atelier.
12. Compléter les états vide/chargement/erreur manquants.
13. Tests sur le parcours cliente et CI.

---

## 8. Décompte

| Statut | Nombre d'écrans | Part |
|---|---|---|
| ✅ Implémenté conforme | 18 | 45 % |
| 🟡 Implémenté avec écarts | 14 | 35 % |
| 🟠 Implémenté mais inatteignable ou non branché | 7 | 17,5 % |
| ❌ Non implémenté | 1 | 2,5 % |

Sur 40 écrans de la maquette, **un seul manque totalement**. Le travail est donc à 97,5 % du raccordement et de la correction, pas de la création. C'est ce qui doit dicter la Phase 4 : peu de nouveaux écrans, beaucoup de branchements et d'alignements de tokens.
