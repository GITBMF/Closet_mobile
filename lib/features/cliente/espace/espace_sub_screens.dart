import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
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
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: EspaceBoutonRond(
            icone: Icons.arrow_back,
            label: 'Retour',
            onTap: () => context.pop(),
          ),
        ),
      ),
      leadingWidth: 72,
      title: Text(
        title,
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
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: EspaceBoutonRond(
                icone: Icons.tune,
                label: 'Réglages',
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
  Size get preferredSize => const Size.fromHeight(57);
}

// -- 1. Mes Moyens de Paiement Screen ---------------------------------------
class EspacePaiementsScreen extends ConsumerWidget {
  const EspacePaiementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: const EspaceSubAppBar(title: 'Moyens de paiement'),
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
                    'Indisponible',
                    'L’enregistrement d’un moyen de paiement n’est pas encore proposé par le serveur.',
                  ),
                  child: const Text(
                    '+ Ajouter un moyen de paiement',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const EspaceSubAppBar(title: 'Mes notifications'),
      body: ClosetListeVide(
        message:
            'Les nouveautés de vos maisons, le suivi de vos pièces et les '
            'confirmations de commande s’afficheront ici.',
        action: () => context.go('/home'),
        libelleAction: 'Retour au dressing',
      ),
    );
  }
}


// -- 5. FAQ & Aide Screen ---------------------------------------------------
class EspaceFaqScreen extends StatelessWidget {
  const EspaceFaqScreen({super.key});

  static const _faq = [
    {
      'q': 'Comment se passe la livraison au Cameroun ?',
      'a': 'Nous livrons à domicile ou en point relais partenaire à Yaoundé et Douala sous 24h à 48h. Pour les autres villes, des expéditions sécurisées sont organisées par agence de voyage sous 72h.',
    },
    {
      'q': 'Les articles sont-ils authentiques ?',
      'a': 'Absolument. Chaque pièce soumise par nos sourceurs passe par une double vérification physique par notre équipe d\'experts avant d\'être publiée en ligne.',
    },
    {
      'q': 'Quelles sont les conditions de retour ?',
      'a': 'S\'agissant de pièces uniques de seconde main haut de gamme, les retours sont acceptés uniquement sous 24h après réception si l\'article ne correspond pas aux photos ou à la description.',
    },
    {
      'q': 'Comment devenir sourceur de pièces ?',
      'a': 'Rendez-vous dans la section « Espace Sourceur » de votre profil, renseignez les informations sur votre atelier et demandez à rejoindre le cercle des sourceurs certifiés.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: const EspaceSubAppBar(title: 'FAQ & Aide'),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: _faq.length,
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
                  _faq[i]['q']!,
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
                      _faq[i]['a']!,
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
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: const EspaceSubAppBar(title: 'Nous contacter'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CONCIERGERIE CLIENT CLOSET',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.taupe,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildContactCard(
                icon: Icons.chat_bubble_outline,
                title: 'WhatsApp Conciergerie',
                subtitle: '+237 699 00 00 00',
                btnLabel: 'Discuter sur WhatsApp',
                color: Colors.green,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _buildContactCard(
                icon: Icons.email_outlined,
                title: 'Assistance E-mail',
                subtitle: 'support@closet.com',
                btnLabel: 'Nous envoyer un e-mail',
                color: ClosetColors.vert,
                onTap: () {},
              ),
              const Spacer(),
              Center(
                child: Text(
                  'DISPONIBLE 7J/7 · 9H00 À 19H00',
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
    return const Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: EspaceSubAppBar(title: 'Confidentialité'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROTECTION DES DONNÉES CLOSET',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.taupe,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20),
              _PolicySection(
                title: '1. Collecte des données',
                body: 'Dans le cadre de votre dressing privé, nous collectons des données de profil (nom, prénom, e-mail, historique d\'achats et de favoris) dans le seul but de personnaliser vos sélections de mode seconde main de luxe.',
              ),
              SizedBox(height: 24),
              _PolicySection(
                title: '2. Sécurité des transactions',
                body: 'Toutes les transactions effectuées par Orange Money, MTN MoMo ou carte de crédit sont sécurisées et cryptées par nos prestataires certifiés. Nous ne stockons aucun mot de passe de paiement.',
              ),
              SizedBox(height: 24),
              _PolicySection(
                title: '3. Partage d\'informations',
                body: 'Chez ClosET, nous respectons scrupuleusement la vie privée de notre clientèle. Vos choix stylistiques et préférences de recherche ne sont jamais revendus ni partagés avec des partenaires tiers.',
              ),
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
    if (_starsSelected == 0) {
      toastInfo(ref, 'Note manquante', 'Veuillez sélectionner au moins une étoile.');
      return;
    }

    toastInfo(
      ref,
      'Avis non transmis',
      'Le serveur n’expose pas encore de dépôt d’évaluation. Votre note n’a pas été envoyée.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: const EspaceSubAppBar(title: 'Nous évaluer'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PARTAGEZ VOTRE EXPÉRIENCE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.taupe,
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
                    const Text(
                      'Quelle note attribuez-vous à l\'application ?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ClosetColors.noir),
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
              const Text(
                'VOTRE COMMENTAIRE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.taupe,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                maxLines: 5,
                style: const TextStyle(color: ClosetColors.noir, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Aidez-nous à nous améliorer en écrivant un commentaire...',
                  hintStyle: const TextStyle(color: ClosetColors.taupe, fontSize: 13),
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
                  child: const Text(
                    'Envoyer mon avis',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
