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
        const _L10nInstance(Locale('fr'));
  }

  static const ClosetL10n fr = _L10nInstance(Locale('fr'));

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
  String get maSelection => t('Ma sélection', 'My selection');
  String selectionAvecCompte(int n) =>
      t('Sélection, $n pièces', 'Selection, $n items');
  String get bienvenueVirgule => t('Bienvenue,', 'Welcome,');

  String get checkoutLivraisonTitre => t('Livraison', 'Delivery');
  String get checkoutPaiementTitre => t('Paiement', 'Payment');
  String get checkoutFinaliserCommande => t('Finaliser ma commande', 'Finalize my order');
  String checkoutEtapeSur2(int n) => t('Étape $n/2', 'Step $n/2');
  String get checkoutDetailsLivraison => t('Détails de livraison', 'Delivery details');
  String get checkoutDelaiLivraison => t(
        'Livraison à domicile disponible sous 24h à 48h après la commande *',
        'Home delivery available within 24 to 48 hours after ordering *',
      );
  String get checkoutNomComplet => t('Nom complet', 'Full name');
  String get checkoutNomCompletHint => t('Marie Dupont', 'Jane Doe');
  String get checkoutIndiquerNomComplet =>
      t('Indiquez votre nom complet.', 'Enter your full name.');
  String get checkoutTelephoneWhatsapp => t('Téléphone (WhatsApp)', 'Phone (WhatsApp)');
  String get checkoutNumeroWhatsapp => t('numéro WhatsApp', 'WhatsApp number');
  String get checkoutMethodePaiement => t('Méthode de paiement', 'Payment method');
  String get checkoutSuivant => t('Suivant', 'Next');
  String get checkoutPoursuivrePaiement => t('Poursuivre — Paiement', 'Continue — Payment');
  String checkoutPoursuivrePaiementMontant(String montant) =>
      t('Poursuivre — Paiement $montant', 'Continue — Payment $montant');
  String get checkoutChoisirVilleLivraison =>
      t('Choisissez votre ville de livraison.', 'Choose your delivery city.');
  String get checkoutCompleterAdresseCascade => t(
        'Complétez région, département et quartier.',
        'Complete region, division and neighbourhood.',
      );
  String get checkoutVilleLivraisonTitre => t('Ville de livraison', 'Delivery city');
  String get checkoutVillesIndisponibles => t('Villes indisponibles', 'Cities unavailable');
  String get checkoutRegionTitre => t('Région', 'Region');
  String get checkoutRegionsIndisponibles =>
      t('Régions indisponibles', 'Regions unavailable');
  String get checkoutDepartementTitre => t('Département', 'Division');
  String get checkoutDepartementsIndisponibles =>
      t('Départements indisponibles', 'Divisions unavailable');
  String get checkoutCompleterAdresseLivraison =>
      t('Complétez votre adresse de livraison.', 'Complete your delivery address.');
  String get checkoutChoisirMoyenPaiement =>
      t('Choisissez un moyen de paiement.', 'Choose a payment method.');
  String get checkoutCompleterInfosPaiement => t(
        'Complétez les informations de paiement.',
        'Complete the payment information.',
      );
  String get checkoutZoneDevis => t(
        'La livraison vers cette zone est à devis. Nous vous contacterons '
            'sur WhatsApp pour la confirmer.',
        'Delivery to this area requires a quote. We will contact you on '
            'WhatsApp to confirm it.',
      );
  String get checkoutRecuPiece => t('Pièce', 'Item');
  String get checkoutRecuPieces => t('Pièces', 'Items');
  String checkoutRecuNPieces(int n) => t('$n pièces', '$n items');
  String get checkoutRecuMoyenPaiement => t('Moyen de paiement', 'Payment method');
  String get checkoutRecuCodePrivilege => t('Code privilège', 'Privilege code');
  String get checkoutChoisirMaVille => t('Choisir ma ville', 'Choose my city');
  String get checkoutChoisirMaRegion => t('Choisir ma région', 'Choose my region');
  String get checkoutChoisirDabordRegion =>
      t("Choisissez d'abord une région", 'Choose a region first');
  String get checkoutChoisirMonDepartement =>
      t('Choisir mon département', 'Choose my division');
  String get checkoutArrondissementLabel => t('Arrondissement', 'District');
  String get checkoutArrondissementHint => t('Yaoundé 3e', 'Yaoundé 3rd district');
  String get checkoutQuartierLabel => t('Quartier', 'Neighbourhood');
  String get checkoutQuartierHint =>
      t('Newtown Collège, face pharmacie', 'Newtown College, opposite the pharmacy');
  String get checkoutRevenirChoixVille =>
      t('Revenir au choix par ville', 'Back to choosing by city');
  String get checkoutSaisirAdresseDetaillee =>
      t('Saisir une adresse détaillée', 'Enter a detailed address');
  String checkoutNumeroMoyen(String libelle) => t('Numéro $libelle', '$libelle number');
  String get checkoutNomPorteur => t('Nom du porteur', 'Cardholder name');
  String get checkoutNumeroCarte => t('Numéro de carte', 'Card number');
  String get checkoutExpiration => t('Expiration', 'Expiry');

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
  String get emailFormatAttendu => t(
        'Utilisez une adresse du type nom@domaine.com.',
        'Use an address like name@domain.com.',
      );
  String get connexionEmailPasTelephone => t(
        'La connexion se fait avec l’e-mail du compte, pas le téléphone.',
        'Sign in uses the account e-mail, not the phone number.',
      );
  String get utiliserEmailCompte => t(
        'Utilisez l’e-mail du compte (nom@domaine.com).',
        'Use the account e-mail (name@domain.com).',
      );
  String get renseignerMdp => t('Renseignez un mot de passe.', 'Please enter a password.');
  String get min8Caracteres => t('Minimum 8 caractères.', 'Minimum 8 characters.');
  String get regle8CaracteresMinimum =>
      t('8 caractères minimum', '8 characters minimum');
  String get regleAuMoinsUneLettre =>
      t('Au moins une lettre', 'At least one letter');
  String get regleAuMoinsUnChiffre =>
      t('Au moins un chiffre', 'At least one digit');
  String get regleSansEspace => t('Sans espace', 'No spaces');
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
  String get continuer => t('Continuer', 'Continue');
  String get etapeIdentite => t('IDENTITÉ', 'IDENTITY');
  String get etapeContact => t('CONTACT', 'CONTACT');
  String get etapeSecurite => t('SÉCURITÉ', 'SECURITY');

  // ─── Connexion requise ──────────────────────────────────────────────────────
  String get connexionRequise => t('Connexion requise', 'Sign in required');
  String get connexionRequiseSelection =>
      t('Connectez-vous pour finaliser votre sélection.',
          'Sign in to complete your selection.');
  String get plusTard => t('Plus tard', 'Later');

  // ─── Erreurs ────────────────────────────────────────────────────────────────
  String get erreurTitre => t('Une erreur est survenue', 'An error occurred');
  String get erreurGenerique => t('Veuillez réessayer.', 'Please try again.');

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

  // ─── Force du mot de passe ──────────────────────────────────────────────────
  String get forceMdpVide => t('Saisissez un mot de passe', 'Enter a password');
  String get forceMdpFaible => t('Faible', 'Weak');
  String get forceMdpMoyen => t('Moyen', 'Medium');
  String get forceMdpFort => t('Fort', 'Strong');
  String get forceMdpExcellent => t('Excellent', 'Excellent');

  // ─── Sourceur — surtitre d'en-tête ──────────────────────────────────────────
  String get espaceSourceur => t('Espace Sourceur', 'Sourceur Space');

  // ─── Sourceur — état / méthode de collecte (partagés) ──────────────────────
  String get etatNeuf => t('Neuf', 'New');
  String get etatTresBonEtat => t('Très bon état', 'Very good condition');
  String get etatBonEtat => t('Bon état', 'Good condition');
  String get etatExcellent => t('Excellent', 'Excellent');
  String get conseilNettoyageSec =>
      t('Nettoyage à sec recommandé', 'Dry cleaning recommended');
  String get conseilLavageMain =>
      t('Lavage à la main, à froid', 'Hand wash, cold');
  String get conseilEntretienCuir => t(
        'Entretien cuir, pas de lavage en machine',
        'Leather care, no machine wash',
      );
  String get codeEnregistreTitre => t('Code enregistré', 'Code saved');
  String get remiseCalculeeAuPaiementMessage => t(
        'La remise sera calculée par ClosET au paiement.',
        'The discount will be calculated by ClosET at payment.',
      );
  String get codePrivilegeLabel => t('Code privilège', 'Privilege code');
  String get cerclePrivilegeHint => t('cercle-privilège', 'privilege-circle');
  String get retirerLabel => t('Retirer', 'Remove');
  String get appliquerLabel => t('Appliquer', 'Apply');
  String get ficheSourceurNonLieeMessage => t(
        'Aucune fiche sourceur n’est liée à ce compte. Le serveur refuse le '
            'dépôt tant que l’adhésion n’est pas enregistrée.',
        'No sourcer profile is linked to this account. The server refuses '
            'submissions until membership is registered.',
      );
  String get depotPasIdentifiantMessage =>
      t('Le dépôt n’a pas renvoyé d’identifiant.', 'The submission didn’t return an identifier.');
  String get envoiDirectPhotosNonPrisEnChargeMessage => t(
        'L’envoi direct de photos n’est pas encore pris en charge par le '
            'serveur. Fournissez un lien déjà hébergé (WhatsApp, Google '
            'Drive…) en attendant.',
        'Direct photo upload isn’t supported by the server yet. Provide an '
            'already-hosted link (WhatsApp, Google Drive…) in the meantime.',
      );
  String get photosNonJointesMessage => t(
        'Les photos n’ont pas pu être jointes : le serveur ne permet pas '
            'encore l’envoi direct depuis l’application. Notre équipe vous '
            'contactera pour les récupérer.',
        'The photos couldn’t be attached: the server doesn’t yet support '
            'direct upload from the app. Our team will contact you to '
            'collect them.',
      );
  String get ficheSourceurAbsenteMessage => t(
        'Aucune fiche sourceur n’est enregistrée pour ce compte. Terminez '
            'l’adhésion avant de confier une pièce.',
        'No sourcer profile is registered for this account. Finish signing '
            'up before submitting an item.',
      );
  String get adhesionEncoreALetudeMessage => t(
        'Votre adhésion est encore à l’étude. Le dépôt s’ouvrira après validation.',
        'Your membership is still under review. Submissions will open after approval.',
      );
  String get ficheSourceurInactiveMessage => t(
        'Votre fiche sourceur n’est plus active. Contactez ClosET avant de confier une pièce.',
        'Your sourcer profile is no longer active. Contact ClosET before submitting an item.',
      );
  String get retraitApprouveLabel => t('Retrait approuvé', 'Withdrawal approved');
  String get retraitEnCoursLabel => t('Retrait en cours', 'Withdrawal in progress');
  String get retraitRefuseLabel => t('Retrait refusé', 'Withdrawal refused');
  String get connectezVousFavorisPiece => t(
        'Connectez-vous pour enregistrer cette pièce dans vos favoris.',
        'Sign in to save this item to your favourites.',
      );
  String get connectezVousModifierFavoris =>
      t('Connectez-vous pour modifier vos favoris.', 'Sign in to edit your favourites.');
  String get connexionRequiseTitre => t('Connexion requise', 'Sign in required');
  String get connectezVousPourContinuer => t(
        'Veuillez vous connecter à votre compte pour continuer.',
        'Please sign in to your account to continue.',
      );
  String get retireeDesFavorisMessage =>
      t('a été retirée de vos favoris.', 'was removed from your favourites.');
  String get ajouteeAuxFavorisMessage =>
      t('a été ajoutée à vos favoris.', 'was added to your favourites.');
  String get favorisTitreCourt => t('Favoris', 'Favourites');
  String get retraitsVersesParClosetMessage => t(
        'Les retraits sont versés par ClosET une fois vos pièces vendues.',
        'Withdrawals are paid out by ClosET once your items are sold.',
      );
  String get livraisonADevisMessage => t(
        'La livraison vers cette zone est à devis. Nous vous contacterons '
            'sur WhatsApp pour confirmer le montant avant tout paiement.',
        'Delivery to this area is quote-based. We’ll contact you on '
            'WhatsApp to confirm the amount before any payment.',
      );
  String get paiementEchoueMessage => t(
        'Le paiement n’a pas abouti. Réessayez ou changez de moyen.',
        'The payment didn’t go through. Try again or change payment method.',
      );
  String get serveurPasIdentifiantPaiementMessage => t(
        'Le serveur n’a pas renvoyé d’identifiant de paiement.',
        'The server didn’t return a payment identifier.',
      );
  String get paiementEnCoursOperateurMessage => t(
        'Le paiement est toujours en cours chez l’opérateur. '
            'Vérifiez « Mes commandes » dans un instant.',
        'The payment is still being processed by the operator. '
            'Check “My orders” in a moment.',
      );
  String get mfaNonDisponibleMessage => t(
        'Ce compte exige une double authentification, non disponible dans '
            'l’application pour le moment.',
        'This account requires two-factor authentication, which isn’t '
            'available in the app yet.',
      );
  String get serveurPasDeJetonMessage => t(
        'Le serveur n’a pas renvoyé de jeton d’accès.',
        'The server didn’t return an access token.',
      );
  String get livraisonDomicileDelaiDefaut => t(
        'Livraison à domicile disponible sous 24h à 48h après la commande *',
        'Home delivery available within 24h to 48h after the order *',
      );
  String get conseilLavageDelicat => t(
        'Lavage délicat. Suivre l’étiquette d’entretien.',
        'Gentle wash. Follow the care label.',
      );
  String get collecteDomicile => t('Collecte à domicile', 'Home pickup');
  String get collecteDepot => t('Dépôt en boutique', 'Drop-off in store');

  // ─── Sourceur — suivi de pièce ──────────────────────────────────────────────
  String get suiviPieceTitre => t('Suivi de pièce', 'Item tracking');
  String get suiviMaPieceTitre => t('Suivre ma pièce', 'Track my item');
  String suiviTailleValeur(String taille) => t('Taille $taille', 'Size $taille');
  String get suiviInformationsRecues => t('Informations reçues', 'Information received');
  String get suiviEvolutionAnalyse =>
      t('Évolution et analyse de votre pièce', 'Progress and review of your item');
  String get suiviRetourEspace => t('Retour dans Mon Espace', 'Back to My Space');
  String get suiviSoumettreNouvelle =>
      t('Soumettre une nouvelle pièce', 'Submit a new item');
  String get suiviEtapeReceptionTitre => t('Reception de la pièce', 'Item received');
  String get suiviEtapeReceptionDetail =>
      t('Votre pièce nous est parvenue', 'We have received your item');
  String get suiviEtapeAnalyseTitre => t('En cours d’analyse', 'Under review');
  String get suiviEtapeAnalyseDetail => t(
        'Nous vérifions l’état de votre pièce conformément aux normes de ClosET',
        'We are checking your item’s condition against ClosET’s standards',
      );
  String get suiviEtapeDecisionTitre => t('Décision de ClosET', 'ClosET’s decision');
  String get suiviEtapeDecisionDetail => t(
        'Acceptation ou refus de la pièce conformément aux normes de ClosET',
        'Item accepted or refused according to ClosET’s standards',
      );
  String get suiviEtapeRefuseTitre => t('Article Refusé', 'Item refused');
  String get suiviEtapeRefuseDetail =>
      t('La pièce ne correspond pas aux normes actuelles de ClosET.',
          'The item does not meet ClosET’s current standards.');
  String get suiviEtapeRetourTitre => t('Retour de l’article', 'Item return');
  String get suiviEtapeRetourneDetail =>
      t('Votre pièce vous a été retournée.', 'Your item has been returned to you.');
  String get suiviEtapeRetourAVenirDetail =>
      t('Vous recevrez votre pièce d’ici peu', 'You will receive your item shortly');
  String get suiviEtapeAccepteTitre => t('Article Accepté', 'Item accepted');
  String get suiviEtapeAccepteDetail => t(
        'La pièce correspond parfaitement aux normes actuelles de ClosET.',
        'The item fully meets ClosET’s current standards.',
      );
  String get suiviEtapeVenteTitre => t('Article Mis en Vente', 'Item listed for sale');
  String get suiviEtapeVenteDetail =>
      t('Votre article a été mis en vente avec succès.', 'Your item was listed for sale successfully.');
  String get suiviEtapeVenteAVenirDetail => t('Mise en vente à venir', 'Listing coming soon');

  // ─── Sourceur — nouvelle pièce ──────────────────────────────────────────────
  String get typeRobe => t('Robe', 'Dress');
  String get typeChemise => t('Chemise', 'Shirt');
  String get typePantalon => t('Pantalon', 'Pants');
  String get typeVeste => t('Veste', 'Jacket');
  String get typeManteau => t('Manteau', 'Coat');
  String get typeJupe => t('Jupe', 'Skirt');
  String get typePull => t('Pull', 'Sweater');
  String get typeTshirt => t('T-shirt', 'T-shirt');
  String get typeBlouse => t('Blouse', 'Blouse');
  String get typeEnsemble => t('Ensemble', 'Set');
  String get typeSac => t('Sac', 'Bag');
  String get typeChaussures => t('Chaussures', 'Shoes');
  String get typeAccessoire => t('Accessoire', 'Accessory');

  String get nouvellePieceTypeArticle => t('Type d’article', 'Item type');
  String get nouvellePiecePreciserType =>
      t('Précisez le type d’article.', 'Specify the item type.');
  String get nouvellePieceTaille => t('Taille', 'Size');
  String get nouvellePieceIndiquerTaille => t('Indiquez la taille.', 'Enter the size.');
  String get nouvellePiecePrixSouhaite => t('Prix souhaité', 'Desired price');
  String get nouvellePieceValorisation => t(
        'ClosET valorise chaque pièce selon ses critères de qualité et '
            'd’élégance.',
        'ClosET values every item according to its quality and elegance '
            'criteria.',
      );
  String get nouvellePieceRecit => t('Récit (facultatif)', 'Story (optional)');
  String get nouvellePieceRecitHint => t(
        'D’où vient cette pièce, et pourquoi la confier.',
        'Where this item comes from, and why you’re consigning it.',
      );
  String get nouvellePieceAutoriserPartage =>
      t('Autoriser ClosET à partager cette pièce', 'Allow ClosET to share this item');
  String get nouvellePiecePartageDetail => t(
        'ClosET pourra relayer le visuel et le récit.',
        'ClosET may feature the photo and story.',
      );
  String get nouvellePiecePoursuivre => t('Poursuivre', 'Continue');
  String get nouvellePieceIndiquerPrix =>
      t('Indiquez un prix souhaité.', 'Enter a desired price.');
  String get nouvellePiecePrixIncorrect =>
      t('Ce prix semble incorrect.', 'This price looks incorrect.');
  String get nouvellePieceMarque => t('Marque (si connue)', 'Brand (if known)');
  String get nouvellePieceMediasVide => t(
        'Ajoutez photos et vidéos avant de soumettre. Facultatif.',
        'Add photos and videos before submitting. Optional.',
      );
  String nouvellePieceMediasAjoutes(int n) => t(
        '$n média${n > 1 ? 's' : ''} ajouté${n > 1 ? 's' : ''}. Vous pouvez '
            'en joindre d’autres.',
        '$n ${n > 1 ? 'items' : 'item'} added. You can attach more.',
      );
  String get nouvellePiecePhoto => t('Photo', 'Photo');
  String get nouvellePieceVideo => t('Vidéo', 'Video');
  String get nouvellePieceImporter => t('Importer', 'Import');
  String get nouvellePieceRetirerMedia => t('Retirer le média', 'Remove media');

  // ─── Sourceur — inscription (parcours 3 étapes) ────────────────────────────
  String get specialiteRobes => t('Robes', 'Dresses');
  String get specialiteVestes => t('Vestes', 'Jackets');
  String get specialiteSacs => t('Sacs', 'Bags');
  String get specialiteAccessoires => t('Accessoires', 'Accessories');
  String get specialiteMultiUnivers => t('Multi-univers', 'Multi-category');
  String get moyenMtnMomo => t('MTN MoMo', 'MTN MoMo');
  String get moyenOrangeMoney => t('Orange Money', 'Orange Money');
  String get moyenVirementBancaire => t('Virement bancaire', 'Bank transfer');
  String get etapeAtelier => t('ATELIER', 'WORKSHOP');
  String get etapeUnivers => t('UNIVERS', 'UNIVERSE');
  String get etapePaiement => t('PAIEMENT', 'PAYMENT');
  String get collabDepotVente =>
      t('Dépôt-vente (commission 25%)', 'Consignment (25% commission)');
  String get collabVenteDirecte =>
      t('Vente directe (achat immédiat)', 'Direct sale (immediate purchase)');
  String get sourceurNomAtelier => t('Nom de votre atelier', 'Your workshop name');
  String get sourceurAtelierHint => t('L’Atelier d’Awa', 'Awa’s Atelier');
  String get villeSimple => t('Ville', 'City');
  String get sourceurTelephoneWhatsapp => t('Téléphone WhatsApp', 'WhatsApp phone number');
  String get universDetailLabel =>
      t('Votre univers en quelques mots', 'Your universe in a few words');
  String get universDetailHint => t(
        'Racontez votre histoire, votre sensibilité, vos coups de cœur...',
        'Tell us your story, your style, your favourite finds...',
      );
  String get specialiteLabel => t('SPÉCIALITÉ', 'SPECIALTY');
  String get typeCollaborationLabel => t('TYPE DE COLLABORATION', 'COLLABORATION TYPE');
  String get moyenRemunerationLabel => t('MOYEN DE RÉMUNÉRATION', 'PAYMENT METHOD');
  String get numeroLabel => t('Numéro', 'Number');
  String get conditionsAdhesionTitre => t('Conditions d’adhésion', 'Membership terms');
  String get conditionsAdhesionCorps => t(
        'En rejoignant le cercle ClosET, vous acceptez :\n'
            '• une commission de 25% prélevée par ClosET sur chaque vente '
            'en dépôt-vente ;\n'
            '• l’authentification de chaque pièce avant mise en ligne ;\n'
            '• le respect de la charte d’authenticité et des délais de '
            'remise des pièces ;\n'
            '• le règlement de vos ventes selon le moyen choisi '
            '(Mobile Money ou virement).\n\n'
            'Ces règles s’appliquent dès validation de votre adhésion.',
        'By joining the ClosET circle, you agree to:\n'
            '• a 25% commission taken by ClosET on every consignment sale;\n'
            '• authentication of every item before it is published;\n'
            '• compliance with the authenticity charter and item handover '
            'deadlines;\n'
            '• payment of your sales via your chosen method (Mobile Money '
            'or bank transfer).\n\n'
            'These rules apply as soon as your membership is approved.',
      );
  String get adhesionTransmiseTitre => t('Adhésion transmise', 'Membership submitted');
  String get adhesionTransmiseCorps => t(
        'Votre fiche d’adhésion a bien été envoyée.',
        'Your membership application has been sent.',
      );
  String get adhesionImpossibleTitre => t('Adhésion impossible', 'Membership failed');
  String get statutApprouve => t('Approuvé', 'Approved');
  String get statutRefuse => t('Refusé', 'Refused');
  String get statutSuspendu => t('Suspendu', 'Suspended');
  String get statutEnEtude => t('En étude', 'Under review');
  String get collaborationVenteDirecte => t('Vente directe', 'Direct sale');
  String get collaborationDepotVente => t('Dépôt-vente', 'Consignment');
  String get nonRenseigne => t('Non renseigné', 'Not provided');
  String get moyenMtnMobileMoney => t('MTN Mobile Money', 'MTN Mobile Money');
  String get moyenCarteVisa => t('Carte Visa', 'Visa card');

  // ─── Tunnel de transaction ──────────────────────────────────────────────────
  String get transactionConfirmerRetrait => t('Confirmer le retrait', 'Confirm withdrawal');
  String get transactionConfirmerPaiement => t('Confirmer le paiement', 'Confirm payment');
  String get transactionMessageConfirmRetrait => t(
        'Vérifiez le montant et le compte crédité. Une fois confirmé, le '
            'retrait est transmis et ne peut plus être annulé ici.',
        'Check the amount and the credited account. Once confirmed, the '
            'withdrawal is submitted and can no longer be cancelled here.',
      );
  String get transactionMessageConfirmPaiement => t(
        'Vérifiez votre commande avant de payer. Une fois confirmé, vous '
            'serez dirigée vers votre opérateur et le paiement ne pourra '
            'plus être annulé depuis l’application.',
        'Check your order before paying. Once confirmed, you will be '
            'redirected to your operator and the payment can no longer be '
            'cancelled from the app.',
      );
  String get transactionPayerMaintenant => t('Payer maintenant', 'Pay now');
  String get transactionTraitementRetrait => t('Traitement en cours', 'Processing');
  String get transactionTraitementPaiement => t('Paiement en cours', 'Payment in progress');
  String get transactionReussie => t('Transaction reussie !', 'Transaction successful!');
  String get transactionPaiementReussi => t('Paiement reussi', 'Payment successful');
  String get transactionMessageSuccesRetrait => t(
        'Votre opération a été effectuée avec succès. Vous allez recevoir '
            'un reçu de confirmation d’ici quelques instants.',
        'Your transaction was completed successfully. You will receive a '
            'confirmation receipt shortly.',
      );
  String get transactionMessageSuccesPaiement => t(
        'Votre paiement a été effectuée avec succès. Vous allez recevoir '
            'un reçu de confirmation d’ici quelques instants.',
        'Your payment was completed successfully. You will receive a '
            'confirmation receipt shortly.',
      );
  String get transactionTotalRetire => t('Total retiré', 'Total withdrawn');
  String get transactionTotalPaye => t('Total payé', 'Total paid');
  String get transactionRetourEspace => t('Retour dans Mon Espace', 'Back to My Space');
  String get transactionPoursuivreVisite => t('Poursuivre ma visite', 'Continue browsing');
  String get transactionDontLivraison => t('Dont livraison', 'Including delivery');
  String get transactionMoyen => t('Moyen', 'Method');
  String get transactionCompte => t('Compte', 'Account');
  String get transactionRecuTitre => t('Votre reçu de transaction', 'Your transaction receipt');
  String transactionNumero(String n) => t('Transaction numéro #$n', 'Transaction number #$n');
  String get transactionDateHeure => t('Date & heure', 'Date & time');
  String get transactionNumeroReference => t('Numéro de référence', 'Reference number');
  String get transactionNotes => t('Note(s)', 'Note(s)');
  String get transactionMerci => t('ClosEt vous remercie !', 'Thank you from ClosET!');
  String get transactionPartagerRecu => t('Partager Mon Reçu', 'Share My Receipt');
  String get transactionPatientez => t(
        'Veuillez patienter quelques instants pendant que nous sécurisons '
            'et validons votre transaction. Merci de ne pas fermer cette '
            'application.',
        'Please wait a moment while we secure and validate your '
            'transaction. Please do not close this app.',
      );
  String get transactionColisPreparation => t(
        'Votre pièce sera préparée avec soin et expédiée très prochainement',
        'Your item will be carefully prepared and shipped very soon',
      );
  String transactionCommandeNumero(String n) => t('Commande N° $n', 'Order No. $n');
  String get transactionConfirmationWhatsapp =>
      t('Confirmation envoyée sur WhatsApp', 'Confirmation sent on WhatsApp');
  String get transactionVoirRecu => t('Voir le reçu', 'View receipt');
  String get transactionToutBon => t('C’est tout bon !', 'All done!');
  String get transactionRefuseeTitre => t('Transaction refusée', 'Transaction refused');
  String get transactionPartageIndisponibleTitre =>
      t('Partage indisponible', 'Sharing unavailable');
  String get transactionPartageIndisponibleCorps => t(
        'Le partage du reçu n’est pas encore proposé par le serveur.',
        'Sharing the receipt is not yet supported by the server.',
      );
  String get identifiantLabel => t('Identifiant', 'Username');
  String get pasDeFicheSourceuse => t(
        'Ce compte n’a pas de fiche sourceuse. Déposez d’abord une adhésion.',
        'This account doesn’t have a sourcer profile. Submit a membership '
            'application first.',
      );
  String get pasEncorePartenaireTitre => t('Pas encore partenaire', 'Not a partner yet');
  String get identificationReussieTitre => t('Identification réussie', 'Signed in successfully');
  String get bienvenueEspaceSourceur =>
      t('Bienvenue dans l’espace sourceur.', 'Welcome to the sourcer space.');
  String get identificationImpossibleTitre => t('Identification impossible', 'Sign-in failed');
  String get espaceSourceurClosetTitre => t('Espace Sourceur ClosET', 'ClosET Sourcer Space');
  String get accederEspaceConfie =>
      t('Accéder à mon espace confié', 'Access my consignment space');
  String get emailOuTelephone => t('Email ou téléphone', 'Email or phone');
  String get mdpMin8Chiffre =>
      t('8 caractères minimum, dont un chiffre.', 'At least 8 characters, including a digit.');
  String get entrerDansMonEspace => t('ENTRER dans mon espace', 'ENTER my space');
  String get remplirFicheAdhesion =>
      t('Remplir la fiche d’adhésion', 'Fill in the membership form');
  String get devenirSourceurClosetTitre =>
      t('Devenir Sourceur ClosET', 'Become a ClosET Sourcer');
  String get programmePartenaire => t('Programme partenaire', 'Partner programme');
  String get confiezPiecesValorisons =>
      t('Confiez vos pièces, nous les valorisons', 'Consign your items, we showcase them');
  String get devenirSourceurCorps => t(
        'Chaque pièce que vous confiez reste tracée jusqu’à vous. Vous '
            'suivez ses statuts en temps réel et vos gains, en toute '
            'transparence. Deux formules : vente directe ou dépôt-vente.',
        'Every item you consign stays traced back to you. You track its '
            'status in real time, and your earnings, with full '
            'transparency. Two options: direct sale or consignment.',
      );
  String get curationSoignee => t('Curation soignée', 'Careful curation');
  String get curationSoigneeDetail =>
      t('Chaque pièce est premiumisée avant mise en ligne.', 'Every item is polished before going live.');
  String get suiviTransparent => t('Suivi transparent', 'Transparent tracking');
  String get suiviTransparentDetail =>
      t('Six statuts, notifiés à chaque étape', 'Six statuses, notified at every step');
  String get remplirMaFicheAdhesion =>
      t('Remplir ma fiche d’adhésion', 'Fill in my membership form');
  String get accederMonEspace => t('Accéder à mon espace', 'Access my space');
  String get dejaPartenaire => t('Déjà partenaire ?', 'Already a partner?');
  String get pieceIntrouvableTitre => t('Pièce introuvable', 'Item not found');
  String get pieceIntrouvableMessage =>
      t('Cette pièce n’est plus dans le dressing.', 'This item is no longer in the wardrobe.');
  String get couleurVetement => t('Couleur du vêtement', 'Item color');
  String get tailleEtCoupe => t('Taille et coupe', 'Size and fit');
  String get conseilsLavageLabel => t('Conseils de lavage', 'Care instructions');
  String get universLabel => t('Univers', 'Universe');
  String get indisponibleLabel => t('Indisponible', 'Unavailable');
  String get retirerDeSelection => t('Retirer de ma sélection', 'Remove from my selection');
  String get ajouterASelection => t('Ajouter à ma sélection', 'Add to my selection');
  String get retireeDeSelection => t('a été retirée de votre sélection.', 'was removed from your selection.');
  String get ajouteeASelection => t('a été ajoutée à votre sélection.', 'was added to your selection.');
  String get retirerDeWishlist => t('Retirer de la wishlist', 'Remove from wishlist');
  String get ajouterAWishlist => t('Ajouter à la wishlist', 'Add to wishlist');
  String get venduPar => t('Vendu par ', 'Sold by ');
  String voirCatalogueDe(String nom) => t('Voir le catalogue de $nom', 'View $nom’s catalogue');

  // ─── Badges de statut ───────────────────────────────────────────────────────
  String get badgeLivree => t('Livrée', 'Delivered');
  String get badgeEnRoute => t('EN route', 'ON the way');
  String get badgePreparation => t('Préparation', 'Preparing');
  String get badgeMiseEnVente => t('Mis en vente', 'Listed for sale');
  String get badgeEnAnalyse => t('En cours d’analyse', 'Under review');
  String get badgeDepotRecu => t('dépôt reçu', 'drop-off received');
  String get badgeRefusee => t('refusé', 'refused');
  String get badgeRetournee => t('Retourné', 'Returned');
  String get badgeVendue => t('Vendue', 'Sold');
  String get badgeAcceptee => t('Acceptée', 'Accepted');
  String get methodeRetraitTitre => t('Méthode de retrait de fonds', 'Withdrawal method');
  String piecesEnVente(String n) => t('Pièces en vente : $n pièces', 'Items for sale: $n items');
  String aReverser(String montant) => t('À reverser : $montant', 'To be paid out: $montant');
  String get validerMethodeRetrait =>
      t('Valider la méthode de retrait', 'Confirm withdrawal method');
  String get retraitsGeresTitre => t('Retraits gérés par ClosET', 'Withdrawals managed by ClosET');
  String get selectionVideMessage =>
      t('Aucune pièce n’a été mise de côté.', 'No items have been set aside.');
  String get decouvrirCollections => t('Découvrir les collections', 'Discover the collections');
  String get catalogueTitre => t('Catalogue', 'Catalogue');
  String get pieceNePlusDisponibleMessage => t(
        'Cette pièce n’est plus disponible.',
        'This item is no longer available.',
      );
  String get mentionChiffrementMessage => t(
        'Toutes vos informations sont chiffrées de bout en bout et stockées '
            'sur des serveurs sécurisés.',
        'All your information is end-to-end encrypted and stored on '
            'secure servers.',
      );
  String get cercleDesSourceursBadge => t('CERCLE DES SOURCEURS', 'CIRCLE OF SOURCERS');
  String get confiezVosPiecesDexception =>
      t('Confiez vos pièces d’exception', 'Entrust your exceptional pieces');
  String get comiteClosEtAuthentifieMessage => t(
        'Le comité Clos ET authentifie, photographie et met en lumière vos '
            'pièces auprès d’une clientèle raffinée.',
        'The Clos ET committee authenticates, photographs and showcases '
            'your pieces to a refined clientele.',
      );
  String get aucunePieceEnVenteSourceurMessage => t(
        'Ce sourceur n’a aucune pièce en vente pour le moment.',
        'This sourcer has no items for sale at the moment.',
      );
  String get uneSeulePieceMiseDeCote => t('1 pièce unique mise de côté pour vous.', '1 unique item set aside for you.');
  String nPiecesMisesDeCote(int n) =>
      t('$n pièces uniques mises de côté pour vous.', '$n unique items set aside for you.');
  String get finaliserMaSelection => t('Finaliser ma sélection', 'Complete my selection');
  String get profilMisAJour => t('Profil mis à jour', 'Profile updated');
  String get miseAJourImpossible => t('Mise à jour impossible', 'Update failed');
  String get nomCompletLabel => t('Nom complet', 'Full name');
  String get veuillezRenseignerNom => t('Veuillez renseigner votre nom.', 'Please enter your name.');
  String get telephoneWhatsappLibelle => t('Téléphone (Whatsapp)', 'Phone (Whatsapp)');
  String get numeroWhatsapp => t('numéro WhatsApp', 'WhatsApp number');
  String indiquerUnLibelle(String libelle) =>
      t('Indiquez un $libelle.', 'Enter a $libelle.');
  String libelleSembleIncorrect(String libelle) =>
      t('Ce $libelle semble incorrect.', 'This $libelle looks incorrect.');
  String libelleSembleIncomplet(String libelle) =>
      t('Ce $libelle semble incomplet.', 'This $libelle looks incomplete.');
  String get numero => t('numéro', 'number');
  String get indicatifDuPays => t('Indicatif du pays', 'Country code');
  String get aTrouveSonDressing =>
      t('A trouvé son dressing', 'Found its wardrobe');
  String get paysOuIndicatifHint => t('Pays ou indicatif…', 'Country or code…');
  String indicatifPaysSemantique(String nomPays, String libelleCourt) => t(
        'Indicatif $nomPays $libelleCourt',
        '$nomPays country code $libelleCourt',
      );

  static const Map<String, String> _nomsPaysEn = {
    'CI': 'Ivory Coast',
    'SN': 'Senegal',
    'BJ': 'Benin',
    'GN': 'Guinea',
    'CD': 'DR Congo',
    'CF': 'Central African Republic',
    'GQ': 'Equatorial Guinea',
    'ZA': 'South Africa',
    'MA': 'Morocco',
    'TN': 'Tunisia',
    'DZ': 'Algeria',
    'EG': 'Egypt',
    'BE': 'Belgium',
    'CH': 'Switzerland',
    'US': 'United States',
    'GB': 'United Kingdom',
    'DE': 'Germany',
    'IT': 'Italy',
    'ES': 'Spain',
    'CM': 'Cameroon',
    'TD': 'Chad',
  };

  String nomPays(String iso, String nomFr) =>
      _fr ? nomFr : (_nomsPaysEn[iso] ?? nomFr);
  String get mettreAJour => t('Mettre à jour', 'Update');
  String get changerMaPhoto => t('Changer ma photo', 'Change my photo');
  String get photoIndisponibleTitre => t('Photo indisponible', 'Photo unavailable');
  String get saisirCodeSixChiffres =>
      t('Saisissez le code à 6 chiffres reçu par e-mail.', 'Enter the 6-digit code received by email.');
  String get codeIncorrectTitre => t('Code incorrect', 'Incorrect code');
  String get codeRenvoyeTitre => t('Code renvoyé', 'Code resent');
  String get nouveauCodeEnvoye =>
      t('Un nouveau code vient d’être envoyé.', 'A new code has just been sent.');
  String get envoiImpossibleTitre => t('Envoi impossible', 'Sending failed');
  String get verifiezVotreEmail => t('Vérifiez votre e-mail', 'Check your email');
  String codeEnvoyeA(String email) => t(
        'Un code à 6 chiffres a été envoyé à $email. Saisissez-le '
            'ci-dessous pour activer votre compte.',
        'A 6-digit code has been sent to $email. Enter it below to '
            'activate your account.',
      );
  String get verifier => t('Vérifier', 'Verify');
  String renvoyerLeCodeCompteASecondes(int s) => t('Renvoyer le code (${s}s)', 'Resend code (${s}s)');
  String get renvoyerLeCode => t('Renvoyer le code', 'Resend code');
  String get chargementEllipse => t('Chargement…', 'Loading…');
  String get unInstant => t('Un instant', 'One moment');
  String get horsConnexionTitre => t('Hors connexion', 'Offline');
  String get horsConnexionMessage => t(
        'Impossible de joindre ClosET. Vérifiez votre réseau puis réessayez.',
        'Can’t reach ClosET. Check your connection and try again.',
      );
  String get listeVideTitreCourt => t('Liste vide', 'Empty list');
  String get actionsIndisponiblesHorsLigne => t(
        'Certaines actions seront indisponibles jusqu’au retour du réseau.',
        'Some actions will be unavailable until the connection returns.',
      );
  String get connexionRetablie => t('Connexion rétablie', 'Connection restored');
  String get apiHorsLigneMessage => t(
        'Vous semblez hors connexion. Vérifiez votre réseau.',
        'You seem to be offline. Check your connection.',
      );
  String get apiDelaiDepasseMessage => t(
        'Le serveur met trop de temps à répondre. Réessayez.',
        'The server is taking too long to respond. Try again.',
      );
  String get apiNonAutoriseMessage =>
      t('Session expirée. Veuillez vous reconnecter.', 'Session expired. Please sign in again.');
  String get apiIntrouvableMessage =>
      t('Ressource introuvable.', 'Resource not found.');
  String get apiValidationMessage =>
      t('Certaines informations sont invalides.', 'Some information is invalid.');
  String get apiServeurMessage => t(
        'Le service est momentanément indisponible. Réessayez dans un instant.',
        'The service is temporarily unavailable. Try again in a moment.',
      );
  String get apiAutreMessage =>
      t('Une erreur est survenue. Veuillez réessayer.', 'An error occurred. Please try again.');
  String get aucuneDonneeMoment => t('Aucune donnée pour le moment.', 'No data for now.');
  String get inspectionTitre =>
      t('Inspection et analyse de votre pièce', 'Inspection and review of your item');
  String get inspectionCorps => t(
        'Notre équipe va examiner votre pièce avec le plus grand soin. '
            'Nous vérifions vos informations et nous vous reviendrons très '
            'rapidement avec une réponse.',
        'Our team will examine your item with the greatest care. We are '
            'checking your information and will get back to you very '
            'soon with an answer.',
      );
  String get suivreAnalysePiece => t('Suivre l’analyse de ma pièce', 'Track my item’s review');
  String get pieceBienRecue => t('Pièce bien reçue !', 'Item received!');
  String get sousTotalLabel => t('Sous-total', 'Subtotal');
  String get livraisonDelicate => t('Livraison délicate', 'Careful delivery');
  String get aDeterminer => t('À déterminer', 'To be determined');
  String get codePinSecurite => t('Code PIN de sécurité', 'Security PIN code');
  String get ajouterCodePin => t(
        'Ajoutez un code PIN pour renforcer la sécurité de votre opération.',
        'Add a PIN code to strengthen the security of your transaction.',
      );
  String get validerNumeroPin => t('Valider le Numéro PIN', 'Confirm PIN number');
  String get felicitationAdhesion => t(
        'Felicitation votre adhesion a été approuvée avec succès !',
        'Congratulations, your membership has been successfully approved!',
      );
  String get espaceDepotOuvertMessage => t(
        'Votre espace de dépôt est désormais ouvert.\n'
            'Vous pouvez confier votre première pièce.',
        'Your consignment space is now open.\n'
            'You can consign your first item.',
      );
  String get entrerEspaceSourceur =>
      t('Entrer dans mon espace sourceur', 'Enter my sourcer space');
  String get verificationApprouvee => t('Vérification approuvée !', 'Verification approved!');
  String get mesFavorisTitre => t('Mes favoris', 'My favourites');
  String get connexionRequiseFavoris => t(
        'Connectez-vous pour enregistrer et retrouver vos pièces favorites.',
        'Sign in to save and find your favourite items.',
      );
  String get aucunFavoriMessage =>
      t('Aucune pièce n’a été ajoutée aux favoris.', 'No items have been added to favourites.');
  String get retirerDesFavoris => t('Retirer des favoris', 'Remove from favourites');
  String get retirerCourt => t('Retirer', 'Remove');
  String get ajouterCourt => t('Ajouter', 'Add');
  String get verifiezVosMessages => t('Vérifiez vos messages', 'Check your messages');
  String get mdpOublieDialogTitre => t('Mot de passe oublié', 'Forgot password');
  String lienEnvoyeA(String email) => t(
        'Si un compte est rattaché à $email, un lien de réinitialisation '
            'vient d’y être envoyé.',
        'If an account is linked to $email, a reset link has just been '
            'sent to it.',
      );
  String get indiquerAdresseReinit => t(
        'Indiquez l’adresse de votre compte : nous y enverrons un lien '
            'de réinitialisation.',
        'Enter your account’s email address: we will send a reset link '
            'there.',
      );
  String get fermer => t('Fermer', 'Close');
  String get envoyerLeLien => t('Envoyer le lien', 'Send the link');
  String get photoIndisponibleCorps => t(
        'Le changement de photo n’est pas encore proposé par le serveur.',
        'Changing your photo is not yet supported by the server.',
      );
  String get virementsEmis => t(
        'Les virements sont émis une fois vos pièces vendues.',
        'Transfers are issued once your items are sold.',
      );
  String get tempsEstimationLabel => t('Temps d’estimation', 'Estimated time');
  String get tempsEstimationEnCours => t('En cours', 'In progress');
  String get commandeIntrouvableTitre => t('Commande introuvable', 'Order not found');
  String get transactionIntrouvableTitre =>
      t('Transaction introuvable', 'Transaction not found');
  String get commandeIntrouvableMessage => t(
        'Cette commande n’apparaît plus dans votre historique.',
        'This order no longer appears in your history.',
      );
  String get deposeLe => t('Déposé le', 'Dropped off on');
  String get estimationLabel => t('Estimation', 'Estimate');
  String get suivreMaCommande => t('Suivre ma commande', 'Track my order');
  String get passerAutresCommandes => t('Passer d’autres commandes', 'Place other orders');
  String get sousTotalLivraison => t('sous-total + livraison', 'subtotal + delivery');
  String get totalARegler => t('Total à régler', 'Total due');
  String get laissezNousMessage => t('Laissez-nous un message', 'Leave us a message');
  String get maCommandeSurtitre => t('ma commande', 'my order');
  String get suiviIndisponible => t(
        'Le suivi n’est plus disponible pour cette commande.',
        'Tracking is no longer available for this order.',
      );
  String get voyagePiece => t('Voyage de votre pièce', 'Your item’s journey');
  String get etapeSelectionConfirmee => t('Sélection confirmée', 'Selection confirmed');
  String get etapePaiementConfirme => t('Paiement confirmé', 'Payment confirmed');
  String get etapePrepareeAvecSoin => t('Préparée avec soin', 'Carefully prepared');
  String get etapePrepareeAFait => t(
        'Votre pièce a reçu son packaging Clos ET',
        'Your item has received its ClosET packaging',
      );
  String get etapePrepareeEnCours => t(
        'Votre pièce reçoit son packaging Clos ET',
        'Your item is receiving its ClosET packaging',
      );
  String get etapeEnRouteTitre => t('En route pour livraison', 'On the way for delivery');
  String get etapeLivraisonPlanification =>
      t('Livraison en cours de planification', 'Delivery being scheduled');
  String etapeLivraisonEstimee(String date) =>
      t('Livraison estimée : $date', 'Estimated delivery: $date');
  String get etapeDressingTitre => t('Dans votre dressing', 'In your wardrobe');
  String get etapeDressingRemise =>
      t('Votre pièce vous a été remise', 'Your item has been handed over');
  String get etapeDressingAVenir => t('Dès la livraison faite', 'As soon as delivered');
  String get supprimerAdresseTitre => t('Supprimer cette adresse ?', 'Delete this address?');
  String get supprimerAdresseCorps => t(
        'Elle ne sera plus proposée au moment de commander.',
        'It will no longer be offered when placing an order.',
      );
  String get supprimer => t('Supprimer', 'Delete');
  String get filtrer => t('Filtrer', 'Filter');
  String get mesAdressesTitre => t('Mes adresses', 'My addresses');
  String get ajouterAdresse => t('Ajouter une adresse', 'Add an address');
  String get modifierAdresse => t('Modifier l’adresse', 'Edit address');
  String get nouvelleAdresse => t('Nouvelle adresse', 'New address');
  String get libelleAdresseLabel => t('Libellé', 'Label');
  String get libelleAdresseHint => t('Maison', 'Home');
  String get donnerNomAdresse =>
      t('Donnez un nom à cette adresse.', 'Give this address a name.');
  String get adresseLabel => t('Adresse', 'Address');
  String get adresseHintExemple =>
      t('Yaoundé, Bastos — Rond-point, immeuble Kaba', 'Yaoundé, Bastos — roundabout, Kaba building');
  String get preciserVilleQuartier =>
      t('Précisez la ville et le quartier.', 'Specify the city and neighbourhood.');
  String get typeLabel => t('Type', 'Type');
  String get parDefautBadge => t('par Défaut', 'Default');
  String get adresseParDefaut => t('Adresse par défaut', 'Default address');
  String get adresseParDefautDetail => t(
        'Proposée en premier au moment de commander.',
        'Suggested first when placing an order.',
      );
  String get enregistrer => t('Enregistrer', 'Save');
  String get supprimerCetteAdresse => t('Supprimer cette adresse', 'Delete this address');
  String get typeAdresseMaison => t('Maison', 'Home');
  String get typeAdresseBureau => t('Bureau', 'Office');
  String get typeAdresseAppartement => t('Appartement', 'Apartment');
  String get typeAdresseAutre => t('Autre', 'Other');
  String get deconnexionConfirmation =>
      t('Êtes vous sûre de vouloir vous\ndéconnecter ?', 'Are you sure you want to\nsign out?');
  String get ouiMeDeconnecter => t('Oui, me déconnecter', 'Yes, sign me out');
  String get nonRetourEspace => t('Non, Retour dans Mon Espace', 'No, back to My Space');
  String get parIciLaSortie => t('Par ici la sortie', 'This way out');
  String get redirectionAutomatique => t(
        'Vous serez automatiquement redirigé vers l’écran d’accueil '
            'd’ici quelques secondes',
        'You will be automatically redirected to the home screen in a '
            'few seconds',
      );
  String get ceNestQuUnAuRevoir => t('Ce n’est qu’un au revoir !', 'See you soon!');
  String get historiqueTitre => t('Historique', 'History');
  String get aucuneDonneePoint => t('Aucune donnée.', 'No data.');
  String get aucunRetraitVerse =>
      t('Aucun retrait n’a encore été versé.', 'No withdrawal has been paid out yet.');
  String get effectuerTransaction => t('Effectuer une transaction', 'Make a transaction');
  String get demandeLabel => t('Demandé', 'Requested');
  String get retireLabel => t('Retiré', 'Withdrawn');
  String soldeMontant(String montant) => t('Solde $montant', 'Balance $montant');
  String get deconnecteEnSecurite => t(
        'Vous êtes maintenant déconnecté en toute sécurité. Prenez soin '
            'de vous, nous avons déjà hâte de vous retrouver !',
        'You are now safely signed out. Take care, we can’t wait to see '
            'you again!',
      );
  String get paiementChiffre => t(
        'Paiement chiffré. Votre pièce est réservée pendant 15 minutes.',
        'Encrypted payment. Your item is reserved for 15 minutes.',
      );
  String get transactionEchecGenerique => t(
        "L'opération n'a pas abouti. Aucun montant n'a été débité. "
            'Veuillez réessayer.',
        'The operation did not go through. No amount was charged. '
            'Please try again.',
      );

  // ─── Espace — sous-écrans ───────────────────────────────────────────────────
  String get espaceReglages => t('Réglages', 'Settings');
  String get espaceMoyensPaiement => t('Moyens de paiement', 'Payment methods');
  String get espaceIndisponibleTitre => t('Indisponible', 'Unavailable');
  String get espacePaiementIndisponible => t(
        'L’enregistrement d’un moyen de paiement n’est pas encore proposé '
            'par le serveur.',
        'Saving a payment method is not yet supported by the server.',
      );
  String get espaceAjouterMoyenPaiement =>
      t('+ Ajouter un moyen de paiement', '+ Add a payment method');
  String get espaceMesNotifications => t('Mes notifications', 'My notifications');
  String get espaceNotifsVideMessage => t(
        'Les nouveautés de vos maisons, le suivi de vos pièces et les '
            'confirmations de commande s’afficheront ici.',
        'New arrivals from your houses, item tracking and order '
            'confirmations will appear here.',
      );
  String get espaceRetourDressing => t('Retour au dressing', 'Back to wardrobe');
  String get espaceFaqTitre => t('FAQ & Aide', 'FAQ & Help');
  String get espaceFaqQ1 => t(
        'Comment se passe la livraison au Cameroun ?',
        'How does delivery work in Cameroon?',
      );
  String get espaceFaqA1 => t(
        'Nous livrons à domicile ou en point relais partenaire à Yaoundé '
            'et Douala sous 24h à 48h. Pour les autres villes, des '
            'expéditions sécurisées sont organisées par agence de voyage '
            'sous 72h.',
        'We deliver to your home or a partner pickup point in Yaoundé and '
            'Douala within 24 to 48 hours. For other cities, secure '
            'shipments are arranged via a travel agency within 72 hours.',
      );
  String get espaceFaqQ2 => t(
        'Les articles sont-ils authentiques ?',
        'Are the items authentic?',
      );
  String get espaceFaqA2 => t(
        'Absolument. Chaque pièce soumise par nos sourceurs passe par une '
            'double vérification physique par notre équipe d’experts avant '
            'd’être publiée en ligne.',
        'Absolutely. Every item submitted by our sourcers goes through a '
            'double physical check by our team of experts before being '
            'published online.',
      );
  String get espaceFaqQ3 => t(
        'Quelles sont les conditions de retour ?',
        'What are the return conditions?',
      );
  String get espaceFaqA3 => t(
        'S’agissant de pièces uniques de seconde main haut de gamme, les '
            'retours sont acceptés uniquement sous 24h après réception si '
            'l’article ne correspond pas aux photos ou à la description.',
        'As these are unique high-end secondhand items, returns are only '
            'accepted within 24 hours of receipt if the item does not '
            'match the photos or description.',
      );
  String get espaceFaqQ4 => t(
        'Comment devenir sourceur de pièces ?',
        'How do I become an item sourcer?',
      );
  String get espaceFaqA4 => t(
        'Rendez-vous dans la section « Espace Sourceur » de votre profil, '
            'renseignez les informations sur votre atelier et demandez à '
            'rejoindre le cercle des sourceurs certifiés.',
        'Go to the "Sourcer Space" section of your profile, fill in your '
            'workshop details and ask to join the circle of certified '
            'sourcers.',
      );
  String get espaceNousContacter => t('Nous contacter', 'Contact us');
  String get espaceConciergerieClient =>
      t('CONCIERGERIE CLIENT CLOSET', 'CLOSET CLIENT CONCIERGE');
  String get espaceWhatsappConciergerie =>
      t('WhatsApp Conciergerie', 'WhatsApp Concierge');
  String get espaceDiscuterWhatsapp => t('Discuter sur WhatsApp', 'Chat on WhatsApp');
  String get espaceAssistanceEmail => t('Assistance E-mail', 'Email Support');
  String get espaceEnvoyerEmail => t('Nous envoyer un e-mail', 'Send us an email');
  String get espaceDisponibilite =>
      t('DISPONIBLE 7J/7 · 9H00 À 19H00', 'AVAILABLE 7 DAYS A WEEK · 9AM TO 7PM');
  String get espaceConfidentialite => t('Confidentialité', 'Privacy');
  String get espaceProtectionDonnees =>
      t('PROTECTION DES DONNÉES CLOSET', 'CLOSET DATA PROTECTION');
  String get espacePolicy1Titre => t('1. Collecte des données', '1. Data collection');
  String get espacePolicy1Corps => t(
        'Dans le cadre de votre dressing privé, nous collectons des '
            'données de profil (nom, prénom, e-mail, historique d’achats '
            'et de favoris) dans le seul but de personnaliser vos '
            'sélections de mode seconde main de luxe.',
        'As part of your private wardrobe, we collect profile data (name, '
            'e-mail, purchase and wishlist history) solely to personalize '
            'your luxury secondhand fashion selections.',
      );
  String get espacePolicy2Titre =>
      t('2. Sécurité des transactions', '2. Transaction security');
  String get espacePolicy2Corps => t(
        'Toutes les transactions effectuées par Orange Money, MTN MoMo ou '
            'carte de crédit sont sécurisées et cryptées par nos '
            'prestataires certifiés. Nous ne stockons aucun mot de passe '
            'de paiement.',
        'All transactions made via Orange Money, MTN MoMo or credit card '
            'are secured and encrypted by our certified providers. We '
            'never store any payment passwords.',
      );
  String get espacePolicy3Titre => t('3. Partage d’informations', '3. Information sharing');
  String get espacePolicy3Corps => t(
        'Chez ClosET, nous respectons scrupuleusement la vie privée de '
            'notre clientèle. Vos choix stylistiques et préférences de '
            'recherche ne sont jamais revendus ni partagés avec des '
            'partenaires tiers.',
        'At ClosET, we scrupulously respect our customers’ privacy. Your '
            'style choices and search preferences are never sold or '
            'shared with third parties.',
      );
  String get espaceEvaluerTitre => t('Nous évaluer', 'Rate us');
  String get espacePartagezExperience =>
      t('PARTAGEZ VOTRE EXPÉRIENCE', 'SHARE YOUR EXPERIENCE');
  String get espaceNoteManquanteTitre => t('Note manquante', 'Missing rating');
  String get espaceSelectionnerEtoile =>
      t('Veuillez sélectionner au moins une étoile.', 'Please select at least one star.');
  String get espaceAvisNonTransmisTitre => t('Avis non transmis', 'Feedback not sent');
  String get espaceAvisNonTransmisCorps => t(
        'Le serveur n’expose pas encore de dépôt d’évaluation. Votre note '
            'n’a pas été envoyée.',
        'The server does not yet support submitting reviews. Your rating '
            'was not sent.',
      );
  String get espaceQuelleNote =>
      t('Quelle note attribuez-vous à l’application ?', 'What rating would you give the app?');
  String get espaceVotreCommentaire => t('VOTRE COMMENTAIRE', 'YOUR COMMENT');
  String get espaceCommentaireHint => t(
        'Aidez-nous à nous améliorer en écrivant un commentaire...',
        'Help us improve by writing a comment...',
      );
  String get espaceEnvoyerAvis => t('Envoyer mon avis', 'Send my feedback');

  // Les dates s'écrivent partout en JJ/MM/AAAA (voir core/utils/date_format) :
  // aucun nom de mois à traduire.
  String get monAtelierLabel => t('Mon atelier', 'My workshop');

  // ─── Sourceur — adhésion ────────────────────────────────────────────────────
  String get adhesionTitre => t('Mon adhésion', 'My membership');
  String get adhesionParcoursSurtitre =>
      t('Parcours de votre adhésion', 'Your membership journey');
  String get adhesionDepotOuverture =>
      t('Le dépôt s’ouvrira après validation', 'Submissions open once approved');
  String get adhesionGarantie => t(
        'C’est notre garantie de qualité : chaque partenaire est validé '
            'avant de confier ses pièces.',
        'This is our quality guarantee: every partner is approved before '
            'consigning items.',
      );
  String get adhesionVoirValidation => t('Voir ma validation', 'View my approval');
  String get retourAccueil => t('Retour à l’accueil', 'Back to home');
  String get adhesionAucuneTitre =>
      t('Aucune adhésion en cours', 'No membership in progress');
  String get adhesionAucuneCorps => t(
        'Déposez votre candidature pour rejoindre le cercle des sourceuses.',
        'Submit your application to join the circle of sourcers.',
      );
  String get adhesionStatutLabel =>
      t('Statut de votre adhésion', 'Your membership status');
  String get adhesionSoumiseTitre =>
      t('Votre fiche est entre nos mains', 'Your file is in our hands');
  String get adhesionSoumiseCorps => t(
        'Notre équipe étudie chaque adhésion avec soin — vous serez '
            'notifiée dès la validation.',
        'Our team carefully reviews every membership — you will be '
            'notified as soon as it is approved.',
      );
  String get adhesionValideeTitre => t('Bienvenue dans le cercle', 'Welcome to the circle');
  String get adhesionValideeCorps => t(
        'Votre adhésion est validée : votre espace de dépôt est ouvert.',
        'Your membership is approved: your consignment space is open.',
      );
  String get adhesionPremierePieceTitre => t('À vous de jouer', 'Your turn');
  String get adhesionPremierePieceCorps =>
      t('Confiez votre première pièce d’exception.', 'Consign your first exceptional item.');
  String get adhesionSoumiseLePrefix => t('Soumise le', 'Submitted on');
  String get adhesionBadgeFicheSoumise => t('Fiche soumise', 'Submission received');
  String get adhesionBadgeEnEtude => t('En cours d’étude', 'Under review');
  String get adhesionBadgeValidee => t('Adhésion validée', 'Membership approved');
  String get adhesionBadgeDepotOuvert => t('Dépôt ouvert', 'Submissions open');
  String get adhesionFrisePremierePiece =>
      t('Première pièce confiée', 'First item submitted');
  String get adhesionFriseAdminVerifie => t(
        'L’administratrice vérifie vos informations',
        'Our admin is verifying your information',
      );
  String get adhesionFriseEspaceOuvert =>
      t('Votre espace de dépôt est ouvert', 'Your consignment space is open');
  String get adhesionFriseEspaceOuverture =>
      t('Votre espace de dépôt s’ouvrira', 'Your consignment space will open');
  String get adhesionFrisePieceConfiee =>
      t('Votre première pièce nous est confiée', 'Your first item has been received');
  String get adhesionFriseDeposerPiece => t(
        'Vous pourrez déposer votre première pièce',
        'You will be able to submit your first item',
      );

  // ─── Onboarding — première utilisation ─────────────────────────────────────
  String get onboardingBienvenue => t('Bienvenue chez ClosET', 'Welcome to ClosET');
  String get onboardingSousTitre => t(
        'Découvrez comment fonctionne votre dressing privé, en quelques écrans.',
        'See how your private wardrobe works, in a few screens.',
      );
  String get onboardingVoirDemo => t('VOIR LA DÉMO', 'WATCH THE DEMO');
  String get onboardingPasser => t('Passer', 'Skip');

  // ─── Visite guidée (spotlight) ──────────────────────────────────────────────
  String get revoirVisiteGuidee =>
      t('Revoir la visite guidée', 'Replay the guided tour');
  String tourEtape(int courante, int total) =>
      t('Étape $courante sur $total', 'Step $courante of $total');
  String get tourPasser => t('PASSER', 'SKIP');
  String get tourSuivant => t('Suivant', 'Next');
  String get tourPrecedent => t('Précédent', 'Back');
  String get tourTerminer => t('Terminer', 'Done');

  // Noms d'écrans, en surtitre de l'infobulle.
  String get tourEcranDressing => t('MON DRESSING', 'MY WARDROBE');
  String get tourEcranNavigation => t('NAVIGATION', 'NAVIGATION');
  String get tourEcranCollections => t('COLLECTIONS', 'COLLECTIONS');
  String get tourEcranPiece => t('FICHE DE LA PIÈCE', 'ITEM PAGE');
  String get tourEcranFavoris => t('MES FAVORIS', 'MY FAVOURITES');
  String get tourEcranSelection => t('MA SÉLECTION', 'MY SELECTION');
  String get tourEcranLivraison => t('LIVRAISON', 'DELIVERY');
  String get tourEcranPaiement => t('PAIEMENT', 'PAYMENT');
  String get tourEcranEspace => t('MON ESPACE', 'MY SPACE');

  // ── Mon dressing ──
  String get tourPieceSemaineTitre =>
      t('La pièce de la semaine', 'Item of the week');
  String get tourPieceSemaineCorps => t(
        'Chaque semaine, une pièce est mise à l’honneur en haut de votre '
            'dressing : sa photo, sa catégorie et son prix d’un seul coup d’œil.',
        'Every week one piece takes the spotlight at the top of your '
            'wardrobe: its photo, category and price at a glance.',
      );
  String get tourDecouvrirTitre => t('Le bouton Découvrir', 'The Discover button');
  String get tourDecouvrirCorps => t(
        'Il ouvre la fiche complète de la pièce : toutes ses photos, sa '
            'matière, sa taille, son état et son histoire.',
        'It opens the full item page: every photo, the material, size, '
            'condition and story.',
      );
  String get tourGrilleTitre => t('Les nouveautés', 'New arrivals');
  String get tourGrilleCorps => t(
        'Sous la vitrine, les dernières pièces entrées au dressing. Le cœur '
            'posé sur chaque carte l’ajoute à vos favoris sans ouvrir la fiche.',
        'Below the showcase, the latest pieces to join the wardrobe. The '
            'heart on each card saves it to your favourites without opening it.',
      );
  String get tourSelectionTitre => t('Ma sélection', 'My selection');
  String get tourSelectionCorps => t(
        'Le raccourci vers les pièces mises de côté avant l’achat. Le chiffre '
            'indique combien de pièces vous attendent.',
        'The shortcut to the pieces set aside before purchase. The number '
            'shows how many are waiting for you.',
      );
  String get tourNotificationsTitre =>
      t('Vos notifications', 'Your notifications');
  String get tourNotificationsCorps => t(
        'Recevez une alerte dès qu’une pièce de vos maisons préférées entre au '
            'dressing, ou dès qu’une commande change d’étape.',
        'Get an alert as soon as a piece from your favourite houses joins the '
            'wardrobe, or when an order moves to its next step.',
      );

  // ── Barre de navigation ──
  String get tourNavDressingTitre => t('Onglet Dressing', 'Wardrobe tab');
  String get tourNavDressingCorps => t(
        'L’accueil : la pièce de la semaine et les nouveautés. C’est ici que '
            'l’on revient toujours.',
        'The home tab: item of the week and new arrivals. This is where you '
            'always come back to.',
      );
  String get tourNavCollectionsTitre => t('Onglet Collections', 'Collections tab');
  String get tourNavCollectionsCorps => t(
        'Tout le catalogue, avec la recherche et les filtres pour aller droit '
            'à ce que vous cherchez.',
        'The whole catalogue, with search and filters to go straight to what '
            'you are looking for.',
      );
  String get tourNavFavorisTitre => t('Onglet Favoris', 'Favourites tab');
  String get tourNavFavorisCorps => t(
        'Vos coups de cœur, gardés de côté pour y revenir plus tard sans les '
            'rechercher.',
        'The pieces you loved, kept aside so you can come back without '
            'searching again.',
      );
  String get tourNavSelectionTitre => t('Onglet Sélection', 'Selection tab');
  String get tourNavSelectionCorps => t(
        'Les pièces que vous vous apprêtez à commander, avec le montant total '
            'avant de finaliser.',
        'The pieces you are about to order, with the running total before you '
            'check out.',
      );
  String get tourNavEspaceTitre => t('Onglet Espace', 'Space tab');
  String get tourNavEspaceCorps => t(
        'Votre profil, vos commandes, vos adresses, la langue et le thème — et '
            'l’entrée du programme sourceur.',
        'Your profile, orders, addresses, language and theme — plus the way '
            'into the sourcer programme.',
      );

  // ── Collections ──
  String get tourRechercheTitre => t('La recherche', 'Search');
  String get tourRechercheCorps => t(
        'Tapez une maison, une matière ou un type de pièce : le catalogue se '
            'réduit à mesure que vous écrivez.',
        'Type a house, a material or a kind of piece: the catalogue narrows '
            'down as you type.',
      );
  String get tourUniversTitre => t('Les univers', 'Universes');
  String get tourUniversCorps => t(
        'Un raccourci par grande famille de pièces. « Toutes » remet le '
            'catalogue entier.',
        'One shortcut per family of pieces. "All" brings the whole catalogue '
            'back.',
      );
  String get tourFiltresTitre => t('Les filtres', 'Filters');
  String get tourFiltresCorps => t(
        'Affinez par univers, taille, état, maison et budget maximum. « Tout '
            'réinitialiser » efface les filtres d’un coup.',
        'Refine by universe, size, condition, house and maximum budget. '
            '"Reset all" clears every filter at once.',
      );

  // ── Fiche de la pièce ──
  String get tourCarrouselTitre => t('Les photos', 'The photos');
  String get tourCarrouselCorps => t(
        'Glissez horizontalement pour voir la pièce sous tous ses angles avant '
            'de vous décider.',
        'Swipe sideways to see the piece from every angle before making up '
            'your mind.',
      );
  String get tourProduitFavoriTitre => t('Mettre en favori', 'Save as favourite');
  String get tourProduitFavoriCorps => t(
        'Le cœur garde la pièce dans vos favoris. Rien n’est réservé : elle '
            'reste disponible pour les autres.',
        'The heart keeps the piece in your favourites. Nothing is reserved: it '
            'stays available to others.',
      );
  String get tourProduitAjoutTitre =>
      t('Ajouter à ma sélection', 'Add to my selection');
  String get tourProduitAjoutCorps => t(
        'La pièce rejoint votre sélection. Sa disponibilité est revérifiée à '
            'cet instant : une pièce déjà partie est refusée.',
        'The piece joins your selection. Its availability is checked again '
            'right then: a piece already gone is turned down.',
      );

  // ── Favoris et sélection ──
  String get tourFavorisAjoutTitre =>
      t('Des favoris à la sélection', 'From favourites to selection');
  String get tourFavorisAjoutCorps => t(
        'Depuis vos favoris, ce bouton fait passer la pièce directement en '
            'sélection, sans rouvrir sa fiche.',
        'Straight from your favourites, this button moves the piece into your '
            'selection without reopening its page.',
      );
  String get tourFinaliserTitre => t('Finaliser ma sélection', 'Check out');
  String get tourFinaliserCorps => t(
        'Le départ du tunnel de commande : livraison, puis paiement, puis '
            'confirmation.',
        'The start of the order flow: delivery, then payment, then '
            'confirmation.',
      );

  // ── Livraison ──
  String get tourLivraisonNomTitre => t('Vos coordonnées', 'Your details');
  String get tourLivraisonNomCorps => t(
        'Le nom qui recevra la commande. Il est prérempli avec celui du compte '
            'et reste modifiable.',
        'The name that will receive the order. It is prefilled from your '
            'account and stays editable.',
      );
  String get tourLivraisonTelTitre => t('Le téléphone WhatsApp', 'WhatsApp phone');
  String get tourLivraisonTelCorps => t(
        'Le numéro utilisé pour convenir de la remise. L’indicatif du pays se '
            'choisit à gauche du champ.',
        'The number used to arrange the handover. The country code is picked '
            'to the left of the field.',
      );
  String get tourLivraisonVilleTitre =>
      t('La ville de livraison', 'Delivery city');
  String get tourLivraisonVilleCorps => t(
        'Choisissez la ville : son délai annoncé et son tarif de livraison '
            's’affichent aussitôt sous le champ.',
        'Pick the city: its announced delay and delivery fee appear right '
            'below the field.',
      );
  String get tourLivraisonQuartierTitre => t('Le quartier', 'Neighbourhood');
  String get tourLivraisonQuartierCorps => t(
        'Dans la ville, précisez le quartier — c’est ce qui permet au livreur '
            'de vous trouver.',
        'Within the city, name the neighbourhood — that is what lets the '
            'courier find you.',
      );
  String get tourLivraisonDetailleeTitre =>
      t('Une adresse détaillée', 'A detailed address');
  String get tourLivraisonDetailleeCorps => t(
        'Hors des villes tarifées, ce lien ouvre la saisie région, puis '
            'département, puis arrondissement, puis quartier.',
        'Outside the priced cities, this link opens the region, then district, '
            'then borough, then neighbourhood fields.',
      );
  String get tourLivraisonSuivantTitre => t('Passer au paiement', 'On to payment');
  String get tourLivraisonSuivantCorps => t(
        'Les coordonnées sont vérifiées avant d’avancer : ville et quartier '
            'sont obligatoires.',
        'Your details are checked before moving on: city and neighbourhood are '
            'required.',
      );

  // ── Paiement ──
  String get tourMoyensTitre => t('Les moyens de paiement', 'Payment methods');
  String get tourMoyensCorps => t(
        'Orange Money, MTN Mobile Money ou carte Visa. Le moyen retenu déplie '
            'son formulaire : numéro mobile, ou porteur, numéro, expiration '
            'et CVV pour la carte.',
        'Orange Money, MTN Mobile Money or Visa card. The chosen method '
            'unfolds its form: mobile number, or cardholder, number, expiry '
            'and CVV for the card.',
      );
  String get tourCodeTitre => t('Le code privilège', 'Privilege code');
  String get tourCodeCorps => t(
        'Un code d’invitation se saisit ici. La remise est calculée par ClosET, '
            'pas par l’application.',
        'An invitation code goes here. The discount is worked out by ClosET, '
            'not by the app.',
      );
  String get tourRecapTitre => t('Le récapitulatif', 'The summary');
  String get tourRecapCorps => t(
        'Sous-total des pièces, remise éventuelle, frais de livraison et '
            'total — tout est visible avant de régler.',
        'Items subtotal, any discount, delivery fee and total — everything is '
            'visible before you pay.',
      );
  String get tourPayerTitre => t('Régler la commande', 'Pay for the order');
  String get tourPayerCorps => t(
        'Le montant total est rappelé sur le bouton. Vient ensuite l’écran de '
            'confirmation, puis le reçu.',
        'The total is repeated on the button. Then comes the confirmation '
            'screen, and finally the receipt.',
      );

  // ── Mon espace ──
  String get tourProfilTitre => t('Votre profil', 'Your profile');
  String get tourProfilCorps => t(
        'Votre nom et votre ancienneté. La pastille verte ouvre la '
            'modification du profil — ou la création du compte si vous êtes '
            'encore invitée.',
        'Your name and how long you have been a member. The green badge opens '
            'profile editing — or account creation if you are still a guest.',
      );
  String get tourCommandesTitre => t('Mes commandes', 'My orders');
  String get tourCommandesCorps => t(
        'L’historique de vos commandes, chacune avec son suivi étape par étape '
            'jusqu’à la remise.',
        'Your order history, each one with step-by-step tracking through to '
            'the handover.',
      );
  String get tourSourceurTitre =>
      t('Devenir sourceuse', 'Becoming a sourcer');
  String get tourSourceurCorps => t(
        'Confier vos propres pièces au dressing : cette carte ouvre le '
            'programme sourceur et son parcours d’adhésion.',
        'Entrust your own pieces to the wardrobe: this card opens the sourcer '
            'programme and its membership path.',
      );
  String get tourLangueTitre => t('Français ou anglais', 'French or English');
  String get tourLangueCorps => t(
        'Toute l’application change de langue, messages d’erreur compris. Le '
            'choix est retenu au prochain lancement.',
        'The whole app switches language, error messages included. Your choice '
            'is remembered next time you open it.',
      );
  String get tourRevoirTitre => t('Revoir cette visite', 'Replay this tour');
  String get tourRevoirCorps => t(
        'Cette entrée relance la visite quand vous voulez. Bonne découverte !',
        'This entry restarts the tour whenever you like. Enjoy exploring!',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Implémentation interne (instanciation hors-arbre)
// ─────────────────────────────────────────────────────────────────────────────

class _L10nInstance extends ClosetL10n {
  const _L10nInstance(Locale locale)
      : super(locale: locale, child: const SizedBox.shrink());
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider Riverpod — accès hors-widget (toasts, services)
// ─────────────────────────────────────────────────────────────────────────────

final l10nProvider = Provider<ClosetL10n>((ref) {
  final locale = ref.watch(localeProvider);
  return _L10nInstance(locale);
});
