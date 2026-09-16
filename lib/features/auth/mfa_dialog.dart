import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../data/api/api_exception.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

/// Demande le code TOTP après un login qui a renvoyé `mfa_required`.
///
/// Retourne l’utilisateur si le code est accepté, `null` si la cliente
/// annule. Un code faux reste dans la boîte pour un nouvel essai.
Future<ClosetUser?> afficherDialogueMfa(
  BuildContext context,
  MfaRequise defi,
) {
  return showDialog<ClosetUser>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _MfaDialog(defi: defi),
  );
}

class _MfaDialog extends ConsumerStatefulWidget {
  const _MfaDialog({required this.defi});

  final MfaRequise defi;

  @override
  ConsumerState<_MfaDialog> createState() => _MfaDialogState();
}

class _MfaDialogState extends ConsumerState<_MfaDialog> {
  final _code = TextEditingController();
  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final saisie = _code.text.trim();
    if (saisie.length < 6 || saisie.length > 10) {
      setState(() => _erreur = 'Le code contient 6 chiffres.');
      return;
    }
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final user = await ref.read(authRepositoryProvider).validerMfa(
            challengeToken: widget.defi.challengeToken,
            code: saisie,
          );
      if (!mounted) return;
      Navigator.of(context).pop(user);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erreur = messageErreur(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
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
        'Double authentification',
        style: ClosetTextStyles.titreBloc.copyWith(color: ClosetColors.vert),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrez le code à 6 chiffres de votre application d’authentification.',
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.carte),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _enCours ? null : () => Navigator.of(context).pop(),
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
