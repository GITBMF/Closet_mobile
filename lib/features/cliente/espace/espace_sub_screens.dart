import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_layout.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/toasts.dart';
import 'espace_screen.dart';

// -- Common Back Button AppBar ----------------------------------------------
class EspaceSubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool italicTitle;
  final VoidCallback? onSettingsTap;

  const EspaceSubAppBar({
    super.key,
    required this.title,
    this.italicTitle = false,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final layout = ClosetLayout.of(context);
    final largeurLeading = layout.gouttiere + layout.cibleTactile;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: ClosetLayout.hauteurBarre,
      leading: Padding(
        padding: EdgeInsets.only(left: layout.gouttiere),
        child: Center(
          child: EspaceBoutonRond(
            icone: Icons.arrow_back,
            label: l10n.retour,
            onTap: () => context.pop(),
          ),
        ),
      ),
      leadingWidth: largeurLeading,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: italicTitle
            ? GoogleFonts.ebGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: ClosetColors.noir,
              )
            : ClosetTextStyles.titreEcran.copyWith(fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        if (onSettingsTap != null)
          Padding(
            padding: EdgeInsets.only(right: layout.gouttiere),
            child: Center(
              child: EspaceBoutonRond(
                icone: Icons.tune,
                label: l10n.espaceReglages,
                onTap: onSettingsTap!,
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: ClosetColors.ligne.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(ClosetLayout.hauteurBarre + 1);
}

// -- 1. Mes Moyens de Paiement Screen ---------------------------------------
class EspacePaiementsScreen extends ConsumerWidget {
  const EspacePaiementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: EspaceSubAppBar(title: l10n.espaceMoyensPaiement),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: ClosetListeVide(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ClosetColors.vert,
                    foregroundColor: ClosetColors.creme,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => toastInfo(
                    ref,
                    l10n.espaceIndisponibleTitre,
                    l10n.espacePaiementIndisponible,
                  ),
                  child: Text(
                    l10n.espaceAjouterMoyenPaiement,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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



// -- 4. Mes notifications ---------------------------------------------------
class EspaceAlertesScreen extends StatelessWidget {
  const EspaceAlertesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: EspaceSubAppBar(title: l10n.espaceMesNotifications),
      body: ClosetListeVide(
        message: l10n.espaceNotifsVideMessage,
        action: () => context.go('/home'),
        libelleAction: l10n.espaceRetourDressing,
      ),
    );
  }
}


// -- 5. FAQ & Aide Screen ---------------------------------------------------
class EspaceFaqScreen extends StatelessWidget {
  const EspaceFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final faq = [
      (l10n.espaceFaqQ1, l10n.espaceFaqA1),
      (l10n.espaceFaqQ2, l10n.espaceFaqA2),
      (l10n.espaceFaqQ3, l10n.espaceFaqA3),
      (l10n.espaceFaqQ4, l10n.espaceFaqA4),
    ];
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: EspaceSubAppBar(title: l10n.espaceFaqTitre),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: faq.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: ClosetColors.creme,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ClosetColors.bordure),
              ),
              child: ExpansionTile(
                iconColor: ClosetColors.dore,
                collapsedIconColor: ClosetColors.vert,
                shape: const Border(),
                title: Text(
                  faq[i].$1,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.noir,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faq[i].$2,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: ClosetColors.noir.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// -- 6. Nous Contacter Screen -----------------------------------------------
class EspaceContactScreen extends StatelessWidget {
  const EspaceContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: EspaceSubAppBar(title: l10n.espaceNousContacter),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.espaceConciergerieClient,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.closetSecondaire,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildContactCard(
                icon: Icons.chat_bubble_outline,
                title: l10n.espaceWhatsappConciergerie,
                subtitle: '+237 699 00 00 00',
                btnLabel: l10n.espaceDiscuterWhatsapp,
                color: Colors.green,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _buildContactCard(
                icon: Icons.email_outlined,
                title: l10n.espaceAssistanceEmail,
                subtitle: 'support@closet.com',
                btnLabel: l10n.espaceEnvoyerEmail,
                color: ClosetColors.vert,
                onTap: () {},
              ),
              const Spacer(),
              Center(
                child: Text(
                  l10n.espaceDisponibilite,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.noir.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String btnLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ClosetColors.creme,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ClosetColors.bordure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ClosetColors.dore, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ClosetColors.noir),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: ClosetColors.taupe),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: ClosetColors.blanc,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
              child: Text(
                btnLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -- 7. Politique de Confidentialité Screen ----------------------------------
class EspaceConfidentialiteScreen extends StatelessWidget {
  const EspaceConfidentialiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: EspaceSubAppBar(title: l10n.espaceConfidentialite),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.espaceProtectionDonnees,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.closetSecondaire,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _PolicySection(title: l10n.espacePolicy1Titre, body: l10n.espacePolicy1Corps),
              const SizedBox(height: 24),
              _PolicySection(title: l10n.espacePolicy2Titre, body: l10n.espacePolicy2Corps),
              const SizedBox(height: 24),
              _PolicySection(title: l10n.espacePolicy3Titre, body: l10n.espacePolicy3Corps),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ClosetColors.noir),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: TextStyle(fontSize: 13, height: 1.5, color: ClosetColors.noir.withValues(alpha: 0.75)),
        ),
      ],
    );
  }
}

// -- 8. Nous Évaluer Screen (New Option) --------------------------------------
class EspaceEvaluationScreen extends ConsumerStatefulWidget {
  const EspaceEvaluationScreen({super.key});

  @override
  ConsumerState<EspaceEvaluationScreen> createState() =>
      _EspaceEvaluationScreenState();
}

class _EspaceEvaluationScreenState
    extends ConsumerState<EspaceEvaluationScreen> {
  int _starsSelected = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    final l10n = ClosetL10n.of(context);
    if (_starsSelected == 0) {
      toastInfo(ref, l10n.espaceNoteManquanteTitre, l10n.espaceSelectionnerEtoile);
      return;
    }

    toastInfo(
      ref,
      l10n.espaceAvisNonTransmisTitre,
      l10n.espaceAvisNonTransmisCorps,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: EspaceSubAppBar(title: l10n.espaceEvaluerTitre),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.espacePartagezExperience,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.closetSecondaire,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ClosetColors.creme,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ClosetColors.bordure),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.espaceQuelleNote,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ClosetColors.noir),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isSelected = starValue <= _starsSelected;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _starsSelected = starValue;
                            });
                          },
                          child: Icon(
                            isSelected ? Icons.star : Icons.star_border,
                            color: isSelected ? ClosetColors.dore : ClosetColors.taupe,
                            size: 40,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.espaceVotreCommentaire,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.closetSecondaire,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                maxLines: 5,
                style: const TextStyle(color: ClosetColors.noir, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.espaceCommentaireHint,
                  hintStyle: TextStyle(color: context.closetSecondaire, fontSize: 13),
                  filled: true,
                  fillColor: ClosetColors.creme,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ClosetColors.bordure),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ClosetColors.bordure),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ClosetColors.vert, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ClosetColors.vert,
                    foregroundColor: ClosetColors.creme,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _submitFeedback,
                  child: Text(
                    l10n.espaceEnvoyerAvis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
