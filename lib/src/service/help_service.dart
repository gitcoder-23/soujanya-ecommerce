import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:martfury/src/model/help_item.dart';

class HelpService {
  static Future<List<HelpCategory>> getHelpContent({String? languageCode}) async {
    try {
      // Use provided language code or default to English
      final locale = languageCode ?? 'en';

      // Try to load help content for current language
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/help/$locale.json');
      } catch (e) {
        // Fallback to English if language file doesn't exist
        jsonString = await rootBundle.loadString('assets/help/en.json');
      }

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> categoriesJson = jsonData['categories'] as List<dynamic>;

      return categoriesJson
          .map((category) => HelpCategory.fromJson(category as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load help content: $e');
    }
  }

  static List<HelpItem> searchHelp(List<HelpCategory> categories, String query) {
    if (query.isEmpty) return [];

    final results = <HelpItem>[];
    final lowerQuery = query.toLowerCase();

    for (final category in categories) {
      for (final item in category.items) {
        if (item.question.toLowerCase().contains(lowerQuery) ||
            item.answer.toLowerCase().contains(lowerQuery)) {
          results.add(item);
        }
      }
    }

    return results;
  }
}
