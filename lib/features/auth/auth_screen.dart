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
          const SnackBar(content: Text('Veuillez renseigner votre nom et prénom.')),
        );
        return;
      }
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez renseigner votre numéro de téléphone.')),
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
      backgroundColor: const Color(0xFF143B33),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: const Color(0xFF5EA38E), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/landing_image.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppTheme.forestGreen,
                              ),
                            ),
                            Center(
                              child: Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF103A2D).withValues(alpha: 0.72),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'CLOS ET',
                                    style: TextStyle(
                                      fontFamily: 'Boldonse',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFF4E9DB),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Bienvenue dans votre dressing !',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'EB Garamond',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEFE6D7),
                        height: 1.2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDE4D5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AuthField(
                      controller: _emailController,
                      hintText: 'Example@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDE4D5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AuthField(
                      controller: _passwordController,
                      hintText: 'At least 8 characters',
                      obscureText: _obscurePassword,
                      suffix: GestureDetector(
                        onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: const Color(0xFFE8E1D5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '8 caractères minimum, dont un chiffre.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDFD3C5),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDAB71),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
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
                                      color: Color(0xFF143B33),
                                    ),
                                  )
                                : const Text(
                                    'ENTER',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF123C32),
                                      letterSpacing: 1,
                                    
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Mot de passe oublié',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEDE4D5),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFEDE4D5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFF7FB0A0))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Ou se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFCDAB71),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFF7FB0A0))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFC29D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                              child: Text(
                                'G -',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF353025),
                                ),
                              ),
                          ),
                          // const SizedBox(width: 10),
                          const Text(
                            'CONTINUER AVEC GOOGLE',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF123C32),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'Pas encore membre ? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEDE4D5),
                          ),
                          children: [
                            TextSpan(
                              text: 'Rejoindre le cercle',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFFEDE4D5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'Continuer en invité →',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB58A40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
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
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1EBE1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB8B0A0), width: 1.2),
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
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7A6C5A),
          ),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
