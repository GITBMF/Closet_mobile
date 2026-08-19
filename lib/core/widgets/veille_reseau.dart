import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'toasts.dart';

final connectiviteProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Affiche un toast quand le réseau tombe ou revient.
class VeilleReseau extends ConsumerStatefulWidget {
  const VeilleReseau({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<VeilleReseau> createState() => _VeilleReseauState();
}

class _VeilleReseauState extends ConsumerState<VeilleReseau> {
  var _dejaHorsLigne = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(connectiviteProvider, (precedent, suivant) {
      suivant.whenData((resultats) {
        final horsLigne = resultats.isEmpty ||
            resultats.every((r) => r == ConnectivityResult.none);
        if (horsLigne && !_dejaHorsLigne) {
          toastInfo(
            ref,
            'Hors connexion',
            'Certaines actions seront indisponibles jusqu’au retour du réseau.',
          );
        } else if (!horsLigne && _dejaHorsLigne) {
          toastSucces(ref, 'Connexion rétablie');
        }
        _dejaHorsLigne = horsLigne;
      });
    });
    return widget.child;
  }
}
