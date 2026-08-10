import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../data/repositories/cart_repository.dart';

enum DeliveryOption { yaoundeDouala, otherCities }

enum PaymentOption { mtnMoney, orangeMoney, creditCard }

final deliveryOptionProvider = StateProvider<DeliveryOption>(
  (ref) => DeliveryOption.yaoundeDouala,
);
final paymentOptionProvider = StateProvider<PaymentOption>(
  (ref) => PaymentOption.mtnMoney,
);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0; // 0: delivery, 1: payment, 2: confirmation
  bool _isPlacing = false;
  bool _validatedInformations = false;

  final _nameController = TextEditingController(text: 'Aïcha N.');
  final _phoneController = TextEditingController(text: '+237 6 90 12 34 56');
  final _addressController = TextEditingController(
    text: 'Bastos, Rue de la Cascade',
  );
  final _cityController = TextEditingController(text: 'Yaoundé');

  bool _deliveryExpanded = true;
  String? _selectedRegion;
  String? _selectedDepartement;
  final _quartierController = TextEditingController();
  final _momoPhoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvcController = TextEditingController();
  String _orderId = '';

  static const Map<String, List<String>> _regionsAndDepartements = {
    'Adamaoua': ['Vina', 'Mbéré', 'Djérem', 'Faro-et-Déo', 'Mayo-Banyo'],
    'Centre': [
      'Mfoundi',
      'Lekié',
      'Nyong-et-So\'o',
      'Nyong-et-Mfoumou',
      'Nyong-et-Kéllé',
      'Mbam-et-Kim',
      'Mbam-et-Inoubou',
      'Haute-Sanaga',
      'Mefou-et-Afamba',
      'Mefou-et-Akono'
    ],
    'Est': ['Lom-et-Djérem', 'Boumba-et-Ngoko', 'Kadey', 'Haut-Nyong'],
    'Extrême-Nord': [
      'Diamaré',
      'Logone-et-Chari',
      'Mayo-Danay',
      'Mayo-Kani',
      'Mayo-Sava',
      'Mayo-Tsanaga'
    ],
    'Littoral': ['Wouri', 'Moungo', 'Sanaga-Maritime', 'Nkam'],
    'Nord': ['Bénoué', 'Faro', 'Mayo-Louti', 'Mayo-Rey'],
    'Nord Ouest': [
      'Mezam',
      'Boyo',
      'Bui',
      'Donga-Mantung',
      'Menchum',
      'Momo',
      'Ngo-Ketunjia'
    ],
    'Ouest': [
      'Mifi',
      'Bamboutos',
      'Haut-Nkam',
      'Menoua',
      'Ndé',
      'Noun',
      'Koung-Khi',
      'Hauts-Plateaux'
    ],
    'Sud': ['Mvila', 'Dja-et-Lobo', 'Océan', 'Vallée-du-Ntem'],
    'Sud-Ouest': [
      'Fako',
      'Meme',
      'Ndian',
      'Manyu',
      'Lebialem',
      'Kupe-Manenguba'
    ],
  };

  @override
  void initState() {
    super.initState();
    _momoPhoneController.text = _phoneController.text;
    _orderId = 'CE-${1000 + (DateTime.now().microsecond % 9000)}';
    _phoneController.addListener(() {
      _momoPhoneController.text = _phoneController.text;
    });
    _quartierController.addListener(() {
      _addressController.text = '${_selectedDepartement ?? ''}, ${_quartierController.text}';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _quartierController.dispose();
    _momoPhoneController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvcController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    if (intPrice >= 1000) {
      final thousands = intPrice ~/ 1000;
      final remainder = intPrice % 1000;
      if (remainder == 0) {
        return '$thousands.000 FCFA';
      }
      return '$thousands.${remainder.toString().padLeft(3, '0')} FCFA';
    }
    return '$intPrice FCFA';
  }

  double _getDeliveryCost(DeliveryOption option) {
    switch (option) {
      case DeliveryOption.yaoundeDouala:
        return 3500; // Match selection screen delivery fee (3.500 FCFA)
      case DeliveryOption.otherCities:
        return 5000;
    }
  }

  void _showDeliveryBottomSheet() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Consumer(
                  builder: (context, ref, _) {
                    final option = ref.watch(deliveryOptionProvider);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choisir la ville de livraison',
                          style: GoogleFonts.lato(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: ClosetColors.noir,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _TownRadioTile(
                          title: 'Yaoundé',
                          subtitle: 'Livraison à domicile 24h-48h',
                          isSelected:
                              option == DeliveryOption.yaoundeDouala &&
                              _cityController.text == 'Yaoundé',
                          onTap: () {
                            ref.read(deliveryOptionProvider.notifier).state =
                                DeliveryOption.yaoundeDouala;
                            setState(() {
                              _cityController.text = 'Yaoundé';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: ClosetColors.ligne, height: 1),
                        _TownRadioTile(
                          title: 'Douala',
                          subtitle: 'Livraison à domicile 24h-48h',
                          isSelected:
                              option == DeliveryOption.yaoundeDouala &&
                              _cityController.text == 'Douala',
                          onTap: () {
                            ref.read(deliveryOptionProvider.notifier).state =
                                DeliveryOption.yaoundeDouala;
                            setState(() {
                              _cityController.text = 'Douala';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(color: ClosetColors.ligne, height: 1),
                        _TownRadioTile(
                          title: 'Autre',
                          subtitle: 'A determiner',
                          isSelected: option == DeliveryOption.otherCities,
                          onTap: () {
                            ref.read(deliveryOptionProvider.notifier).state =
                                DeliveryOption.otherCities;
                            setState(() {
                              _cityController.text = 'Autre';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                top: -40,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ClosetColors.creme,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final option = ref.watch(paymentOptionProvider);
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moyen de paiement',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ClosetColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<PaymentOption>(
                    title: const Text('MTN Mobile Money'),
                    value: PaymentOption.mtnMoney,
                    groupValue: option,
                    activeColor: ClosetColors.vert,
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(paymentOptionProvider.notifier).state = v;
                      }
                    },
                  ),
                  RadioListTile<PaymentOption>(
                    title: const Text('Orange Money'),
                    value: PaymentOption.orangeMoney,
                    groupValue: option,
                    activeColor: ClosetColors.vert,
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(paymentOptionProvider.notifier).state = v;
                      }
                    },
                  ),
                  RadioListTile<PaymentOption>(
                    title: const Text('Carte bancaire'),
                    value: PaymentOption.creditCard,
                    groupValue: option,
                    activeColor: ClosetColors.vert,
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(paymentOptionProvider.notifier).state = v;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClosetColors.vert,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Enregistrer',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetField(
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: ClosetColors.taupe),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ClosetColors.ligne),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: ClosetColors.vert),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartTotalProvider);
    final deliveryOption = ref.watch(deliveryOptionProvider);
    final paymentOption = ref.watch(paymentOptionProvider);
    final deliveryCost = _getDeliveryCost(deliveryOption);
    final total = subtotal + deliveryCost;

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (_step > 0 && _step < 2) {
                  setState(() => _step--);
                } else {
                  context.pop();
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ClosetColors.ligne),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: ClosetColors.vertFonce,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _step == 0 ? 'Ma sélection' : 'Finaliser ma sélection',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ClosetColors.vertFonce,
              ),
            ),
            Text(
              _step == 0 ? 'ETAPE 1/3' : 'ETAPE 2/3',
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: ClosetColors.taupe,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 18,
                color: ClosetColors.vertFonce,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_none,
                size: 18,
                color: ClosetColors.vertFonce,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _step == 2
          ? _ConfirmationView(
              onGoHome: () {
                ref.read(cartProvider.notifier).clear();
                context.go('/collections');
              },
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      120,
                    ), // Spacing for bottom button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Stepper
                        _StepBar(currentStep: _step),
                        const SizedBox(height: 16),

                        if (_step == 0) ...[
                          // Nom complet Field
                          _buildLabeledField(
                            label: 'Nom complet',
                            hintText: 'Aïcha N.',
                            controller: _nameController,
                          ),
                          const SizedBox(height: 16),

                          // Téléphone (Whatsapp) Field
                          _buildLabeledField(
                            label: 'Téléphone (Whatsapp)',
                            hintText: '+237 6 90 12 34 56',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Nous vous écrirons sur WhatsApp pour suivre votre pièce.',
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: ClosetColors.taupe,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Location Detail Collapsible Card
                          _buildCollapsibleCard(
                            title: 'Détails de livraison',
                            subtitle: _selectedRegion != null && _selectedDepartement != null && _quartierController.text.isNotEmpty
                                ? '$_selectedRegion, $_selectedDepartement, ${_quartierController.text}'
                                : 'Veuillez entrez vos informations',
                            icon: Icons.location_on_outlined,
                            isExpanded: _deliveryExpanded,
                            onTap: () {
                              setState(() {
                                _deliveryExpanded = !_deliveryExpanded;
                              });
                            },
                          ),
                          if (_deliveryExpanded) ...[
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    label: 'Région',
                                    value: _selectedRegion,
                                    items: _regionsAndDepartements.keys.toList(),
                                    hintText: 'Choisir',
                                    onChanged: (v) {
                                      setState(() {
                                        _selectedRegion = v;
                                        _selectedDepartement = null; // Reset department
                                        _cityController.text = v ?? '';
                                        _addressController.text = _quartierController.text;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDropdownField(
                                    label: 'Département',
                                    value: _selectedDepartement,
                                    items: _selectedRegion != null
                                        ? _regionsAndDepartements[_selectedRegion]!
                                        : [],
                                    hintText: 'Choisir',
                                    onChanged: (v) {
                                      setState(() {
                                        _selectedDepartement = v;
                                        _addressController.text = '${v ?? ''}, ${_quartierController.text}';
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildLabeledField(
                              label: 'Quartier',
                              hintText: 'Veuillez écrire le nom de votre quartier',
                              controller: _quartierController,
                            ),
                          ],
                          const SizedBox(height: 12),

                          // Payment Detail Collapsible Card
                          _buildCollapsibleCard(
                            title: 'Méthode de paiement',
                            subtitle: paymentOption == PaymentOption.mtnMoney
                                ? 'MTN Mobile Money'
                                : paymentOption == PaymentOption.orangeMoney
                                ? 'Orange Money'
                                : 'Carte bancaire',
                            icon: Icons.account_balance_wallet_outlined,
                            onTap: _showPaymentBottomSheet,
                          ),
                          const SizedBox(height: 20),

                          // Validation switch row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'VALIDER LES INFORMATIONS',
                                style: GoogleFonts.lato(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: ClosetColors.vertFonce,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              CupertinoSwitch(
                                value: _validatedInformations,
                                activeColor: ClosetColors.vert,
                                trackColor: ClosetColors.ligne.withValues(
                                  alpha: 0.3,
                                ),
                                onChanged: (v) {
                                  setState(() => _validatedInformations = v);
                                },
                              ),
                            ],
                          ),
                        ] else ...[
                          // Étape 2 — Paiement
                          Text(
                            'Étape 2 — Paiement',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ClosetColors.vertFonce,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 1. MTN Mobile Money Option
                          _buildPaymentMethodTile(
                            option: PaymentOption.mtnMoney,
                            title: 'MTN Mobile Money',
                            subtitle: 'Validation sur votre téléphone',
                            logoWidget: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFCE00),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'MTN',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 2. Orange Money Option
                          _buildPaymentMethodTile(
                            option: PaymentOption.orangeMoney,
                            title: 'Orange Money',
                            subtitle: 'Validation sur votre téléphone',
                            logoWidget: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6600),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'OM',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 3. Carte bancaire Option
                          _buildPaymentMethodTile(
                            option: PaymentOption.creditCard,
                            title: 'Carte bancaire',
                            subtitle: 'Visa · paiement sécurisé Stripe',
                            logoWidget: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ClosetColors.vertFonce,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.credit_card,
                                color: ClosetColors.doreClair,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Conditional Inputs based on selected method
                          if (paymentOption == PaymentOption.mtnMoney || paymentOption == PaymentOption.orangeMoney) ...[
                            _buildLabeledField(
                              label: paymentOption == PaymentOption.mtnMoney ? 'Numéro MTN MoMo' : 'Numéro Orange Money',
                              hintText: '+237 6 90 12 34 56',
                              controller: _momoPhoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Un message de confirmation s'affichera sur ce numéro.",
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: ClosetColors.taupe,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else ...[
                            // Card Details
                            _buildLabeledField(
                              label: 'Numéro de carte',
                              hintText: '4242 4242 4242 4242',
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLabeledField(
                                    label: 'Date d\'expiration',
                                    hintText: 'MM/AA',
                                    controller: _cardExpiryController,
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildLabeledField(
                                    label: 'Code CVC',
                                    hintText: '123',
                                    controller: _cardCvcController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Summary Total box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: ClosetColors.creme,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: ClosetColors.ligne),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total à régler',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: ClosetColors.noir,
                                  ),
                                ),
                                Text(
                                  _formatPrice(total),
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ClosetColors.vertFonce,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Security notice
                          Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: ClosetColors.vertFonce,
                                size: 15,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Paiement chiffré. Votre pièce est réservée pendant 15 minutes.',
                                  style: GoogleFonts.lato(
                                    fontSize: 11,
                                    color: ClosetColors.taupe,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Button
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: GestureDetector(
                    onTap: _isPlacing
                        ? null
                        : () async {
                            if (_step == 0) {
                              if (_nameController.text.isEmpty ||
                                  _phoneController.text.isEmpty ||
                                  _selectedRegion == null ||
                                  _selectedDepartement == null ||
                                  _quartierController.text.isEmpty ||
                                  !_validatedInformations) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Veuillez remplir tous les champs et cocher la validation.',
                                    ),
                                    backgroundColor: ClosetColors.erreur,
                                  ),
                                );
                                return;
                              }
                              setState(() => _step = 1);
                            } else {
                              setState(() => _isPlacing = true);
                              await Future<void>.delayed(
                                const Duration(milliseconds: 1500),
                              );
                              if (mounted) {
                                setState(() {
                                  _isPlacing = false;
                                  _step = 2;
                                });
                              }
                            }
                          },
                    child: _step == 0
                        ? Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: ClosetColors.creme,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: ClosetColors.dore,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Poursuivre -Paiement',
                                style: GoogleFonts.lato(
                                  color: ClosetColors.doreEncre,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: ClosetColors.vert,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _isPlacing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Confirmer — ${_formatPrice(total)}',
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: ClosetColors.noir,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ClosetColors.ligne),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.lato(fontSize: 14, color: ClosetColors.noir),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.lato(
                fontSize: 13,
                color: ClosetColors.ligne,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hintText,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: ClosetColors.noir,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ClosetColors.ligne),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hintText,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: ClosetColors.ligne,
                ),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: ClosetColors.taupe,
                size: 20,
              ),
              style: GoogleFonts.lato(fontSize: 14, color: ClosetColors.noir),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentOption option,
    required String title,
    required String subtitle,
    required Widget logoWidget,
  }) {
    final paymentOption = ref.watch(paymentOptionProvider);
    final isSelected = paymentOption == option;

    return GestureDetector(
      onTap: () {
        ref.read(paymentOptionProvider.notifier).state = option;
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ClosetColors.creme,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ClosetColors.vert : ClosetColors.ligne,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            logoWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ClosetColors.vertFonce,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: ClosetColors.taupe,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ClosetColors.vert : ClosetColors.ligne,
                  width: 2,
                ),
                color: isSelected ? ClosetColors.vert : Colors.transparent,
              ),
              padding: const EdgeInsets.all(3),
              child: isSelected
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ClosetColors.creme,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool? isExpanded,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ClosetColors.ligne),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF5EEDF), // Light gold/beige
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: ClosetColors.doreEncre),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ClosetColors.noir,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: ClosetColors.taupe,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isExpanded == null
                  ? Icons.chevron_right
                  : (isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right),
              size: 20,
              color: ClosetColors.taupe,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTextLine(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: ClosetColors.taupe,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ClosetColors.vertFonce,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stepper ──────────────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int currentStep;
  const _StepBar({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: ClosetColors.vert,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: currentStep >= 1
                    ? (currentStep == 1 ? ClosetColors.dore : ClosetColors.vert)
                    : ClosetColors.ligne,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: currentStep >= 2 ? ClosetColors.vert : ClosetColors.ligne,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
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
              decoration: const BoxDecoration(
                color: Color(0xFFD6EBE0), // Light green success bg
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 54,
                color: ClosetColors.succes,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Commande confirmée !',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ClosetColors.vertFonce,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre sélection a été reçue.\nNos équipes préparent votre commande avec soin.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: ClosetColors.taupe,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vous recevrez un message de confirmation sur WhatsApp avec le suivi de votre livraison.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 12, color: ClosetColors.taupe),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ClosetColors.vert,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: onGoHome,
                child: Text(
                  'Retour aux Collections',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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

class _TownRadioTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TownRadioTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ClosetColors.noir,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: ClosetColors.taupe,
                  ),
                ),
              ],
            ),
            isSelected
                ? Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ClosetColors.ligne, width: 2),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
