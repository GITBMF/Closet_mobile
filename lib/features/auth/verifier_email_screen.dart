import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/api/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';

/// Vérification du code à 6 chiffres reçu par e-mail — poussé juste après
/// l'inscription quand le backend refuse la connexion (`email_not_verified`).
///
/// Le compte existe déjà côté serveur : cet écran ne fait que confirmer le
/// code puis rejoue la connexion avec les identifiants qu'on lui a passés,
/// pour ouvrir la session sans redemander le mot de passe.
class VerifierEmailScreen extends ConsumerStatefulWidget {
  const VerifierEmailScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  ConsumerState<VerifierEmailScreen> createState() =>
      _VerifierEmailScreenState();
}

class _VerifierEmailScreenState extends ConsumerState<VerifierEmailScreen> {
  final _code = TextEditingController();
  bool _enCours = false;
  bool _renvoiEnCours = false;
  int _cooldown = 0;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verifier() async {
    final l10n = ClosetL10n.of(context);
    final code = _code.text.trim();
    if (code.length < 4) {
      await dialogueErreur(
        context,
        ApiException(
          message: l10n.saisirCodeSixChiffres,
          kind: KindErreurApi.validation,
        ),
        titre: l10n.emailInvalideTitre,
      );
      return;
    }

    setState(() => _enCours = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.verifierEmail(email: widget.email, code: code);
      final user = await authRepo.logIn(
        email: widget.email,
        password: widget.password,
        l10n: l10n,
      );
      try {
        await ref
            .read(sourceurRepositoryProvider)
            .chargerProfil(compte: user, l10n: l10n);
      } catch (_) {}

      if (!mounted) return;
      setState(() => _enCours = false);
      await dialogueSucces(
        context,
        titre: l10n.compteCree,
        message: l10n.bienvenuePrenom(user.firstName),
      );
      if (!mounted) return;
      if (user.estSourceur) {
        context.go('/sourceur/espace');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _enCours = false);
      await dialogueErreur(context, e, titre: ClosetL10n.of(context).codeIncorrectTitre);
    }
  }

  Future<void> _renvoyer() async {
    if (_cooldown > 0 || _renvoiEnCours) return;
    setState(() => _renvoiEnCours = true);
    final l10n = ClosetL10n.of(context);
    try {
      final message = await ref
          .read(authRepositoryProvider)
          .renvoyerCodeVerification(widget.email);
      if (!mounted) return;
      await dialogueSucces(
        context,
        titre: l10n.codeRenvoyeTitre,
        message: message.isEmpty ? l10n.nouveauCodeEnvoye : message,
      );
      _demarrerCooldown();
    } catch (e) {
      if (!mounted) return;
      await dialogueErreur(context, e, titre: l10n.envoiImpossibleTitre);
    } finally {
      if (mounted) setState(() => _renvoiEnCours = false);
    }
  }

  void _demarrerCooldown() {
    setState(() => _cooldown = 30);
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _cooldown -= 1);
      return _cooldown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: ClosetColors.beige),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.verifiezVotreEmail,
                style: ClosetTextStyles.titreEcran.copyWith(
                  color: ClosetColors.neutre200,
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              Text(
                l10n.codeEnvoyeA(widget.email),
                style: ClosetTextStyles.corps.copyWith(
                  color: ClosetColors.beige,
                ),
              ),
              const SizedBox(height: AppSpacing.p32),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => _verifier(),
                style: ClosetTextStyles.titreEcran.copyWith(
                  color: ClosetColors.noir,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: ClosetColors.champFond,
                  hintText: '••••••',
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.carte),
                    borderSide: const BorderSide(
                      color: ClosetColors.champBordure,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.carte),
                    borderSide: const BorderSide(
                      color: ClosetColors.champBordure,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.carte),
                    borderSide: const BorderSide(color: ClosetColors.fond300),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
              SizedBox(
                height: 44,
                child: Material(
                  color: ClosetColors.fond300,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: _enCours ? null : _verifier,
                    child: Center(
                      child: _enCours
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ClosetColors.neutre900,
                              ),
                            )
                          : Text(
                              l10n.verifier,
                              style: ClosetTextStyles.bouton.copyWith(
                                color: ClosetColors.neutre900,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p20),
              Center(
                child: TextButton(
                  onPressed: _cooldown > 0 ? null : _renvoyer,
                  child: Text(
                    _cooldown > 0
                        ? l10n.renvoyerLeCodeCompteASecondes(_cooldown)
                        : l10n.renvoyerLeCode,
                    style: ClosetTextStyles.corps.copyWith(
                      color: ClosetColors.beige,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
