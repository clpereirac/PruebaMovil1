import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String _filter = 'all'; // 'all', 'pending', 'completed', 'today'

  List<Reminder> get reminders => _getFilteredReminders();
  bool get isLoading => _isLoading;
  String get currentFilter => _filter;

  List<Reminder> get todayReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _reminders.where((reminder) {
      return reminder.dateTime.isAfter(today) &&
          reminder.dateTime.isBefore(tomorrow) &&
          !reminder.isCompleted;
    }).toList();
  }

  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    return _reminders
        .where((reminder) {
          return reminder.dateTime.isAfter(now) && !reminder.isCompleted;
        })
        .take(10)
        .toList();
  }

  List<Reminder> get overdueReminders {
    final now = DateTime.now();
    return _reminders.where((reminder) {
      return reminder.dateTime.isBefore(now) && !reminder.isCompleted;
    }).toList();
  }

  List<Reminder> _getFilteredReminders() {
    switch (_filter) {
      case 'pending':
        return _reminders.where((r) => !r.isCompleted).toList();
      case 'completed':
        return _reminders.where((r) => r.isCompleted).toList();
      case 'today':
        return todayReminders;
      default:
        return _reminders;
    }
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await _databaseService.getAllReminders();

      // Reprogramar recordatorios que están en el futuro
      await _reprogramActiveReminders();
    } catch (e) {
      debugPrint('Error loading reminders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _reprogramActiveReminders() async {
    final now = DateTime.now();
    final activeReminders =
        _reminders
            .where(
              (reminder) =>
                  reminder.dateTime.isAfter(now) && !reminder.isCompleted,
            )
            .toList();

    // Solo restaurar una vez y no programar recurrencias
    for (final reminder in activeReminders) {
      try {
        // Usar programarRecurrencia: false para evitar el ciclo infinito
        await _notificationService.scheduleReminder(
          reminder,
          saveToPrefs: false,
          programarRecurrencia: false,
        );
      } catch (e) {
        debugPrint('Error reprogramming reminder ${reminder.id}: $e');
      }
    }

    if (activeReminders.isNotEmpty) {
      debugPrint(
        '🔄 Restaurando ${activeReminders.length} recordatorios activos',
      );
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      final id = await _databaseService.insertReminder(reminder);
      final newReminder = reminder.copyWith(id: id);

      // Programar notificación
      if (newReminder.dateTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleReminder(newReminder);
      }

      _reminders.add(newReminder);
      _sortReminders();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding reminder: $e');
      await _notificationService.showInstantNotification(
        '❌ Error',
        'No se pudo crear el recordatorio',
      );
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _databaseService.updateReminder(reminder);

      // Actualizar notificación
      await _notificationService.cancelReminder(reminder.id!);
      if (reminder.dateTime.isAfter(DateTime.now()) && !reminder.isCompleted) {
        await _notificationService.scheduleReminder(reminder);
      }

      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder;
        _sortReminders();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      await _notificationService.showInstantNotification(
        '❌ Error',
        'No se pudo actualizar el recordatorio',
      );
    }
  }

  Future<void> deleteReminder(int id) async {
    try {
      final reminder = _reminders.firstWhere((r) => r.id == id);

      await _databaseService.deleteReminder(id);
      await _notificationService.cancelReminder(id);

      _reminders.removeWhere((reminder) => reminder.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      await _notificationService.showInstantNotification(
        '❌ Error',
        'No se pudo eliminar el recordatorio',
      );
    }
  }

  Future<void> markAsCompleted(int id) async {
    try {
      await _databaseService.markAsCompleted(id);
      await _notificationService.cancelReminder(id);

      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        final reminder = _reminders[index];
        _reminders[index] = reminder.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        notifyListeners();

        // Si es recurrente, crear y programar la siguiente instancia
        if (reminder.isRecurring && reminder.recurringType != null) {
          DateTime nextDate;
          switch (reminder.recurringType!) {
            case 'daily':
              nextDate = reminder.dateTime.add(const Duration(days: 1));
              break;
            case 'weekly':
              nextDate = reminder.dateTime.add(const Duration(days: 7));
              break;
            case 'monthly':
              nextDate = DateTime(
                reminder.dateTime.year,
                reminder.dateTime.month + 1,
                reminder.dateTime.day,
                reminder.dateTime.hour,
                reminder.dateTime.minute,
              );
              break;
            case 'yearly':
              nextDate = DateTime(
                reminder.dateTime.year + 1,
                reminder.dateTime.month,
                reminder.dateTime.day,
                reminder.dateTime.hour,
                reminder.dateTime.minute,
              );
              break;
            default:
              return;
          }
          final nextReminder = reminder.copyWith(
            id: null,
            dateTime: nextDate,
            isCompleted: false,
            completedAt: null,
            createdAt: DateTime.now(),
          );
          await addReminder(nextReminder);
        }
      }
    } catch (e) {
      debugPrint('Error marking reminder as completed: $e');
    }
  }

  Future<void> markAsIncomplete(int id) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        final reminder = _reminders[index].copyWith(
          isCompleted: false,
          completedAt: null,
        );

        await _databaseService.updateReminder(reminder);

        // Reprogramar si es futuro
        if (reminder.dateTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleReminder(reminder);
        }

        _reminders[index] = reminder;
        notifyListeners();

        await _notificationService.showInstantNotification(
          '🔄 Reactivado',
          '"${reminder.title}" marcado como pendiente',
          category: reminder.category,
        );
      }
    } catch (e) {
      debugPrint('Error marking reminder as incomplete: $e');
    }
  }

  List<Reminder> getRemindersByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _reminders.where((reminder) {
      return reminder.dateTime.isAfter(startOfDay) &&
          reminder.dateTime.isBefore(endOfDay);
    }).toList();
  }

  List<Reminder> searchReminders(String query) {
    if (query.isEmpty) return _reminders;

    final lowerQuery = query.toLowerCase();
    return _reminders.where((reminder) {
      return reminder.title.toLowerCase().contains(lowerQuery) ||
          (reminder.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void _sortReminders() {
    _reminders.sort((a, b) {
      // Primero por completado (pendientes primero)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Luego por fecha
      return a.dateTime.compareTo(b.dateTime);
    });
  }

  // Estadísticas mejoradas
  Map<String, dynamic> getDetailedStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final thisWeek = today.add(const Duration(days: 7));

    final total = _reminders.length;
    final completed = _reminders.where((r) => r.isCompleted).length;
    final pending = _reminders.where((r) => !r.isCompleted).length;
    final todayCount =
        _reminders
            .where(
              (r) =>
                  r.dateTime.isAfter(today) &&
                  r.dateTime.isBefore(tomorrow) &&
                  !r.isCompleted,
            )
            .length;
    final overdue =
        _reminders
            .where((r) => r.dateTime.isBefore(now) && !r.isCompleted)
            .length;
    final thisWeekCount =
        _reminders
            .where(
              (r) =>
                  r.dateTime.isAfter(now) &&
                  r.dateTime.isBefore(thisWeek) &&
                  !r.isCompleted,
            )
            .length;

    // Estadísticas por categoría
    final categoryStats = <String, int>{};
    for (final reminder in _reminders.where((r) => !r.isCompleted)) {
      categoryStats[reminder.category] =
          (categoryStats[reminder.category] ?? 0) + 1;
    }

    // Estadísticas por prioridad
    final priorityStats = <int, int>{};
    for (final reminder in _reminders.where((r) => !r.isCompleted)) {
      priorityStats[reminder.priority] =
          (priorityStats[reminder.priority] ?? 0) + 1;
    }

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'today': todayCount,
      'overdue': overdue,
      'thisWeek': thisWeekCount,
      'completionRate': total > 0 ? (completed / total * 100).round() : 0,
      'categoryStats': categoryStats,
      'priorityStats': priorityStats,
      'recurringCount':
          _reminders.where((r) => r.isRecurring && !r.isCompleted).length,
    };
  }

  // Método para limpiar recordatorios antiguos completados
  Future<void> cleanupOldReminders({int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final oldCompleted =
        _reminders
            .where(
              (r) =>
                  r.isCompleted &&
                  (r.completedAt?.isBefore(cutoffDate) ?? false),
            )
            .toList();

    for (final reminder in oldCompleted) {
      if (reminder.id != null) {
        await _databaseService.deleteReminder(reminder.id!);
      }
    }

    _reminders.removeWhere((r) => oldCompleted.contains(r));
    notifyListeners();

    if (oldCompleted.isNotEmpty) {
      await _notificationService.showInstantNotification(
        '🧹 Limpieza Completada',
        '${oldCompleted.length} recordatorio${oldCompleted.length > 1 ? 's' : ''} antiguo${oldCompleted.length > 1 ? 's' : ''} eliminado${oldCompleted.length > 1 ? 's' : ''}',
      );
    }
  }

  // Método para duplicar recordatorio
  Future<void> duplicateReminder(
    Reminder reminder,
    DateTime newDateTime,
  ) async {
    final duplicated = Reminder(
      title: '${reminder.title} (Copia)',
      description: reminder.description,
      dateTime: newDateTime,
      category: reminder.category,
      type: reminder.type,
      priority: reminder.priority,
      isRecurring: reminder.isRecurring,
      recurringType: reminder.recurringType,
      createdAt: DateTime.now(),
    );

    await addReminder(duplicated);

    await _notificationService.showInstantNotification(
      '📋 Recordatorio Duplicado',
      '"${reminder.title}" copiado para ${_formatDate(newDateTime)}',
      category: reminder.category,
    );
  }

  // Método para posponer recordatorio
  Future<void> snoozeReminder(int id, Duration snoozeDuration) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      final newDateTime = DateTime.now().add(snoozeDuration);
      final snoozedReminder = reminder.copyWith(dateTime: newDateTime);

      await updateReminder(snoozedReminder);

      await _notificationService.showInstantNotification(
        '⏰ Recordatorio Pospuesto',
        '"${reminder.title}" reprogramado para ${_formatDateTime(newDateTime)}',
        category: reminder.category,
      );
    }
  }

  // Verificar permisos de notificaciones
  Future<bool> checkNotificationPermissions() async {
    return await _notificationService.areNotificationsEnabled();
  }

  // Exportar recordatorios (para futuras funciones)
  String exportReminders() {
    // Básico por ahora, se puede mejorar después
    final export =
        _reminders
            .map(
              (r) => {
                'title': r.title,
                'description': r.description,
                'dateTime': r.dateTime.toIso8601String(),
                'category': r.category,
                'priority': r.priority,
                'isCompleted': r.isCompleted,
              },
            )
            .toList();

    return export.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'hoy';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'mañana';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} a las ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<List<Reminder>> getAllReminders() async {
    try {
      _isLoading = true;
      notifyListeners();
      _reminders = await _databaseService.getAllReminders();
      return _reminders;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleReminderCompleted(int id, bool value) async {
    try {
      if (value) {
        await markAsCompleted(id);
      } else {
        final index = _reminders.indexWhere((r) => r.id == id);
        if (index != -1) {
          final reminder = _reminders[index];
          _reminders[index] = reminder.copyWith(
            isCompleted: false,
            completedAt: null,
          );
          await _databaseService.updateReminder(_reminders[index]);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error toggling reminder completion: $e');
    }
  }
}
