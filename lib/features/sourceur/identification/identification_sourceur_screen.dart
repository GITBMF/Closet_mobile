import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_buttons.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../widgets/sourceur_header.dart';
import '../widgets/sourceur_programme_visuel.dart';

/// Identification Espace Sourceur — connexion du partenaire déjà validé.
///
/// Même habillage de champ que `5:1304` (fond bleuté, bordure `#D4D7E3`),
/// photo dressing en carte arrondie, et renvoi vers la passerelle d'adhésion
/// pour qui n'est pas encore partenaire.
class IdentificationSourceurScreen extends ConsumerStatefulWidget {
  const IdentificationSourceurScreen({super.key});

  @override
  ConsumerState<IdentificationSourceurScreen> createState() =>
      _IdentificationSourceurScreenState();
}

class _IdentificationSourceurScreenState
    extends ConsumerState<IdentificationSourceurScreen> {
  final _identifiant = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _masque = true;
  bool _enCours = false;

  @override
  void dispose() {
    _identifiant.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _entrer() async {
    final identifiant = _identifiant.text.trim();
    final motDePasse = _motDePasse.text;

    if (identifiant.isEmpty || motDePasse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    setState(() => _enCours = true);
    try {
      final ClosetUser user = await ref
          .read(authRepositoryProvider)
          .logIn(email: identifiant, password: motDePasse);
      if (!mounted) return;
      ref.read(currentUserProvider.notifier).state = user;
      context.go('/sourceur/adhesion');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  void _versAdhesion() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/sourceur/devenir');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.vert,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.p24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p20,
                  vertical: AppSpacing.p8,
                ),
                child: Row(
                  children: [
                    SourceurBoutonRond(
                      icone: Icons.arrow_back_ios_new,
                      label: 'Retour',
                      onTap: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Espace Sourceur ClosET',
                        textAlign: TextAlign.center,
                        style: ClosetTextStyles.sousTitre.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.p20),
                child: SourceurVisuelCarte(),
              ),
              const SizedBox(height: AppSpacing.p32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Accéder à mon espace confié',
                      style: ClosetTextStyles.titreEcran.copyWith(
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    _ChampSourceur(
                      label: 'Email ou téléphone',
                      hint: 'Example@email.com',
                      controller: _identifiant,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    _ChampSourceur(
                      label: 'Password',
                      hint: 'At least 8 characters',
                      controller: _motDePasse,
                      obscure: _masque,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _entrer(),
                      suffix: IconButton(
                        icon: Icon(
                          _masque
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: ClosetColors.champPlaceholder,
                        ),
                        onPressed: () => setState(() => _masque = !_masque),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      '8 caractères minimum, dont un chiffre.',
                      style: ClosetTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    SizedBox(
                      height: 44,
                      child: _enCours
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ClosetColors.fond300,
                                ),
                              ),
                            )
                          : ClosetPrimaryButton(
                              label: 'ENTRER DANS MON ESPACE',
                              dore: true,
                              hauteur: 44,
                              onPressed: _entrer,
                            ),
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Un lien de réinitialisation vous sera envoyé.',
                            ),
                          ),
                        ),
                        child: Text(
                          'Mot de passe oublié',
                          style: ClosetTextStyles.corps.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    Center(
                      child: TextButton(
                        onPressed: _versAdhesion,
                        child: Text.rich(
                          TextSpan(
                            text: 'Pas encore membre ? ',
                            style: ClosetTextStyles.corps.copyWith(
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: 'Remplir la fiche d’adhésion',
                                style: ClosetTextStyles.corps.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ClosetColors.fond300,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

/// Champ de l'espace sourceur : libellé doré, zone bleutée de 42, rayon 8.
class _ChampSourceur extends StatelessWidget {
  const _ChampSourceur({
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
