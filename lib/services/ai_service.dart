import 'dart:math';

class AIService {
  // Mock AI Service
  // In a real app, this would call OpenAI or Gemini API

  static Future<String> improveText(String text) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    if (text.isEmpty) return 'Generated content based on context...';

    // Simple mock logic
    if (text.length < 10) {
      return '$text - Enhanced with more details and professional tone.';
    }

    return text.split(' ').map((word) {
      if (word.length > 4 && Random().nextBool()) {
        return '$word(improved)';
      }
      return word;
    }).join(' ');
  }

  static Future<String> generateDescription(String topic) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'This project is a comprehensive solution for $topic. It includes robust features, scalable architecture, and follows best practices for modern development.';
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

