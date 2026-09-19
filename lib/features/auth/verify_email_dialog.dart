import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../data/api/api_exception.dart';
import '../../data/repositories/auth_repository.dart';

/// Saisie du code envoyé par e-mail après l’inscription.
///
/// Retourne `true` si `POST /auth/verify-email` a réussi.
Future<bool?> afficherDialogueVerificationEmail(
  BuildContext context, {
  required String email,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _VerifyEmailDialog(email: email),
  );
}

class _VerifyEmailDialog extends ConsumerStatefulWidget {
  const _VerifyEmailDialog({required this.email});

  final String email;

  @override
  ConsumerState<_VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends ConsumerState<_VerifyEmailDialog> {
  final _code = TextEditingController();
  bool _enCours = false;
  bool _renvoiEnCours = false;
  String? _erreur;
  String? _info;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final saisie = _code.text.trim();
    if (saisie.length < 4 || saisie.length > 10) {
      setState(() => _erreur = 'Le code contient 6 chiffres.');
      return;
    }
    setState(() {
      _enCours = true;
      _erreur = null;
      _info = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifierEmail(
            email: widget.email,
            code: saisie,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erreur = messageErreur(e).isEmpty
          ? 'Code incorrect ou expiré.'
          : messageErreur(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _renvoyer() async {
    setState(() {
      _renvoiEnCours = true;
      _erreur = null;
      _info = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .renvoyerCodeVerification(widget.email);
      if (!mounted) return;
      setState(() => _info = 'Un nouveau code a été envoyé.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _erreur = messageErreur(e).isEmpty
          ? 'Impossible de renvoyer le code.'
          : messageErreur(e));
    } finally {
      if (mounted) setState(() => _renvoiEnCours = false);
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
        'Vérifiez votre e-mail',
        style: ClosetTextStyles.titreBloc.copyWith(color: ClosetColors.vert),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Un code a été envoyé à ${widget.email}. Saisissez-le pour activer le compte.',
            style: ClosetTextStyles.meta.copyWith(color: ClosetColors.taupe),
          ),
          const SizedBox(height: AppSpacing.p16),
          TextField(
            controller: _code,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _enCours ? null : _valider(),
            style: ClosetTextStyles.corps.copyWith(
              letterSpacing: 6,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '000000',
              counterText: '',
              errorText: _erreur,
              helperText: _info,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.carte),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _enCours || _renvoiEnCours ? null : _renvoyer,
          child: _renvoiEnCours
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ClosetColors.vert,
                  ),
                )
              : Text(
                  'Renvoyer',
                  style:
                      ClosetTextStyles.bouton.copyWith(color: ClosetColors.taupe),
                ),
        ),
        TextButton(
          onPressed: _enCours ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Annuler',
            style: ClosetTextStyles.bouton.copyWith(color: ClosetColors.taupe),
          ),
        ),
        TextButton(
          onPressed: _enCours ? null : _valider,
          child: _enCours
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ClosetColors.vert,
                  ),
                )
              : Text(
                  'Valider',
                  style: ClosetTextStyles.bouton
                      .copyWith(color: ClosetColors.vert),
                ),
        ),
      ],
    );
  }
}
