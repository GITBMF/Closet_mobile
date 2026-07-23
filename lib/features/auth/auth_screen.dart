import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

// ─── Auth State ──────────────────────────────────────────────────────────────

/// true = l'utilisateur est connecté
final isAuthenticatedProvider = StateProvider<bool>((ref) => ref.watch(currentUserProvider) != null);

// ─── Auth Screen (Login / Register) ─────────────────────────────────────────

enum AuthMode { login, register }

final authModeProvider = StateProvider<AuthMode>((ref) => AuthMode.login);

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // used as First Name (Prénom)
  final _lastNameController = TextEditingController(); // used as Last Name (Nom)
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
      if (firstName.isEmpty || lastName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez renseigner votre nom et prénom.')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      ClosetUser user;
      if (isLogin) {
        user = await authRepo.logIn(email: email, password: password);
      } else {
        user = await authRepo.signUp(
          firstName: _nameController.text,
          lastName: _lastNameController.text,
          email: email,
          password: password,
        );
      }

      if (mounted) {
        ref.read(currentUserProvider.notifier).state = user;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isLogin ? 'Bon retour, ${user.firstName} !' : 'Inscription réussie !')),
        );
        context.go('/home');
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Hero Header ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  height: 260,
                  decoration: const BoxDecoration(
                    color: AppTheme.forestGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 80,
                        height: 80,
                        errorBuilder: (_, _, _) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                            border: Border.all(color: AppTheme.goldCloset, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              'C',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Clos ET',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'L\'ÉLÉGANCE DURABLE',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Mode Toggle ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.sandBeige,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ref.read(authModeProvider.notifier).state =
                                  AuthMode.login;
                              _animController
                                ..reset()
                                ..forward();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isLogin
                                    ? AppTheme.blackCloset
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Center(
                                child: Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isLogin
                                        ? Colors.white
                                        : AppTheme.greyText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ref.read(authModeProvider.notifier).state =
                                  AuthMode.register;
                              _animController
                                ..reset()
                                ..forward();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isLogin
                                    ? AppTheme.blackCloset
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Center(
                                child: Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: !isLogin
                                        ? Colors.white
                                        : AppTheme.greyText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Form ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    children: [
                      if (!isLogin) ...[
                        _AuthField(
                          controller: _nameController,
                          label: 'Votre prénom',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _AuthField(
                          controller: _lastNameController,
                          label: 'Votre nom',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                      ],
                      _AuthField(
                        controller: _emailController,
                        label: 'Adresse e-mail',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _AuthField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffix: GestureDetector(
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ),

                      if (isLogin) ...[
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.forestGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _isLoading ? null : _submit,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppTheme.forestGreen.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isLogin
                                          ? 'Accéder à mon dressing'
                                          : 'Créer mon dressing privé',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      const Row(
                        children: [
                          Expanded(
                              child: Divider(color: AppTheme.sandBeige)),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ou continuer sans compte',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.greyText,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: AppTheme.sandBeige)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Guest CTA
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppTheme.sandBeige),
                            ),
                            child: const Center(
                              child: Text(
                                'Poursuivre ma visite',
                                style: TextStyle(
                                  color: AppTheme.greyText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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

// ── Auth Field ───────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.warmCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.sandBeige),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.blackCloset,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            fontSize: 14,
            color: AppTheme.greyText.withValues(alpha: 0.8),
          ),
          prefixIcon: Icon(icon, size: 18, color: AppTheme.greyText),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: suffix,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
