import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import '../../core/widgets/closet_buttons.dart';
import 'transaction_models.dart';
import 'widgets/transaction_scaffold.dart';

/// Saisie du code PIN — transcription de la maquette `32:704`.
///
/// Quatre cases blanches : le chiffre saisi est visible, la case active
/// porte le curseur, le CTA doré n'est actif qu'une fois les 4 chiffres
/// entrés.
class PinScreen extends StatefulWidget {
  const PinScreen({
    super.key,
    required this.demande,
    required this.onValide,
  });

  final DemandeTransaction demande;

  /// Appelé avec le code saisi une fois les 4 chiffres entrés.
  final ValueChanged<String> onValide;

  /// Nombre de chiffres du code, d'après la maquette.
  static const int longueurCode = 4;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _complet => _controller.text.length == PinScreen.longueurCode;

  String get _consigne => widget.demande.type == TypeOperation.retrait
      ? 'Ajoutez un code PIN pour renforcer la sécurité de votre '
          'portefeuille.'
      : 'Ajoutez un code PIN pour renforcer la sécurité de votre '
          'opération.';

  @override
  Widget build(BuildContext context) {
    return TransactionScaffold(
      titre: null,
      hautTitre: 72,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.p24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
            child: Text(
              'Code PIN de sécurité',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreHero.copyWith(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.p16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _consigne,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.corps.copyWith(
                fontSize: 13,
                height: 1.45,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _CasesPin(
            code: _controller.text,
            onTap: () => _focus.requestFocus(),
          ),
          // Champ réel, invisible : il porte la saisie et le clavier.
          SizedBox(
            height: 0,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                maxLength: PinScreen.longueurCode,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (v) {
                  if (_complet) widget.onValide(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              child: ClosetPrimaryButton(
                label: 'Valider le Numéro PIN',
                dore: true,
                hauteur: 44,
                onPressed:
                    _complet ? () => widget.onValide(_controller.text) : null,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CasesPin extends StatelessWidget {
  const _CasesPin({required this.code, required this.onTap});

  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final indexActif = code.length.clamp(0, PinScreen.longueurCode - 1);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < PinScreen.longueurCode; i++)
              _Case(
                chiffre: i < code.length ? code[i] : null,
                actif: i == indexActif && code.length < PinScreen.longueurCode,
              ),
          ],
        ),
      ),
    );
  }
}

class _Case extends StatelessWidget {
  const _Case({required this.chiffre, required this.actif});

  final String? chiffre;
  final bool actif;

  @override
  Widget build(BuildContext context) {
    final rempli = chiffre != null;
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rempli || actif ? ClosetColors.blanc : ClosetColors.caseVide,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: actif ? ClosetColors.fond300 : ClosetColors.caseVide,
          width: AppStroke.fin,
        ),
      ),
      child: Text(
        rempli ? chiffre! : (actif ? '|' : ''),
        style: ClosetTextStyles.libelleFort.copyWith(
          fontSize: 22,
          color: ClosetColors.noir,
        ),
      ),
    );
  }
}
