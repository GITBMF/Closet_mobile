# Rapport de livraison — ClosET mobile

**Date** : 19 août 2026  
**Maquette** : [ClosEt App](https://www.figma.com/design/Echo68Mu5LH6P4FPCcY0Zs/ClosEt-App.fig?node-id=1-3) (`Echo68Mu5LH6P4FPCcY0Zs`, page Visualization `1:3`)  
**API** : [ClosET Swagger](https://closet-backend-be8g.onrender.com/docs) — base `https://closet-backend-be8g.onrender.com/api/v1`

---

## 1. Succès

| Sujet | Ce qui a été corrigé |
|---|---|
| Footer au milieu de l’écran | Cause : `Center` dans `bottomNavigationBar` + `extendBody: true`. La barre prenait toute la hauteur disponible et la pilule se centrait au milieu. Alignée en bas, bandeau vert pleine largeur comme `12:672` / `24:109`. |
| Articles invisibles | Le backend **renvoie bien des pièces** (`GET /pieces`). L’accueil les **jetait** parce que `GET /universes` et `GET /houses` sont vides (`[]`) et que tout `house_id` / `universe_id` est `null`. L’accueil lit désormais le catalogue + `GET /showcasing/home`, enrichit les images, et affiche nouveautés / coups de cœur sans exiger un univers. |
| Fiche article | `GET /pieces/{id}` est branché ; les images viennent aussi de `media[]`. La barre « Ajouter à mon dressing » ne s’étire plus. Un récit s’affiche même si `description` est nulle. |
| Connexion / inscription | Écran `5:1304` (`/auth`) : e-mail + mot de passe, inscription, mot de passe oublié, invitée. Accessible depuis onboarding (« J’AI DÉJÀ UN COMPTE »), depuis « Invitée » dans l’en-tête, et depuis Mon espace. |
| Espace cliente | Onglet **Espace** (`24:39`). Invité : CTA « Se connecter / S’inscrire ». Connectée : commandes, favoris, adresses, profil, déconnexion. |
| Navigation | Dressing · Collections · Wishlist · Selection · Espace, collée en bas. |

Contrôles : `flutter analyze lib` 0 issue ; `flutter test` 36 tests OK.

---

## 2. Échecs / limites restantes

| Sujet | Pourquoi ce n’est pas « pixel-perfect + backend complet » |
|---|---|
| Google Sign-In | La maquette montre « CONTINUER avec Google ». L’API n’expose pas d’OAuth Google. Le bouton reste inerte (toast). |
| Univers / maisons | `GET /universes` et `GET /houses` répondent `[]`. Les puces Robes / Vestes / Sacs de la maquette ne peuvent pas filtrer de vraies catégories tant que le back ne les alimente pas. |
| Images de vitrine | Les objets `featured` de `GET /showcasing/home` n’ont souvent **pas** de `image_url`. On les enrichit via le catalogue ; si la pièce n’est plus listée, le visuel reste vide. |
| Données produit incomplètes | Pas de matière, entretien, mensurations côté API. La fiche affiche ce qui existe (état, taille, récit) et un texte de repli pour « À propos ». |
| Retrait sourceur | Pas de `POST` de virement. Un retrait est refusé honnêtement. |
| Photo de profil | `PATCH /me` met à jour nom / e-mail / téléphone, pas l’avatar. |

---

## 3. Attentes (ce que la maquette + la doc demandent)

1. Reproduire les 40 écrans Figma (splash, onboarding, auth, dressing, collections, fiche, sélection, checkout 3 étapes, espace, sourceur).
2. Brancher réellement `https://closet-backend-be8g.onrender.com/api/v1`.
3. Barre de navigation en pilule verte en **bas** d’écran, jamais au milieu.
4. Catalogue vivant, pas des placeholders.
5. Parcours cliente : connexion, espace, détail d’article.

Les écrans existaient déjà en grande partie. Les griefs venaient surtout de **bugs de layout** et d’un **filtrage trop strict** face à un backend incomplet (univers/maisons vides).

---

## 4. Manquements (écarts Figma ↔ app ↔ API)

| Maquette | App | Backend |
|---|---|---|
| Puces Robes / Vestes / Sacs | « Tout l’univers » seulement si l’API n’a pas d’univers | `universes: []` |
| Maison Coco Chanel, Zara… | Marque déduite du titre (« Nike Baskets » → Nike) | `house_id: null` |
| Entretien, coupe, packaging détaillés | Lignes affichées seulement si le champ existe | `description: null`, pas d’entretien |
| Connexion Google | Toast | Pas d’endpoint |
| Nav flottante + bandeau 94 px | Bandeau + pilule, collés en bas | — |

---

## 5. Propositions

1. **Côté backend (prioritaire)**  
   - Peupler `houses` et `universes`, lier chaque pièce (`house_id`, `universe_id`).  
   - Inclure `image_url` / `images` dans `showcasing.featured[].piece`.  
   - Ajouter matière, entretien, mensurations sur `GET /pieces/{id}`.  
   - Documenter ou implémenter Google OAuth si le bouton Figma doit vivre.

2. **Côté app (ensuite)**  
   - Relancer l’app (`flutter run`) : splash → onboarding ou accueil → onglet Espace / Collections.  
   - Télécharger les SVG d’icônes Figma (maison, cœur, panier, user) à la place des icônes Material.  
   - Brancher Google uniquement quand l’API le permet.

3. **Produit**  
   - Compte de démo documenté dans le Swagger pour tester login sans créer un utilisateur à chaque fois.
