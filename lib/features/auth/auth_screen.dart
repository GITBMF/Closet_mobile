import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/validation/formats.dart';
import '../../../core/validation/indicateurs_pays.dart';
import '../../../core/widgets/aide_mot_de_passe.dart';
import '../../../core/widgets/champ_telephone.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/google_g_icon.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';
import 'mot_de_passe_oublie_dialog.dart';

// ─── Auth State ──────────────────────────────────────────────────────────────

/// true = une session [currentUserProvider] est ouverte.
///
/// Dérivé du user, pas un StateProvider : après login / logout le routeur
/// et l'espace doivent voir le même état, sinon SE CONNECTER « réussit »
/// puis toutes les actions protégées restent mortes.
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider) != null,
);

/// Si la session est ouverte, continue. Sinon affiche la demande de connexion.
Future<bool> exigerConnexion(
  BuildContext context,
  WidgetRef ref, {
  String? message,
}) async {
  if (ref.read(isAuthenticatedProvider)) return true;
  final aller = await ClosetDialogue.connexionRequise(
    context,
    message: message,
  );
  if (aller && context.mounted) {
    await context.push('/auth');
  }
  return false;
}

// ─── Auth Screen (Login / Register) ─────────────────────────────────────────

enum AuthMode { login, register }

final authModeProvider = StateProvider<AuthMode>((ref) => AuthMode.login);

/// Connexion / Inscription — transcription de la maquette Figma `5:1304`.
///
/// Fond vert profond, carte photo de 352 × 210 (rayon 19) coiffée du logo,
/// titre EB Garamond, champs bleutés à bordure `#D4D7E3`, CTA doré de 44,
/// séparateur « Ou se connecter » puis connexion Google.
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Prénom
  final _lastNameController = TextEditingController(); // Nom
  final _phone = TelephoneController();
  bool _obscurePassword = true;
  bool _isLoading = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _phone.dispose();
    _animController.dispose();
    super.dispose();
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
      final erreurTel = validerTelephone(phone, obligatoire: true);
      if (erreurTel != null) {
        toastInfo(ref, l10n.telephone, erreurTel);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = isLogin
          ? await authRepo.logIn(email: email, password: password)
          : await authRepo.signUp(
              firstName: firstName,
              lastName: lastName,
              email: email,
              password: password,
              phone: phone,
            );

      try {
        await ref
            .read(sourceurRepositoryProvider)
            .chargerProfil(compte: user);
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

    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeroLogo(),
                const SizedBox(height: 39),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isLogin) ...[
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
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? l10n.renseignerNom
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.p16),
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
                      ],
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
                        validator: isLogin
                            ? (v) => _validerMotDePasseConnexion(v, l10n)
                            : (v) => _validerMotDePasseInscription(v, l10n),
                        suffix: IconButton(
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
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p8),
                      if (isLogin)
                        Text(
                          l10n.hintMdpRegle,
                          style: ClosetTextStyles.meta.copyWith(
                            fontWeight: FontWeight.w300,
                            color: ClosetColors.beige,
                          ),
                        )
                      else
                        ListenableBuilder(
                          listenable: _passwordController,
                          builder: (_, _) => AideMotDePasse(
                            saisie: _passwordController.text,
                            surFondSombre: true,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.p24),
                      _BoutonDore(
                        label: isLogin ? l10n.boutonSeConnecter : l10n.boutonCreerCompte,
                        enCours: _isLoading,
                        onPressed: _isLoading ? null : _submit,
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
                      const SizedBox(height: AppSpacing.p8),
                      const _SeparateurOu(),
                      const SizedBox(height: AppSpacing.p20),
                      Center(
                        child: SizedBox(
                          width: 312,
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
                      const SizedBox(height: AppSpacing.p24),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              ref.read(authModeProvider.notifier).state =
                                  isLogin ? AuthMode.register : AuthMode.login,
                          child: Text.rich(
                            TextSpan(
                              text: isLogin
                                  ? l10n.pasEncoreMembre
                                  : l10n.dejaMembre,
                              style: ClosetTextStyles.corps.copyWith(
                                color: ClosetColors.beige,
                              ),
                              children: [
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
class _HeroLogo extends StatelessWidget {
  const _HeroLogo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
      child: SizedBox(
        height: 210,
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
            Image.asset(
              'assets/logo_fond_vert.png',
              width: 148,
              height: 84,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(width: 148, height: 84),
            ),
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

/// Filet — texte — filet, comme dans la maquette.
class _SeparateurOu extends StatelessWidget {
  const _SeparateurOu();

  @override
  Widget build(BuildContext context) {
    const filet = Expanded(
      child: Divider(
        color: ClosetColors.filetSeparateur,
        thickness: AppStroke.fin,
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
