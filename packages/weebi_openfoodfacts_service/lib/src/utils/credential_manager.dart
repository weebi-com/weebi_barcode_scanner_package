import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Authentication method for Open Prices API
enum OpenPricesAuthMethod {
  none,
  loginPassword,
  apiToken,
}

/// Manages credentials for various APIs used by the service
class CredentialManager {
  static Map<String, dynamic>? _credentials;
  static Map<String, dynamic>? _openPricesCredentials;
  static bool _initialized = false;

  /// Initialize credential loading
  static Future<void> initialize() async {
    if (_initialized) return;
    
    await _loadCredentials();
    await _loadOpenPricesCredentials();
    _initialized = true;
  }

  /// Load all credentials (alias for initialize for backward compatibility)
  static Future<void> loadAllCredentials({String? packageRoot}) async {
    await initialize();
  }

  /// Load general credentials from credentials.json
  static Future<void> _loadCredentials() async {
    try {
      final file = await _getCredentialFile('credentials.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        _credentials = json.decode(content) as Map<String, dynamic>;
        debugPrint('Loaded general credentials from: ${file.path}');
      }
    } catch (e) {
      debugPrint('Error loading general credentials: $e');
      _credentials = null;
    }
  }

  /// Load Open Prices credentials from open_prices_credentials.json
  static Future<void> _loadOpenPricesCredentials() async {
    try {
      final file = await _getCredentialFile('open_prices_credentials.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        _openPricesCredentials = json.decode(content) as Map<String, dynamic>;
        debugPrint('Loaded Open Prices credentials from: ${file.path}');
      } else {
        // Create template if file doesn't exist
        await _createOpenPricesCredentialTemplate(file);
      }
    } catch (e) {
      debugPrint('Error loading Open Prices credentials: $e');
      _openPricesCredentials = null;
    }
  }

  /// Find the credential file relative to the package root or current directory
  static Future<File> _getCredentialFile(String filename) async {
    // In tests, look in the test directory first
    if (kDebugMode) {
      final testFile = File(path.join('test', filename));
      if (await testFile.exists()) {
        return testFile;
      }
    }
    
    // Try to find the package root by looking for pubspec.yaml
    Directory current = Directory.current;
    
    while (current.path != current.parent.path) {
      final pubspecFile = File(path.join(current.path, 'pubspec.yaml'));
      if (await pubspecFile.exists()) {
        final content = await pubspecFile.readAsString();
        if (content.contains('name: weebi_openfoodfacts_service')) {
          return File(path.join(current.path, filename));
        }
      }
      current = current.parent;
    }
    
    // Fallback to current directory
    return File(path.join(Directory.current.path, filename));
  }

  /// Create a template for Open Prices credentials
  static Future<void> _createOpenPricesCredentialTemplate(File file) async {
    try {
      final template = {
        '_comment': 'Open Prices API Credentials - Keep this file secure and in .gitignore',
        '_security_warning': 'NEVER commit this file to git! Always add it to .gitignore',
        '_important_note': 'OpenFoodFacts API works WITHOUT credentials! Only Open Prices requires authentication.',
        '_instructions': {
          '1': 'Use your OpenFoodFacts account credentials (same login for Open Prices)',
          '2': 'Replace the placeholder values below with your actual credentials',
          '3': 'Add "open_prices_credentials.json" to your .gitignore file',
          '4': 'The service will automatically handle login authentication',
          '5': 'Basic product information works without any credentials'
        },
        'open_prices': {
          'username': 'your_openfoodfacts_username',
          'password': 'your_openfoodfacts_password',
          'api_url': 'https://prices.openfoodfacts.org/api/v1',
          'app_name': 'YourAppName/1.0',
          'session_timeout': 3600
        },
        'setup_guide': {
          'account_creation': {
            '1': 'Visit https://openfoodfacts.org',
            '2': 'Create an account or login with existing account',
            '3': 'Use the SAME username and password above',
            '4': 'Works for both OpenFoodFacts and Open Prices APIs'
          },
          'security_setup': {
            '1': 'Add "open_prices_credentials.json" to your .gitignore',
            '2': 'Never commit this file to version control',
            '3': 'For production: use environment variables or secure storage',
            '4': 'This template can be safely shared (without actual credentials)'
          },
          'features_without_credentials': {
            '1': '✅ Basic product information (name, brand, ingredients, etc.)',
            '2': '✅ Product images and nutrition data',
            '3': '✅ Multi-language support',
            '4': '✅ Product caching',
            '5': '❌ Pricing data (requires credentials)',
            '6': '❌ Price history and statistics (requires credentials)'
          }
        }
      };
      
      await file.parent.create(recursive: true);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(template)
      );
      
      debugPrint('Created Open Prices credential template: ${file.path}');
      debugPrint('ℹ️  Note: Basic product information works without credentials!');
      debugPrint('ℹ️  Only pricing features require authentication.');
    } catch (e) {
      debugPrint('Error creating credential template: $e');
    }
  }

  /// Get Open Prices username
  static String? get openPricesUsername {
    final username = _openPricesCredentials?['open_prices']?['username'];
    return (username != null && username != 'your_openfoodfacts_username') ? username : null;
  }

  /// Get Open Prices password
  static String? get openPricesPassword {
    final password = _openPricesCredentials?['open_prices']?['password'];
    return (password != null && password != 'your_openfoodfacts_password') ? password : null;
  }

  /// Get Open Prices API URL
  static String? get openPricesApiUrl {
    return _openPricesCredentials?['open_prices']?['api_url'] ?? 'https://prices.openfoodfacts.org/api/v1';
  }

  /// Get Open Prices app name
  static String? get openPricesAppName {
    return _openPricesCredentials?['open_prices']?['app_name'] ?? 'WeebiApp/1.0';
  }

  /// Get session timeout for login authentication
  static int get sessionTimeout {
    return _openPricesCredentials?['open_prices']?['session_timeout'] ?? 3600; // 1 hour default
  }

  /// Get Open Prices API token (if using token authentication)
  static String? get openPricesAuthToken {
    return _openPricesCredentials?['open_prices']?['auth_token'];
  }

  /// Check if Open Prices auth token is available
  static bool get hasOpenPricesAuthToken {
    final token = openPricesAuthToken;
    return token != null && token.isNotEmpty && token != 'your_api_token_here';
  }

  /// Get the preferred authentication method
  static OpenPricesAuthMethod get preferredAuthMethod {
    if (hasOpenPricesAuthToken) {
      return OpenPricesAuthMethod.apiToken;
    } else if (hasOpenPricesLoginCredentials) {
      return OpenPricesAuthMethod.loginPassword;
    } else {
      return OpenPricesAuthMethod.none;
    }
  }

  /// Get authentication details for any supported method
  static Map<String, dynamic> getAuthDetails() {
    if (hasOpenPricesAuthToken) {
      return {
        'method': 'api_token',
        'auth_token': openPricesAuthToken!,
      };
    } else if (hasOpenPricesLoginCredentials) {
      return {
        'method': 'login_password',
        'username': openPricesUsername!,
        'password': openPricesPassword!,
        'session_timeout': sessionTimeout,
        'app_name': openPricesAppName,
      };
    } else {
      return {
        'method': 'none',
        'error': 'No valid credentials found',
      };
    }
  }

  /// Get any credential by key path (e.g., 'api.key' or 'database.password')
  static String? getCredential(String keyPath) {
    if (_credentials == null) return null;
    
    final keys = keyPath.split('.');
    dynamic current = _credentials;
    
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    
    return current?.toString();
  }

  /// Check if credentials are loaded
  static bool get hasCredentials => _credentials != null;

  /// Check if Open Prices credentials are loaded
  static bool get hasOpenPricesCredentials => _openPricesCredentials != null;

  /// Check if Open Prices login credentials are available
  static bool get hasOpenPricesLoginCredentials {
    final username = openPricesUsername;
    final password = openPricesPassword;
    return username != null && username.isNotEmpty && 
           password != null && password.isNotEmpty;
  }

  /// Check if Open Prices authentication is available
  static bool get hasOpenPricesAuth => hasOpenPricesLoginCredentials;

  /// Reload credentials (useful for development)
  static Future<void> reload() async {
    _initialized = false;
    _credentials = null;
    _openPricesCredentials = null;
    await initialize();
  }

  /// Clear all loaded credentials
  static void clear() {
    _credentials = null;
    _openPricesCredentials = null;
    _initialized = false;
  }

  /// Clear credentials from memory (alias for clear)
  static void clearCredentials() {
    clear();
  }
} 