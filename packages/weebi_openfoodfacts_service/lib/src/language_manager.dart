import 'models/weebi_language.dart';

/// Manages language preferences and fallbacks
class LanguageManager {
  List<AppLanguage> _preferredLanguages;

  LanguageManager(this._preferredLanguages) {
    if (_preferredLanguages.isEmpty) {
      _preferredLanguages = [AppLanguage.english];
    }
  }

  /// Get preferred languages in order of preference
  List<AppLanguage> get preferredLanguages => List.unmodifiable(_preferredLanguages);

  /// Update preferred languages
  void updatePreferredLanguages(List<AppLanguage> languages) {
    _preferredLanguages = languages.isNotEmpty ? languages : [AppLanguage.english];
  }

  /// Get primary language
  AppLanguage get primaryLanguage => _preferredLanguages.first;
} 