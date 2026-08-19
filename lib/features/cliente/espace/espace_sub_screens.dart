import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import 'espace_screen.dart';

// ── Common Back Button AppBar ──────────────────────────────────────────────
class EspaceSubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool italicTitle;
  final bool highlightTitle;
  final VoidCallback? onSettingsTap;

  const EspaceSubAppBar({
    super.key,
    required this.title,
    this.italicTitle = false,
    this.highlightTitle = false,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ClosetColors.beige,
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
      title: highlightTitle
          ? ColoredBox(
              color: ClosetColors.jaune100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(title, style: _styleTitre),
              ),
            )
          : Text(title, style: _styleTitre),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: EspaceBoutonRond(
              icone: Icons.tune,
              label: 'Réglages',
              onTap: onSettingsTap ?? () {},
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

  TextStyle get _styleTitre => italicTitle
      ? GoogleFonts.ebGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: ClosetColors.noir,
        )
      : ClosetTextStyles.titreEcran.copyWith(fontSize: 20);

  @override
  Size get preferredSize => const Size.fromHeight(57);
}

// ── 1. Mes Informations Screen ─────────────────────────────────────────────
class EspaceInfoScreen extends ConsumerStatefulWidget {
  const EspaceInfoScreen({super.key});

  @override
  ConsumerState<EspaceInfoScreen> createState() => _EspaceInfoScreenState();
}

class _EspaceInfoScreenState extends ConsumerState<EspaceInfoScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read<ClosetUser?>(currentUserProvider);
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: '+237 677 45 22 18');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveInfo() {
    // Update local currentUser state
    final user = ref.read<ClosetUser?>(currentUserProvider);
    if (user != null) {
      ref.read(currentUserProvider.notifier).state = user.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informations enregistrées avec succès.'),
        backgroundColor: ClosetColors.vert,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: const EspaceSubAppBar(title: 'Mes informations'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('PRÉNOM', _firstNameController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildField('NOM', _lastNameController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildField('ADRESSE EMAIL', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildField('TÉLÉPHONE', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
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
                  onPressed: _saveInfo,
                  child: const Text(
                    'Enregistrer les modifications',
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

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: ClosetColors.taupe,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: ClosetColors.noir, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: ClosetColors.taupe, size: 20),
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
      ],
    );
  }
}

// ── 2. Mes Adresses Screen ─────────────────────────────────────────────────
class EspaceAdressesScreen extends StatefulWidget {
  const EspaceAdressesScreen({super.key});

  @override
  State<EspaceAdressesScreen> createState() => _EspaceAdressesScreenState();
}

class _EspaceAdressesScreenState extends State<EspaceAdressesScreen> {
  final List<Map<String, dynamic>> _adresses = [
    {
      'id': '1',
      'label': 'Maison',
      'address': '61480 Sunbrook Park, PC 5679',
      'isDefault': true,
    },
    {
      'id': '2',
      'label': 'Bureau',
      'address': '69993 Meadow Valley Terra, PC 3637',
      'isDefault': false,
    },
    {
      'id': '3',
      'label': 'Appartement',
      'address': '21833 Clyde Gallagher, PC 4662',
      'isDefault': false,
    },
    {
      'id': '4',
      'label': 'Maison Familiale',
      'address': '5259 Blue Bill Park, PC 4627',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: const EspaceSubAppBar(
        title: 'Mes adresses',
        italicTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        itemCount: _adresses.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 1,
          color: ClosetColors.ligne.withValues(alpha: 0.7),
        ),
        itemBuilder: (context, index) {
          final addr = _adresses[index];
          return _AddressListTile(
            label: addr['label'] as String,
            address: addr['address'] as String,
            isDefault: addr['isDefault'] as bool,
            onEdit: () {},
          );
        },
      ),
    );
  }
}

class _AddressListTile extends StatelessWidget {
  const _AddressListTile({
    required this.label,
    required this.address,
    required this.isDefault,
    required this.onEdit,
  });

  final String label;
  final String address;
  final bool isDefault;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ClosetColors.vert,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_outlined, size: 22, color: ClosetColors.creme),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.noir,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF98C1B0).withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PAR DÉFAUT',
                          style: GoogleFonts.lato(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: ClosetColors.vert,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  address,
                  style: GoogleFonts.lato(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: ClosetColors.taupe,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(left: 10, top: 2),
              child: Icon(Icons.edit_outlined, size: 20, color: Color(0xFFC49A6C)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3. Mes Moyens de Paiement Screen ───────────────────────────────────────
class EspacePaiementsScreen extends StatefulWidget {
  const EspacePaiementsScreen({super.key});

  @override
  State<EspacePaiementsScreen> createState() => _EspacePaiementsScreenState();
}

class _EspacePaiementsScreenState extends State<EspacePaiementsScreen> {
  final List<Map<String, dynamic>> _methods = [
    {
      'id': '1',
      'type': 'Orange Money',
      'number': '+237 6 99 ••• •••',
      'icon': Icons.phone_android,
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'MTN MoMo',
      'number': '+237 6 77 ••• •••',
      'icon': Icons.phone_android,
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: const EspaceSubAppBar(title: 'Moyens de paiement'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COMPTES DE FACTURATION ENREGISTRÉS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.taupe,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _methods.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = _methods[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: ClosetColors.creme,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ClosetColors.bordure),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: ClosetColors.vert.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item['icon'] as IconData, color: ClosetColors.vert),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['type'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: ClosetColors.noir,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['number'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ClosetColors.taupe,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item['isDefault'] as bool)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ClosetColors.dore.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Principal',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: ClosetColors.doreEncre,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulation: Ajout d\'un compte Orange ou MTN.'),
                        backgroundColor: ClosetColors.vert,
                      ),
                    );
                  },
                  child: const Text(
                    '+ Ajouter un moyen de paiement',
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

// ── 4. Mes Alertes Pièces Screen ───────────────────────────────────────────
class EspaceAlertesScreen extends StatefulWidget {
  const EspaceAlertesScreen({super.key});

  @override
  State<EspaceAlertesScreen> createState() => _EspaceAlertesScreenState();
}

class _EspaceAlertesScreenState extends State<EspaceAlertesScreen> {
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'brand': 'Sézane',
      'criteria': 'Robes · Taille 38',
      'active': true,
    },
    {
      'id': '2',
      'brand': 'Jacquemus',
      'criteria': 'Sacs · Toutes tailles',
      'active': true,
    },
    {
      'id': '3',
      'brand': 'Maje',
      'criteria': 'Vestes · Taille 36 / 38',
      'active': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.ivoire,
      appBar: const EspaceSubAppBar(title: 'Mes alertes pièces'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ALERTES DE RECHERCHE ACTIVES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.taupe,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _alerts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: ClosetColors.creme,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ClosetColors.bordure),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert['brand'] as String,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: ClosetColors.noir,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  alert['criteria'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ClosetColors.taupe,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: alert['active'] as bool,
                            activeColor: ClosetColors.dore,
                            activeTrackColor: ClosetColors.vert,
                            onChanged: (val) {
                              setState(() {
                                alert['active'] = val;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _alerts.removeAt(index);
                              });
                            },
                            child: const Icon(Icons.delete_outline, color: ClosetColors.erreur, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 5. FAQ & Aide Screen ───────────────────────────────────────────────────
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

// ── 6. Nous Contacter Screen ───────────────────────────────────────────────
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
                foregroundColor: Colors.white,
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

// ── 7. Politique de Confidentialité Screen ──────────────────────────────────
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

// ── 8. Nous Évaluer Screen (New Option) ──────────────────────────────────────
class EspaceEvaluationScreen extends StatefulWidget {
  const EspaceEvaluationScreen({super.key});

  @override
  State<EspaceEvaluationScreen> createState() => _EspaceEvaluationScreenState();
}

class _EspaceEvaluationScreenState extends State<EspaceEvaluationScreen> {
  int _starsSelected = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_starsSelected == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une étoile.'),
          backgroundColor: ClosetColors.erreur,
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ClosetColors.ivoire,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: ClosetColors.vert),
              SizedBox(width: 10),
              Text(
                'Merci pour votre avis !',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ClosetColors.noir),
              ),
            ],
          ),
          content: const Text(
            'Vos commentaires précieux nous permettent d\'améliorer l\'expérience de dressing privé ClosET chaque jour.',
            style: TextStyle(fontSize: 13, height: 1.4, color: ClosetColors.noir),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ClosetColors.vert,
                foregroundColor: ClosetColors.creme,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.pop(); // Pop EspaceEvaluationScreen
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
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
