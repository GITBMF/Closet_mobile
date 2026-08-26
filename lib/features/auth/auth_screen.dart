import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/validation/formats.dart';
import '../../../core/validation/indicateurs_pays.dart';
import '../../../core/widgets/aide_mot_de_passe.dart';
import '../../../core/widgets/champ_telephone.dart';
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

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final isLogin = ref.read(authModeProvider) == AuthMode.login;

    final erreurEmail = validerEmail(email);
    if (erreurEmail != null) {
      toastInfo(ref, 'E-mail invalide', erreurEmail);
      return;
    }
    final erreurMdp = validerMotDePasse(password, connexion: isLogin);
    if (erreurMdp != null) {
      toastInfo(ref, 'Mot de passe', erreurMdp);
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
          'Champs manquants',
          'Veuillez renseigner votre nom et prénom.',
        );
        return;
      }
      final nomComplet =
          '$firstName $lastName'.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (nomComplet.length < 2) {
        toastInfo(ref, 'Nom incomplet', 'Le nom doit contenir au moins 2 caractères.');
        return;
      }
      if (nomComplet.length > 150) {
        toastInfo(ref, 'Nom trop long', '150 caractères maximum.');
        return;
      }
      final erreurTel = validerTelephone(phone, obligatoire: true);
      if (erreurTel != null) {
        toastInfo(ref, 'Téléphone', erreurTel);
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
        await ref.read(sourceurRepositoryProvider).chargerProfil();
      } catch (_) {}

      if (!mounted) return;
      setState(() => _isLoading = false);
      await dialogueSucces(
        context,
        titre: isLogin ? 'Connexion réussie' : 'Compte créé',
        message: isLogin
            ? 'Bon retour, ${user.firstName} !'
            : 'Bienvenue, ${user.firstName} !',
      );
      if (!mounted) return;
      if (context.canPop()) {
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
          titre: isLogin ? 'Connexion impossible' : 'Inscription impossible',
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
                        ? 'Bienvenue dans votre dressing !'
                        : 'Rejoignez le cercle',
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
                          label: 'Prénom',
                          hint: 'Marie',
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          formatters: const [FormateurPrenom()],
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Veuillez renseigner votre prénom.'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.p16),
                        _ChampAuth(
                          label: 'Nom',
                          hint: 'DUPONT',
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.characters,
                          formatters: const [FormateurNom()],
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Veuillez renseigner votre nom.'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.p16),
                        ChampTelephone(
                          label: 'Téléphone',
                          controller: _phone,
                          hint: '6 90 12 34 56',
                          style: StyleChampTelephone.auth,
                          validerAvecLeFormulaire: false,
                          textInputAction: TextInputAction.next,
                          validator: _validerTelephone,
                        ),
                        const SizedBox(height: AppSpacing.p16),
                      ],
                      _ChampAuth(
                        label: 'Email',
                        hint: 'Example@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        sansEspaces: true,
                        validator: _validerEmail,
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      _ChampAuth(
                        label: 'Mot de passe',
                        hint: 'Au moins 8 caractères',
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: isLogin
                            ? _validerMotDePasseConnexion
                            : _validerMotDePasseInscription,
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
                          '8 caractères minimum, dont un chiffre.',
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
                        label: isLogin ? 'SE CONNECTER' : 'CRÉER MON COMPTE',
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
                              'Mot de passe oublié',
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
                            label: 'CONTINUER avec Google',
                            icone: const GoogleGIcon(taille: 18),
                            onPressed: () {
                              toastInfo(
                                ref,
                                'Indisponible',
                                'La connexion Google n’est pas proposée par le serveur pour le moment.',
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
                                  ? 'Pas encore membre ? '
                                  : 'Déjà membre ? ',
                              style: ClosetTextStyles.corps.copyWith(
                                color: ClosetColors.beige,
                              ),
                              children: [
                                TextSpan(
                                  text: isLogin
                                      ? 'Rejoindre le cercle'
                                      : 'Se connecter',
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
                                'Continuer en invitée',
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

  static String? _validerEmail(String? v) {
    final valeur = v?.trim() ?? '';
    if (valeur.isEmpty) return 'Veuillez renseigner votre email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(valeur)) {
      return 'Cet email semble incorrect.';
    }
    return null;
  }

  static String? _validerMotDePasseConnexion(String? v) {
    if ((v ?? '').isEmpty) return 'Veuillez renseigner votre mot de passe.';
    return null;
  }

  static String? _validerMotDePasseInscription(String? v) {
    final valeur = v ?? '';
    if (valeur.isEmpty) return 'Veuillez renseigner votre mot de passe.';
    if (valeur.length < 8) return '8 caractères minimum.';
    if (!RegExp(r'\d').hasMatch(valeur)) {
      return 'Ajoutez au moins un chiffre.';
    }
    return null;
  }

  static String? _validerTelephone(String? v) {
    final valeur = (v ?? '').replaceAll(RegExp(r'[\s.\-]'), '');
    if (valeur.isEmpty) return 'Veuillez renseigner votre numéro.';
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(valeur)) {
      return 'Ce numéro semble incorrect.';
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
            'Ou se connecter',
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
