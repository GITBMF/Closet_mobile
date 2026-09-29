import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/validation/formats.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../../auth/mfa_dialog.dart';
import '../../auth/mot_de_passe_oublie_dialog.dart';
import '../../auth/verify_email_dialog.dart';
import '../widgets/sourceur_header.dart';
import '../widgets/sourceur_programme_visuel.dart';

/// Identification Espace Sourceur — transcription de la maquette `26:1877`.
///
/// Même habillage de champ que `5:1304` (fond bleuté, bordure `#D4D7E3`),
/// arche blanche au-dessus, et renvoi vers la fiche d'adhésion pour qui n'est
/// pas encore partenaire.
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
    final l10n = ClosetL10n.of(context);
    final identifiant = _identifiant.text.trim();
    final motDePasse = _motDePasse.text;

    final erreurId = validerIdentifiantConnexion(identifiant, l10n);
    if (erreurId != null) {
      toastInfo(ref, l10n.identifiantLabel, erreurId);
      return;
    }
    final erreurMdp =
        validerMotDePasse(motDePasse, connexion: true, l10n: l10n);
    if (erreurMdp != null) {
      toastInfo(ref, l10n.motDePasse, erreurMdp);
      return;
    }

    setState(() => _enCours = true);
    try {
      try {
        await ref
            .read(authRepositoryProvider)
            .logIn(email: identifiant, password: motDePasse, l10n: l10n);
      } on EmailAVerifier catch (defi) {
        if (!mounted) return;
        setState(() => _enCours = false);
        final ok = await afficherDialogueVerificationEmail(
          context,
          email: defi.email,
        );
        if (ok != true || !mounted) return;
        setState(() => _enCours = true);
        await ref
            .read(authRepositoryProvider)
            .logIn(email: identifiant, password: motDePasse, l10n: l10n);
      } on MfaRequise catch (defi) {
        if (!mounted) return;
        setState(() => _enCours = false);
        final viaMfa = await afficherDialogueMfa(context, defi);
        if (viaMfa == null || !mounted) return;
      }
      if (!mounted) return;
      final user = ref.read(currentUserProvider);
      await ref
          .read(sourceurRepositoryProvider)
          .chargerProfil(compte: user, l10n: l10n);
      if (!mounted) return;
      final repo = ref.read(sourceurRepositoryProvider);
      if (!repo.accesAutorisePour(user)) {
        if (!mounted) return;
        setState(() => _enCours = false);
        await dialogueErreur(
          context,
          l10n.pasDeFicheSourceuse,
          titre: l10n.pasEncorePartenaireTitre,
        );
        if (!mounted) return;
        context.go('/sourceur/inscription');
        return;
      }
      if (!mounted) return;
      setState(() => _enCours = false);
      await dialogueSucces(
        context,
        titre: l10n.identificationReussieTitre,
        message: l10n.bienvenueEspaceSourceur,
      );
      if (!mounted) return;
      context.go('/sourceur/espace');
    } catch (e) {
      if (mounted) {
        setState(() => _enCours = false);
        await dialogueErreur(context, e, titre: l10n.identificationImpossibleTitre);
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
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
                        label: l10n.retour,
                        onTap: () => sourceurRetour(context),
                      ),
                    Expanded(
                      child: Text(
                        l10n.espaceSourceurClosetTitre,
                        textAlign: TextAlign.center,
                        style: ClosetTextStyles.sousTitre.copyWith(
                          color: ClosetColors.blanc,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p20),
              const SourceurCadrePhoto(hauteur: 220),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.accederEspaceConfie,
                      style: ClosetTextStyles.titreEcran.copyWith(
                        letterSpacing: 0.44,
                        color: ClosetColors.blanc,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    _ChampSourceur(
                      label: l10n.emailOuTelephone,
                      hint: 'Example@email.com',
                      controller: _identifiant,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      sansEspaces: true,
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    _ChampSourceur(
                      label: l10n.motDePasse,
                      hint: l10n.hintMotDePasse,
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
                      l10n.mdpMin8Chiffre,
                      style: ClosetTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w300,
                        color: ClosetColors.beige,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p24),
                    SizedBox(
                      height: 44,
                      child: Material(
                        color: _enCours
                            ? ClosetColors.doreDesactive
                            : ClosetColors.fond300,
                        borderRadius: BorderRadius.circular(AppRadius.cercle),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(AppRadius.cercle),
                          onTap: _enCours ? null : _entrer,
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
                                    l10n.entrerDansMonEspace,
                                    style: ClosetTextStyles.bouton.copyWith(
                                      color: ClosetColors.neutre900,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    Center(
                      child: TextButton(
                        onPressed: () => afficherMotDePasseOublie(
                          context,
                          emailInitial: _identifiant.text,
                        ),
                        child: Text(
                          l10n.motDePasseOublie,
                          style: ClosetTextStyles.corps.copyWith(
                            color: ClosetColors.beige,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p20),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/sourceur/inscription'),
                        child: Text.rich(
                          TextSpan(
                            text: '${l10n.pasEncoreMembre} ',
                            style: ClosetTextStyles.corps.copyWith(
                              color: ClosetColors.beige,
                            ),
                            children: [
                              TextSpan(
                                text: l10n.remplirFicheAdhesion,
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
    this.sansEspaces = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final bool sansEspaces;

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
            autocorrect: !sansEspaces,
            enableSuggestions: !sansEspaces,
            inputFormatters: [
              if (sansEspaces)
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
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
