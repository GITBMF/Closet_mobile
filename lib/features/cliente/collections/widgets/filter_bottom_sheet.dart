import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/closet_colors.dart';
import '../../../../../core/widgets/closet_chip.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Mock state for filters
  String _selectedUnivers = 'Robes';
  String _selectedTaille = 'M';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ClosetColors.beige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: ClosetColors.ligne,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Affiner ma recherche',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: ClosetColors.vertFonce,
                ),
              ),
              const Text(
                'Tout réinitialiser',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B6C3F), // doreEncre equivalent
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Univers
                  const Text(
                    'UNIVERS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF8B6C3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip('Robes', _selectedUnivers == 'Robes', (v) => setState(() => _selectedUnivers = v)),
                      _buildChip('Vestes', _selectedUnivers == 'Vestes', (v) => setState(() => _selectedUnivers = v)),
                      _buildChip('Jupes', _selectedUnivers == 'Jupes', (v) => setState(() => _selectedUnivers = v)),
                      _buildChip('Sacs', _selectedUnivers == 'Sacs', (v) => setState(() => _selectedUnivers = v)),
                      _buildChip('Chaussures', _selectedUnivers == 'Chaussures', (v) => setState(() => _selectedUnivers = v)),
                      _buildChip('Accessoires', _selectedUnivers == 'Accessoires', (v) => setState(() => _selectedUnivers = v)),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Taille
                  const Text(
                    'TAILLE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF8B6C3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip('XS', _selectedTaille == 'XS', (v) => setState(() => _selectedTaille = v)),
                      _buildChip('S', _selectedTaille == 'S', (v) => setState(() => _selectedTaille = v)),
                      _buildChip('M', _selectedTaille == 'M', (v) => setState(() => _selectedTaille = v)),
                      _buildChip('L', _selectedTaille == 'L', (v) => setState(() => _selectedTaille = v)),
                      _buildChip('XL', _selectedTaille == 'XL', (v) => setState(() => _selectedTaille = v)),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // État
                  const Text(
                    'ÉTAT DE LA PIÈCE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF8B6C3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip('Neuf', false, (v) {}),
                      _buildChip('Très bon état', false, (v) {}),
                      _buildChip('Bon état', false, (v) {}),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Prix
                  const Text(
                    'PRIX',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFF8B6C3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mock Slider UI
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 24,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 4,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ClosetColors.ligne,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Positioned(
                                left: 30,
                                right: 80,
                                child: Container(
                                  height: 4,
                                  color: ClosetColors.vertFonce,
                                ),
                              ),
                              Positioned(
                                left: 20,
                                child: _buildSliderThumb(),
                              ),
                              Positioned(
                                right: 70,
                                child: _buildSliderThumb(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('10 000 F', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ClosetColors.vertFonce)),
                            Text('45 000 F', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ClosetColors.vertFonce)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Bottom Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: ClosetColors.vertFonce,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Voir 18 pièces',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isActive, Function(String) onTap) {
    return ClosetChip(
      label: label,
      isActive: isActive,
      onTap: () => onTap(label),
    );
  }
  
  Widget _buildSliderThumb() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: ClosetColors.creme,
        shape: BoxShape.circle,
        border: Border.all(color: ClosetColors.vertFonce, width: 2.5),
      ),
    );
  }
}
