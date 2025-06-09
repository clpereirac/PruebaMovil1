import 'package:flutter/material.dart';

class AppColors {
  // Colores primarios
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Colores de acento
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFA78BFA);
  static const Color accentDark = Color(0xFF7C3AED);

  // Colores de fondo
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F1F1F);

  // Colores de texto
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Colores de estado
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Colores de prioridad
  static const Color priorityLow = Color(0xFF3B82F6);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);

  // Colores de categorías
  static const Color categoryHealth = Color(0xFFEF4444);
  static const Color categoryFinance = Color(0xFF10B981);
  static const Color categoryFamily = Color(0xFFF59E0B);
  static const Color categoryCommunity = Color(0xFF8B5CF6);
  static const Color categoryWork = Color(0xFF3B82F6);
  static const Color categoryPersonal = Color(0xFF6B7280);

  // Colores neutros
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, warningDark],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, errorDark],
  );

  // Sombras
  static const List<BoxShadow> lightShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> mediumShadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> heavyShadow = [
    BoxShadow(color: Color(0x29000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  // Métodos utilitarios
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return categoryHealth;
      case 'finance':
        return categoryFinance;
      case 'family':
        return categoryFamily;
      case 'community':
        return categoryCommunity;
      case 'work':
        return categoryWork;
      case 'personal':
        return categoryPersonal;
      default:
        return grey500;
    }
  }

  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return priorityLow;
      case 2:
        return priorityMedium;
      case 3:
        return priorityHigh;
      default:
        return priorityMedium;
    }
  }

  static LinearGradient getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return successGradient;
      case 'pending':
        return warningGradient;
      case 'overdue':
        return errorGradient;
      default:
        return primaryGradient;
    }
  }

  // Paletas de colores temáticas
  static const List<Color> warmColors = [
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFFEAB308), // Yellow
  ];

  static const List<Color> coolColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF06B6D4), // Cyan
    Color(0xFF8B5CF6), // Purple
    Color(0xFF10B981), // Emerald
  ];

  static const List<Color> neutralColors = [
    Color(0xFF6B7280), // Gray
    Color(0xFF78716C), // Stone
    Color(0xFF71717A), // Zinc
    Color(0xFF737373), // Neutral
  ];

  // Colores accesibles (WCAG AA)
  static const Color accessibleBlue = Color(0xFF0066CC);
  static const Color accessibleGreen = Color(0xFF008844);
  static const Color accessibleRed = Color(0xFFCC0000);
  static const Color accessibleOrange = Color(0xFFCC6600);
}
