import 'package:flutter/material.dart';

class AppColors {
  // World Class Brand Palette
  static const Color primary = Color(0xFF6366F1); // Modern Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color accent = Color(0xFFF43F5E); // Rose Accent
  
  // Luxury Backgrounds
  static const Color darkBackground = Color(0xFF030712); // Deep Space Black
  static const Color lightBackground = Color(0xFFF9FAFB); // Pure Soft White
  
  // Glassmorphism Surfaces
  static const Color glassDark = Color(0x1AFFFFFF); // 10% White
  static const Color glassLight = Color(0x0D000000); // 5% Black
  
  // Canvas & Paper (Compatibility names restored)
  static const Color canvasBackgroundDark = Color(0xFF111827); // Slate 900
  static const Color canvasBackgroundLight = Colors.white;
  static const Color canvasDark = canvasBackgroundDark;
  static const Color canvasLight = canvasBackgroundLight;
  
  // Editor Backgrounds (Compatibility names restored)
  static const Color editorBackgroundDark = Color(0xFF020617); // Slate 950
  static const Color editorBackgroundLight = Color(0xFFF1F5F9); // Slate 100

  // Text Colors (Compatibility names restored)
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Social Preview (Compatibility names restored)
  static const Color socialPreviewDark = Color(0xFF1E293B);
  
  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
