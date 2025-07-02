import 'package:openfoodfacts/openfoodfacts.dart' as off;

/// Supported languages for Weebi OpenFoodFacts integration
enum WeebiLanguage {
  english,
  french,
  spanish,
  german,
  italian,
  portuguese,
  dutch,
  chinese,
  japanese,
  arabic;

  /// Convert to OpenFoodFacts language
  off.OpenFoodFactsLanguage get openFoodFactsLanguage {
    switch (this) {
      case WeebiLanguage.english:
        return off.OpenFoodFactsLanguage.ENGLISH;
      case WeebiLanguage.french:
        return off.OpenFoodFactsLanguage.FRENCH;
      case WeebiLanguage.spanish:
        return off.OpenFoodFactsLanguage.SPANISH;
      case WeebiLanguage.german:
        return off.OpenFoodFactsLanguage.GERMAN;
      case WeebiLanguage.italian:
        return off.OpenFoodFactsLanguage.ITALIAN;
      case WeebiLanguage.portuguese:
        return off.OpenFoodFactsLanguage.PORTUGUESE;
      case WeebiLanguage.dutch:
        return off.OpenFoodFactsLanguage.DUTCH;
      case WeebiLanguage.chinese:
        return off.OpenFoodFactsLanguage.CHINESE;
      case WeebiLanguage.japanese:
        return off.OpenFoodFactsLanguage.JAPANESE;
      case WeebiLanguage.arabic:
        return off.OpenFoodFactsLanguage.ARABIC;
    }
  }

  /// Language code (ISO 639-1)
  String get code {
    switch (this) {
      case WeebiLanguage.english:
        return 'en';
      case WeebiLanguage.french:
        return 'fr';
      case WeebiLanguage.spanish:
        return 'es';
      case WeebiLanguage.german:
        return 'de';
      case WeebiLanguage.italian:
        return 'it';
      case WeebiLanguage.portuguese:
        return 'pt';
      case WeebiLanguage.dutch:
        return 'nl';
      case WeebiLanguage.chinese:
        return 'zh';
      case WeebiLanguage.japanese:
        return 'ja';
      case WeebiLanguage.arabic:
        return 'ar';
    }
  }

  /// Display name
  String get displayName {
    switch (this) {
      case WeebiLanguage.english:
        return 'English';
      case WeebiLanguage.french:
        return 'Français';
      case WeebiLanguage.spanish:
        return 'Español';
      case WeebiLanguage.german:
        return 'Deutsch';
      case WeebiLanguage.italian:
        return 'Italiano';
      case WeebiLanguage.portuguese:
        return 'Português';
      case WeebiLanguage.dutch:
        return 'Nederlands';
      case WeebiLanguage.chinese:
        return '中文';
      case WeebiLanguage.japanese:
        return '日本語';
      case WeebiLanguage.arabic:
        return 'العربية';
    }
  }

  /// Create from language code
  static WeebiLanguage? fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return WeebiLanguage.english;
      case 'fr':
        return WeebiLanguage.french;
      case 'es':
        return WeebiLanguage.spanish;
      case 'de':
        return WeebiLanguage.german;
      case 'it':
        return WeebiLanguage.italian;
      case 'pt':
        return WeebiLanguage.portuguese;
      case 'nl':
        return WeebiLanguage.dutch;
      case 'zh':
        return WeebiLanguage.chinese;
      case 'ja':
        return WeebiLanguage.japanese;
      case 'ar':
        return WeebiLanguage.arabic;
      default:
        return null;
    }
  }
} 