import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/validation/formats.dart';
import '../../data/api/api_exception.dart';
import '../../data/repositories/auth_repository.dart';

/// Demande de réinitialisation de mot de passe, partagée par la connexion
/// cliente (`5:1304`) et l'identification sourceuse (`26:1877`).
///
/// Les deux écrans se contentaient d'afficher « Un lien de réinitialisation
/// vous sera envoyé » sans rien demander ni rien envoyer. Ils collectent
/// désormais l'adresse et passent par [AuthRepository].
Future<void> afficherMotDePasseOublie(
  BuildContext context, {
  String emailInitial = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _MotDePasseOublieDialog(emailInitial: emailInitial),
  );
}

class _MotDePasseOublieDialog extends ConsumerStatefulWidget {
  const _MotDePasseOublieDialog({required this.emailInitial});

  final String emailInitial;

  @override
  ConsumerState<_MotDePasseOublieDialog> createState() =>
      _MotDePasseOublieDialogState();
}

class _MotDePasseOublieDialogState
    extends ConsumerState<_MotDePasseOublieDialog> {
  late final TextEditingController _email =
      TextEditingController(text: widget.emailInitial);

  bool _envoiEnCours = false;
  String? _erreur;
  String _messageServeur = '';

  /// Une fois l'envoi accepté, la boîte affiche sa confirmation à la place du
  /// formulaire : refermer aussitôt laisserait douter que quelque chose se soit
  /// passé.
  bool _envoye = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final erreurEmail = validerEmail(_email.text);
    if (erreurEmail != null) {
      setState(() => _erreur = erreurEmail);
      return;
    }
    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });
    try {
      final message = await ref
          .read(authRepositoryProvider)
          .demanderReinitialisation(_email.text);
      if (!mounted) return;
      setState(() {
        _messageServeur = message;
        _envoye = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erreur = messageErreur(e));
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ClosetColors.blanc,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.carte),
      ),
      title: Text(
        _envoye ? 'Vérifiez vos messages' : 'Mot de passe oublié',
        style: ClosetTextStyles.titreBloc.copyWith(color: ClosetColors.vert),
      ),
      content: _envoye
          ? Text(
              messageMelange(
                local:
                    'Si un compte est rattaché à ${_email.text.trim()}, un lien '
                    'de réinitialisation vient d’y être envoyé.',
                backend: _messageServeur,
              ),
              style:
                  ClosetTextStyles.meta.copyWith(color: ClosetColors.taupe),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Indiquez l’adresse de votre compte : nous y enverrons un '
                  'lien de réinitialisation.',
                  style:
                      ClosetTextStyles.meta.copyWith(color: ClosetColors.taupe),
                ),
                const SizedBox(height: AppSpacing.p16),
                TextField(
                  controller: _email,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  onSubmitted: (_) => _envoiEnCours ? null : _envoyer(),
                  style: ClosetTextStyles.corps,
                  decoration: InputDecoration(
                    hintText: 'vous@exemple.com',
                    errorText: _erreur,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.carte),
                    ),
                  ),
                ),
              ],
            ),
      actions: _envoye
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Fermer',
                  style:
                      ClosetTextStyles.bouton.copyWith(color: ClosetColors.vert),
                ),
              ),
            ]
          : [
              TextButton(
                onPressed:
                    _envoiEnCours ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Annuler',
                  style: ClosetTextStyles.bouton
                      .copyWith(color: ClosetColors.taupe),
                ),
              ),
              TextButton(
                onPressed: _envoiEnCours ? null : _envoyer,
                child: _envoiEnCours
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ClosetColors.vert,
                        ),
                      )
                    : Text(
                        'Envoyer le lien',
                        style: ClosetTextStyles.bouton
                            .copyWith(color: ClosetColors.vert),
                      ),
              ),
            ],
    );
  }
}
