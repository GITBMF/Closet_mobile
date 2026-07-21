import 'package:flutter/material.dart';

/// Palette officielle CLOSET (charte graphique).
class ClosetColors {
  ClosetColors._();

  // Rôles de couleur
  static const Color noir = Color(0xFF171512); // Texte principal
  static const Color vert = Color(0xFF1C382D); // Vert profond : CTA primaires, surfaces fortes
  static const Color vertFonce = Color(0xFF12241D); // Vert nuit : Tabbar, écrans immersifs
  static const Color beige = Color(0xFFF3EBDD); // Beige sable : Fond de l'application
  static const Color creme = Color(0xFFFBF7EF); // Blanc cassé : Cartes, champs, feuilles
  
  static const Color dore = Color(0xFFC6A24B); // Doré lumière : Décoratif uniquement (filets, icônes)
  static const Color doreEncre = Color(0xFF7E611C); // Doré encre : Seul doré autorisé en texte sur clair
  static const Color doreClair = Color(0xFFDCBE72); // Doré clair : doré sur vert profond
  
  static const Color taupe = Color(0xFF6B5F4C); // Texte secondaire sur clair
  static const Color ligne = Color(0xFFE2D7C2); // Lignes et bordures
  
  static const Color succes = Color(0xFF2E6B4F);
  static const Color alerte = Color(0xFF8A5A17);
  static const Color erreur = Color(0xFF9B3A2E); // Terre brûlée — jamais de rouge criard

  // Noms de compatibilité avec l'ancien code sourceur
  static const Color ivoire = beige;
  static const Color bordure = ligne;
  static const Color sauge = Color(0xFFA9B2A3);
  static const Color doreDesactive = Color(0xFFE4D2A6);
  static const Color rougeBadge = erreur;
  static const Color texteSecondaire = taupe;
  static const Color texteSurVert = creme;
}
