import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/validation/formats.dart';
import '../../../core/validation/indicateurs_pays.dart';
import '../../../core/widgets/champ_telephone.dart';
import '../../../core/widgets/closet_field.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

/// Modifier mon profil — transcription de la maquette `25:710`.
///
/// Avatar de 120 avec sa pastille d'édition, trois champs blancs cerclés d'or
/// à libellé posé au-dessus, puis le bouton « Mettre à jour ».
class ModifierProfilScreen extends ConsumerStatefulWidget {
  const ModifierProfilScreen({super.key});

  @override
  ConsumerState<ModifierProfilScreen> createState() =>
      _ModifierProfilScreenState();
}

class _ModifierProfilScreenState
    extends ConsumerState<ModifierProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _email;
  late final TelephoneController _telephone;

  @override
  void initState() {
    super.initState();
    final user = ref.read<ClosetUser?>(currentUserProvider);
    _nom = TextEditingController(text: user?.nomComplet ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _telephone = TelephoneController(initial: user?.phone);
  }

  @override
  void dispose() {
    _nom.dispose();
    _email.dispose();
    _telephone.dispose();
    super.dispose();
  }

  /// Envoi en cours. Bloque le bouton pour éviter deux mises à jour
  /// concurrentes, dont la seconde écraserait la première.
  bool _envoiEnCours = false;

  Future<void> _enregistrer() async {
    if (_envoiEnCours) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = ClosetL10n.of(context);

    setState(() => _envoiEnCours = true);
    try {
      await ref.read(authRepositoryProvider).mettreAJourProfil(
            nomComplet: _nom.text,
            email: _email.text,
            phone: _telephone.e164,
          );
      if (!mounted) return;
      toastSucces(ref, l10n.profilMisAJour);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      toastErreur(ref, e, titre: l10n.miseAJourImpossible);
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final user = ref.watch<ClosetUser?>(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _EnTeteRetour(
              titre: '',
              onRetour: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p20,
                  AppSpacing.p32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: _AvatarEditable(user: user)),
                      const SizedBox(height: 29),
                      ClosetChampLibelle(
                        label: l10n.nomCompletLabel,
                        controller: _nom,
                        hint: 'Jane Doe',
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.veuillezRenseignerNom
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      ClosetChampLibelle(
                        label: l10n.email,
                        controller: _email,
                        hint: 'jane.doe@email.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) => validerEmail(v, l10n: l10n),
                        autocorrect: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      ChampTelephone(
                        label: l10n.telephoneWhatsappLibelle,
                        controller: _telephone,
                        hint: '6 90 12 34 56',
                        style: StyleChampTelephone.libelle,
                        obligatoire: false,
                        textInputAction: TextInputAction.done,
                        validator: (v) => validerTelephone(
                          v,
                          obligatoire: false,
                          libelle: l10n.numeroWhatsapp,
                          l10n: l10n,
                        ),
                      ),
                      const SizedBox(height: 47),
                      Center(
                        child: SizedBox(
                          width: 312,
                          height: 44,
                          child: Material(
                            color: ClosetColors.vert,
                            borderRadius:
                                BorderRadius.circular(AppRadius.cercle),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.cercle),
                              onTap: _envoiEnCours ? null : _enregistrer,
                              child: Center(
                                child: _envoiEnCours
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: ClosetColors.blanc,
                                        ),
                                      )
                                    : Text(
                                        l10n.mettreAJour,
                                        style:
                                            ClosetTextStyles.bouton.copyWith(
                                          color: ClosetColors.blanc,
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }

}

/// Bandeau de retour : bouton rond à gauche, titre centré, filet doré.
class _EnTeteRetour extends StatelessWidget {
  const _EnTeteRetour({required this.titre, required this.onRetour});

  final String titre;
  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ClosetColors.fond400,
            width: AppStroke.fin,
          ),
        ),
      ),
      child: SizedBox(
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                titre,
                style: ClosetTextStyles.accroche.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ClosetColors.noir,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.p20),
                child: Semantics(
                  button: true,
                  label: ClosetL10n.of(context).retour,
                  child: GestureDetector(
                    onTap: onRetour,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ClosetColors.blanc,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ClosetColors.fond300,
                          width: AppStroke.fin,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: ClosetColors.vert,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar de 120 aux initiales, avec sa pastille d'édition de 40.
class _AvatarEditable extends ConsumerWidget {
  const _AvatarEditable({required this.user});

  final ClosetUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = user?.firstName.isNotEmpty ?? false
        ? user!.firstName[0].toUpperCase()
        : '';
    final n = user?.lastName.isNotEmpty ?? false
        ? user!.lastName[0].toUpperCase()
        : '';
    final initiales = '$p$n'.isEmpty ? '?' : '$p$n';

    return SizedBox(
      width: 160,
      height: 120,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ClosetColors.emeraude100,
              shape: BoxShape.circle,
            ),
            child: Text(
              initiales,
              style: ClosetTextStyles.montantHero.copyWith(
                fontSize: 40,
                color: ClosetColors.vert,
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: 80,
            child: Semantics(
              button: true,
              label: ClosetL10n.of(context).changerMaPhoto,
              child: GestureDetector(
                onTap: () => toastInfo(
                  ref,
                  ClosetL10n.of(context).photoIndisponibleTitre,
                  ClosetL10n.of(context).photoIndisponibleCorps,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: ClosetColors.vert,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 17,
                    color: ClosetColors.blanc,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
