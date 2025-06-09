class AppConstants {
  // Información de la aplicación
  static const String appName = 'No Me Olvido';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription = 'Tu asistente personal de recordatorios';

  // URLs y contacto
  static const String supportEmail = 'soporte@nomeolvido.app';
  static const String websiteUrl = 'https://nomeolvido.app';
  static const String privacyPolicyUrl = 'https://nomeolvido.app/privacy';
  static const String termsOfServiceUrl = 'https://nomeolvido.app/terms';

  // Configuraciones de base de datos
  static const String databaseName = 'no_me_olvido.db';
  static const int databaseVersion = 1;
  static const String remindersTableName = 'reminders';

  // Configuraciones de notificaciones
  static const String notificationChannelId = 'reminders_channel';
  static const String notificationChannelName = 'Recordatorios';
  static const String notificationChannelDescription =
      'Notificaciones de recordatorios importantes';

  // Configuraciones de tiempo
  static const int defaultSnoozeMinutes = 15;
  static const int maxSnoozeTimes = 3;
  static const int autoCleanupDays = 30;
  static const int maxRecurringReminders = 50;

  // Límites de la aplicación
  static const int maxReminderTitleLength = 100;
  static const int maxReminderDescriptionLength = 500;
  static const int maxRemindersPerDay = 20;
  static const int maxTotalReminders = 1000;

  // Configuraciones de UI
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Duraciones de animación
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 350;
  static const int longAnimationDuration = 500;

  // Configuraciones de búsqueda
  static const int minSearchLength = 2;
  static const int searchDelayMs = 300;

  // Formatos de fecha y hora
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String fullDateFormat = 'EEEE, dd \'de\' MMMM \'de\' yyyy';

  // Claves de SharedPreferences
  static const String keyFirstLaunch = 'first_launch';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyAutoCleanup = 'auto_cleanup';
  static const String keyThemeMode = 'theme_mode';
  static const String keyAccentColor = 'accent_color';
  static const String keyDefaultReminderTime = 'default_reminder_time';
  static const String keyLastBackupDate = 'last_backup_date';

  // Categorías predefinidas
  static const List<String> defaultCategories = [
    'health',
    'finance',
    'family',
    'community',
    'work',
    'personal',
  ];

  // Íconos de categorías
  static const Map<String, int> categoryIcons = {
    'health': 0xe1ac, // Icons.health_and_safety
    'finance': 0xe227, // Icons.attach_money
    'family': 0xe1af, // Icons.family_restroom
    'community': 0xe1d9, // Icons.group
    'work': 0xe1b0, // Icons.work
    'personal': 0xe1bb, // Icons.person
  };

  // Sonidos de notificación
  static const List<String> notificationSounds = [
    'default',
    'bell',
    'chime',
    'ding',
    'notification',
  ];

  // Intervalos de recordatorios recurrentes
  static const Map<String, String> recurringIntervals = {
    'daily': 'Diario',
    'weekly': 'Semanal',
    'monthly': 'Mensual',
    'yearly': 'Anual',
  };

  // Opciones de posponer (en minutos)
  static const List<int> snoozeOptions = [5, 10, 15, 30, 60];

  // Textos de la aplicación
  static const String welcomeTitle = '¡Bienvenido a No Me Olvido!';
  static const String welcomeSubtitle =
      'Tu asistente personal para nunca olvidar lo importante';

  static const String emptyRemindersTitle = 'No tienes recordatorios';
  static const String emptyRemindersSubtitle =
      'Toca el botón + para crear tu primer recordatorio';

  static const String emptySearchTitle = 'Sin resultados';
  static const String emptySearchSubtitle = 'Intenta con otras palabras clave';

  // Mensajes de error
  static const String errorGeneral = 'Ha ocurrido un error inesperado';
  static const String errorNetwork = 'Verifica tu conexión a internet';
  static const String errorPermissions = 'Permisos insuficientes';
  static const String errorDatabase = 'Error en la base de datos';
  static const String errorNotification = 'Error al programar notificación';

  // Mensajes de éxito
  static const String successReminderCreated =
      'Recordatorio creado exitosamente';
  static const String successReminderUpdated = 'Recordatorio actualizado';
  static const String successReminderDeleted = 'Recordatorio eliminado';
  static const String successReminderCompleted = '¡Recordatorio completado!';

  // Configuraciones de validación
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 50;

  // URLs de ayuda
  static const String helpUrl = 'https://nomeolvido.app/help';
  static const String faqUrl = 'https://nomeolvido.app/faq';
  static const String tutorialUrl = 'https://nomeolvido.app/tutorial';

  // Configuraciones de backup
  static const int maxBackupFiles = 5;
  static const String backupFileExtension = '.nmb'; // No Me olvido Backup

  // Analytics eventos
  static const String eventReminderCreated = 'reminder_created';
  static const String eventReminderCompleted = 'reminder_completed';
  static const String eventAppOpened = 'app_opened';
  static const String eventSettingsOpened = 'settings_opened';

  // Configuraciones de desarrollo
  static const bool enableDebugMode = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;

  // Feature flags
  static const bool enableCloudSync = false;
  static const bool enablePremiumFeatures = false;
  static const bool enableSocialSharing = false;
  static const bool enableWidgets = false;

  // Configuraciones regionales
  static const String defaultLocale = 'es_ES';
  static const String defaultTimeZone = 'America/La_Paz';

  // Límites de rate limiting
  static const int maxNotificationsPerHour = 10;
  static const int maxAPICallsPerMinute = 60;

  // Configuraciones de cache
  static const int cacheExpirationHours = 24;
  static const int maxCacheSize = 100; // MB

  // Patrones de expresiones regulares
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';

  // Configuraciones de exportación
  static const List<String> exportFormats = ['json', 'csv', 'txt'];
  static const String defaultExportFormat = 'json';

  // Configuraciones de importación
  static const List<String> supportedImportFormats = ['json', 'csv'];
  static const int maxImportFileSize = 10; // MB

  // Configuraciones de seguridad
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  // Configuraciones de accesibilidad
  static const double minTouchTargetSize = 44.0;
  static const double maxFontSize = 28.0;
  static const double minFontSize = 12.0;

  // Configuraciones de performance
  static const int maxItemsPerPage = 50;
  static const int preloadItemsCount = 10;
  static const int maxConcurrentOperations = 3;

  // Configuraciones de red
  static const int connectionTimeoutSeconds = 30;
  static const int readTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Métodos utilitarios para constantes
  static String getAppInfo() {
    return '$appName v$appVersion ($appBuildNumber)';
  }

  static String getFullAppName() {
    return '$appName - $appDescription';
  }

  static Duration getAnimationDuration(String type) {
    switch (type) {
      case 'short':
        return Duration(milliseconds: shortAnimationDuration);
      case 'medium':
        return Duration(milliseconds: mediumAnimationDuration);
      case 'long':
        return Duration(milliseconds: longAnimationDuration);
      default:
        return Duration(milliseconds: mediumAnimationDuration);
    }
  }

  static Duration getSnoozeDuration(int minutes) {
    return Duration(minutes: minutes);
  }

  static bool isValidReminderTitle(String title) {
    return title.isNotEmpty && title.length <= maxReminderTitleLength;
  }

  static bool isValidReminderDescription(String? description) {
    return description == null ||
        description.length <= maxReminderDescriptionLength;
  }

  // Nombres de categorías en español
  static const Map<String, String> categoryNames = {
    'health': 'Salud',
    'finance': 'Finanzas',
    'family': 'Familia',
    'community': 'Comunidad',
    'work': 'Trabajo',
    'personal': 'Personal',
  };

  // Descripciones de categorías
  static const Map<String, String> categoryDescriptions = {
    'health': 'Citas médicas, medicamentos, ejercicio',
    'finance': 'Pagos, facturas, inversiones',
    'family': 'Cumpleaños, reuniones familiares',
    'community': 'Eventos, reuniones, voluntariado',
    'work': 'Reuniones, proyectos, deadlines',
    'personal': 'Tareas personales, hobbies',
  };

  // Niveles de prioridad
  static const Map<int, String> priorityNames = {
    1: 'Baja',
    2: 'Media',
    3: 'Alta',
  };

  static const Map<int, String> priorityDescriptions = {
    1: 'No urgente, puedes posponerlo',
    2: 'Importante, pero no crítico',
    3: 'Urgente, requiere atención inmediata',
  };

  // Estados de recordatorios
  static const Map<String, String> reminderStates = {
    'pending': 'Pendiente',
    'completed': 'Completado',
    'overdue': 'Atrasado',
    'cancelled': 'Cancelado',
  };

  // Frases motivacionales
  static const List<String> motivationalQuotes = [
    '¡Excelente trabajo manteniéndote organizado!',
    'Cada recordatorio completado es un paso hacia tus metas.',
    '¡Sigue así! La organización es clave del éxito.',
    'Tus buenos hábitos te llevarán lejos.',
    'La constancia es la madre de la excelencia.',
    '¡Eres increíble organizándote!',
    'Un día productivo más gracias a tu planificación.',
  ];

  // Configuraciones de notificaciones por prioridad
  static const Map<int, Map<String, dynamic>> priorityNotificationSettings = {
    1: {
      'vibrationPattern': [0, 250, 250, 250],
      'importance': 'default',
      'sound': 'default',
    },
    2: {
      'vibrationPattern': [0, 500, 200, 500],
      'importance': 'high',
      'sound': 'notification',
    },
    3: {
      'vibrationPattern': [0, 1000, 200, 1000, 200, 1000],
      'importance': 'max',
      'sound': 'alarm',
    },
  };

  // Configuraciones de colores por tema
  static const Map<String, int> lightThemeColors = {
    'primary': 0xFF6366F1,
    'secondary': 0xFF8B5CF6,
    'surface': 0xFFFFFFFF,
    'background': 0xFFFAFAFA,
    'error': 0xFFEF4444,
    'success': 0xFF10B981,
    'warning': 0xFFF59E0B,
  };

  static const Map<String, int> darkThemeColors = {
    'primary': 0xFF818CF8,
    'secondary': 0xFFA78BFA,
    'surface': 0xFF1F1F1F,
    'background': 0xFF0F0F0F,
    'error': 0xFFF87171,
    'success': 0xFF34D399,
    'warning': 0xFFFBBF24,
  };

  // Configuraciones de tipografía
  static const Map<String, double> fontSizes = {
    'caption': 12.0,
    'body2': 14.0,
    'body1': 16.0,
    'subtitle2': 18.0,
    'subtitle1': 20.0,
    'headline6': 22.0,
    'headline5': 24.0,
    'headline4': 28.0,
    'headline3': 32.0,
    'headline2': 36.0,
    'headline1': 40.0,
  };

  // Configuraciones de espaciado
  static const Map<String, double> spacing = {
    'xs': 4.0,
    'sm': 8.0,
    'md': 16.0,
    'lg': 24.0,
    'xl': 32.0,
    'xxl': 48.0,
  };

  // Configuraciones de elevación/sombras
  static const Map<String, double> elevations = {
    'none': 0.0,
    'low': 2.0,
    'medium': 4.0,
    'high': 8.0,
    'highest': 16.0,
  };
}
