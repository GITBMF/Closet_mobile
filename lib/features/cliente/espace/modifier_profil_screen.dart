import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_field.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_storage_service.dart';

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
  final _picker = ImagePicker();
  late final TextEditingController _nom;
  late final TextEditingController _email;
  late final TextEditingController _telephone;
  String? _avatarPath;
  bool _enregistrementEnCours = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read<ClosetUser?>(currentUserProvider);
    _nom = TextEditingController(text: user?.nomComplet ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _telephone = TextEditingController(text: user?.phone ?? '');
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

    setState(() => _envoiEnCours = true);
    try {
      await ref.read(authRepositoryProvider).mettreAJourProfil(
            nomComplet: _nom.text,
            email: _email.text,
            phone: _telephone.text,
          );
      if (!mounted) return;
      toastSucces(ref, 'Profil mis à jour');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      toastErreur(ref, e, titre: 'Mise à jour impossible');
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch<ClosetUser?>(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _EnTeteRetour(
              titre: 'Modifier mon profil',
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
                      Center(
                        child: _AvatarEditable(
                          user: user,
                          imagePath: _avatarPath,
                          onChanger: _choisirSource,
                        ),
                      ),
                      const SizedBox(height: 29),
                      ClosetChampLibelle(
                        label: 'Nom complet',
                        controller: _nom,
                        hint: 'Aïcha N.',
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Veuillez renseigner votre nom.'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      ClosetChampLibelle(
                        label: 'Email',
                        controller: _email,
                        hint: 'AichaN@outlook.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validerEmail,
                      ),
                      const SizedBox(height: AppSpacing.p24),
                      ClosetChampLibelle(
                        label: 'Téléphone (Whatsapp)',
                        controller: _telephone,
                        hint: '+237 6 90 12 34 56',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        validator: _validerTelephone,
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
                                        'Mettre à jour',
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

  static String? _validerEmail(String? v) {
    final valeur = v?.trim() ?? '';
    if (valeur.isEmpty) return 'Veuillez renseigner votre email.';
    final motif = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!motif.hasMatch(valeur)) return 'Cet email semble incorrect.';
    return null;
  }

  static String? _validerTelephone(String? v) {
    final valeur = (v ?? '').replaceAll(RegExp(r'[\s.\-]'), '');
    if (valeur.isEmpty) return null; // champ facultatif
    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(valeur)) {
      return 'Ce numéro semble incorrect.';
    }
    return null;
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
  final String? imagePath;
  final VoidCallback onChanger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = user?.firstName.isNotEmpty ?? false
        ? user!.firstName[0].toUpperCase()
        : '';
    final n = user?.lastName.isNotEmpty ?? false
        ? user!.lastName[0].toUpperCase()
        : '';
    final initiales = '$p$n'.isEmpty ? '?' : '$p$n';
    final fichier = imagePath == null ? null : File(imagePath!);
    final aUnePhoto = fichier != null && fichier.existsSync();

    return SizedBox(
      width: 160,
      height: 120,
      child: Stack(
        children: [
          ClipOval(
            child: GestureDetector(
              onTap: onChanger,
              child: aUnePhoto
                  ? Image.file(
                      fichier,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      color: ClosetColors.emeraude100,
                      child: Text(
                        initiales,
                        style: ClosetTextStyles.montantHero.copyWith(
                          fontSize: 40,
                          color: ClosetColors.vert,
                        ),
                      ),
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
