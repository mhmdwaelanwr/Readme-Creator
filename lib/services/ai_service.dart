import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../models/readme_element.dart';

class AIService {
  /// Improves existing text to be more professional.
  static Future<String> improveText(String text, {String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) return text;
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text('As a technical writer, improve this README section to be professional, concise, and engaging. Return only the improved text:\n\n$text')];
      final response = await model.generateContent(content);
      return response.text ?? text;
    } catch (e) {
      debugPrint('AI Error: $e');
      return text;
    }
  }

  static Future<String> fixGrammar(String text, {String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) return text;
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text('Fix grammar and spelling in this text, keeping the markdown structure:\n\n$text')];
      final response = await model.generateContent(content);
      return response.text ?? text;
    } catch (e) {
      return text;
    }
  }

  static Future<String> generateDescription(String topic, {String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) return 'Generated description for $topic';
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text('Generate a short engaging description for: $topic')];
      final response = await model.generateContent(content);
      return response.text ?? 'A project about $topic';
    } catch (e) {
      return 'A project about $topic';
    }
  }

  static Future<String> generateReadmeFromStructure(String structure, {String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) return '# Generated README\n\n$structure';
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text('Generate a README.md based on this structure:\n\n$structure')];
      final response = await model.generateContent(content);
      return response.text ?? '# Generated README';
    } catch (e) {
      return '# Generated README';
    }
  }

  /// Generates a full ReadmeElement list based on a prompt.
  static Future<List<ReadmeElement>> magicCompose(String prompt, {String? apiKey}) async {
    if (apiKey == null || apiKey.isEmpty) return [];
    
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final aiPrompt = '''
      You are an expert GitHub README generator. Based on this description: "$prompt", 
      generate a professional README structure.
      Return the response ONLY as a JSON array of objects.
      Each object must have a "type" field and data fields.
      Supported types: 
      - "heading" (text, level: 1-3)
      - "paragraph" (text)
      - "list" (items: list of strings, isOrdered: bool)
      - "codeBlock" (code, language)
      - "divider" (no extra fields)
      
      Example: [{"type": "heading", "text": "Project Name", "level": 1}, {"type": "divider"}]
      Return ONLY the raw JSON. No markdown backticks.
      ''';
      
      final content = [Content.text(aiPrompt)];
      final response = await model.generateContent(content);
      final cleanJson = response.text?.replaceAll('```json', '').replaceAll('```', '').trim() ?? '[]';
      
      final List<dynamic> decoded = jsonDecode(cleanJson);
      return decoded.map((item) => ReadmeElement.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Magic Compose Error: $e');
      return [
        HeadingElement(text: 'Error in Generation', level: 1),
        ParagraphElement(text: 'The AI could not process your request. Please try a simpler prompt.'),
      ];
    }
  }

  /// Analyzes project elements and provides a health score.
  static double calculateHealthScore(List<ReadmeElement> elements) {
    if (elements.isEmpty) return 0.0;
    double score = 0.0;
    
    bool hasH1 = elements.any((e) => e is HeadingElement && e.level == 1);
    bool hasImage = elements.any((e) => e is ImageElement);
    bool hasCode = elements.any((e) => e is CodeBlockElement);
    bool hasSocials = elements.any((e) => e is SocialsElement);
    
    if (hasH1) score += 30;
    if (hasImage) score += 20;
    if (hasCode) score += 20;
    if (hasSocials) score += 10;
    
    // Add points for length
    if (elements.length > 5) score += 20;
    
    return score.clamp(0, 100);
  }
}
