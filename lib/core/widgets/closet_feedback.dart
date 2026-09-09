import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/sourceur/widgets/sourceur_header.dart';
import '../l10n/closet_l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/closet_colors.dart';
import '../theme/closet_text_styles.dart';
import 'closet_buttons.dart';

/// Liste vide — aucune donnée renvoyée par le backend.
class ClosetListeVide extends StatelessWidget {
  const ClosetListeVide({
    super.key,
    this.titre,
    this.message,
    this.action,
    this.libelleAction,
  });

  final String? titre;
  final String? message;
  final VoidCallback? action;
  final String? libelleAction;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final titreAffiche = titre ?? l10n.listeVideTitre;
    final messageAffiche = message ?? l10n.listeVideMessage;
    final contenu = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: ClosetColors.fond300,
          ),
          const SizedBox(height: AppSpacing.p20),
          Text(
            titreAffiche,
            textAlign: TextAlign.center,
            style: ClosetTextStyles.titreSection,
          ),
          const SizedBox(height: AppSpacing.p12),
          Text(
            messageAffiche,
            textAlign: TextAlign.center,
            style: ClosetTextStyles.citation.copyWith(
              color: ClosetColors.taupe,
            ),
          ),
          if (action != null && libelleAction != null) ...[
            const SizedBox(height: AppSpacing.p24),
            ClosetPrimaryButton(
              label: libelleAction!,
              dore: true,
              hauteur: AppSpacing.minTouchTarget,
              onPressed: action,
            ),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight && constraints.maxHeight > 200) {
          return Center(child: contenu);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: contenu,
        );
      },
    );
  }
}

/// En-tête centré des sous-pages (favoris, commandes, dépôts) — Figma `25:924`.
class ClosetPageHeader extends StatelessWidget {
  const ClosetPageHeader({
    super.key,
    required this.titre,
    this.onRetour,
    this.action,
    this.italique = true,
  });

  final String titre;
  final VoidCallback? onRetour;
  final Widget? action;
  final bool italique;

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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.p20,
          AppSpacing.p8,
          AppSpacing.p20,
          AppSpacing.p12,
        ),
        child: Row(
          children: [
            SourceurBoutonRond(
              icone: Icons.arrow_back_ios_new,
              label: ClosetL10n.of(context).retour,
              onTap: onRetour ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
            ),
            Expanded(
              child: Text(
                titre,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ClosetTextStyles.accroche.copyWith(
                  fontWeight: FontWeight.w600,
                  fontStyle: italique ? FontStyle.italic : FontStyle.normal,
                  color: ClosetColors.noir,
                ),
              ),
            ),
            SizedBox(
              width: 42,
              child: action ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fenêtre modale de chargement, succès ou erreur.
class ClosetDialogue {
  ClosetDialogue._();

  static Future<void> chargement(
    BuildContext context, {
    String? message,
  }) {
    final texte = message ?? ClosetL10n.of(context).chargementMessage;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.carte),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: ClosetColors.dore),
              const SizedBox(height: AppSpacing.p20),
              Text(
                texte,
                textAlign: TextAlign.center,
                style: ClosetTextStyles.corps,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> resultat(
    BuildContext context, {
    required bool succes,
    required String titre,
    required String message,
    String libelle = 'OK',
  }) {
    final ok = libelle == 'OK' ? ClosetL10n.of(context).ok : libelle;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        title: Column(
          children: [
            Icon(
              succes
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              size: 40,
              color: succes ? ClosetColors.emeraude400 : ClosetColors.erreur,
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreSection,
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: ClosetTextStyles.citation.copyWith(color: ClosetColors.taupe),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 200,
            child: ClosetPrimaryButton(
              label: ok,
              dore: succes,
              hauteur: 44,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  /// Demande de connexion avant une sélection — l'invitée ne voit pas le panier.
  static Future<bool> connexionRequise(
    BuildContext context, {
    String? message,
  }) async {
    final l10n = ClosetL10n.of(context);
    final aller = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        title: Column(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 40,
              color: ClosetColors.vert,
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              l10n.connexionRequise,
              textAlign: TextAlign.center,
              style: ClosetTextStyles.titreSection,
            ),
          ],
        ),
        content: Text(
          message ?? l10n.connexionRequiseSelection,
          textAlign: TextAlign.center,
          style: ClosetTextStyles.citation.copyWith(color: ClosetColors.taupe),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.plusTard,
              style: ClosetTextStyles.corps.copyWith(color: ClosetColors.taupe),
            ),
          ),
          const SizedBox(width: AppSpacing.p8),
          SizedBox(
            width: 160,
            child: ClosetPrimaryButton(
              label: l10n.seConnecter,
              dore: true,
              hauteur: 44,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
    return aller == true;
  }

  static void fermer(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// Affiche le chargement pendant [action], puis le ferme.
  static Future<T?> executer<T>(
    BuildContext context, {
    required Future<T> Function() action,
    String? message,
  }) async {
    final texte = message ?? ClosetL10n.of(context).chargementMessage;
    final nav = Navigator.of(context, rootNavigator: true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.carte),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: ClosetColors.dore),
                const SizedBox(height: AppSpacing.p20),
                Text(
                  texte,
                  textAlign: TextAlign.center,
                  style: ClosetTextStyles.corps,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    try {
      final resultat = await action();
      if (nav.canPop()) nav.pop();
      return resultat;
    } catch (_) {
      if (nav.canPop()) nav.pop();
      rethrow;
    }
  }
}
