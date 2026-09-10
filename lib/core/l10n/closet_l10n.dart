import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/locale_provider.dart';

/// Système i18n maison — supporte [Locale('fr')] et [Locale('en')].
class ClosetL10n extends InheritedWidget {
  const ClosetL10n({
    super.key,
    required this.locale,
    required super.child,
  });

  final Locale locale;

  bool get _fr => locale.languageCode != 'en';

  static ClosetL10n of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClosetL10n>() ??
        _L10nInstance(const Locale('fr'));
  }

  static final ClosetL10n fr = _L10nInstance(const Locale('fr'));

  String t(String fr, String en) => _fr ? fr : en;

  @override
  bool updateShouldNotify(ClosetL10n old) => old.locale != locale;

  // ─── Navigation ─────────────────────────────────────────────────────────────
  String get navDressing => t('Mon Dressing', 'My Wardrobe');
  String get navCollections => t('Collections', 'Collections');
  String get navWishlist => t('Wishlist', 'Wishlist');
  String get navSelection => t('Sélection', 'Selection');
  String get navEspace => t('Espace', 'Space');
  String get navDepots => t('Mes Dépôts', 'My Items');
  String get navConfier => t('Confier', 'Consign');
  String get navGains => t('Gains', 'Earnings');

  // ─── Dressing / Accueil ─────────────────────────────────────────────────────
  String get dressingVide => t('Votre dressing est vide.', 'Your wardrobe is empty.');
  String get pieceDeLaSemaine => t('Pièce de la semaine', 'Item of the week');
  String get decouvrir => t('Découvrir', 'Discover');
  String pieceSemaineSemantics(String titre, String prix) =>
      t('Pièce de la semaine : $titre — $prix', 'Item of the week: $titre — $prix');
  String get libelleCategorie => t('Catégorie', 'Category');

  // ─── Collections / Recherche ────────────────────────────────────────────────
  String get rechercherPiece => t('Rechercher une pièce…', 'Search for an item…');
  String get toutes => t('Toutes', 'All');
  String get aucunePieceRecherche => t('Aucune pièce ne correspond.', 'No items found.');
  String get effacerRecherche => t('Effacer', 'Clear');
  String nbPieces(int n) => n == 1 ? t('1 pièce', '1 item') : t('$n pièces', '$n items');

  // ─── Fiche produit ──────────────────────────────────────────────────────────
  String get enStock => t('En stock', 'In stock');
  String get epuise => t('Épuisé', 'Sold out');
  String get voirCatalogueSourceur => t('Voir le catalogue', 'View catalogue');
  String get couleur => t('Couleur', 'Color');
  String get tailleLabel => t('Taille', 'Size');
  String get matiere => t('Matière', 'Material');
  String get etatPiece => t('État', 'Condition');
  String get descriptionArticle => t('À propos de cette pièce', 'About this item');

  // ─── Sélection / Checkout ───────────────────────────────────────────────────
  String get selectionVide => t('Votre sélection est vide.', 'Your selection is empty.');
  String get paiementEnCours => t('Paiement en cours…', 'Payment in progress…');
  String get annulerPaiement => t('Annuler', 'Cancel');

  // ─── Espace client ──────────────────────────────────────────────────────────
  String get monEspace => t('Mon Espace', 'My Space');
  String get mesCommandes => t('Mes commandes', 'My orders');
  String get mesInformations => t('Mes informations', 'My information');
  String get modifierProfil => t('Modifier le profil', 'Edit profile');
  String get invite => t('Invité', 'Guest');
  String get connectezVousPieces =>
      t('Connectez-vous pour accéder à vos pièces.', 'Sign in to access your items.');
  String get membreDressing => t('Membre ClosET', 'ClosET member');
  String get seConnecterInscrire => t("Se connecter / S'inscrire", 'Sign in / Register');
  String get logout => t('Se déconnecter', 'Sign out');
  String get deconnexion => t('Déconnexion', 'Sign out');
  String get themeSombre => t('Mode sombre', 'Dark mode');
  String get langue => t('Langue', 'Language');
  String get ok => t('OK', 'OK');
  String get retour => t('Retour', 'Back');

  // ─── Carte Sourceur ─────────────────────────────────────────────────────────
  String get nouveau => t('Nouveau', 'New');
  String get devenirSourceur => t('Devenir Sourceur', 'Become a Sourcer');
  String get monEspaceSourceur => t('Mon Espace Sourceur', 'My Sourcer Space');
  String get carteSourceurCorps =>
      t('Confiez vos pièces et gagnez sur chaque vente.',
          'Consign your items and earn on every sale.');
  String get monEspaceCourt => t('Mon Espace', 'My Space');
  String get rejoindreCercleCourt => t('Rejoindre', 'Join');

  // ─── Espace sourceur ────────────────────────────────────────────────────────
  String get revenirEspaceClient => t('Basculer vers le compte Client', 'Switch to Client account');
  String get policesConfidentialite => t('Confidentialité & CGU', 'Privacy & Terms');
  String get ajouterCompteSourceur => t('Ajouter un compte sourceur', 'Add a sourcer account');
  String get statut => t('Statut', 'Status');
  String get telephone => t('Téléphone', 'Phone');
  String get collaboration => t('Collaboration', 'Collaboration');
  String get paiement => t('Paiement', 'Payment');
  String get membreDepuis => t('Membre depuis', 'Member since');

  // ─── Sourceur — Dépôts ──────────────────────────────────────────────────────
  String get mesDepots => t('Mes Dépôts', 'My Items');
  String get aucuneDonnee => t('Aucune donnée', 'No data');
  String get depotsVide =>
      t("Vous n'avez encore confié aucune pièce.", "You haven't consigned any items yet.");
  String get confierUnePiece => t('Confier une pièce', 'Consign an item');
  String get aucunePieceFiltre => t('Aucune pièce pour ce filtre.', 'No items for this filter.');
  String get enVente => t('En vente', 'For sale');
  String get enLigne => t('En ligne', 'Online');
  String get enCoursAnalyse => t('En analyse', 'Under review');
  String get vendues => t('Vendues', 'Sold');
  String get chiffreAffaires => t('CA', 'Revenue');

  // ─── Sourceur — Gains ───────────────────────────────────────────────────────
  String get mesGains => t('Mes Gains', 'My Earnings');
  String get notifications => t('Notifications', 'Notifications');
  String get tousMouvements => t('Tous', 'All');
  String get retraitsApprouves => t('Approuvés', 'Approved');
  String get retraitsEnCours => t('En cours', 'Pending');
  String get retraitsRefuses => t('Refusés', 'Refused');
  String get effectuerRetrait => t('Effectuer un retrait', 'Request withdrawal');
  String get soldeDisponible => t('Solde disponible', 'Available balance');
  String get soldeEnAttente => t('En attente', 'Pending');

  // ─── Sourceur — Formulaire ──────────────────────────────────────────────────
  String get photosInaccessibles =>
      t("Impossible d'accéder aux photos.", 'Cannot access photos.');
  String get galerieInaccessible =>
      t("Impossible d'accéder à la galerie.", 'Cannot access gallery.');
  String get cameraInaccessible =>
      t("Impossible d'accéder à la caméra.", 'Cannot access camera.');
  String get depotEnCours => t('Dépôt en cours…', 'Submitting…');
  String get depotImpossible => t('Dépôt impossible', 'Submission failed');
  String get pieceRecue => t('Pièce reçue !', 'Item received!');
  String pieceEnExamen(String nom) =>
      t('« $nom » est en cours d\'examen par notre équipe.',
          '"$nom" is being reviewed by our team.');

  // ─── Feedback / États écran ─────────────────────────────────────────────────
  String get chargementMessage => t('Préparation de votre dressing…', 'Preparing your wardrobe…');
  String get retryLabel => t('Réessayer', 'Retry');
  String get vide => t('Aucun contenu', 'No content');
  String get listeVideTitre => t('Aucun contenu', 'Nothing here');
  String get listeVideMessage =>
      t('Cette section est vide pour le moment.', 'This section is empty for now.');

  // ─── Auth ────────────────────────────────────────────────────────────────────
  String get ouSeConnecter => t('ou se connecter avec', 'or sign in with');
  String get emailInvalide => t('Adresse e-mail invalide.', 'Invalid e-mail address.');
  String get emailInvalideTitre => t('E-mail invalide', 'Invalid e-mail');
  String get motDePasseTropCourt => t('Minimum 6 caractères.', 'Minimum 6 characters.');
  String get champsObligatoires => t('Ce champ est obligatoire.', 'This field is required.');
  String get telephoneInvalide => t('Numéro de téléphone invalide.', 'Invalid phone number.');
  String get champsManquants => t('Champs manquants', 'Missing fields');
  String get renseignerNomPrenom =>
      t('Renseignez votre prénom et nom.', 'Please enter your first and last name.');
  String get nomIncomplet => t('Nom incomplet', 'Incomplete name');
  String get nomMinCaracteres =>
      t('Minimum 2 caractères par champ.', 'Minimum 2 characters per field.');
  String get nomTropLong => t('Nom trop long', 'Name too long');
  String get max150 => t('Maximum 150 caractères.', 'Maximum 150 characters.');
  String get renseignerNom => t('Renseignez votre nom.', 'Please enter your last name.');
  String get renseignerPrenom => t('Renseignez votre prénom.', 'Please enter your first name.');
  String get renseignerEmail => t('Renseignez votre e-mail.', 'Please enter your e-mail.');
  String get emailIncorrect => t('Format e-mail incorrect.', 'Incorrect e-mail format.');
  String get renseignerMdp => t('Renseignez un mot de passe.', 'Please enter a password.');
  String get min8Caracteres => t('Minimum 8 caractères.', 'Minimum 8 characters.');
  String get motDePasse => t('Mot de passe', 'Password');
  String get hintMotDePasse => t('Au moins 8 caractères', 'At least 8 characters');
  String get hintMdpRegle =>
      t('Majuscule, chiffre, caractère spécial requis.',
          'Uppercase, number, special character required.');
  String get motDePasseOublie => t('Mot de passe oublié ?', 'Forgot password?');
  String get boutonSeConnecter => t('Se connecter', 'Sign in');
  String get boutonCreerCompte => t('Créer mon compte', 'Create account');
  String get continuerGoogle => t('Continuer avec Google', 'Continue with Google');
  String get googleIndisponibleTitre => t('Google indisponible', 'Google unavailable');
  String get googleIndisponible =>
      t("La connexion Google n'est pas disponible sur cet appareil.",
          'Google sign-in is not available on this device.');
  String get pasEncoreMembre => t('Pas encore membre ?', 'Not a member yet?');
  String get dejaMembre => t('Déjà membre ?', 'Already a member?');
  String get rejoindreLeCercle => t('Rejoindre le cercle', 'Join the circle');
  String get seConnecter => t('Se connecter', 'Sign in');
  String get continuerInvitee => t('Continuer sans compte', 'Continue without account');
  String get authTitreConnexion => t('Connexion', 'Sign in');
  String get authTitreInscription => t('Inscription', 'Register');
  String get connexionReussie => t('Connexion réussie', 'Signed in');
  String get compteCree => t('Compte créé', 'Account created');
  String bonRetour(String prenom) => t('Bon retour, $prenom !', 'Welcome back, $prenom!');
  String bienvenuePrenom(String prenom) => t('Bienvenue, $prenom !', 'Welcome, $prenom!');
  String get connexionImpossible => t('Connexion impossible', 'Sign-in failed');
  String get inscriptionImpossible => t('Inscription impossible', 'Registration failed');
  String get prenom => t('Prénom', 'First name');
  String get nom => t('Nom', 'Last name');
  String get email => t('E-mail', 'E-mail');

  // ─── Connexion requise ──────────────────────────────────────────────────────
  String get connexionRequise => t('Connexion requise', 'Sign in required');
  String get connexionRequiseSelection =>
      t('Connectez-vous pour finaliser votre sélection.',
          'Sign in to complete your selection.');
  String get plusTard => t('Plus tard', 'Later');

  // ─── Erreurs ────────────────────────────────────────────────────────────────
  String get erreurTitre => t('Une erreur est survenue', 'An error occurred');
  String get erreurGenerique => t('Veuillez réessayer.', 'Please try again.');

  String messageDepuisErreur(Object erreur) {
    final s = erreur.toString();
    if (s.contains('SocketException') || s.contains('NetworkException')) {
      return t('Vérifiez votre connexion internet.', 'Check your internet connection.');
    }
    if (s.contains('401') || s.contains('Unauthorized')) {
      return t('Session expirée, veuillez vous reconnecter.',
          'Session expired, please sign in again.');
    }
    if (s.contains('404')) return t('Contenu introuvable.', 'Content not found.');
    if (s.contains('500') || s.contains('502') || s.contains('503')) {
      return t('Problème serveur. Réessayez plus tard.', 'Server error. Please try again later.');
    }
    final match = RegExp(r'"([^"]{4,120})"').firstMatch(s);
    if (match != null) return match.group(1)!;
    return '';
  }

  // ─── Toasts ─────────────────────────────────────────────────────────────────
  String toastPiece(String nom, String resultat) => '$nom $resultat';

  // ─── Filtres / Recherche avancée ────────────────────────────────────────────
  String get affinerRecherche => t('Affiner la recherche', 'Refine search');
  String get toutReinitialiser => t('Tout réinitialiser', 'Reset all');
  String get voirLesPieces => t('Voir les pièces', 'View items');
  String get filtreUnivers => t('Univers', 'Universe');
  String get filtreTaille => t('Taille', 'Size');
  String get filtreEtat => t('État', 'Condition');
  String get filtreMaison => t('Maison', 'House');
  String get filtreBudget => t('Budget', 'Budget');

  // ─── Validation formulaire (compléments) ────────────────────────────────────
  String get ajouterChiffre =>
      t('Ajoutez au moins un chiffre.', 'Add at least one digit.');
  String get ajouterLettre =>
      t('Ajoutez au moins une lettre.', 'Add at least one letter.');
  String get mdpSansEspaces => t('Le mot de passe ne doit pas contenir d’espaces.',
      'The password must not contain spaces.');
  String get max128 => t('128 caractères maximum.', '128 characters maximum.');
  String get renseignerNumero =>
      t('Renseignez votre numéro.', 'Please enter your number.');
  String get numeroIncorrect =>
      t('Numéro de téléphone incorrect.', 'Incorrect phone number.');

  // ─── Sourceur — surtitre d'en-tête ──────────────────────────────────────────
  String get espaceSourceur => t('Espace Sourceur', 'Sourceur Space');
}

// ─────────────────────────────────────────────────────────────────────────────
// Implémentation interne (instanciation hors-arbre)
// ─────────────────────────────────────────────────────────────────────────────

class _L10nInstance extends ClosetL10n {
  _L10nInstance(Locale locale)
      : super(locale: locale, child: const SizedBox.shrink());
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider Riverpod — accès hors-widget (toasts, services)
// ─────────────────────────────────────────────────────────────────────────────

final l10nProvider = Provider<ClosetL10n>((ref) {
  final locale = ref.watch(localeProvider);
  return _L10nInstance(locale);
});
