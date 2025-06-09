import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder.dart';
import '../models/category.dart';
import '../models/reminder_type.dart';
import '../services/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final Map<int, Timer> _activeTimers = {};
  static const MethodChannel _vibratorChannel = MethodChannel(
    'com.nomeolvido/vibrator',
  );

  // GlobalKey para acceder al contexto
  static GlobalKey<NavigatorState>? navigatorKey;

  // Zona horaria local
  static late tz.Location local;

  NotificationService._internal();
  factory NotificationService() => _instance;

  Future<void> initialize() async {
    print('🔔 Inicializando NotificationService FINAL');

    // Inicializar timezone
    tz.initializeTimeZones();
    local = tz.local;

    // Configurar notificaciones locales
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Crear canales de notificación
    await _createNotificationChannels();

    // Solicitar permisos
    await requestPermissions();

    // Restaurar recordatorios programados
    await _restoreScheduledReminders();

    print('🚀 NotificationService inicializado correctamente');
  }

  Future<void> _createNotificationChannels() async {
    final List<AndroidNotificationChannel> channels = [
      // Canal normal
      const AndroidNotificationChannel(
        'reminders_normal',
        'Recordatorios',
        description: 'Notificaciones de recordatorios importantes',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      // Canal de alta prioridad
      const AndroidNotificationChannel(
        'reminders_high',
        'Alta Prioridad',
        description: 'Recordatorios urgentes de alta prioridad',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    ];

    final androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      for (final channel in channels) {
        await androidImplementation.createNotificationChannel(channel);
      }
    }
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> areNotificationsEnabled() async {
    final androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  static void _onNotificationTap(NotificationResponse response) {
    print('🔔 Notificación tocada: \x1B[33m${response.payload}\x1B[0m');

    if (response.actionId == 'mark_done') {
      print('✅ Usuario marcó recordatorio como completado');
      // Programar la siguiente recurrencia si es recurrente
      try {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          final reminderId = data['id'];
          // Aquí deberíamos obtener el recordatorio original desde la base de datos
          // y programar la siguiente recurrencia. Esto requiere acceso a ReminderProvider o DatabaseService.
          // Se puede implementar un canal de comunicación o usar un callback para esto.
        }
      } catch (e) {
        print('❌ Error al programar la siguiente recurrencia: $e');
      }
    }
    if (response.actionId == 'stop_vibration') {
      print('🛑 Usuario pidió detener la vibración');
      try {
        const MethodChannel('com.nomeolvido/vibrator').invokeMethod('cancel');
      } catch (e) {
        print('❌ Error al detener la vibración: $e');
      }
    }
  }

  Future<void> scheduleReminder(
    Reminder reminder, {
    bool saveToPrefs = true,
    bool programarRecurrencia =
        false, // Por defecto, no programar la siguiente recurrencia automáticamente
  }) async {
    if (reminder.dateTime.isBefore(DateTime.now())) {
      print('⚠️ No se puede programar recordatorio para fecha pasada');
      return;
    }

    // Verificar permisos antes de programar
    final hasPermission = await areNotificationsEnabled();
    if (!hasPermission) {
      print('⚠️ No hay permiso para notificaciones');
      await requestPermissions();

      // Mostrar notificación de error
      await _showInAppNotification(
        '❌ Error de Permiso',
        'Se necesita permiso para notificaciones',
        Colors.red,
        Icons.error,
      );
      return;
    }

    final category = ReminderCategory.getCategoryById(reminder.category);
    final reminderId =
        reminder.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    print('⏰ Programando recordatorio: [32m${reminder.title}[0m');
    print('📅 Para: ${reminder.dateTime}');

    try {
      // Cancelar notificación anterior si existe
      await _notifications.cancel(reminderId);

      // Configurar la notificación programada
      final androidDetails = AndroidNotificationDetails(
        reminder.priority == 3 ? 'reminders_high' : 'reminders_normal',
        reminder.priority == 3 ? 'Alta Prioridad' : 'Recordatorios',
        channelDescription: 'Notificaciones de recordatorios',
        importance: reminder.priority == 3 ? Importance.max : Importance.high,
        priority: reminder.priority == 3 ? Priority.max : Priority.high,
        showWhen: true,
        // Solo habilitar vibración para prioridad alta
        enableVibration: reminder.priority == 3,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          reminder.description ?? 'Tienes un recordatorio pendiente',
          contentTitle:
              '${_getPriorityEmoji(reminder.priority)} ${reminder.title}',
        ),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        actions: [
          const AndroidNotificationAction(
            'mark_done',
            'Completado',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'stop_vibration',
            'Detener vibración',
            showsUserInterface: false,
          ),
        ],
      );

      // Programar la notificación usando el sistema de Android
      await _notifications.zonedSchedule(
        reminderId,
        '${_getPriorityEmoji(reminder.priority)} ${reminder.title}',
        reminder.description ?? 'Tienes un recordatorio pendiente',
        tz.TZDateTime.from(reminder.dateTime, local),
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({
          'id': reminderId,
          'category': reminder.category,
          'priority': reminder.priority,
        }),
      );

      // Guardar en SharedPreferences para persistencia solo si corresponde
      if (saveToPrefs) {
        await _saveScheduledReminder(reminder);
      }

      // Mostrar confirmación en la app
      await _showInAppNotification(
        '✅ Recordatorio Programado',
        '"${reminder.title}" para ${_formatDateTime(reminder.dateTime)}',
        category.color,
        Icons.schedule,
      );

      print('✅ Recordatorio programado exitosamente');

      // Si es recurrente, NO programar la siguiente ocurrencia aquí
      // La siguiente ocurrencia se programará cuando el usuario marque como completado o interactúe con la notificación
    } catch (e) {
      print('❌ Error programando recordatorio: $e');
      await _showInAppNotification(
        '❌ Error',
        'No se pudo programar el recordatorio: ${e.toString()}',
        Colors.red,
        Icons.error,
      );
    }
  }

  String _getPriorityEmoji(int priority) {
    switch (priority) {
      case 3:
        return '🚨';
      case 2:
        return '⚠️';
      default:
        return 'ℹ️';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String prefix;
    if (reminderDate == today) {
      prefix = 'Hoy';
    } else if (reminderDate == tomorrow) {
      prefix = 'Mañana';
    } else {
      prefix = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    return '$prefix a las ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required int priority,
    required String category,
  }) async {
    try {
      String priorityEmoji =
          priority == 3
              ? '🚨'
              : priority == 2
              ? '⚠️'
              : 'ℹ️';
      String channelId = priority == 3 ? 'reminders_high' : 'reminders_normal';

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            channelId,
            priority == 3 ? 'Alta Prioridad' : 'Recordatorios',
            channelDescription: 'Notificaciones de recordatorios',
            importance: priority == 3 ? Importance.max : Importance.high,
            priority: priority == 3 ? Priority.max : Priority.high,
            showWhen: true,
            enableVibration: priority == 3,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap(
              '@mipmap/ic_launcher',
            ),
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: '$priorityEmoji $title',
            ),
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            autoCancel: true,
            actions: [
              const AndroidNotificationAction(
                'mark_done',
                'Completado',
                showsUserInterface: false,
              ),
              const AndroidNotificationAction(
                'stop_vibration',
                'Detener vibración',
                showsUserInterface: false,
              ),
            ],
          );

      await _notifications.show(
        id,
        '$priorityEmoji $title',
        body,
        NotificationDetails(android: androidDetails),
        payload: jsonEncode({
          'id': id,
          'category': category,
          'priority': priority,
        }),
      );

      print('✅ Notificación mostrada: $title');

      // Vibración extra solo para alta prioridad
      if (priority == 3) {
        await _vibrate();
      }
    } catch (e) {
      print('❌ Error mostrando notificación: $e');
    }
  }

  Future<void> _vibrate() async {
    try {
      // Solo vibrar si está habilitado en las preferencias
      final storage = StorageService();
      if (!storage.vibrationEnabled) return;

      // Intentar usar el vibrator nativo de Android
      try {
        // Patrón de vibración: [espera, vibrar]
        // Duración en milisegundos: [0, 15000] (15 segundos continuos)
        await _vibratorChannel.invokeMethod('vibrate', {
          'pattern': [0, 15000],
          'repeat': -1, // No repetir
        });
        // No cancelar automáticamente, se detendrá solo si el usuario lo indica
      } catch (e) {
        print('Error usando vibrator nativo: $e');
        // Fallback a HapticFeedback si el vibrator nativo falla
        for (int i = 0; i < 15; i++) {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      }
    } catch (e) {
      print('Error en vibración: $e');
    }
  }

  Future<void> _saveScheduledReminder(Reminder reminder) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledReminders =
          prefs.getStringList('scheduled_reminders') ?? [];

      final reminderData = jsonEncode({
        'id': reminder.id,
        'title': reminder.title,
        'description': reminder.description,
        'dateTime': reminder.dateTime.toIso8601String(),
        'category': reminder.category,
        'priority': reminder.priority,
        'isRecurring': reminder.isRecurring,
        'recurringType': reminder.recurringType,
        'type': reminder.type.toString(),
      });

      // Remover si ya existe
      scheduledReminders.removeWhere((item) {
        try {
          final data = jsonDecode(item);
          return data['id'] == reminder.id;
        } catch (e) {
          return false;
        }
      });

      scheduledReminders.add(reminderData);
      await prefs.setStringList('scheduled_reminders', scheduledReminders);

      print('💾 Recordatorio guardado');
    } catch (e) {
      print('❌ Error guardando recordatorio: $e');
    }
  }

  Future<void> _removeScheduledReminder(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledReminders =
          prefs.getStringList('scheduled_reminders') ?? [];

      scheduledReminders.removeWhere((item) {
        try {
          final data = jsonDecode(item);
          return data['id'] == id;
        } catch (e) {
          return false;
        }
      });

      await prefs.setStringList('scheduled_reminders', scheduledReminders);
      print('🗑️ Recordatorio removido de storage');
    } catch (e) {
      print('❌ Error removiendo recordatorio: $e');
    }
  }

  Future<void> _restoreScheduledReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledReminders =
          prefs.getStringList('scheduled_reminders') ?? [];

      int restored = 0;
      final now = DateTime.now();

      for (final reminderData in scheduledReminders) {
        try {
          final data = jsonDecode(reminderData);
          final dateTime = DateTime.parse(data['dateTime']);

          // Solo restaurar si la fecha es futura
          if (dateTime.isAfter(now)) {
            final reminder = Reminder(
              id: data['id'],
              title: data['title'],
              description: data['description'],
              dateTime: dateTime,
              category: data['category'],
              type: ReminderType.values.firstWhere(
                (t) => t.toString() == data['type'],
                orElse: () => ReminderType.otro,
              ),
              priority: data['priority'],
              isRecurring: data['isRecurring'] ?? false,
              recurringType: data['recurringType'],
              createdAt: now,
            );

            // Llamar a scheduleReminder con programarRecurrencia: false para evitar el ciclo infinito
            await scheduleReminder(
              reminder,
              saveToPrefs: false,
              programarRecurrencia: false,
            );
            restored++;
          }
        } catch (e) {
          print('❌ Error restaurando recordatorio: $e');
        }
      }

      if (restored > 0) {
        print('🔄 $restored recordatorios restaurados');
        await _showInAppNotification(
          '🔄 Recordatorios Restaurados',
          '$restored recordatorio${restored > 1 ? 's' : ''} reprogramado${restored > 1 ? 's' : ''}',
          Colors.blue,
          Icons.restore,
        );
      }
    } catch (e) {
      print('❌ Error restaurando recordatorios: $e');
    }
  }

  Future<void> _scheduleNextRecurrence(Reminder reminder) async {
    if (!reminder.isRecurring || reminder.recurringType == null) return;

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

    final nextReminder = reminder.copyWith(dateTime: nextDate);
    await scheduleReminder(nextReminder);

    print('🔄 Siguiente recurrencia programada para: $nextDate');
  }

  Future<void> cancelReminder(int id) async {
    // Cancelar timer activo
    _activeTimers[id]?.cancel();
    _activeTimers.remove(id);

    // Cancelar notificación local
    await _notifications.cancel(id);

    // Remover de storage
    await _removeScheduledReminder(id);

    print('🗑️ Recordatorio cancelado ID: $id');
  }

  Future<void> showInstantNotification(
    String title,
    String body, {
    String? category,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _showNotification(
      id: id,
      title: title,
      body: body,
      priority: 2,
      category: category ?? 'personal',
    );
  }

  Future<void> _showInAppNotification(
    String title,
    String message,
    Color color,
    IconData icon,
  ) async {
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<void> cancelAllNotifications() async {
    // Cancelar todos los timers
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();

    // Cancelar todas las notificaciones
    await _notifications.cancelAll();

    // Limpiar storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_reminders');

    await _showInAppNotification(
      '🗑️ Todo Cancelado',
      'Todos los recordatorios han sido cancelados',
      Colors.orange,
      Icons.notifications_off,
    );

    print('🗑️ Todas las notificaciones canceladas');
  }

  // Método de prueba simple
  Future<void> scheduleTestNotification() async {
    final testReminder = Reminder(
      id: 99999,
      title: '🚨 Prueba de Notificación de Alta Prioridad',
      description:
          '¡Probando la vibración fuerte para recordatorios importantes!',
      dateTime: DateTime.now().add(const Duration(seconds: 10)),
      category: 'personal',
      type: ReminderType.otro,
      priority: 3,
      createdAt: DateTime.now(),
    );

    await scheduleReminder(testReminder);
    print('🧪 Notificación de prueba de alta prioridad programada');
  }

  Future<void> debugPrintStatus() async {
    final enabled = await areNotificationsEnabled();
    final pending = await getPendingNotifications();
    final activeTimers = _activeTimers.length;

    print('🔍 DEBUG - Estado del NotificationService:');
    print('   📱 Notificaciones habilitadas: $enabled');
    print('   ⏰ Timers activos: $activeTimers');
    print('   📋 Notificaciones pendientes: ${pending.length}');
    print('   🔔 Inicializado: true');
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} día${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    }
  }
}
