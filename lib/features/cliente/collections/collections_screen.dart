import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/piece_card.dart';
import '../dressing/piece_detail_screen.dart';
import 'widgets/filter_bottom_sheet.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  // Dummy State mimicking Backend Data
  final List<String> _activeFilters = ['Robes', 'Taille M'];
  final List<String> _allFilters = ['Prix', 'Matières', 'Couleurs'];

  final List<Map<String, dynamic>> _pieces = [
    {
      'id': '1',
      'maison': 'MAJE',
      'nom': 'Robe Jardin d\'Été',
      'prix': '29 000 F',
      'imageUrl': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': 'NEUF',
      'isFavorite': true,
      'isSold': false,
    },
    {
      'id': '2',
      'maison': 'ZARA STUDIO',
      'nom': 'Robe Soie Sauvage',
      'prix': '22 500 F',
      'imageUrl': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': null,
      'isFavorite': false,
      'isSold': false,
    },
    {
      'id': '3',
      'maison': 'SANDRO',
      'nom': 'Robe Lumière d\'Or',
      'prix': '41 000 F',
      'imageUrl': 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': null,
      'isFavorite': false,
      'isSold': false,
    },
    {
      'id': '4',
      'maison': 'CLAUDIE P.',
      'nom': 'Robe Velours Nuit',
      'prix': '45 000 F',
      'imageUrl': 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': null,
      'isFavorite': false,
      'isSold': true,
    },
  ];

  void _toggleFavorite(int index) {
    setState(() {
      _pieces[index]['isFavorite'] = !(_pieces[index]['isFavorite'] as bool);
    });
  }

  void _removeFilter(String filter) {
    setState(() {
      _activeFilters.remove(filter);
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClosetColors.creme,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            'Collections',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: ClosetColors.vertFonce,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18, left: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ClosetColors.ligne),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: ClosetColors.vertFonce, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            clipBehavior: Clip.none,
            child: Row(
              children: [
                // Static count chip
                ClosetChip(
                  label: 'Filtres · ${_activeFilters.length}', 
                  isActive: _activeFilters.isNotEmpty,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 60,
                        ),
                        child: const FilterBottomSheet(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                
                // Dynamic active filters
                ..._activeFilters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClosetChip(
                      label: filter,
                      isActive: true,
                      hasCloseIcon: true,
                      onCloseTap: () => _removeFilter(filter),
                    ),
                  );
                }),
                
                // Available inactive filters to tap
                ..._allFilters.map((filter) {
                  if (_activeFilters.contains(filter)) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClosetChip(
                      label: filter,
                      isActive: false,
                      onTap: () => _toggleFilter(filter),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Piece Counter
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Text(
              '18 pièces · triées par nouveautés',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ClosetColors.taupe,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 40.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 0.69,
              ),
              itemCount: _pieces.length,
              itemBuilder: (context, index) {
                final piece = _pieces[index];
                return PieceCard(
                  maison: piece['maison'],
                  nom: piece['nom'],
                  prix: piece['prix'],
                  imageUrl: piece['imageUrl'],
                  isImageArche: piece['isImageArche'],
                  statusBadgeText: piece['statusBadgeText'],
                  isFavorite: piece['isFavorite'],
                  isSold: piece['isSold'],
                  onFavoriteTap: () => _toggleFavorite(index),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PieceDetailScreen(
                          maison: piece['maison'],
                          nom: piece['nom'],
                          prix: piece['prix'],
                          imageUrl: piece['imageUrl'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
