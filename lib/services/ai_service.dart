import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  // Mock AI Service
  // In a real app, this would call OpenAI or Gemini API

  static Future<String> improveText(String text, {String? apiKey}) async {
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        // Using the model version suggested by the user's context
        final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
        final content = [Content.text('Improve the following text for a README file, making it more professional and concise:\n\n$text')];
        final response = await model.generateContent(content);
        return response.text ?? text;
      } catch (e) {
        debugPrint('Gemini API Error: $e');
        // Return the actual error message to help debugging
        return '$text (Error: ${e.toString().replaceAll('GenerativeAIException: ', '')})';
      }
    }

    // Mock fallback
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

  static Future<String> generateDescription(String topic, {String? apiKey}) async {
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
        final content = [Content.text('Generate a short, engaging project description for a project about: $topic')];
        final response = await model.generateContent(content);
        return response.text ?? 'Could not generate description.';
      } catch (e) {
        debugPrint('Gemini API Error: $e');
        return 'Error: ${e.toString().replaceAll('GenerativeAIException: ', '')}';
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    final templates = [
      'This project is a comprehensive solution for $topic. It includes robust features, scalable architecture, and follows best practices for modern development.',
      '🚀 $topic: The ultimate tool for developers. Boost your productivity with our cutting-edge features.',
      'A lightweight, fast, and flexible library for $topic. Designed with simplicity in mind.',
      'Welcome to the $topic project! We aim to solve complex problems with elegant solutions.',
    ];
    return templates[Random().nextInt(templates.length)];
  }

  static Future<String> fixGrammar(String text, {String? apiKey}) async {
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
        final content = [Content.text('Fix grammar and spelling in the following text:\n\n$text')];
        final response = await model.generateContent(content);
        return response.text ?? text;
      } catch (e) {
        debugPrint('Gemini API Error: $e');
        return text; // For grammar, just return original text on error to avoid breaking flow
      }
    }

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
