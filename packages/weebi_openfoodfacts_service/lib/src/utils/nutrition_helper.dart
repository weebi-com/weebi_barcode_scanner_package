import 'package:flutter/material.dart';

/// Utility class for nutrition-related helpers
class NutritionHelper {
  /// Get nutrition grade color for UI
  static Color? getNutriScoreColor(String? nutriScore) {
    if (nutriScore == null) return null;
    
    switch (nutriScore.toUpperCase()) {
      case 'A':
        return const Color(0xFF008856); // Dark green
      case 'B':
        return const Color(0xFF85BB2F); // Light green  
      case 'C':
        return const Color(0xFFFFD100); // Yellow
      case 'D':
        return const Color(0xFFFF8C00); // Orange
      case 'E':
        return const Color(0xFFE63946); // Red
      default:
        return null;
    }
  }
  
  /// Get NOVA group description
  static String getNovaGroupDescription(int? novaGroup) {
    switch (novaGroup) {
      case 1:
        return 'Unprocessed or minimally processed foods';
      case 2:
        return 'Processed culinary ingredients';
      case 3:
        return 'Processed foods';
      case 4:
        return 'Ultra-processed foods';
      default:
        return 'Processing level unknown';
    }
  }
  
  /// Get NOVA group color
  static Color getNovaGroupColor(int? novaGroup) {
    switch (novaGroup) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  /// Format energy value for display
  static String formatEnergy(double? energyKcal) {
    if (energyKcal == null) return 'N/A';
    return '${energyKcal.round()} kcal';
  }
} 