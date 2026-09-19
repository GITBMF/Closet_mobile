import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_layout.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/validation/formats.dart';
import '../../../core/validation/indicateurs_pays.dart';
import '../../../core/widgets/aide_mot_de_passe.dart';
import '../../../core/widgets/champ_telephone.dart';
import '../../../core/widgets/closet_filet.dart';
import '../../../core/widgets/google_g_icon.dart';
import '../../../core/widgets/logo_closet.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';
import 'mfa_dialog.dart';
import 'mot_de_passe_oublie_dialog.dart';
import 'verify_email_dialog.dart';

// ─── Auth State ──────────────────────────────────────────────────────────────

/// true = une session [currentUserProvider] est ouverte.
///
/// Dérivé du user, pas un StateProvider : après login / logout le routeur
/// et l'espace doivent voir le même état, sinon SE CONNECTER « réussit »
/// puis toutes les actions protégées restent mortes.
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider) != null,
);

enum AuthMode { login, register }

final authModeProvider = StateProvider<AuthMode>((ref) => AuthMode.login);

/// Si la session est ouverte, continue. Sinon ouvre l’inscription.
Future<bool> exigerConnexion(
  BuildContext context,
  WidgetRef ref, {
  String? message,
}) async {
  if (ref.read(isAuthenticatedProvider)) return true;
  allerCreerCompte(context, ref);
  return false;
}

void allerCreerCompte(BuildContext context, WidgetRef ref) {
  ref.read(authModeProvider.notifier).state = AuthMode.register;
  context.push('/auth');
}

// ─── Auth Screen (Login / Register) ─────────────────────────────────────────

/// Connexion / Inscription — transcription de la maquette Figma `5:1304`.
///
/// Fond vert profond, carte photo de 352 × 210 (rayon 19) coiffée du logo,
/// titre EB Garamond, champs bleutés à bordure `#D4D7E3`, CTA doré de 44,
/// séparateur « Ou se connecter » puis connexion Google.
///
/// L'inscription se déroule en 3 étapes (Identité, Contact, Sécurité) pour
/// alléger chaque écran — la connexion reste un formulaire unique.
///
/// Note : la maquette porte deux textes en bleu nuit (`#0C1421`, `#122B31`)
/// posés sur le fond vert — donc invisibles. Ce sont des restes de gabarit ;
/// ils sont rendus ici en crème pour rester lisibles.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Prénom
  final _lastNameController = TextEditingController(); // Nom
  final _phone = TelephoneController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _etape = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _phone.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Champs minimalement renseignés pour l'étape courante — ouvre le CTA
  /// « Continuer », la validation fine reste faite par les champs eux-mêmes.
  bool get _etapeValide {
    switch (_etape) {
      case 0:
        return _nameController.text.trim().isNotEmpty &&
            _lastNameController.text.trim().isNotEmpty;
      case 1:
        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                .hasMatch(_emailController.text.trim()) &&
            _phone.estValide;
      default:
        return _passwordController.text.length >= 8 &&
            RegExp(r'\d').hasMatch(_passwordController.text);
    }
  }

  void _changerEtape(int delta) {
    setState(() => _etape = (_etape + delta).clamp(0, 2));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _basculerMode(bool versLogin) {
    ref.read(authModeProvider.notifier).state =
        versLogin ? AuthMode.login : AuthMode.register;
    setState(() => _etape = 0);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = ClosetL10n.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final isLogin = ref.read(authModeProvider) == AuthMode.login;

    final erreurEmail = validerEmail(email, l10n: l10n);
    if (erreurEmail != null) {
      toastInfo(ref, l10n.emailInvalideTitre, erreurEmail);
      return;
    }
    final erreurMdp = validerMotDePasse(password, connexion: isLogin, l10n: l10n);
    if (erreurMdp != null) {
      toastInfo(ref, l10n.motDePasse, erreurMdp);
      return;
    }

    var firstName = '';
    var lastName = '';
    var phone = '';
    if (!isLogin) {
      firstName = _nameController.text.trim();
      lastName = _lastNameController.text.trim();
      phone = _phone.e164;
      if (firstName.isEmpty || lastName.isEmpty) {
        toastInfo(
          ref,
          l10n.champsManquants,
          l10n.renseignerNomPrenom,
        );
        return;
      }
      final nomComplet =
          '$firstName $lastName'.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (nomComplet.length < 2) {
        toastInfo(ref, l10n.nomIncomplet, l10n.nomMinCaracteres);
        return;
      }
      if (nomComplet.length > 150) {
        toastInfo(ref, l10n.nomTropLong, l10n.max150);
        return;
      }
      final erreurTel = validerTelephone(phone, obligatoire: true, l10n: l10n);
      if (erreurTel != null) {
        toastInfo(ref, l10n.telephone, erreurTel);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      late final ClosetUser user;
      try {
        user = isLogin
            ? await authRepo.logIn(email: email, password: password, l10n: l10n)
            : await authRepo.signUp(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password,
                phone: phone,
                l10n: l10n,
              );
      } on EmailAVerifier catch (defi) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        final ok = await afficherDialogueVerificationEmail(
          context,
          email: defi.email,
        );
        if (ok != true || !mounted) return;
        setState(() => _isLoading = true);
        try {
          user = await authRepo.logIn(email: email, password: password, l10n: l10n);
        } on MfaRequise catch (mfa) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          final viaMfa = await afficherDialogueMfa(context, mfa);
          if (viaMfa == null || !mounted) return;
          user = viaMfa;
        }
      } on MfaRequise catch (defi) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        final viaMfa = await afficherDialogueMfa(context, defi);
        if (viaMfa == null || !mounted) return;
        user = viaMfa;
      }

      try {
        await ref
            .read(sourceurRepositoryProvider)
            .chargerProfil(compte: user, l10n: l10n);
      } catch (_) {}

      if (!mounted) return;
      setState(() => _isLoading = false);
      await dialogueSucces(
        context,
        titre: isLogin ? l10n.connexionReussie : l10n.compteCree,
        message: isLogin
            ? l10n.bonRetour(user.firstName)
            : l10n.bienvenuePrenom(user.firstName),
      );
      if (!mounted) return;
      if (user.estSourceur) {
        context.go('/sourceur/espace');
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        await dialogueErreur(
          context,
          e,
          titre: isLogin ? l10n.connexionImpossible : l10n.inscriptionImpossible,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(authModeProvider);
    final isLogin = mode == AuthMode.login;
    final l10n = ClosetL10n.of(context);
    final layout = ClosetLayout.of(context);
    final marge = layout.gouttiere;

    return PopScope(
      canPop: isLogin || _etape == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _changerEtape(-1);
      },
      child: Scaffold(
        backgroundColor: ClosetColors.vert,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.p24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroLogo(hauteur: layout.compact ? 170 : 210, marge: marge),
                      const SizedBox(height: 39),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: marge),
                        child: Text(
                          isLogin
                              ? l10n.authTitreConnexion
                              : l10n.authTitreInscription,
                          style: ClosetTextStyles.titreEcran.copyWith(
                            letterSpacing: 0.44,
                            color: ClosetColors.neutre200,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      if (!isLogin) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: marge + 8),
                          child: _EtapesInscription(
                            etape: _etape,
                            labels: [
                              l10n.etapeIdentite,
                              l10n.etapeContact,
                              l10n.etapeSecurite,
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p24),
                      ],
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: marge),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isLogin)
                                ..._buildChampsConnexion(l10n)
                              else
                                ...switch (_etape) {
                                  0 => _buildEtapeIdentite(l10n),
                                  1 => _buildEtapeContact(l10n),
                                  _ => _buildEtapeSecurite(l10n),
                                },
                              const SizedBox(height: AppSpacing.p24),
                              ListenableBuilder(
                                listenable: Listenable.merge([
                                  _nameController,
                                  _lastNameController,
                                  _phone,
                                  _emailController,
                                  _passwordController,
                                ]),
                                builder: (_, _) => isLogin
                                    ? _BoutonDore(
                                        label: l10n.boutonSeConnecter,
                                        enCours: _isLoading,
                                        onPressed:
                                            _isLoading ? null : _submit,
                                      )
                                    : _buildBoutonsEtape(l10n),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p20),
                      if (isLogin)
                        Center(
                          child: TextButton(
                            onPressed: () => afficherMotDePasseOublie(
                              context,
                              emailInitial: _emailController.text,
                            ),
                            child: Text(
                              l10n.motDePasseOublie,
                              style: ClosetTextStyles.corps.copyWith(
                                color: ClosetColors.beige,
                              ),
                            ),
                          ),
                        ),
                      if (isLogin || _etape == 0) ...[
                        const SizedBox(height: AppSpacing.p8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: marge),
                          child: const _SeparateurOu(),
                        ),
                        const SizedBox(height: AppSpacing.p20),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: marge),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 312),
                              child: SizedBox(
                                width: double.infinity,
                                child: _BoutonDore(
                                  label: l10n.continuerGoogle,
                                  icone: const GoogleGIcon(taille: 18),
                                  onPressed: () {
                                    toastInfo(
                                      ref,
                                      l10n.googleIndisponibleTitre,
                                      l10n.googleIndisponible,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p24),
                        Center(
                          child: TextButton(
                            onPressed: () => _basculerMode(!isLogin),
                            child: Text.rich(
                              TextSpan(
                                text: isLogin
                                    ? l10n.pasEncoreMembre
                                    : l10n.dejaMembre,
                                style: ClosetTextStyles.corps.copyWith(
                                  color: ClosetColors.beige,
                                ),
                                children: [
                                  const TextSpan(text: ' '),
                                  TextSpan(
                                    text: isLogin
                                        ? l10n.rejoindreLeCercle
                                        : l10n.seConnecter,
                                    style: ClosetTextStyles.corps.copyWith(
                                      color: ClosetColors.fond300,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/home'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.continuerInvitee,
                                  style: ClosetTextStyles.detail.copyWith(
                                    color: ClosetColors.fond400,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 12,
                                  color: ClosetColors.fond400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChampsConnexion(ClosetL10n l10n) => [
        _ChampAuth(
          label: l10n.email,
          hint: 'Example@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          sansEspaces: true,
          validator: (v) => _validerEmail(v, l10n),
        ),
        const SizedBox(height: AppSpacing.p16),
        _ChampAuth(
          label: l10n.motDePasse,
          hint: l10n.hintMotDePasse,
          controller: _passwordController,
          obscure: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          validator: (v) => _validerMotDePasseConnexion(v, l10n),
          suffix: _suffixVisibilite(),
        ),
        const SizedBox(height: AppSpacing.p8),
        Text(
          l10n.hintMdpRegle,
          style: ClosetTextStyles.meta.copyWith(
            fontWeight: FontWeight.w300,
            color: ClosetColors.beige,
          ),
        ),
      ];

  List<Widget> _buildEtapeIdentite(ClosetL10n l10n) => [
        _ChampAuth(
          label: l10n.prenom,
          hint: 'Marie',
          controller: _nameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          formatters: const [FormateurPrenom()],
          validator: (v) => (v == null || v.trim().isEmpty)
              ? l10n.renseignerPrenom
              : null,
        ),
        const SizedBox(height: AppSpacing.p16),
        _ChampAuth(
          label: l10n.nom,
          hint: 'DUPONT',
          controller: _lastNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          formatters: const [FormateurNom()],
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.renseignerNom : null,
        ),
      ];

  List<Widget> _buildEtapeContact(ClosetL10n l10n) => [
        ChampTelephone(
          label: l10n.telephone,
          controller: _phone,
          hint: '6 90 12 34 56',
          style: StyleChampTelephone.auth,
          validerAvecLeFormulaire: false,
          textInputAction: TextInputAction.next,
          validator: (v) => _validerTelephone(v, l10n),
        ),
        const SizedBox(height: AppSpacing.p16),
        _ChampAuth(
          label: l10n.email,
          hint: 'Example@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          sansEspaces: true,
          validator: (v) => _validerEmail(v, l10n),
        ),
      ];

  List<Widget> _buildEtapeSecurite(ClosetL10n l10n) => [
        _ChampAuth(
          label: l10n.motDePasse,
          hint: l10n.hintMotDePasse,
          controller: _passwordController,
          obscure: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          validator: (v) => _validerMotDePasseInscription(v, l10n),
          suffix: _suffixVisibilite(),
        ),
        const SizedBox(height: AppSpacing.p8),
        ListenableBuilder(
          listenable: _passwordController,
          builder: (_, _) => AideMotDePasse(
            saisie: _passwordController.text,
            surFondSombre: true,
          ),
        ),
      ];

  Widget _suffixVisibilite() => IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 18,
          color: ClosetColors.champPlaceholder,
        ),
        onPressed: () => setState(
          () => _obscurePassword = !_obscurePassword,
        ),
      );

  Widget _buildBoutonsEtape(ClosetL10n l10n) {
    final derniereEtape = _etape == 2;
    final bouton = _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: ClosetColors.fond300),
          )
        : _BoutonDore(
            label: derniereEtape ? l10n.boutonCreerCompte : l10n.continuer,
            onPressed: !_etapeValide
                ? null
                : (derniereEtape ? _submit : () => _changerEtape(1)),
          );

    if (_etape == 0) return bouton;
    return Row(
      children: [
        Expanded(
          child: _BoutonContourClair(
            label: l10n.retour,
            onPressed: () => _changerEtape(-1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: bouton),
      ],
    );
  }

  static String? _validerEmail(String? v, ClosetL10n l10n) {
    final valeur = v?.trim() ?? '';
    if (valeur.isEmpty) return l10n.renseignerEmail;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valeur)) {
      return l10n.emailIncorrect;
    }
    return null;
  }

  static String? _validerMotDePasseConnexion(String? v, ClosetL10n l10n) {
    if ((v ?? '').isEmpty) return l10n.renseignerMdp;
    return null;
  }

  static String? _validerMotDePasseInscription(String? v, ClosetL10n l10n) {
    final valeur = v ?? '';
    if (valeur.isEmpty) return l10n.renseignerMdp;
    if (valeur.length < 8) return l10n.min8Caracteres;
    if (!RegExp(r'\d').hasMatch(valeur)) {
      return l10n.ajouterChiffre;
    }
    return null;
  }

  static String? _validerTelephone(String? v, ClosetL10n l10n) {
    final valeur = (v ?? '').replaceAll(RegExp(r'[\s.\-]'), '');
    if (valeur.isEmpty) return l10n.renseignerNumero;
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(valeur)) {
      return l10n.numeroIncorrect;
    }
    return null;
  }
}

/// Carte photo de 352 × 210 (rayon 19) surmontée de la plaque au logo.
///
/// Hauteur et gouttière passées par l'écran hôte pour s'adapter à la
/// largeur/hauteur réelles de l'appareil (petit Android, iPhone SE…).
class _HeroLogo extends StatelessWidget {
  const _HeroLogo({required this.hauteur, required this.marge});

  final double hauteur;
  final double marge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: marge),
      child: SizedBox(
        height: hauteur,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: SizedBox.expand(
                child: Image.asset(
                  'assets/onboarding_1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: ClosetColors.emeraude400),
                ),
              ),
            ),
            const LogoCloset.auth(),
          ],
        ),
      ),
    );
  }
}

/// Champ de l'écran de connexion : libellé doré au-dessus, zone bleutée
/// bordée `#D4D7E3` de 42 de haut, rayon 8.
class _ChampAuth extends StatelessWidget {
  const _ChampAuth({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
    this.autocorrect = true,
    this.sansEspaces = false,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.formatters = const [],
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final bool autocorrect;
  final bool sansEspaces;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> formatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ClosetTextStyles.labelChamp.copyWith(
            color: ClosetColors.fond300,
          ),
        ),
        const SizedBox(height: AppSpacing.p8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          autocorrect: autocorrect,
          enableSuggestions: autocorrect,
          textCapitalization: textCapitalization,
          validator: validator,
          inputFormatters: [
            if (sansEspaces) FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ...formatters,
          ],
          style: ClosetTextStyles.saisie.copyWith(color: context.closetEncre),
          cursorColor: ClosetColors.vert,
          cursorWidth: 1.5,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ClosetTextStyles.saisie.copyWith(
              color: ClosetColors.champPlaceholder,
            ),
            filled: true,
            fillColor: ClosetColors.champFond,
            isDense: true,
            errorStyle: ClosetTextStyles.meta.copyWith(
              color: ClosetColors.fond300,
            ),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p12,
              vertical: AppSpacing.p12,
            ),
            border: _bordure(ClosetColors.champBordure),
            enabledBorder: _bordure(ClosetColors.champBordure),
            focusedBorder: _bordure(ClosetColors.fond300),
            errorBorder: _bordure(ClosetColors.fond300),
            focusedErrorBorder: _bordure(ClosetColors.fond300),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _bordure(Color couleur) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.carte),
        borderSide: BorderSide(color: couleur, width: AppStroke.fin),
      );
}

/// CTA doré de la maquette : 44 de haut, rayon 100, fond `#CDAB71`.
class _BoutonDore extends StatelessWidget {
  const _BoutonDore({
    required this.label,
    this.onPressed,
    this.enCours = false,
    this.icone,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enCours;
  final Widget? icone;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(AppRadius.cercle);
    return SizedBox(
      height: 44,
      child: Material(
        color: onPressed == null
            ? ClosetColors.doreDesactive
            : ClosetColors.fond300,
        borderRadius: rayon,
        child: InkWell(
          borderRadius: rayon,
          onTap: onPressed,
          child: Center(
            child: enCours
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ClosetColors.neutre900,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icone != null) ...[
                        icone!,
                        const SizedBox(width: 10),
                      ],
                      Text(
                        label,
                        style: ClosetTextStyles.bouton.copyWith(
                          color: ClosetColors.neutre900,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Bouton « Retour » — contour doré, transparent, même gabarit que
/// [_BoutonDore] pour s'aligner dans la même rangée.
class _BoutonContourClair extends StatelessWidget {
  const _BoutonContourClair({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final rayon = BorderRadius.circular(AppRadius.cercle);
    return SizedBox(
      height: 44,
      child: Material(
        color: Colors.transparent,
        borderRadius: rayon,
        child: InkWell(
          borderRadius: rayon,
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: rayon,
              border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
            ),
            child: Center(
              child: Text(
                label,
                style: ClosetTextStyles.bouton.copyWith(
                  color: ClosetColors.fond300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filet — texte — filet, comme dans la maquette.
class _SeparateurOu extends StatelessWidget {
  const _SeparateurOu();

  @override
  Widget build(BuildContext context) {
    const filet = Expanded(
      child: ClosetFilet(
        couleur: ClosetColors.filetSeparateur,
        hauteur: 1,
      ),
    );
    return Row(
      children: [
        filet,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
          child: Text(
            ClosetL10n.of(context).ouSeConnecter,
            style: ClosetTextStyles.corps.copyWith(
              color: ClosetColors.fond300,
            ),
          ),
        ),
        filet,
      ],
    );
  }
}

/// Indicateur des 3 étapes de l'inscription (Identité, Contact, Sécurité),
/// habillé pour le fond vert profond de l'écran — contrairement au
/// [StepIndicator] du parcours sourceur, pensé pour une carte claire.
class _EtapesInscription extends StatelessWidget {
  const _EtapesInscription({required this.etape, required this.labels});

  /// Index (base 0) de l'étape courante.
  final int etape;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final enfants = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      enfants.add(_EtapeInscriptionItem(
        numero: i + 1,
        label: labels[i],
        etat: i == etape
            ? _EtatEtapeAuth.courante
            : i < etape
                ? _EtatEtapeAuth.validee
                : _EtatEtapeAuth.aVenir,
      ));
      if (i < labels.length - 1) {
        enfants.add(Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 20, left: 6, right: 6),
            color: i < etape
                ? ClosetColors.fond300
                : ClosetColors.beige.withValues(alpha: 0.25),
          ),
        ));
      }
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: enfants);
  }
}

enum _EtatEtapeAuth { validee, courante, aVenir }

class _EtapeInscriptionItem extends StatelessWidget {
  const _EtapeInscriptionItem({
    required this.numero,
    required this.label,
    required this.etat,
  });

  final int numero;
  final String label;
  final _EtatEtapeAuth etat;

  @override
  Widget build(BuildContext context) {
    final (fond, texte, bordure) = switch (etat) {
      _EtatEtapeAuth.courante || _EtatEtapeAuth.validee => (
          ClosetColors.fond300,
          ClosetColors.neutre900,
          ClosetColors.fond300,
        ),
      _EtatEtapeAuth.aVenir => (
          Colors.transparent,
          ClosetColors.beige,
          ClosetColors.beige.withValues(alpha: 0.4),
        ),
    };
    final taille = etat == _EtatEtapeAuth.courante ? 32.0 : 28.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: taille,
          height: taille,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fond,
            shape: BoxShape.circle,
            border: Border.all(color: bordure, width: AppStroke.fin),
          ),
          child: etat == _EtatEtapeAuth.validee
              ? Icon(Icons.check, size: 15, color: texte)
              : Text(
                  '$numero',
                  style: ClosetTextStyles.numeroEtape.copyWith(color: texte),
                ),
        ),
        const SizedBox(height: 6),
        Text(label, style: ClosetTextStyles.labelEtape.copyWith(color: texte)),
      ],
    );
  }
}
