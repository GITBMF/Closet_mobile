import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/cart_repository.dart';

enum DeliveryOption { yaoundeDouala, otherCities }
enum PaymentOption { card, mtnMoney, orangeMoney }

final deliveryOptionProvider =
    StateProvider<DeliveryOption>((ref) => DeliveryOption.yaoundeDouala);
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

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Cameroun');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final thousands = intPrice ~/ 1000;
    final remainder = intPrice % 1000;
    if (remainder == 0) return '$thousands 000 FCFA';
    return '$thousands ${remainder.toString().padLeft(3, '0')} FCFA';
  }

  double _getDeliveryCost(DeliveryOption option) {
    switch (option) {
      case DeliveryOption.yaoundeDouala:
        return 2500;
      case DeliveryOption.otherCities:
        return 5000;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartTotalProvider);
    final cartItems = ref.watch(cartListProvider);
    final deliveryOption = ref.watch(deliveryOptionProvider);
    final paymentOption = ref.watch(paymentOptionProvider);
    final deliveryCost = _getDeliveryCost(deliveryOption);
    final total = subtotal + deliveryCost;
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (_step > 0 && _step < 2) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
          child: Icon(Icons.arrow_back_ios_new,
              size: 18, color: onSurfaceColor),
        ),
        title: Text(
          'Finaliser ma sélection',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: onSurfaceColor,
          ),
        ),
      ),
      body: _step == 2
          ? _ConfirmationView(onGoHome: () {
              // Clear cart after checkout is confirmed
              ref.read(cartProvider.notifier).clear();
              context.go('/home');
            })
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
                            nameController: _nameController,
                            phoneController: _phoneController,
                            addressController: _addressController,
                            cityController: _cityController,
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
                    color: theme.colorScheme.surface,
                    border: Border(top: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1))),
                    boxShadow: [
                      BoxShadow(
                        color: onSurfaceColor.withValues(alpha: 0.06),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${cartItems.length} pièce${cartItems.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: onSurfaceColor.withValues(alpha: 0.6),
                                ),
                              ),
                              Text(
                                'Livraison : ${_formatPrice(deliveryCost)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: onSurfaceColor.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatPrice(total),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
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
                                    if (_nameController.text.isEmpty ||
                                        _phoneController.text.isEmpty ||
                                        _addressController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Veuillez remplir tous les champs de livraison.')),
                                      );
                                      return;
                                    }
                                    setState(() => _step = 1);
                                  } else {
                                    setState(() => _isPlacing = true);
                                    await Future<void>.delayed(
                                        const Duration(milliseconds: 1500));
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
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isPlacing
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary),
                                    )
                                  : Text(
                                      _step == 0
                                          ? 'Continuer vers le paiement'
                                          : 'Confirmer ma commande',
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          _StepDot(label: 'Livraison', index: 0, current: currentStep),
          Expanded(
              child: Container(
                  height: 1,
                  color: currentStep >= 1
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.2))),
          _StepDot(label: 'Paiement', index: 1, current: currentStep),
          Expanded(
              child: Container(
                  height: 1,
                  color: currentStep >= 2
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.2))),
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
    final theme = Theme.of(context);
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
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: isDone || isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check, size: 14, color: theme.colorScheme.onPrimary)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;

  const _DeliveryStep({
    required this.selected,
    required this.onChanged,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MODE DE LIVRAISON (CAMEROUN)',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: onSurfaceColor.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        _DeliveryCard(
          title: 'Livraison Yaoundé / Douala',
          subtitle: 'Sous 24h · Écrin ClosET inclus',
          price: '2 500 FCFA',
          icon: Icons.electric_moped_outlined,
          isSelected: selected == DeliveryOption.yaoundeDouala,
          onTap: () => onChanged(DeliveryOption.yaoundeDouala),
        ),
        const SizedBox(height: 12),
        _DeliveryCard(
          title: 'Autres villes du Cameroun',
          subtitle: 'Expédition sous 48h-72h par agence',
          price: '5 000 FCFA',
          icon: Icons.local_shipping_outlined,
          isSelected: selected == DeliveryOption.otherCities,
          onTap: () => onChanged(DeliveryOption.otherCities),
        ),
        const SizedBox(height: 28),
        Text(
          'ADRESSE DE LIVRAISON',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: onSurfaceColor.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        ...[
          _AddressField(label: 'Prénom & Nom du destinataire', icon: Icons.person_outline, controller: nameController),
          const SizedBox(height: 10),
          _AddressField(label: 'Numéro de téléphone (+237)', icon: Icons.phone_outlined, controller: phoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          _AddressField(label: 'Quartier / Adresse complète', icon: Icons.location_on_outlined, controller: addressController),
          const SizedBox(height: 10),
          _AddressField(label: 'Ville / Pays', icon: Icons.public_outlined, controller: cityController, readOnly: true),
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
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.15),
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
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 20,
                  color: isSelected ? theme.colorScheme.primary : onSurfaceColor.withValues(alpha: 0.6)),
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
                          ? theme.colorScheme.primary
                          : onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11, color: onSurfaceColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? theme.colorScheme.primary : onSurfaceColor,
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
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;

  const _AddressField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 14, color: onSurfaceColor),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(fontSize: 13, color: onSurfaceColor.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, size: 18, color: onSurfaceColor.withValues(alpha: 0.5)),
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
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOYEN DE PAIEMENT',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: onSurfaceColor.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        _PaymentCard(
          title: 'Carte bancaire',
          subtitle: 'Visa · Mastercard · Sigue · UBA',
          icon: Icons.credit_card_outlined,
          isSelected: selected == PaymentOption.card,
          onTap: () => onChanged(PaymentOption.card),
        ),
        const SizedBox(height: 12),
        _PaymentCard(
          title: 'MTN Mobile Money',
          subtitle: 'Paiement instantané via MoMo',
          imageAsset: 'assets/mtn.png',
          isSelected: selected == PaymentOption.mtnMoney,
          onTap: () => onChanged(PaymentOption.mtnMoney),
        ),
        const SizedBox(height: 12),
        _PaymentCard(
          title: 'Orange Money',
          subtitle: 'Paiement instantané via Orange Money',
          imageAsset: 'assets/orange.png',
          isSelected: selected == PaymentOption.orangeMoney,
          onTap: () => onChanged(PaymentOption.orangeMoney),
        ),
        const SizedBox(height: 28),
        if (selected == PaymentOption.card) ...[
          Text(
            'INFORMATIONS CARTE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor.withValues(alpha: 0.5),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          _AddressField(
              label: 'Numéro de carte', icon: Icons.credit_card, controller: TextEditingController()),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _AddressField(
                      label: 'MM/AA', icon: Icons.calendar_today_outlined, controller: TextEditingController())),
              const SizedBox(width: 10),
              Expanded(
                  child: _AddressField(
                      label: 'CVV', icon: Icons.lock_outline, controller: TextEditingController())),
            ],
          ),
          const SizedBox(height: 10),
          _AddressField(label: 'Nom sur la carte', icon: Icons.person_outline, controller: TextEditingController()),
        ],
        if (selected == PaymentOption.mtnMoney || selected == PaymentOption.orangeMoney) ...[
          Text(
            'TÉLÉPHONE PAIEMENT MOBILE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor.withValues(alpha: 0.5),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          _AddressField(
              label: 'Numéro de téléphone Mobile Money', icon: Icons.phone_android_outlined, controller: TextEditingController(), keyboardType: TextInputType.phone),
        ],
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imageAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.title,
    required this.subtitle,
    this.icon,
    this.imageAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.15),
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
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: imageAsset != null
                  ? ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          imageAsset!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.payment_outlined,
                            size: 20,
                            color: isSelected ? theme.colorScheme.primary : onSurfaceColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    )
                  : Icon(icon ?? Icons.payment_outlined,
                      size: 20,
                      color: isSelected ? theme.colorScheme.primary : onSurfaceColor.withValues(alpha: 0.6)),
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
                          ? theme.colorScheme.primary
                          : onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 11, color: onSurfaceColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.2),
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
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

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
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 54,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Commande confirmée !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre sélection a été reçue.\nNos équipes préparent votre commande avec soin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: onSurfaceColor.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vous recevrez un SMS de confirmation\navec le suivi de votre livraison.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: onSurfaceColor.withValues(alpha: 0.5),
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
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Retour à mon dressing',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
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
