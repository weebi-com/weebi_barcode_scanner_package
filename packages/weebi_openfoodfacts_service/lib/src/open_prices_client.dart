import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models/weebi_product.dart';
import 'utils/credential_manager.dart';

/// Client for Open Prices API integration
/// Based on: https://github.com/openfoodfacts/open-prices
/// Implements proper OAuth2 flow: login -> access token -> API requests
class OpenPricesClient {
  static const String _baseUrl = 'https://prices.openfoodfacts.org/api/v1';
  static const String _authUrl = 'https://world.openfoodfacts.org/cgi/session.pl';
  static const String _userAgent = 'WeebiOpenFoodFactsService/1.1.0';
  
  /// Authentication state
  String? _accessToken;
  DateTime? _tokenExpiry;
  String? _sessionCookie;
  
  /// Stored credentials for token refresh
  String? _username;
  String? _password;
  String? _apiToken;
  
  /// Authentication method being used
  OpenPricesAuthMethod _authMethod = OpenPricesAuthMethod.none;
  
  /// HTTP client instance
  final http.Client _httpClient;
  
  OpenPricesClient({http.Client? httpClient}) 
    : _httpClient = httpClient ?? http.Client();
  
  /// Set API token for direct token authentication
  void setAuthToken(String token) {
    _apiToken = token;
    _accessToken = token; // API tokens can be used directly
    _authMethod = OpenPricesAuthMethod.apiToken;
    _tokenExpiry = null; // API tokens typically don't expire
    debugPrint('✅ Open Prices: API token authentication configured');
  }
  
  /// Authenticate using OAuth2 login flow
  /// Step 1: POST to /cgi/session.pl to get access token
  Future<bool> authenticateWithLogin(String username, String password, {int sessionTimeout = 3600}) async {
    try {
      debugPrint('🔐 Open Prices: Starting OAuth2 login flow for user: $username');
      
      // Store credentials for refresh
      _username = username;
      _password = password;
      
      // Step 1: Login to get access token
      final loginResponse = await _httpClient.post(
        Uri.parse(_authUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': _userAgent,
        },
        body: {
          'user_id': username,
          'password': password,
          'action': 'process',
        }.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&'),
      );
      
      debugPrint('🔐 Login response status: ${loginResponse.statusCode}');
      
      if (loginResponse.statusCode == 200) {
        // Extract session cookie from response headers
        final cookies = loginResponse.headers['set-cookie'];
        if (cookies != null && cookies.contains('session=')) {
          // Parse session cookie
          final sessionMatch = RegExp(r'session=([^;]+)').firstMatch(cookies);
          if (sessionMatch != null) {
            _sessionCookie = sessionMatch.group(1);
            _accessToken = _sessionCookie; // Use session as access token
            _authMethod = OpenPricesAuthMethod.loginPassword;
            _tokenExpiry = DateTime.now().add(Duration(seconds: sessionTimeout));
            
            debugPrint('✅ Open Prices: OAuth2 login successful - token obtained');
            return true;
          }
        }
        
        // Alternative: Check if response contains JSON with token
        try {
          final responseData = json.decode(loginResponse.body);
          final token = responseData['access_token'] ?? responseData['token'] ?? responseData['session_id'];
          
          if (token != null) {
            _accessToken = token;
            _authMethod = OpenPricesAuthMethod.loginPassword;
            _tokenExpiry = DateTime.now().add(Duration(seconds: sessionTimeout));
            
            debugPrint('✅ Open Prices: OAuth2 login successful - JSON token obtained');
            return true;
          }
        } catch (e) {
          // Response is not JSON, continue with cookie-based approach
        }
        
        // If we get here, login succeeded but no token found
        debugPrint('⚠️  Open Prices: Login succeeded but no access token found');
        debugPrint('Response headers: ${loginResponse.headers}');
        debugPrint('Response body preview: ${loginResponse.body.substring(0, loginResponse.body.length.clamp(0, 200))}');
        return false;
        
      } else {
        debugPrint('❌ Open Prices: Login failed with status ${loginResponse.statusCode}');
        debugPrint('Response: ${loginResponse.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Open Prices: OAuth2 login error: $e');
      return false;
    }
  }
  
  /// Configure authentication automatically from credential manager
  Future<bool> configureAuthentication() async {
    final authDetails = CredentialManager.getAuthDetails();
    final method = authDetails['method'];
    
    switch (method) {
      case 'api_token':
        final token = authDetails['auth_token'];
        if (token != null) {
          setAuthToken(token);
          return true;
        }
        break;
        
      case 'login_password':
        final username = authDetails['username'];
        final password = authDetails['password'];
        final timeout = authDetails['session_timeout'] ?? 3600;
        
        if (username != null && password != null) {
          return await authenticateWithLogin(username, password, sessionTimeout: timeout);
        }
        break;
        
      case 'none':
      default:
        debugPrint('ℹ️  Open Prices: No authentication configured - running in read-only mode');
        return false;
    }
    
    return false;
  }
  
  /// Check if access token is expired
  bool get isTokenExpired {
    if (_authMethod == OpenPricesAuthMethod.apiToken) {
      return false; // API tokens typically don't expire
    }
    
    if (_tokenExpiry == null) {
      return false; // No expiry set
    }
    
    return DateTime.now().isAfter(_tokenExpiry!);
  }
  
  /// Check if authentication is available and valid
  bool get isAuthenticated {
    return _accessToken != null && !isTokenExpired;
  }
  
  /// Refresh access token using stored credentials
  /// In OAuth2, this would use refresh_token, but Open Prices uses re-login
  Future<bool> refreshAccessToken() async {
    debugPrint('🔄 Open Prices: Refreshing access token');
    
    // Clear current token
    _accessToken = null;
    _sessionCookie = null;
    
    if (_authMethod == OpenPricesAuthMethod.loginPassword && _username != null && _password != null) {
      // Re-authenticate using stored credentials
      final authDetails = CredentialManager.getAuthDetails();
      final timeout = authDetails['session_timeout'] ?? 3600;
      
      return await authenticateWithLogin(_username!, _password!, sessionTimeout: timeout);
    } else if (_authMethod == OpenPricesAuthMethod.apiToken && _apiToken != null) {
      // API tokens don't need refresh, just reuse
      setAuthToken(_apiToken!);
      return true;
    }
    
    debugPrint('❌ Open Prices: Cannot refresh token - no stored credentials');
    return false;
  }
  
  /// Get authorization headers for API requests
  Map<String, String> get _authHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'User-Agent': _userAgent,
    };
    
    if (_accessToken != null) {
      if (_authMethod == OpenPricesAuthMethod.apiToken) {
        // API token uses Bearer authorization
        headers['Authorization'] = 'Bearer $_accessToken';
      } else if (_authMethod == OpenPricesAuthMethod.loginPassword) {
        // Session-based auth might use different header
        if (_sessionCookie != null) {
          headers['Cookie'] = 'session=$_sessionCookie';
        } else {
          headers['Authorization'] = 'Bearer $_accessToken';
        }
      }
    }
    
    return headers;
  }
  
  /// Make an authenticated API request with automatic token refresh
  Future<http.Response> _makeAuthenticatedRequest(
    String method,
    String endpoint, {
    Map<String, String>? additionalHeaders,
    String? body,
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: {...uri.queryParameters, ...queryParams});
    }
    
    // Check if token needs refresh
    if (isTokenExpired && _authMethod == OpenPricesAuthMethod.loginPassword) {
      debugPrint('🔄 Open Prices: Token expired, refreshing...');
      await refreshAccessToken();
    }
    
    final headers = {..._authHeaders};
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    http.Response response;
    
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _httpClient.post(uri, headers: headers, body: body);
          break;
        case 'PUT':
          response = await _httpClient.put(uri, headers: headers, body: body);
          break;
        case 'DELETE':
          response = await _httpClient.delete(uri, headers: headers);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      
      // Handle token expiry (401 Unauthorized)
      if (response.statusCode == 401 && _authMethod == OpenPricesAuthMethod.loginPassword) {
        debugPrint('🔄 Open Prices: Got 401, attempting token refresh');
        
        if (await refreshAccessToken()) {
          // Retry request with fresh token
          final freshHeaders = {..._authHeaders};
          if (additionalHeaders != null) {
            freshHeaders.addAll(additionalHeaders);
          }
          
          switch (method.toUpperCase()) {
            case 'GET':
              response = await _httpClient.get(uri, headers: freshHeaders);
              break;
            case 'POST':
              response = await _httpClient.post(uri, headers: freshHeaders, body: body);
              break;
            case 'PUT':
              response = await _httpClient.put(uri, headers: freshHeaders, body: body);
              break;
            case 'DELETE':
              response = await _httpClient.delete(uri, headers: freshHeaders);
              break;
          }
        }
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Open Prices: Request error: $e');
      rethrow;
    }
  }
  
  /// Get prices for a specific product by barcode
  Future<List<WeebiPrice>> getProductPrices(
    String barcode, {
    int limit = 20,
    String? location,
    DateTime? since,
  }) async {
    try {
      final queryParams = <String, String>{
        'product_code': barcode,
        'size': limit.toString(),
      };
      
      if (location != null) {
        queryParams['location_osm_name'] = location;
      }
      
      if (since != null) {
        queryParams['date__gte'] = since.toIso8601String().split('T')[0];
      }
      
      debugPrint('📊 Fetching prices for $barcode from Open Prices API');
      
      final response = await _makeAuthenticatedRequest('GET', '/prices', queryParams: queryParams);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        
        final prices = results
            .map((json) => WeebiPrice.fromOpenPrices(json as Map<String, dynamic>))
            .toList();
        
        debugPrint('✅ Found ${prices.length} prices for $barcode');
        return prices;
      } else if (response.statusCode == 404) {
        debugPrint('ℹ️  No prices found for $barcode');
        return [];
      } else {
        debugPrint('❌ Open Prices API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching prices for $barcode: $e');
      return [];
    }
  }
  
  /// Submit a new price (requires authentication with access token)
  Future<bool> submitPrice({
    required String barcode,
    required double price,
    required String currency,
    required String locationId,
    String? proofUrl,
    DateTime? date,
  }) async {
    try {
      if (!isAuthenticated) {
        debugPrint('❌ Open Prices: Authentication required to submit prices');
        debugPrint('💡 Use configureAuthentication() or authenticateWithLogin() first');
        return false;
      }
      
      final bodyData = {
        'product_code': barcode,
        'price': price,
        'currency': currency,
        'location_osm_id': locationId,
        'date': (date ?? DateTime.now()).toIso8601String().split('T')[0],
      };
      
      if (proofUrl != null) {
        bodyData['proof'] = proofUrl;
      }
      
      debugPrint('💰 Submitting price for $barcode: $price $currency');
      
      final response = await _makeAuthenticatedRequest(
        'POST',
        '/prices',
        body: json.encode(bodyData),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('✅ Open Prices: Price submitted successfully');
        return true;
      } else {
        debugPrint('❌ Open Prices: Price submission failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Open Prices: Error submitting price: $e');
      return false;
    }
  }
  
  /// Get the latest price for a product
  Future<WeebiPrice?> getLatestPrice(String barcode, {String? location}) async {
    final prices = await getProductPrices(barcode, limit: 1, location: location);
    
    if (prices.isNotEmpty) {
      prices.sort((a, b) => b.date.compareTo(a.date));
      return prices.first;
    }
    
    return null;
  }
  
  /// Get price statistics for a product
  Future<WeebiPriceStats?> getPriceStats(String barcode, {String? location}) async {
    final since = DateTime.now().subtract(const Duration(days: 30));
    final prices = await getProductPrices(
      barcode,
      limit: 100,
      location: location,
      since: since,
    );
    
    if (prices.isEmpty) return null;
    
    return WeebiPriceStats.fromPrices(prices);
  }
  
  /// Get available locations (stores/cities) with price data
  Future<List<Map<String, dynamic>>> getLocations({int limit = 50}) async {
    try {
      final response = await _makeAuthenticatedRequest(
        'GET', 
        '/locations', 
        queryParams: {'size': limit.toString()}
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List<dynamic>).cast<Map<String, dynamic>>();
      } else {
        debugPrint('❌ Open Prices locations error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching locations: $e');
      return [];
    }
  }
  
  /// Get Open Prices API status
  Future<Map<String, dynamic>?> getApiStatus() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/status'),
        headers: {'User-Agent': _userAgent},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching API status: $e');
      return null;
    }
  }
  
  /// Search for products with prices in a location
  Future<List<Map<String, dynamic>>> searchProductsWithPrices({
    String? location,
    String? storeBrand,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'size': limit.toString(),
      };
      
      if (location != null) {
        queryParams['location_osm_name'] = location;
      }
      
      if (storeBrand != null) {
        queryParams['location_osm_brand'] = storeBrand;
      }
      
      debugPrint('🔍 Searching for products with prices (location: $location, brand: $storeBrand)');
      
      final response = await _makeAuthenticatedRequest('GET', '/prices', queryParams: queryParams);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        
        debugPrint('✅ Found ${results.length} products with prices');
        return results.cast<Map<String, dynamic>>();
      } else {
        debugPrint('❌ Open Prices search error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error searching products with prices: $e');
      return [];
    }
  }

  /// Get authentication status information
  Map<String, dynamic> getAuthStatus() {
    return {
      'authenticated': isAuthenticated,
      'auth_method': _authMethod.toString().split('.').last,
      'token_expired': isTokenExpired,
      'token_expiry': _tokenExpiry?.toIso8601String(),
      'has_access_token': _accessToken != null,
      'has_stored_credentials': _username != null || _apiToken != null,
    };
  }
  
  /// Dispose of the client
  void dispose() {
    _httpClient.close();
    _accessToken = null;
    _tokenExpiry = null;
    _sessionCookie = null;
    _username = null;
    _password = null;
    _apiToken = null;
    _authMethod = OpenPricesAuthMethod.none;
  }
} 