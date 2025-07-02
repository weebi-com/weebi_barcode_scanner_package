/// Utility class for barcode validation
class BarcodeValidator {
  /// Check if barcode is valid
  static bool isValid(String barcode) {
    if (barcode.isEmpty) return false;
    
    // Basic validation for common barcode formats
    return barcode.length >= 8 && barcode.length <= 14 && 
           RegExp(r'^\d+$').hasMatch(barcode);
  }

  /// Check if barcode is likely a food product (EAN-13 starting with certain prefixes)
  static bool isLikelyFoodProduct(String barcode) {
    if (barcode.length != 13) return false;
    
    // Common food product prefixes (simplified check)
    final foodPrefixes = ['3', '4', '5', '6', '7', '8', '9'];
    return foodPrefixes.any((prefix) => barcode.startsWith(prefix));
  }

  /// Validate EAN-13 checksum
  static bool isValidEAN13(String barcode) {
    if (barcode.length != 13 || !RegExp(r'^\d+$').hasMatch(barcode)) {
      return false;
    }

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(barcode[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }

    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[12]);
  }
} 