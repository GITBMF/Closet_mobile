import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_storage_service.dart';
import '../../transaction/widgets/transaction_scaffold.dart';

/// Étapes de la sortie de session.
enum _EtapeSortie { confirmation, adieu }

/// Déconnexion — transcription des maquettes `36:2064` et `36:2113`.
///
/// Les deux écrans partagent une route : une fois la session détruite, il n'y
/// a plus rien vers quoi revenir, donc `PopScope` bloque le retour à partir de
/// l'écran d'adieu.
class DeconnexionScreen extends ConsumerStatefulWidget {
  const DeconnexionScreen({super.key});

  /// Délai avant redirection automatique, annoncé par la maquette.
  static const Duration delaiRedirection = Duration(seconds: 4);

  @override
  ConsumerState<DeconnexionScreen> createState() => _DeconnexionScreenState();
}

class _DeconnexionScreenState extends ConsumerState<DeconnexionScreen> {
  _EtapeSortie _etape = _EtapeSortie.confirmation;

  Future<void> _confirmer() async {
    // Purge du stockage avant l'état mémoire : sans cet appel les jetons
    // persistés survivraient à la déconnexion.
    await AuthStorageService.clearAuthData();
    if (!mounted) return;
    ref.read(currentUserProvider.notifier).state = null;
    setState(() => _etape = _EtapeSortie.adieu);

    Future.delayed(DeconnexionScreen.delaiRedirection, () {
      if (mounted) context.go('/auth');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _etape == _EtapeSortie.confirmation,
      child: switch (_etape) {
        _EtapeSortie.confirmation => _Confirmation(
            onConfirmer: _confirmer,
            onAnnuler: () => context.pop(),
          ),
        _EtapeSortie.adieu => const _Adieu(),
      },
    );
  }
}

class _Confirmation extends StatelessWidget {
  const _Confirmation({required this.onConfirmer, required this.onAnnuler});

  final VoidCallback onConfirmer;
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    return TransactionScaffold(
      hautTitre: 47,
      child: Column(
        children: [
          const SizedBox(height: 124),
          const _ArcheSortie(),
          const SizedBox(height: 42),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Text(
              'Êtes vous sûre de vouloir vous\ndéconnecter ?',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.sousTitre.copyWith(
                fontSize: 27,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          BoutonTransaction(
            label: 'Oui, me déconnecter',
            onPressed: onConfirmer,
          ),
          const SizedBox(height: 24),
          BoutonTransaction(
            label: 'Non, Retour dans Mon Espace',
            dore: false,
            onPressed: onAnnuler,
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

/// Arche blanche de 217 × 275 cerclée d'or, portant le mot de sortie.
class _ArcheSortie extends StatelessWidget {
  const _ArcheSortie();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217,
      height: 275,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.p20,
        AppSpacing.p32,
        AppSpacing.p20,
        AppSpacing.p24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ClosetColors.fond300, width: AppStroke.fin),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(159)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(
            Icons.waving_hand_outlined,
            size: 54,
            color: ClosetColors.fond300,
          ),
          const Spacer(),
          Text(
            'Par ici la sortie Mme',
            textAlign: TextAlign.center,
            style: ClosetTextStyles.sousTitre.copyWith(
              letterSpacing: 0.38,
              color: ClosetColors.vert,
            ),
          ),
        ],
      ),
    );
  }
}

class _Adieu extends StatelessWidget {
  const _Adieu();

  @override
  Widget build(BuildContext context) {
    return TransactionScaffold(
      mention: 'Vous serez automatiquement redirigé vers l’écran d’accueil '
          'd’ici quelques secondes',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
            child: Text(
              'Ce n’est qu’un au revoir !',
              textAlign: TextAlign.center,
              style: ClosetTextStyles.sousTitre.copyWith(
                fontSize: 20,
                color: ClosetColors.fond300,
              ),
            ),
          ),
          const SizedBox(height: 62),
          const TexteTransaction(
            'Vous êtes maintenant déconnecté en toute sécurité. Prenez soin '
            'de vous, nous avons déjà hâte de vous retrouver !',
          ),
          const Spacer(),
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
