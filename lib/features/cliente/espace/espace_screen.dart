import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/sourceur_repository.dart';

const _kProfileImage = 'assets/onboarding_1.jpg';

class EspaceScreen extends ConsumerWidget {
  const EspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ClosetUser? user = ref.watch<ClosetUser?>(currentUserProvider);
    final sourceurRepo = ref.watch<SourceurRepository>(sourceurRepositoryProvider);
    final isDark = ref.watch<ThemeMode>(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mon espace',
                    style: GoogleFonts.ebGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.noir,
                      height: 1.1,
                    ),
                  ),
                  EspaceCircleButton(
                    icon: Icons.tune,
                    onTap: () => _showSettingsSheet(context, ref, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Profile ─────────────────────────────────────────────
              _ProfileSection(user: user),
              const SizedBox(height: 20),

              // ── Sourceur Banner ───────────────────────────────────
              if (!sourceurRepo.estInscrit) ...[
                _SourceurBanner(
                  onTap: () => context.push('/sourceur/inscription'),
                ),
                const SizedBox(height: 20),
              ],

              // ── Menu ──────────────────────────────────────────────
              _EspaceMenuItem(
                icon: Icons.inventory_2_outlined,
                label: 'Mes commandes',
                onTap: () {
                  if (user == null) {
                    _showLoginRequiredDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vos commandes seront bientôt disponibles.')),
                    );
                  }
                },
              ),
              _EspaceMenuItem(
                icon: Icons.favorite_border,
                label: 'Mes favoris',
                onTap: () => context.go('/wishlist'),
              ),
              _EspaceMenuItem(
                icon: Icons.location_on_outlined,
                label: 'Mes adresses',
                onTap: () {
                  if (user == null) {
                    context.push('/espace/adresses');
                    // _showLoginRequiredDialog(context);
                  } else {
                    context.push('/espace/adresses');
                  }
                },
              ),
              _EspaceMenuItem(
                icon: Icons.person_outline,
                label: 'Mes informations',
                onTap: () {
                  if (user == null) {
                    _showLoginRequiredDialog(context);
                  } else {
                    context.push('/espace/infos');
                  }
                },
              ),
              _EspaceMenuItem(
                icon: Icons.notifications_none,
                label: 'Mes notifications',
                onTap: () {
                  if (user == null) {
                    _showLoginRequiredDialog(context);
                  } else {
                    context.push('/espace/alertes');
                  }
                },
              ),
              _EspaceMenuItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () {
                  if (user != null) {
                    ref.read(currentUserProvider.notifier).state = null;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vous avez été déconnecté.')),
                    );
                  } else {
                    context.push('/auth');
                  }
                },
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ClosetColors.creme,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Préférences', style: ClosetTextStyles.sectionTitle),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dark_mode_outlined, color: ClosetColors.vert),
                title: Text('Mode sombre', style: ClosetTextStyles.corps),
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: ClosetColors.dore,
                  onChanged: (_) {
                    ref.read<ThemeModeNotifier>(themeModeProvider.notifier).toggleTheme();
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(color: ClosetColors.ligne),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline, color: ClosetColors.vert),
                title: Text('FAQ & aide', style: ClosetTextStyles.corps),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/espace/faq');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined, color: ClosetColors.vert),
                title: Text('Confidentialité', style: ClosetTextStyles.corps),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/espace/confidentialite');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ClosetColors.creme,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: ClosetColors.vert),
              SizedBox(width: 10),
              Text(
                'Connexion requise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ClosetColors.noir,
                ),
              ),
            ],
          ),
          content: const Text(
            'Veuillez vous connecter à votre compte ClosET pour accéder à vos informations personnelles.',
            style: TextStyle(fontSize: 14, color: ClosetColors.noir, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: ClosetColors.taupe, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ClosetColors.vert,
                foregroundColor: ClosetColors.creme,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.push('/auth');
              },
              child: const Text('Se connecter'),
            ),
          ],
        );
      },
    );
  }
}

// ── Shared circle button (also used by sub-screens) ─────────────────────────

class EspaceCircleButton extends StatelessWidget {
  const EspaceCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ClosetColors.creme,
          shape: BoxShape.circle,
          border: Border.all(color: ClosetColors.ligne, width: 1),
        ),
        child: Icon(icon, size: 20, color: ClosetColors.noir),
      ),
    );
  }
}

// ── Profile Section ──────────────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.user});

  final ClosetUser? user;

  String get _displayName {
    if (user == null) return 'Aïcha N.';
    final lastInitial = user!.lastName.isNotEmpty ? '${user!.lastName[0]}.' : '';
    return '${user!.firstName} $lastInitial'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.asset(
            _kProfileImage,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 60,
              height: 60,
              color: ClosetColors.fond300,
              child: const Icon(Icons.person, color: ClosetColors.taupe, size: 32),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _displayName,
                    style: GoogleFonts.lato(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ClosetColors.noir,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.verified, size: 17, color: ClosetColors.dore),
                  const SizedBox(width: 10),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () {
                      // if (user != null) {
                        context.push('/espace/infos');
                      // }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: ClosetColors.vert,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_outlined, size: 15, color: ClosetColors.creme),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Membre du dressing depuis mars 2026',
                style: GoogleFonts.lato(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: ClosetColors.taupe,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sourceur Banner ──────────────────────────────────────────────────────────

class _SourceurBanner extends StatelessWidget {
  const _SourceurBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF98C1B0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NOUVEAU',
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: ClosetColors.vertFonce,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side - takes 50% of the width
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Devenir Sourceur Clos ET',
                        style: GoogleFonts.ebGaramond(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFE1CDA6),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Confiez vos pièces d'exceptionnet rejoignez notre cercle privénde curatrices",
                        style: GoogleFonts.lato(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: ClosetColors.creme.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Right side - takes 50% of the width
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC49A6C),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        "REJOINDRE LE CERCLE",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: ClosetColors.noir,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ── Menu Item ────────────────────────────────────────────────────────────────

class _EspaceMenuItem extends StatelessWidget {
  const _EspaceMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ClosetColors.fond300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: ClosetColors.noir.withValues(alpha: 0.75)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.lato(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: ClosetColors.noir,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: ClosetColors.noir.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: ClosetColors.ligne.withValues(alpha: 0.7),
          ),
      ],
    );
  }
}
