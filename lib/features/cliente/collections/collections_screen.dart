import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/widgets/piece_card.dart';
import '../dressing/piece_detail_screen.dart';
import '../../main_layout.dart';
import '../espace/notifications_screen.dart';

class CollectionsScreen extends StatefulWidget {
  final String? initialCategory;

  const CollectionsScreen({super.key, this.initialCategory});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final List<String> _categories = ['Tout', 'Robes', 'Vestes', 'Sacs', 'Blouses', 'Escarpins'];
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Tout';
  }

  final List<Map<String, dynamic>> _pieces = [
    {
      'id': '1',
      'categorie': 'Robes',
      'maison': 'SANDRO',
      'nom': 'Robe Élégance Durable',
      'prix': '38 500 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': 'Excellent',
      'subtitle': 'T. 38 - Soie',
      'isFavorite': false,
      'isSold': false,
    },
    {
      'id': '2',
      'categorie': 'Sacs',
      'maison': 'SÉZANE',
      'nom': 'Sac Cuir Camel',
      'prix': '31 000 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': 'Très bon',
      'subtitle': 'T. Porté épaule - Cuir pleine fleur',
      'isFavorite': true,
      'isSold': false,
    },
    {
      'id': '3',
      'categorie': 'Vestes',
      'maison': 'MAJE',
      'nom': 'Veste Tweed Crème',
      'prix': '24 500 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': 'Excellent',
      'subtitle': 'T. 36 - Laine - Tweed',
      'isFavorite': false,
      'isSold': false,
    },
    {
      'id': '4',
      'categorie': 'Blouses',
      'maison': 'RUE SEREINE',
      'nom': 'Blouse Ivoire Fluide',
      'prix': '18 500 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': 'Très bon',
      'subtitle': 'T. S - Soie',
      'isFavorite': true,
      'isSold': false,
    },
    {
      'id': '5',
      'categorie': 'Robes',
      'maison': 'MASSIMO DUTTI',
      'nom': 'Robe Plissée Sable',
      'prix': '22 000 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': 'Très bon',
      'subtitle': 'T. 38 - Viscose',
      'isFavorite': false,
      'isSold': false,
    },
    {
      'id': '6',
      'categorie': 'Robes',
      'maison': 'MAJE',
      'nom': 'Robe Portefeuille',
      'prix': '',
      'imageUrl': 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&q=80&w=400',
      'isImageArche': true,
      'statusBadgeText': null,
      'subtitle': null,
      'isFavorite': false,
      'isSold': true,
    },
  ];

  void _toggleFavorite(int index) {
    setState(() {
      _pieces[index]['isFavorite'] = !(_pieces[index]['isFavorite'] as bool);
    });
  }

  Widget _buildAppBarAction(IconData icon, {int badgeCount = 0, Color? badgeColor, Color badgeTextColor = Colors.white, VoidCallback? onPressed}) {
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

  @override
  Widget build(BuildContext context) {
    final filteredPieces = _selectedCategory == 'Tout'
        ? _pieces
        : _pieces.where((p) => p['categorie'] == _selectedCategory).toList();

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
              onTap: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainLayout(initialIndex: 0)),
                (route) => false,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: ClosetColors.doreClair,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'C',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    color: ClosetColors.vertFonce,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collections',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                const Text(
                  "LE DRESSING",
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.doreEncre,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _buildAppBarAction(Icons.search, onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainLayout(initialIndex: 1)), (route) => false)),
          _buildAppBarAction(Icons.favorite_border, badgeCount: 2, badgeColor: ClosetColors.erreur, onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainLayout(initialIndex: 2)), (route) => false)),
          _buildAppBarAction(Icons.shopping_bag_outlined, onPressed: () => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainLayout(initialIndex: 1)), (route) => false)),
          _buildAppBarAction(Icons.notifications_none, badgeCount: 6, badgeColor: ClosetColors.doreClair, badgeTextColor: ClosetColors.vertFonce, onPressed: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => const NotificationsScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Toutes les pièces & Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toutes les pièces',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ClosetColors.ligne),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tune, size: 14, color: ClosetColors.vertFonce),
                          const SizedBox(width: 4),
                          const Text(
                            'Filtres',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ClosetColors.vertFonce,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ClosetColors.ligne),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_vert, size: 14, color: ClosetColors.vertFonce),
                          const SizedBox(width: 4),
                          const Text(
                            'Nouveautés',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ClosetColors.vertFonce,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ClosetColors.ligne),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: ClosetColors.taupe, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Rechercher une pièce, une maison...',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: ClosetColors.taupe.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: _categories.map((category) {
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1C2C26) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? const Color(0xFF1C2C26) : ClosetColors.ligne),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : ClosetColors.vertFonce,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Counts Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredPieces.length} pièces uniques',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ClosetColors.taupe,
                  ),
                ),
                const Text(
                  'Nouveautés',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ClosetColors.taupe,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 40.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 0.53,
              ),
              itemCount: filteredPieces.length,
              itemBuilder: (context, index) {
                final piece = filteredPieces[index];
                return PieceCard(
                  maison: piece['maison'],
                  nom: piece['nom'],
                  prix: piece['prix'],
                  imageUrl: piece['imageUrl'],
                  isImageArche: piece['isImageArche'],
                  statusBadgeText: piece['statusBadgeText'],
                  subtitle: piece['subtitle'],
                  isFavorite: piece['isFavorite'],
                  isSold: piece['isSold'],
                  onFavoriteTap: () {
                    final originalIndex = _pieces.indexWhere((p) => p['id'] == piece['id']);
                    if (originalIndex != -1) {
                      _toggleFavorite(originalIndex);
                    }
                  },
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
