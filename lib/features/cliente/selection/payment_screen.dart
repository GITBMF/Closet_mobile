import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import 'confirmation_screen.dart';
import '../../main_layout.dart';
import '../espace/notifications_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0; // 0 for MoMo, 1 for OM, 2 for CB

  Widget _buildAppBarAction(
    IconData icon, {
    int badgeCount = 0,
    Color? badgeColor,
    Color badgeTextColor = Colors.white,
    VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: ClosetColors.ligne),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(icon, color: ClosetColors.vertFonce, size: 20),
            onPressed: onPressed ?? () {},
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor ?? ClosetColors.erreur,
                  shape: BoxShape.circle,
                  border: Border.all(color: ClosetColors.creme, width: 1.5),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep(
    String number,
    String label, {
    bool isActive = false,
    bool isCompleted = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isActive
                ? ClosetColors.vertFonce
                : (isCompleted ? ClosetColors.doreClair : Colors.transparent),
            shape: BoxShape.circle,
            border: (isActive || isCompleted)
                ? null
                : Border.all(color: ClosetColors.taupe.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : (isCompleted ? ClosetColors.vertFonce : ClosetColors.taupe),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 1.0,
            color: isActive ? ClosetColors.vertFonce : ClosetColors.taupe,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required Color iconBgColor,
    required String iconText,
    required String title,
    required String subtitle,
    required IconData iconSubtitle,
  }) {
    final bool isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : ClosetColors.creme,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ClosetColors.vertFonce : ClosetColors.ligne,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                iconText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(iconSubtitle, size: 12, color: ClosetColors.taupe),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: ClosetColors.taupe,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? ClosetColors.vertFonce
                      : ClosetColors.taupe.withValues(alpha: 0.3),
                  width: isSelected ? 6 : 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ClosetColors.ligne),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chevron_left,
                  color: ClosetColors.vertFonce,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiement',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const Text(
                  'ÉTAPE 3 / 3',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.taupe,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _buildAppBarAction(
            Icons.search,
            onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 1)), (route) => false),
          ),
          _buildAppBarAction(
            Icons.favorite_border,
            badgeCount: 2,
            badgeColor: ClosetColors.erreur,
            onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 2)), (route) => false),
          ),
          _buildAppBarAction(
            Icons.shopping_bag_outlined,
            badgeCount: 2,
            badgeColor: ClosetColors.vertFonce,
            onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 1)), (route) => false),
          ),
          _buildAppBarAction(
            Icons.notifications_none,
            badgeCount: 2,
            badgeColor: ClosetColors.doreClair,
            badgeTextColor: ClosetColors.vertFonce,
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => const NotificationsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 12.0,
          bottom: 40.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStep('1', 'SÉLECTION', isCompleted: true),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 1,
                  color: ClosetColors.taupe.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                _buildStep('2', 'LIVRAISON', isCompleted: true),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 1,
                  color: ClosetColors.taupe.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                _buildStep('3', 'PAIEMENT', isActive: true),
              ],
            ),

            const SizedBox(height: 32),

            // Header text
            const Text(
              'ÉTAPE FINALE',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w700,
                color: ClosetColors.doreEncre,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Régler ma sélection',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: ClosetColors.vertFonce,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choisissez votre mode de paiement — nous préparons votre écrin avec le plus grand soin.',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: ClosetColors.taupe,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ClosetColors.creme,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ClosetColors.ligne),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: ClosetColors.doreEncre,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'LIVRAISON À',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              color: ClosetColors.taupe,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'MODIFIER',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                          color: ClosetColors.doreEncre,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Awa Diallo',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Résidence les Palmiers, Bastos, Yaoundé',
                          style: TextStyle(
                            fontSize: 12,
                            color: ClosetColors.taupe,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Methods
            _buildPaymentOption(
              index: 0,
              iconBgColor: const Color(0xFFFFCC00),
              iconText: 'MoMo',
              title: 'MTN MoMo',
              subtitle: 'Paiement mobile instantané',
              iconSubtitle: Icons.phone_android,
            ),
            _buildPaymentOption(
              index: 1,
              iconBgColor: const Color(0xFFFF6600),
              iconText: 'OM',
              title: 'Orange Money',
              subtitle: 'Confirmation immédiate',
              iconSubtitle: Icons.phone_android,
            ),
            _buildPaymentOption(
              index: 2,
              iconBgColor: const Color(0xFF1A1A1A),
              iconText: 'CB',
              title: 'Carte bancaire',
              subtitle: 'Visa · Mastercard',
              iconSubtitle: Icons.credit_card,
            ),

            const SizedBox(height: 16),

            // Phone Number Input
            if (_selectedPaymentMethod == 0 || _selectedPaymentMethod == 1)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ClosetColors.creme,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ClosetColors.ligne),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPaymentMethod == 0
                          ? 'NUMÉRO MTN'
                          : 'NUMÉRO ORANGE',
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: ClosetColors.taupe,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(
                        text: '+237 6 77 45 22 18',
                      ),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: ClosetColors.ligne,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                      ),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: ClosetColors.vertFonce,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vous recevrez une notification USSD pour valider le paiement.',
                      style: TextStyle(fontSize: 11, color: ClosetColors.taupe),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Footer Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ClosetColors.vertFonce,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'À RÉGLER',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                      color: ClosetColors.doreClair,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '66 500 FCFA',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: ClosetColors.doreClair,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Livraison délicate incluse · Bastos, Yaoundé',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 33),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfirmationScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2C26), // Darker green for button
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'CONFIRMER LE PAIEMENT',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Security Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 12, color: ClosetColors.taupe),
                const SizedBox(width: 6),
                const Text(
                  'CRYPTAGE BANCAIRE · TRANSACTION PROTÉGÉE',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.taupe,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
