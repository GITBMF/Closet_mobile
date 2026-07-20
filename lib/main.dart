import 'package:flutter/material.dart';

import 'core/theme/closet_colors.dart';
import 'features/main_layout.dart';

void main() {
  runApp(const ClosetApp());
}

class ClosetApp extends StatelessWidget {
  const ClosetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clos ET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: ClosetColors.ivoire,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ClosetColors.vert,
          surface: ClosetColors.ivoire,
        ),
      ),
      home: const MainLayout(),
    );
  }
}
