import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/closet_colors.dart';
import '../../core/theme/closet_text_styles.dart';
import 'transaction_models.dart';
import 'widgets/transaction_scaffold.dart';

/// Saisie du code PIN — transcription de la maquette `32:704`.
///
/// Quatre cases de 75 × 60 (rayon 4) : grise tant qu'elle est vide, blanche
/// cerclée d'or quand elle a le focus, blanche cerclée de gris une fois
/// remplie.
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

  @override
  Widget build(BuildContext context) {
    return TransactionScaffold(
      titre: 'Code PIN de sécurité',
      child: Column(
        children: [
          const SizedBox(height: 55),
          const TexteTransaction(
            'Ajoutez un code PIN pour renforcer la sécurité de votre '
            'opération.',
          ),
          const SizedBox(height: 32),
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
                obscureText: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (v) {
                  if (_complet) widget.onValide(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 88),
          BoutonTransaction(
            label: 'Valider le Numéro PIN',
            onPressed:
                _complet ? () => widget.onValide(_controller.text) : null,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
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
      width: 75,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rempli || actif ? Colors.white : ClosetColors.caseVide,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: actif ? ClosetColors.fond300 : ClosetColors.caseVide,
          width: AppStroke.fin,
        ),
      ),
      child: Text(
        rempli ? '•' : (actif ? '|' : ''),
        style: ClosetTextStyles.libelle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: ClosetColors.pinTexte,
        ),
      ),
    );
  }
}
