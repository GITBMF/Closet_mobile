import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/validation/formats.dart';
import '../../../core/validation/indicateurs_pays.dart';
import '../../../core/widgets/champ_telephone.dart';
import '../../../core/widgets/closet_buttons.dart';
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

class _ModifierProfilScreenState extends ConsumerState<ModifierProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _email;
  late final TelephoneController _telephone;

  late final String _nomInitial;
  late final String _emailInitial;
  late final String _telInitial;

  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read<ClosetUser?>(currentUserProvider);
    _nom = TextEditingController(text: user?.nomComplet ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _telephone = TelephoneController(initial: user?.phone);
    _nomInitial = _nom.text.trim();
    _emailInitial = _email.text.trim().toLowerCase();
    _telInitial = _telephone.e164;
    _nom.addListener(_surSaisie);
    _email.addListener(_surSaisie);
    _telephone.addListener(_surSaisie);
  }

  @override
  void dispose() {
    _nom.removeListener(_surSaisie);
    _email.removeListener(_surSaisie);
    _telephone.removeListener(_surSaisie);
    _nom.dispose();
    _email.dispose();
    _telephone.dispose();
    super.dispose();
  }

  void _surSaisie() {
    if (mounted) setState(() {});
  }

  bool get _modifie =>
      _nom.text.trim() != _nomInitial ||
      _email.text.trim().toLowerCase() != _emailInitial ||
      _telephone.e164 != _telInitial;

  Future<bool> _confirmerSortie() async {
    if (!_modifie) return true;
    final l10n = ClosetL10n.of(context);
    final quitter = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        title: Text(
          l10n.modificationsNonEnregistrees,
          style: ClosetTextStyles.titreSection,
        ),
        content: Text(
          l10n.quitterSansEnregistrer,
          style: ClosetTextStyles.citation.copyWith(color: ClosetColors.taupe),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.continuerEdition,
              style: ClosetTextStyles.corps.copyWith(color: ClosetColors.vert),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.quitter,
              style: ClosetTextStyles.corps.copyWith(
                color: ClosetColors.erreur,
              ),
            ),
          ),
        ],
      ),
    );
    return quitter == true;
  }

  Future<void> _quitter() async {
    if (!await _confirmerSortie()) return;
    if (mounted) context.pop();
  }

  Future<void> _enregistrer() async {
    if (_envoiEnCours || !_modifie) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _envoiEnCours = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .mettreAJourProfil(
            nomComplet: _nom.text,
            email: _email.text,
            phone: _telephone.e164,
          );
      if (!mounted) return;
      final l10n = ClosetL10n.of(context);
      final notifier = ref.read<NotificationNotifier>(
        notificationProvider.notifier,
      );
      context.pop();
      notifier.showSuccess(l10n.profilMisAJour, l10n.profilMisAJour);
    } catch (e) {
      if (!mounted) return;
      toastErreur(ref, e, titre: 'Mise à jour impossible');
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final user = ref.watch<ClosetUser?>(currentUserProvider);
    final peutEnregistrer = _modifie && !_envoiEnCours;

    return PopScope(
      canPop: !_modifie,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _quitter();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _EnTeteRetour(titre: '', onRetour: _quitter),
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
                          label: 'Nom complet',
                          controller: _nom,
                          hint: 'Marie Dupont',
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Veuillez renseigner votre nom.'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.p24),
                        ClosetChampLibelle(
                          label: 'Email',
                          controller: _email,
                          hint: 'marie.dupont@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: validerEmail,
                          autocorrect: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.p24),
                        ChampTelephone(
                          label: 'Téléphone (Whatsapp)',
                          controller: _telephone,
                          hint: '6 90 12 34 56',
                          style: StyleChampTelephone.libelle,
                          obligatoire: false,
                          textInputAction: TextInputAction.done,
                          paysFixe: IndicateurPays.cameroun,
                          validator: (v) => validerTelephone(
                            v,
                            obligatoire: false,
                            libelle: 'numéro WhatsApp',
                            camerounUniquement: true,
                          ),
                        ),
                        const SizedBox(height: 47),
                        Center(
                          child: SizedBox(
                            width: 312,
                            height: 44,
                            child: _envoiEnCours
                                ? Material(
                                    color: ClosetColors.vert,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.cercle,
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: ClosetColors.blanc,
                                        ),
                                      ),
                                    ),
                                  )
                                : ClosetPrimaryButton(
                                    label: l10n.mettreAJour,
                                    hauteur: 44,
                                    onPressed: peutEnregistrer
                                        ? _enregistrer
                                        : null,
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p12),
                        Center(
                          child: SizedBox(
                            width: 312,
                            height: 44,
                            child: ClosetOutlineButton(
                              label: l10n.annulerPaiement,
                              hauteur: 44,
                              onPressed: _envoiEnCours ? null : _quitter,
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
          bottom: BorderSide(color: ClosetColors.fond400, width: AppStroke.fin),
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
                  label: 'Retour',
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
              label: 'Changer ma photo',
              child: GestureDetector(
                onTap: () => toastInfo(
                  ref,
                  'Photo indisponible',
                  'Le changement de photo n’est pas encore proposé par le serveur.',
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
