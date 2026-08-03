import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/repositories/sourceur_repository.dart';
import '../widgets/sourceur_app_bar.dart';

class SourceurEspaceScreen extends ConsumerStatefulWidget {
  const SourceurEspaceScreen({super.key});

  @override
  ConsumerState<SourceurEspaceScreen> createState() => _SourceurEspaceScreenState();
}

class _SourceurEspaceScreenState extends ConsumerState<SourceurEspaceScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = ref.watch<SourceurRepository>(sourceurRepositoryProvider);
    final profile = repo.profile;
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final nomAtelier = profile?.nomAtelier ?? 'Mon Atelier';
    final ville = profile?.ville ?? 'Yaoundé';
    final depuis = profile?.depuis ?? 'Juillet 2026';
    final whatsapp = profile?.whatsapp ?? '';
    final univers = profile?.univers ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SourceurAppBar(
        title: 'Mon Espace',
        subtitle: 'PREFÉRENCES ATELIER',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: ClosetColors.dore),
            tooltip: 'Modifier mon profil',
            onPressed: () {
              HapticFeedback.lightImpact();
              if (profile != null) {
                _showEditModal(context, repo, profile, theme);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 22),
            color: onSurfaceColor,
            tooltip: 'Mes revenus',
            onPressed: () => context.go('/sourceur/revenus'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 22),
            color: onSurfaceColor,
            tooltip: 'Espace client',
            onPressed: () => context.go('/espace'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profil Card ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: onSurfaceColor.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: ClosetColors.vert,
                      shape: BoxShape.circle,
                      border: Border.all(color: ClosetColors.dore, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.storefront_outlined,
                        color: ClosetColors.creme,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nomAtelier,
                    style: GoogleFonts.ebGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ville.toUpperCase()} · MEMBRE DEPUIS ${depuis.toUpperCase()}',
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      color: isDark ? ClosetColors.doreClair : ClosetColors.doreEncre,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (whatsapp.isNotEmpty || univers.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Divider(color: theme.dividerColor.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (univers.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                'UNIVERS',
                                style: GoogleFonts.lato(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceColor.withValues(alpha: 0.5),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                univers,
                                style: GoogleFonts.cormorant(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ],
                          ),
                        if (whatsapp.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                'WHATSAPP',
                                style: GoogleFonts.lato(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceColor.withValues(alpha: 0.5),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                whatsapp,
                                style: GoogleFonts.cormorant(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Section Préférences ──────────────────────────────────────────
            Text(
              'PRÉFÉRENCES',
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor.withValues(alpha: 0.5),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
              ),
              child: SwitchListTile(
                value: isDark,
                onChanged: (value) {
                  ref.read<ThemeModeNotifier>(themeModeProvider.notifier).toggleTheme();
                },
                activeThumbColor: isDark ? ClosetColors.doreClair : ClosetColors.dore,
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: onSurfaceColor,
                ),
                title: Text(
                  'Mode sombre',
                  style: GoogleFonts.ebGaramond(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: onSurfaceColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Section Actions ──────────────────────────────────────────────
            Text(
              'NAVIGATION',
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: onSurfaceColor.withValues(alpha: 0.5),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
              ),
              child: ListTile(
                onTap: () => context.go('/espace'),
                leading: Icon(
                  Icons.person_pin_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  "Retourner à l'espace client",
                  style: GoogleFonts.ebGaramond(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: onSurfaceColor.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, SourceurRepository repo, SourceurProfile profile, ThemeData theme) {
    final nomAtelierCtrl = TextEditingController(text: profile.nomAtelier);
    final villeCtrl = TextEditingController(text: profile.ville);
    final whatsappCtrl = TextEditingController(text: profile.whatsapp);
    final universCtrl = TextEditingController(text: profile.univers);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final onSurfaceColor = theme.colorScheme.onSurface;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier mon profil',
                style: GoogleFonts.ebGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nomAtelierCtrl,
                style: ClosetTextStyles.saisie.copyWith(color: onSurfaceColor),
                decoration: InputDecoration(
                  labelText: 'Nom de l\'atelier',
                  labelStyle: ClosetTextStyles.labelChamp.copyWith(
                    color: onSurfaceColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: villeCtrl,
                style: ClosetTextStyles.saisie.copyWith(color: onSurfaceColor),
                decoration: InputDecoration(
                  labelText: 'Ville',
                  labelStyle: ClosetTextStyles.labelChamp.copyWith(
                    color: onSurfaceColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: whatsappCtrl,
                style: ClosetTextStyles.saisie.copyWith(color: onSurfaceColor),
                decoration: InputDecoration(
                  labelText: 'Numéro WhatsApp',
                  labelStyle: ClosetTextStyles.labelChamp.copyWith(
                    color: onSurfaceColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: universCtrl,
                style: ClosetTextStyles.saisie.copyWith(color: onSurfaceColor),
                decoration: InputDecoration(
                  labelText: 'Univers (ex: Vintage, Luxe...)',
                  labelStyle: ClosetTextStyles.labelChamp.copyWith(
                    color: onSurfaceColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ClosetColors.vert,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final updated = profile.copyWith(
                      nomAtelier: nomAtelierCtrl.text.trim(),
                      ville: villeCtrl.text.trim(),
                      whatsapp: whatsappCtrl.text.trim(),
                      univers: universCtrl.text.trim(),
                    );
                    repo.updateProfile(updated);
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    'ENREGISTRER',
                    style: ClosetTextStyles.bouton.copyWith(
                      color: ClosetColors.creme,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
