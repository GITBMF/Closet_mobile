import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/cart_repository.dart';

enum DeliveryOption { abidjan, international }
enum PaymentOption { card, mobile, bank }

final deliveryOptionProvider =
    StateProvider<DeliveryOption>((ref) => DeliveryOption.abidjan);
final paymentOptionProvider =
    StateProvider<PaymentOption>((ref) => PaymentOption.card);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0; // 0: delivery, 1: payment, 2: confirmation
  bool _isPlacing = false;

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final thousands = intPrice ~/ 1000;
    final remainder = intPrice % 1000;
    if (remainder == 0) return '$thousands 000 FCFA';
    return '$thousands ${remainder.toString().padLeft(3, '0')} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);
    final cartItems = ref.watch(cartProvider);
    final deliveryOption = ref.watch(deliveryOptionProvider);
    final paymentOption = ref.watch(paymentOptionProvider);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.blackCloset),
        ),
        title: const Text(
          'Finaliser ma sélection',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.blackCloset,
          ),
        ),
      ),
      body: _step == 2
          ? _ConfirmationView(onGoHome: () => context.go('/home'))
          : Column(
              children: [
                // Progress stepper
                _StepBar(currentStep: _step),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _step == 0
                        ? _DeliveryStep(
                            selected: deliveryOption,
                            onChanged: (v) => ref
                                .read(deliveryOptionProvider.notifier)
                                .state = v,
                          )
                        : _PaymentStep(
                            selected: paymentOption,
                            onChanged: (v) => ref
                                .read(paymentOptionProvider.notifier)
                                .state = v,
                          ),
                  ),
                ),
                // Order summary + CTA
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  decoration: BoxDecoration(
                    color: AppTheme.warmCream,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cartItems.length} pièce${cartItems.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.greyText,
                            ),
                          ),
                          Text(
                            _formatPrice(total),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.blackCloset,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _isPlacing
                              ? null
                              : () async {
                                  if (_step == 0) {
                                    setState(() => _step = 1);
                                  } else {
                                    setState(() => _isPlacing = true);
                                    await Future.delayed(
                                        const Duration(milliseconds: 1500));
                                    ref.read(cartProvider.notifier);
                                    if (mounted) {
                                      setState(() {
                                        _isPlacing = false;
                                        _step = 2;
                                      });
                                    }
                                  }
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isPlacing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : Text(
                                      _step == 0
                                          ? 'Continuer vers le paiement'
                                          : 'Confirmer ma commande',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Step bar ─────────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int currentStep;
  const _StepBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          _StepDot(label: 'Livraison', index: 0, current: currentStep),
          Expanded(
              child: Container(
                  height: 1,
                  color: currentStep >= 1
                      ? AppTheme.forestGreen
                      : AppTheme.sandBeige)),
          _StepDot(label: 'Paiement', index: 1, current: currentStep),
          Expanded(
              child: Container(
                  height: 1,
                  color: currentStep >= 2
                      ? AppTheme.forestGreen
                      : AppTheme.sandBeige)),
          _StepDot(label: 'Confirmé', index: 2, current: currentStep),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  const _StepDot({required this.label, required this.index, required this.current});

  @override
  Widget build(BuildContext context) {
    final isDone = index < current;
    final isActive = index == current;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isActive
                ? AppTheme.forestGreen
                : AppTheme.sandBeige,
            border: Border.all(
              color: isDone || isActive
                  ? AppTheme.forestGreen
                  : AppTheme.sandBeige,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppTheme.greyText,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isActive ? AppTheme.forestGreen : AppTheme.greyText,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ── Delivery Step ─────────────────────────────────────────────────────────────

class _DeliveryStep extends StatelessWidget {
  final DeliveryOption selected;
  final void Function(DeliveryOption) onChanged;
  const _DeliveryStep({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MODE DE LIVRAISON',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.greyText,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        _DeliveryCard(
          title: 'Livraison Abidjan / Yaoundé',
          subtitle: 'Sous 24h · Écrin ClosET inclus',
          price: '2 500 FCFA',
          icon: Icons.electric_moped_outlined,
          isSelected: selected == DeliveryOption.abidjan,
          onTap: () => onChanged(DeliveryOption.abidjan),
        ),
        const SizedBox(height: 12),
        _DeliveryCard(
          title: 'Expédition internationale',
          subtitle: 'Sous 5 jours ouvrés · Paris inclus',
          price: '8 000 FCFA',
          icon: Icons.flight_takeoff_outlined,
          isSelected: selected == DeliveryOption.international,
          onTap: () => onChanged(DeliveryOption.international),
        ),
        const SizedBox(height: 28),
        const Text(
          'ADRESSE DE LIVRAISON',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.greyText,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        ...[
          _AddressField(label: 'Prénom & Nom', icon: Icons.person_outline),
          const SizedBox(height: 10),
          _AddressField(label: 'Téléphone', icon: Icons.phone_outlined),
          const SizedBox(height: 10),
          _AddressField(label: 'Adresse complète', icon: Icons.location_on_outlined),
          const SizedBox(height: 10),
          _AddressField(label: 'Ville / Pays', icon: Icons.public_outlined),
        ],
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _DeliveryCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.forestGreen.withValues(alpha: 0.06)
              : AppTheme.warmCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.forestGreen : AppTheme.sandBeige,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.forestGreen.withValues(alpha: 0.1)
                    : AppTheme.sandBeige,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 20,
                  color: isSelected ? AppTheme.forestGreen : AppTheme.greyText),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppTheme.forestGreen
                          : AppTheme.blackCloset,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.greyText),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    isSelected ? AppTheme.forestGreen : AppTheme.blackCloset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final String label;
  final IconData icon;
  const _AddressField({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warmCream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.sandBeige),
      ),
      child: TextField(
        style: const TextStyle(fontSize: 14, color: AppTheme.blackCloset),
        decoration: InputDecoration(
          hintText: label,
          hintStyle:
              const TextStyle(fontSize: 13, color: AppTheme.greyText),
          prefixIcon: Icon(icon, size: 18, color: AppTheme.greyText),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Payment Step ──────────────────────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  final PaymentOption selected;
  final void Function(PaymentOption) onChanged;
  const _PaymentStep({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MOYEN DE PAIEMENT',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.greyText,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        _PaymentCard(
          title: 'Carte bancaire',
          subtitle: 'Visa · Mastercard · Paiement sécurisé',
          icon: Icons.credit_card_outlined,
          isSelected: selected == PaymentOption.card,
          onTap: () => onChanged(PaymentOption.card),
        ),
        const SizedBox(height: 12),
        _PaymentCard(
          title: 'Mobile Money',
          subtitle: 'MTN · Orange · Wave',
          icon: Icons.phone_android_outlined,
          isSelected: selected == PaymentOption.mobile,
          onTap: () => onChanged(PaymentOption.mobile),
        ),
        const SizedBox(height: 12),
        _PaymentCard(
          title: 'Virement bancaire',
          subtitle: 'Informations fournies après commande',
          icon: Icons.account_balance_outlined,
          isSelected: selected == PaymentOption.bank,
          onTap: () => onChanged(PaymentOption.bank),
        ),
        const SizedBox(height: 28),
        if (selected == PaymentOption.card) ...[
          const Text(
            'INFORMATIONS CARTE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.greyText,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          _AddressField(
              label: 'Numéro de carte', icon: Icons.credit_card),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                  child: _AddressField(
                      label: 'MM/AA', icon: Icons.calendar_today_outlined)),
              SizedBox(width: 10),
              Expanded(
                  child: _AddressField(
                      label: 'CVV', icon: Icons.lock_outline)),
            ],
          ),
          const SizedBox(height: 10),
          _AddressField(label: 'Nom sur la carte', icon: Icons.person_outline),
        ],
        if (selected == PaymentOption.mobile) ...[
          const SizedBox(height: 14),
          _AddressField(
              label: 'Numéro de téléphone', icon: Icons.phone_outlined),
        ],
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _PaymentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.forestGreen.withValues(alpha: 0.06)
              : AppTheme.warmCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.forestGreen : AppTheme.sandBeige,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.forestGreen.withValues(alpha: 0.1)
                    : AppTheme.sandBeige,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 20,
                  color:
                      isSelected ? AppTheme.forestGreen : AppTheme.greyText),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppTheme.forestGreen
                          : AppTheme.blackCloset,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.greyText),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.forestGreen : AppTheme.sandBeige,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirmation ──────────────────────────────────────────────────────────────

class _ConfirmationView extends StatelessWidget {
  final VoidCallback onGoHome;
  const _ConfirmationView({required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.forestGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 54,
                color: AppTheme.forestGreen,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Commande confirmée !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.blackCloset,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Votre sélection a été reçue.\nNos équipes préparent votre commande avec soin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.greyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vous recevrez un e-mail de confirmation\navec le suivi de votre livraison.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.greyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: onGoHome,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 36, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Retour à mon dressing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
