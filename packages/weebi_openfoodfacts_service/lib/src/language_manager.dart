import 'models/weebi_language.dart';

/// Manages language preferences and fallbacks
class LanguageManager {
  List<WeebiLanguage> _preferredLanguages;

  LanguageManager(this._preferredLanguages) {
    if (_preferredLanguages.isEmpty) {
      _preferredLanguages = [WeebiLanguage.english];
    }
  }

  /// Get preferred languages in order of preference
  List<WeebiLanguage> get preferredLanguages => List.unmodifiable(_preferredLanguages);

  /// Update preferred languages
  void updatePreferredLanguages(List<WeebiLanguage> languages) {
    _preferredLanguages = languages.isNotEmpty ? languages : [WeebiLanguage.english];
  }

  /// Get primary language
  WeebiLanguage get primaryLanguage => _preferredLanguages.first;
} 