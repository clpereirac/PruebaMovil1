import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class DateHelpers {
  // Formatear fecha en español
  static String formatDate(DateTime date) {
    final formatter = DateFormat(AppConstants.dateFormat, 'es_ES');
    return formatter.format(date);
  }

  // Formatear hora
  static String formatTime(DateTime time) {
    final formatter = DateFormat(AppConstants.timeFormat);
    return formatter.format(time);
  }

  // Formatear fecha y hora completa
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat(AppConstants.dateTimeFormat, 'es_ES');
    return formatter.format(dateTime);
  }

  // Formatear fecha completa en español
  static String formatFullDate(DateTime date) {
    final formatter = DateFormat(AppConstants.fullDateFormat, 'es_ES');
    return formatter.format(date);
  }

  // Obtener fecha relativa (hoy, mañana, etc.)
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Mañana';
    } else if (difference == -1) {
      return 'Ayer';
    } else if (difference > 1 && difference <= 7) {
      final formatter = DateFormat('EEEE', 'es_ES');
      return formatter.format(date);
    } else if (difference < -1 && difference >= -7) {
      final formatter = DateFormat('EEEE', 'es_ES');
      return 'El ${formatter.format(date)} pasado';
    } else {
      return formatDate(date);
    }
  }

  // Obtener tiempo restante hasta una fecha
  static String getTimeUntil(DateTime target) {
    final now = DateTime.now();
    final difference = target.difference(now);

    if (difference.isNegative) {
      return 'Atrasado';
    }

    if (difference.inDays > 0) {
      return 'En ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'En ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'En ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'En menos de un minuto';
    }
  }

  // Verificar si una fecha es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Verificar si una fecha es mañana
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Obtener el inicio del día
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Obtener el fin del día
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Obtener el primer día de la semana
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // Calcular la próxima fecha recurrente
  static DateTime? getNextRecurrenceDate(DateTime current, String type) {
    switch (type) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(
          current.year,
          current.month + 1,
          current.day,
          current.hour,
          current.minute,
        );
      case 'yearly':
        return DateTime(
          current.year + 1,
          current.month,
          current.day,
          current.hour,
          current.minute,
        );
      default:
        return null;
    }
  }
}

class StringHelpers {
  // Capitalizar primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalizar cada palabra
  static String capitalizeWords(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }

  // Truncar texto con ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Limpiar espacios extra
  static String cleanSpaces(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Validar email
  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailPattern).hasMatch(email);
  }

  // Generar un ID único simple
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Extraer iniciales de un nombre
  static String getInitials(String name, {int maxInitials = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials =
        words
            .take(maxInitials)
            .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
            .join();
    return initials;
  }

  // Buscar coincidencias en texto
  static bool containsIgnoreCase(String text, String query) {
    return text.toLowerCase().contains(query.toLowerCase());
  }

  // Remover acentos y caracteres especiales
  static String removeAccents(String text) {
    const accents = 'áéíóúàèìòùäëïöüâêîôûãñç';
    const withoutAccents = 'aeiouaeiouaeiouaeiouanc';

    String result = text.toLowerCase();
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], withoutAccents[i]);
    }
    return result;
  }
}

class ColorHelpers {
  // Obtener color de texto contrastante
  static Color getContrastingColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Generar color aleatorio
  static Color randomColor() {
    return Color(
      (DateTime.now().millisecondsSinceEpoch * 16777215) % 0xFFFFFF,
    ).withOpacity(1.0);
  }

  // Mezclar dos colores
  static Color blendColors(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio) ?? color1;
  }

  // Hacer un color más claro
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Hacer un color más oscuro
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

class ValidationHelpers {
  // Validar título del recordatorio
  static String? validateReminderTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'El título es requerido';
    }
    if (title.length > AppConstants.maxReminderTitleLength) {
      return 'El título no puede exceder ${AppConstants.maxReminderTitleLength} caracteres';
    }
    return null;
  }

  // Validar descripción del recordatorio
  static String? validateReminderDescription(String? description) {
    if (description != null &&
        description.length > AppConstants.maxReminderDescriptionLength) {
      return 'La descripción no puede exceder ${AppConstants.maxReminderDescriptionLength} caracteres';
    }
    return null;
  }

  // Validar fecha del recordatorio
  static String? validateReminderDate(DateTime? date) {
    if (date == null) {
      return 'La fecha es requerida';
    }
    if (date.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      return 'La fecha no puede ser en el pasado';
    }
    return null;
  }

  // Validar formulario completo de recordatorio
  static Map<String, String?> validateReminderForm({
    required String? title,
    String? description,
    required DateTime? dateTime,
  }) {
    return {
      'title': validateReminderTitle(title),
      'description': validateReminderDescription(description),
      'dateTime': validateReminderDate(dateTime),
    };
  }
}

class UIHelpers {
  // Mostrar SnackBar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Mostrar diálogo de confirmación
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style:
                    confirmColor != null
                        ? ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                        )
                        : null,
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  // Obtener el MediaQuery de forma segura
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // Verificar si es una pantalla pequeña
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context).width < 600;
  }

  // Obtener padding seguro
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Cerrar el teclado
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}

class FormatHelpers {
  // Formatear número con separadores de miles
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'es_ES');
    return formatter.format(number);
  }

  // Formatear porcentaje
  static String formatPercentage(double value) {
    return '${(value * 100).round()}%';
  }

  // Formatear duración en texto legible
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} día${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Menos de un minuto';
    }
  }

  // Formatear tamaño de archivo
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
