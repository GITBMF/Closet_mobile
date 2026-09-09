# ClosET

Application mobile Flutter de ClosET — dressing de pièces de seconde main (Cameroun). Deux espaces : **cliente** (découverte, sélection, commande) et **sourceur** (adhésion, dépôt de pièces, suivi).

La maquette Figma est la source de vérité visuelle. L’app parle à l’API publique `https://closet-backend-be8g.onrender.com/api/v1`.

## Stack

| | |
|---|---|
| SDK | Dart `^3.8.1`, Flutter stable |
| État / navigation | Riverpod, go_router |
| HTTP | Dio (`lib/data/bff_client/api_client.dart`) |
| Local | SharedPreferences (session, panier, adresses) |
| UI | Tokens ClosET, lucide_icons, Google Fonts, Boldonse |

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) (canal stable)
- Un émulateur Android / iOS, ou Chrome pour le web

Le fichier `.env` est déclaré en asset et gitignoré. L’URL d’API n’en est **pas** lue (elle est en dur dans le client HTTP), mais Flutter refuse de bundler un asset manquant. À la racine du clone :

```bash
# Windows (PowerShell)
New-Item -ItemType File -Name .env -ErrorAction SilentlyContinue

# macOS / Linux
touch .env
```

## Lancer

```bash
flutter pub get
flutter run
```

Cibles utiles :

```bash
flutter run -d chrome
flutter run -d android
flutter build apk --debug
```

## Architecture

```
lib/
  main.dart                 Point d’entrée, thème, overlay réseau
  core/                     Router, thème, widgets partagés
  data/
    bff_client/             Client HTTP unique (jeton, refresh, erreurs)
    repositories/           Auth, catalogue, commandes, sourcing, geo…
    models/                 DTOs
    services/               Persistance locale
  features/
    auth/                   Connexion / inscription
    cliente/                Dressing, collections, fiche, wishlist, espace
    checkout/               Adresse, moyen de paiement, récap
    transaction/            Traitement, succès, reçu
    sourceur/               Programme, adhésion, dépôts, revenus
design/
  openapi.json              Spec backend
  raw/                      Dump Figma
docs/                       Cartographie, écarts, plan, rapports
```

Les dépôts passent tous par `BffClient`. Malgré le nom, ce n’est **pas** un BFF : l’app appelle l’API Render directement.

## Parcours

**Cliente** — splash → onboarding → dressing / collections / fiche → sélection → checkout → paiement CinetPay (`payment_url`) → commandes.

**Sourceur** — devenir sourceur → identification → adhésion → espace, dépôts, suivi de pièce. Les retraits sont versés par ClosET : l’app affiche l’historique (`GET /sourcing/payouts`) et refuse un virement simulé.

Routes protégées côté client : `/checkout`, `/transaction`, `/sourceur/*` (sauf landing et identification). Le catalogue reste consultable sans compte.

## API

Base : `https://closet-backend-be8g.onrender.com/api/v1`  
Swagger : [closet-backend-be8g.onrender.com/docs](https://closet-backend-be8g.onrender.com/docs)

| Domaine | Endpoints |
|---|---|
| Auth | `/auth/register`, `/login`, `/refresh`, `/logout`, `/forgot-password`, `/me` |
| Catalogue | `/pieces`, `/houses`, `/universes`, `/showcasing/home` |
| Wishlist | `/wishlist` |
| Géo / livraison | `/geo/*`, `/delivery/quote` |
| Commandes / paiement | `/orders`, `/payments/initiate`, `/payments/{id}` |
| Sourceur | `/sourcing/me`, `/apply`, `/submissions`, `/payouts` |

Panier et adresses n’ont pas d’endpoint : ils restent sur l’appareil.

## Tests et CI

```bash
flutter analyze --fatal-infos
flutter test
```

La CI (`.github/workflows/ci.yml`) rejoue l’analyse, les tests et `flutter build web` sur chaque push / PR vers `main`.

## Design

Maquette : fichier Figma **ClosEt App**. Relevés et mapping écran ↔ route dans `docs/figma-mapping.md`. Tokens couleur / typo dans `lib/core/theme/`.

## Limites connues

- **Google Sign-In** : bouton présent, API sans OAuth — toast uniquement.
- **Univers / maisons** : `GET /universes` et `GET /houses` peuvent renvoyer `[]` ; les filtres de catégories dépendent de ces listes.
- **Photo de profil** : `PATCH /me` met à jour nom, e-mail, téléphone, pas l’avatar.
- **Paiement carte** : le formulaire Visa est visuel ; le paiement réel passe par l’URL CinetPay.

## Documentation interne

| Fichier | Contenu |
|---|---|
| [docs/figma-mapping.md](docs/figma-mapping.md) | Écrans Figma → routes |
| [docs/gap-analysis.md](docs/gap-analysis.md) | Écarts au moment de l’audit |
| [docs/plan-de-travail.md](docs/plan-de-travail.md) | Lots de travail |
| [docs/rapport-final.md](docs/rapport-final.md) | Statut de livraison |
| [design/openapi.json](design/openapi.json) | Contrat API |
