import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

// ─── Auth State ──────────────────────────────────────────────────────────────

/// true = l'utilisateur est connecté
final isAuthenticatedProvider =
    StateProvider<bool>((ref) => ref.watch(currentUserProvider) != null);

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Prénom
  final _lastNameController = TextEditingController(); // Nom
  final _phoneController = TextEditingController();
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
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final isLogin = ref.read(authModeProvider) == AuthMode.login;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    if (!isLogin) {
      final firstName = _nameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();
      if (firstName.isEmpty || lastName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez renseigner votre nom et prénom.'),
          ),
        );
        return;
      }
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez renseigner votre numéro de téléphone.'),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      ClosetUser? user;
      if (isLogin) {
        user = await authRepo.logIn(email: email, password: password);
      } else {
        await authRepo.signUp(
          firstName: _nameController.text,
          lastName: _lastNameController.text,
          email: email,
          password: password,
          phone: _phoneController.text,
        );
      }

      if (mounted) {
        if (isLogin && user != null) {
          ref.read(currentUserProvider.notifier).state = user;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bon retour, ${user.firstName} !')),
          );
          context.go('/home');
        } else {
          ref.read(authModeProvider.notifier).state = AuthMode.login;
          _passwordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie ! Veuillez vous connecter.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isLogin) ...[
                        _ChampAuth(
                          label: 'Prénom',
                          hint: 'Aïcha',
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.p16),
                        _ChampAuth(
                          label: 'Nom',
                          hint: 'N.',
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.p16),
                        _ChampAuth(
                          label: 'Téléphone',
                          hint: '+237 6 00 00 00 00',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.p16),
                      ],
                      _ChampAuth(
                        label: 'Email',
                        hint: 'Example@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      _ChampAuth(
                        label: 'Mot de passe',
                        hint: 'Au moins 8 caractères',
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
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
                      Text(
                        '8 caractères minimum, dont un chiffre.',
                        style: ClosetTextStyles.meta.copyWith(
                          fontWeight: FontWeight.w300,
                          color: ClosetColors.beige,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      _BoutonDore(
                        label: isLogin ? 'ENTRER' : 'CRÉER MON COMPTE',
                        enCours: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                      const SizedBox(height: AppSpacing.p20),
                      if (isLogin)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Un lien de réinitialisation vous sera envoyé.',
                                  ),
                                ),
                              );
                            },
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
                            icone: Icons.g_mobiledata_rounded,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Connexion Google bientôt disponible.',
                                  ),
                                ),
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
              ],
            ),
          ),
        ),
      ),
    );
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
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

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
        SizedBox(
          height: 42,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            style: ClosetTextStyles.saisie.copyWith(color: ClosetColors.noir),
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
            ),
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
  final IconData? icone;

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
                        Icon(icone, size: 20, color: ClosetColors.neutre900),
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
