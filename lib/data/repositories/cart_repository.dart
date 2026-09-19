import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/closet_l10n.dart';
import '../../core/widgets/toasts.dart';
import '../../features/auth/auth_screen.dart';
import '../api/api_exception.dart';
import '../models/article.dart';
import '../services/local_storage_service.dart';
import 'catalog_repository.dart';

// ── Local storage provider (async initialisation) ────────────────────────────

final localStorageProvider = FutureProvider<LocalStorageService>((ref) async {
  return LocalStorageService.create();
});

// ── Cart ─────────────────────────────────────────────────────────────────────

/// Issue d'un ajout à la sélection, pour choisir le message annoncé.
enum AjoutSelection { ajoutee, dejaPresente, indisponible }

class CartNotifier extends AsyncNotifier<List<Article>> {
  late LocalStorageService _storage;

  @override
  Future<List<Article>> build() async {
    _storage = await ref.watch(localStorageProvider.future);
    return _storage.loadCart();
  }

  /// Insertion locale, sur le seul drapeau [Article.isSoldOut] déjà connu.
  /// `false` = pièce non ajoutée car vendue, réservée ou retirée.
  ///
  /// Les ajouts déclenchés par une personne passent par [ajouter], qui
  /// reconfirme d'abord la disponibilité auprès du backend.
  bool addArticle(Article article) {
    if (article.isSoldOut) return false;
    final current = state.value ?? [];
    if (!current.any((a) => a.id == article.id)) {
      final next = [...current, article];
      state = AsyncData(next);
      _storage.saveCart(next);
    }
    return true;
  }

  /// Ajout depuis l'interface : la disponibilité est reconfirmée auprès du
  /// backend juste avant d'insérer la pièce. Le drapeau porté par [article]
  /// vient d'une liste chargée parfois longtemps avant le geste d'ajout — la
  /// pièce peut avoir été vendue ou retirée entre-temps.
  ///
  /// Si l'appel échoue (hors ligne, backend muet), on s'en tient au drapeau
  /// déjà connu : le paiement revérifiera de toute façon côté serveur.
  Future<AjoutSelection> ajouter(Article article) async {
    if (article.isSoldOut) return AjoutSelection.indisponible;
    if (isInCart(article.id)) return AjoutSelection.dejaPresente;
    if (!await _encoreDisponible(article.id)) {
      return AjoutSelection.indisponible;
    }
    addArticle(article);
    return AjoutSelection.ajoutee;
  }

  Future<bool> _encoreDisponible(String id) async {
    try {
      final frais = await ref.read(catalogRepositoryProvider).getById(id);
      // Pièce introuvable = retirée du catalogue.
      if (frais == null) return false;
      return !frais.isSoldOut;
    } on ApiException {
      return true;
    }
  }

  void removeArticle(String id) {
    final next = (state.value ?? []).where((a) => a.id != id).toList();
    state = AsyncData(next);
    _storage.saveCart(next);
  }

  void clear() {
    state = const AsyncData([]);
    _storage.saveCart([]);
  }

  bool isInCart(String id) =>
      (state.value ?? []).any((a) => a.id == id);

  double get total =>
      (state.value ?? []).fold(0, (s, a) => s + a.price);
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<Article>>(
  CartNotifier.new,
);

/// Synchronous convenience list — falls back to [] while async loads.
final cartListProvider = Provider<List<Article>>((ref) {
  return ref.watch(cartProvider).value ?? [];
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartListProvider).fold(0, (s, a) => s + a.price);
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartListProvider).length;
});

/// Ajoute ou retire une pièce de la sélection, puis annonce le résultat.
Future<void> basculerSelection(
  BuildContext context,
  WidgetRef ref,
  Article article,
) async {
  final l10n = ref.read(l10nProvider);
  if (!ref.read(isAuthenticatedProvider)) {
    allerCreerCompte(context, ref);
    return;
  }
  final panier = ref.read(cartProvider.notifier);
  if (panier.isInCart(article.id)) {
    panier.removeArticle(article.id);
    toastActionPiece(
      ref,
      nom: article.title,
      resultat: l10n.retireeDeSelection,
      succes: false,
    );
    return;
  }
  final issue = await panier.ajouter(article);
  // La vérification passe par le réseau : l'écran a pu être quitté entre-temps.
  if (!ref.context.mounted) return;
  switch (issue) {
    case AjoutSelection.ajoutee:
    case AjoutSelection.dejaPresente:
      toastActionPiece(
        ref,
        nom: article.title,
        resultat: l10n.ajouteeASelection,
      );
    case AjoutSelection.indisponible:
      toastInfo(ref, article.title, l10n.pieceNePlusDisponibleMessage);
  }
}
