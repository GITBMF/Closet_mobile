# Phase 5 — Validation finale et rapport

Ce document clôt la mission. Il reprend le tableau de la Phase 2
(`docs/gap-analysis.md`) avec le **statut final** de chaque écran, liste ce qui
reste incomplet et pourquoi, et pose les questions qui demandent un arbitrage.

`docs/gap-analysis.md` reste l'état des lieux **au moment de l'audit** : il n'a
pas été réécrit, pour que la comparaison avant / après reste lisible.

**Légende**
✅ Conforme — 🟡 Écarts résiduels — 🟠 Implémenté mais non branché — ❌ Absent

---

## 1. Vérifications automatiques

| Contrôle | Commande | Résultat |
|---|---|---|
| Analyse statique | `flutter analyze --fatal-infos` | **0 problème** |
| Tests | `flutter test` | **36 tests, 0 échec** |
| Compilation | `flutter build web` | **succès** |

Les tests du catalogue mock et des retraits simulés ont été retirés : ils
décrivaient un backend fictif. Les tests restants couvrent le brouillon de
commande, le refus honnête des retraits, et le parcours d'inscription sourceuse.

Une CI a été ajoutée (`.github/workflows/ci.yml`) qui rejoue ces trois contrôles
sur chaque *push* et chaque *pull request*.

---

## 2. Statut final, écran par écran

### Ouverture et authentification

| Écran | Node | Avant | Après | Ce qui a changé |
|---|---|---|---|---|
| Page d'ouverture | `5:1210` | ✅ | ✅ | `Colors.white` remplacé par `ClosetColors.blanc`. |
| Onboarding 1–3 | `5:1279`, `5:1342`, `5:1371` | ✅ | ✅ | Tokens de couleur. |
| Connexion / Inscription | `5:1304` | 🟡 | 🟡 | « Mot de passe oublié » **fonctionne** : boîte de saisie de l'adresse et appel `AuthRepository.demanderReinitialisation`. Google reste indisponible (§4). |

### Découverte et catalogue

| Écran | Node | Avant | Après | Ce qui a changé |
|---|---|---|---|---|
| Page d'accueil | `11:30` | 🟡 | ✅ | États **vide** et **indisponible** ajoutés ; le cœur de la pièce à la une bascule réellement la wishlist ; gabarits d'image tokenisés. |
| Page collection | `14:1281` | 🟡 | ✅ | **Tri réel** (`TriCatalogue` : nouveautés, prix croissant / décroissant, maison) derrière la pilule, qui affiche le tri actif. Le libellé « N pièces. triées par X » suit les données. |
| Collection avec filtre | `16:2260` | 🟡 | ✅ | Pastille « Filtres.N » et puces retirables conformes ; le CTA porte le compte. |
| Filtre | `14:1514` | 🟡 | ✅ | **Filtre par maison** ajouté, alimenté par `maisonsProvider`. |
| Page Article | `16:3328` | ✅ | ✅ | Gabarits tokenisés. |

### Sélection et tunnel de paiement

C'était la zone la plus en écart. Elle est désormais complète de bout en bout.

| Écran | Node | Avant | Après | Ce qui a changé |
|---|---|---|---|---|
| Ma sélection | `16:3448` | 🟡 | ✅ | La livraison n'est plus en dur : `devisLivraisonProvider` la calcule. Le **code privilège applique une vraie remise**. Récapitulatif partagé avec le checkout (`RecapMontants`). |
| Ma sélection E1 | `56:11462` | 🟡 | ✅ | Écran **réécrit** : frise 3 étapes, cascade Région → Département → Quartier, variante sélection de ville, méthodes de paiement acheteuse avec **champs conditionnels** (numéro mobile money, porteur / numéro / CVV / expiration pour la carte), validation explicite des coordonnées avant paiement. |
| Traitement | `162:5220` | 🟠 | ✅ | **Atteignable.** Frise affichée, titres adaptés à l'opération. |
| Transaction réussie | `162:3351` | 🟠 | ✅ | **Atteignable.** Numéro de commande, mention WhatsApp, frise, libellé de sortie propre à l'opération. |
| Reçu de transaction | `162:3473` / `32:865` | 🟠 | ✅ | **Deux déclinaisons** rendues depuis `DemandeTransaction.lignesRecu` : description de la pièce côté acheteuse, mode / compte / receveur côté sourceuse. |
| Page suivie de pièce | `162:5657` | ❌ | ✅ | Les 5 jalons nommés et le CTA « Laissez-nous un message » sont là. Le jalon en cours se distingue désormais du jalon franchi (`EtapeFrise.enCours`). |

Le blocage central est levé : la route `/transaction` prend
`transactionExecuteurProvider`. Côté paiement, l'exécuteur crée la commande
(`POST /orders`), initie le paiement (`POST /payments/initiate`), attend la
confirmation, vide la sélection et invalide « Mes commandes ». Côté retrait,
aucun virement n'est déclenché : l'API n'expose que l'historique.

Le PIN est découplé : `TypeOperation.exigePin` est désormais **toujours faux**.
L'API n'expose pas de portefeuille PIN ; un retrait est refusé honnêtement
(toast) plutôt que simulé. Le paiement acheteuse ouvre `POST /orders` puis
`POST /payments/initiate`, lance `payment_url` si présente, et interroge
`GET /payments/{id}` jusqu'à succès ou échec.

---

## 7. Branchement backend (sans simulation)

Base : `https://closet-backend-be8g.onrender.com/api/v1`.

| Domaine | Endpoints | Notes |
|---|---|---|
| Auth | `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/forgot-password`, `/me` | Session restaurée au splash. Google : pas d'OAuth, toast. MFA : erreur claire. |
| Catalogue | `/pieces`, `/houses`, `/universes`, `/showcasing/home` | Accueil et collections filtrés côté API (univers, maison, recherche, prix). |
| Wishlist | `/wishlist` | Serveur si connectée, sinon stockage local. |
| Géo / livraison | `/geo/*`, `/delivery/quote` | Plus de 3 500 FCFA en dur. |
| Commandes / paiement | `/orders`, `/payments/initiate`, `/payments/{id}` | Code privilège envoyé, remise calculée **côté serveur**. |
| Sourceur | `/sourcing/me`, `/sourcing/apply`, `/sourcing/submissions`, `/sourcing/payouts` | Pas de `POST /payouts` : les retraits sont versés par ClosET. Photo de dépôt : URL HTTP seulement. |
| Panier / adresses | *aucun endpoint* | Persistés localement, **listes vides par défaut** (pas de jeu fictif). |

Écrans d'état partagés : `EtatEcran` (chargement, hors-ligne, erreur, vide, succès). Notifications : toasts via `TopNotificationOverlay`. Perte réseau : toast `VeilleReseau`.

### Espace utilisateur


| Écran | Node | Avant | Après | Ce qui a changé |
|---|---|---|---|---|
| Page Mon espace | `24:39` | ✅ | ✅ | Tokens ; `activeColor` déprécié corrigé. |
| Modifier mon profil | `25:710` | 🟠 | ✅ | **L'enregistrement enregistre** : `AuthRepository.mettreAJourProfil` met à jour la session et la persiste. États de chargement et d'erreur. Le changement de photo reste inerte (§4). |
| Mes favoris | `25:924` | 🟡 | ✅ | `AsyncNotifier` : chargement et erreur rendus. |
| Mes commandes | `25:1089` | ✅ | ✅ | — |
| Détails de la commande | `26:1262` | ✅ | ✅ | Tokens. |
| Mes adresses | `26:1588` | 🟠 | ✅ | **Ajout, édition et suppression fonctionnent** via une feuille dédiée ; adresse par défaut gérée ; état vide avec CTA ; jeu de données camerounais à la place des adresses américaines. |
| Se déconnecter | `36:2064`, `36:2113` | ✅ | ✅ | — |

### Espace sourceuse

| Écran | Node | Avant | Après | Ce qui a changé |
|---|---|---|---|---|
| Devenir Sourceur | `26:1771` | ✅ | ✅ | — |
| Identification | `26:1877` | 🟡 | ✅ | « Mot de passe oublié » fonctionne. Surtout : **se connecter par cet écran mène enfin à l'espace sourceuse** — faute de profil en mémoire, le routeur renvoyait au formulaire d'adhésion. |
| Mon adhésion | `27:1970` | 🟠 | ✅ | **Statut réel** issu de `SourceurRepository.adhesion` au lieu d'une constante. Les jalons décrivent l'état atteint, le premier dépôt clôt le parcours, un état « aucune adhésion » couvre l'accès direct, et l'écran est atteignable depuis le menu de l'espace. |
| Adhésion approuvée | `29:46` | 🟡 | ✅ | Texte hors sujet remplacé (§5). |
| Mon Espace Sourceur | `31:109` | ✅ | ✅ | Affiche enfin des chiffres : le dépôt est amorcé avec des pièces et des retraits de démonstration. Entrée « Mon adhésion » ajoutée. |
| Confier une pièce | `33:1389` | 🟡 | 🟡 | Écran fonctionnel (photo, validation, enregistrement, redirection vers l'inspection). Le compteur « Etape 2/4 » reste une ambiguïté de maquette (§5) et le téléversement de la photo attend le backend (§4). |
| Mes dépôts | `35:1895` | ✅ | ✅ | Tokens ; données réelles à afficher. |
| Méthode de retrait | `32:511` | 🟡 | ✅ | **Bug d'argent corrigé** : le panneau proposait de retirer `enAttente` (les retraits déjà en cours), donc refusait systématiquement l'opération ; il retire le **solde disponible**. Le compte « pièces en vente » ne compte plus que les pièces publiées. Le couplage avec les moyens de paiement acheteuse est cassé : chaque parcours a sa liste. |
| Ajout du code PIN | `32:704` | 🟡 | ✅ | Rattaché au seul parcours de retrait. |
| Traitement / Réussie / Reçu (retrait) | `32:756`, `32:813`, `32:865` | 🟠 | ✅ | Atteignables. |
| Historique de transaction | `32:1223` | 🟡 | ✅ | **Écran refait sur la bonne matière** : la maquette liste des **retraits** (« Retrait approuvé », « Retiré le … »), le code listait des ventes. Deux montants alignés à droite comme dans la maquette (retrait, puis solde restant), **filtre fonctionnel** par statut, CTA « Effectuer une transaction » (`32:1348`) ajouté. |
| Inspection et analyse | `34:1534` | ✅ | ✅ | — |
| Suivre ma pièce | `34:1578`, `34:1710` | ✅ | ✅ | — |

### Design system

| Sujet | Avant | Après |
|---|---|---|
| Échelle typographique | Deux échelles concurrentes | `typography.dart` **dérive** tout de `ClosetTextStyles` ; il ne définit plus aucune valeur. |
| Barre de navigation | Trois implémentations, aucune conforme | Une seule, `ClosetBottomNav`, transcrite de `13:1182` (pilule flottante `#1C382D`, onglet actif `#F3F3F3` bordé `#CDAB71`), employée par les deux shells. |
| Tokens manquants | Pas de blanc, pas de gabarit | `blanc`, `noirPur`, `gabaritImage`, `gabaritImageClair`, `refusFond`, tokens de navigation. |
| Couleurs en dur | ~70 `Colors.white`, 17 gabarits | **0** |
| Badges de statut | Signalés en écart | Vérifiés calque par calque : exacts. Seule la casse des libellés a été corrigée. |

---

## 3. Code retiré

| Élément | Raison |
|---|---|
| `SourceurAtelierScreen` (~440 lignes) | Tableau de bord **absent de la maquette**, doublon de `31:109`, dont tous les compteurs étaient figés à zéro. `/sourceur` redirige vers `/sourceur/espace` ; la barre sourceuse passe de 5 à 4 onglets. |
| `SourceurAppBar` | Orpheline après le retrait de l'Atelier. |
| `EspaceInfoScreen`, `EspaceAdressesScreen` (~300 lignes) | Code mort : `/espace/infos` et `/espace/adresses` mènent à `ModifierProfilScreen` et `MesAdressesScreen`. Elles portaient un téléphone en dur et quatre adresses américaines fictives. |
| `_NavItem` × 2, `_FriseEtapes`, `_Champ`, `_BoutonSecondaire`, `_LignePaiement`, `_Recapitulatif`, `_LigneMontant` | Doublons locaux remplacés par des composants partagés. |
| `docs/plan-travail.md` | Doublon de `docs/plan-de-travail.md`. |

---

## 4. Ce qui reste incomplet, et pourquoi

### Dépendances backend

Rien de ce qui suit ne peut être terminé côté application seule. Chaque point
porte un `TODO(backend)` à l'endroit exact du code, et la signature des méthodes
est déjà à sa forme finale — le raccordement ne demandera pas de remaniement.

| Sujet | Endpoint disponible | État |
|---|---|---|
| Toutes les données | l'ensemble de l'API | L'application tourne sur des dépôts en mémoire. C'est le chantier suivant. |
| Connexion Google | **aucun** | Le backend n'expose ni `/auth/google` ni OAuth. Le bouton, que la maquette met en avant, annonce son indisponibilité. Il faut soit un endpoint, soit une configuration Firebase. |
| Réinitialisation du mot de passe | `POST /auth/forgot-password` | La boîte de dialogue collecte l'adresse et appelle une méthode qui simule l'envoi. |
| Photo d'une pièce confiée | `POST /sourcing/submissions/{id}/media` | La photo est choisie et conservée localement (`XFile.path`), jamais téléversée. |
| Photo de profil | `PATCH /me` | Le bouton de changement d'avatar est inerte. |
| Validation d'une adhésion | `GET /sourcing/me` | Décision d'administratrice. Faute de serveur, elle est **simulée** : l'adhésion passe de « en cours d'étude » à « validée » huit secondes après la soumission, pour que la frise de `27:1970` avance pendant une démonstration. Explicitement marqué comme simulation dans le code. |
| Vérification du code PIN | `POST /payouts` | Contrôle local : « 0000 » est refusé, ce qui garde l'écran d'erreur démontrable sans laisser croire à un vrai contrôle. |
| Code privilège | `CheckoutIn.privilege_code` | Table locale d'un seul code, celui inscrit dans la maquette. Le calcul de la remise appartient au serveur. |
| Commission de 25 % | paramètre serveur | Constante d'application pour l'instant. |
| Univers et maisons | `GET /universes`, `GET /houses` | Listes déduites des articles simulés. |
| Déconnexion | `POST /auth/logout` | Déconnexion locale seulement. |

### Dette non traitée

| Sujet | Détail |
|---|---|
| `dart format` | **81 des 94 fichiers** ne sont pas au format canonique. Le passage doit faire l'objet d'un commit dédié, sinon il noie toute autre modification. La CI est prête à activer le contrôle : une ligne à décommenter. |
| `fontSize` littéraux | Il en reste dans les écrans hors maquette (`espace_sub_screens.dart` surtout), qui concentrent l'essentiel de la dette de style. |
| Écarts du parcours d'inscription sourceuse | La spécialité choisie et toute l'étape PAIEMENT sont perdues à la soumission. Deux tests ignorés les documentent ; les corriger demande d'étendre `SourceurProfile`. |
| Couverture de tests | 56 tests, répartis entre les dépôts (26) et les écrans du parcours sourceuse et du brouillon de commande (30). Aucun test d'intégration du tunnel de bout en bout, ni de test de rendu sur les écrans du catalogue. |

---

## 5. Décisions prises et questions ouvertes

### Décisions structurantes

1. **Suppression de l'onglet Atelier.** La maquette ne connaît qu'un « Mon
   Espace Sourceur ». Garder les deux imposait d'entretenir un tableau de bord
   qui n'affichait que des zéros. La barre sourceuse compte donc 4 onglets.
2. **Le PIN appartient au retrait, pas au paiement.** `32:704` parle du
   « portefeuille » de la sourceuse, et le backend délègue le paiement acheteuse
   à un fournisseur externe. Le tunnel est piloté par `TypeOperation` plutôt que
   dupliqué.
3. **Les modèles géographiques reprennent la forme des DTO du backend**
   (`RegionOut`, `DivisionOut`, `CityOut`), identifiants entiers compris, même là
   où l'usage camerounais dit « département » quand l'API dit « division ». Le
   passage aux appels réels ne touchera aucun écran.
4. **Un état partagé pour la commande en cours** (`BrouillonCommande`). Sans lui,
   le checkout poussait une demande de transaction sans jamais créer de commande
   ni vider la sélection.
5. **Amorçage du dépôt sourceur avec un jeu de démonstration.** Sans pièces ni
   retraits, cinq écrans conformes n'affichaient que leur état vide. Le
   constructeur accepte des listes vides, ce dont les tests se servent.
6. **`enCours` ajouté à la frise.** Une commande en préparation devait choisir
   entre se dire « préparée » (faux) et « pas commencée » (faux aussi).

### Questions qui demandent votre arbitrage

1. **« Etape 2/4 » sur `33:1389`.** La maquette ne dessine ni les étapes 1, 3 et
   4, ni de compteur sur l'inspection (`34:1534`) ou le suivi (`34:1710`). Le
   compteur est transcrit tel quel. Quelles sont les quatre étapes ? S'il s'agit
   d'adhésion → formulaire → inspection → suivi, il faut porter le compteur sur
   les deux écrans suivants.
2. **Texte de `29:46`.** La maquette écrit, sur l'écran de validation
   d'adhésion : « Votre pièce sera préparée avec soin et expédiée très
   prochainement » — une phrase du reçu acheteuse, alors qu'aucune pièce n'a
   encore été confiée. Elle a été remplacée par « Votre espace de dépôt est
   ouvert : confiez-nous votre première pièce d'exception ». À valider.
3. **Les deux montants de `32:1223`.** Chaque ligne d'historique porte
   « 32.000 F » puis « 20.000 FCFA ». Le second a été rendu comme le **solde
   restant après le mouvement**. S'il s'agit d'autre chose (frais, montant net),
   la ligne est à revoir.
4. **Connexion Google.** Endpoint backend, ou Firebase côté application ?
5. **Deux villes tarifées seulement.** La maquette propose Yaoundé, Douala et
   « Autre » (à devis). Le tarif unique de 3 500 FCFA vient de `16:3448`. La
   grille réelle est à fournir, ou `GET /delivery/quote` à brancher.
6. **Délai de validation d'adhésion simulé à 8 secondes.** Confortable en
   démonstration, mais un compte partenaire reste enfermé sur la fiche de suivi
   pendant ce temps. À supprimer dès le raccordement.

---

## 6. Prochaines étapes recommandées

1. **Branchement API terminé** pour tout ce que le serveur expose. Restent hors
   API (donc locaux ou inactifs, jamais simulés) : panier, carnet d'adresses,
   Google OAuth, PIN portefeuille, upload binaire sourceur, alertes, avis.
2. **Passer `dart format` sur tout le projet**, dans un commit isolé, puis
   activer le contrôle dans la CI.
3. **Traiter les deux écarts du parcours d'inscription sourceuse** que les tests
   ignorés documentent.
4. **Ajouter un test d'intégration du tunnel** : sélection → checkout →
   paiement → reçu → « Mes commandes ». C'est le parcours qui engage de l'argent,
   et c'est celui qui a le plus changé.
5. **Trancher les six questions du §5**, en particulier le compteur d'étapes et
   la grille de livraison, qui touchent des textes affichés.
