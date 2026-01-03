import 'dart:math';

class AIService {
  // Mock AI Service
  // In a real app, this would call OpenAI or Gemini API

  static Future<String> improveText(String text) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    if (text.isEmpty) return 'Generated content based on context...';

    final improvements = [
      '$text - Enhanced with more details and professional tone.',
      '✨ $text (Polished)',
      '🚀 $text (Optimized for impact)',
      'Here is a better version: $text. It is now more concise and clear.',
    ];

    // Simple mock logic
    if (text.length < 10) {
      return improvements[0];
    }

    return '${text.split(' ').map((word) {
      if (word.length > 4 && Random().nextBool()) {
        return word; // Keep original sometimes
      }
      return word;
    }).join(' ')} (AI Enhanced)';
  }

  static Future<String> generateDescription(String topic) async {
    await Future.delayed(const Duration(seconds: 1));
    final templates = [
      'This project is a comprehensive solution for $topic. It includes robust features, scalable architecture, and follows best practices for modern development.',
      '🚀 $topic: The ultimate tool for developers. Boost your productivity with our cutting-edge features.',
      'A lightweight, fast, and flexible library for $topic. Designed with simplicity in mind.',
      'Welcome to the $topic project! We aim to solve complex problems with elegant solutions.',
    ];
    return templates[Random().nextInt(templates.length)];
  }

  static Future<String> fixGrammar(String text) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock grammar fix
    String fixed = text.trim();
    if (fixed.isNotEmpty) {
      fixed = fixed[0].toUpperCase() + fixed.substring(1);
      if (!fixed.endsWith('.')) fixed += '.';
    }
    return fixed;
  }
}
