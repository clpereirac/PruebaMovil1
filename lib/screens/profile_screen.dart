import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storage = StorageService();
  final NotificationService _notificationService = NotificationService();
  final Map<String, int> usage = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Perfil y Configuración',
        showBackButton: true,
      ),
      body: Consumer2<ReminderProvider, ThemeProvider>(
        builder: (context, reminderProvider, themeProvider, child) {
          final stats = reminderProvider.getDetailedStatistics();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tarjeta de perfil
              _buildProfileCard(context, stats),
              const SizedBox(height: 24),

              // Sección de personalización
              _buildSection(context, 'Personalización', Icons.palette, [
                _buildThemeSelector(context, themeProvider),
                _buildColorSelector(context, themeProvider),
              ]),
              const SizedBox(height: 24),

              // Sección de notificaciones
              _buildSection(context, 'Notificaciones', Icons.notifications, [
                _buildNotificationSettings(),
                _buildNotificationTestButton(),
              ]),
              const SizedBox(height: 24),

              // Sección de datos
              _buildSection(context, 'Datos', Icons.storage, [
                _buildDataSettings(context, reminderProvider),
              ]),
              const SizedBox(height: 24),

              // Sección de información
              _buildSection(context, 'Información', Icons.info, [
                _buildAppInfo(context),
              ]),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar con animación
              Hero(
                tag: 'user_avatar',
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nombre de usuario
              Text(
                'Usuario Pro',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Descripción con badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Organizado',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                'Organizando mi vida con No Me Olvido',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Estadísticas rápidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    context,
                    'Total',
                    FormatHelpers.formatNumber(stats['total']),
                    Icons.list_alt,
                    AppColors.info,
                  ),
                  _buildStatItem(
                    context,
                    'Completados',
                    FormatHelpers.formatNumber(stats['completed']),
                    Icons.check_circle,
                    AppColors.success,
                  ),
                  _buildStatItem(
                    context,
                    'Pendientes',
                    FormatHelpers.formatNumber(stats['pending']),
                    Icons.schedule,
                    AppColors.warning,
                  ),
                ],
              ),

              // Tasa de completitud
              if (stats['total'] > 0) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tasa de Completitud',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${stats['completionRate']}%',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getCompletionColor(
                                stats['completionRate'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: stats['completionRate'] / 100,
                        backgroundColor: Theme.of(
                          context,
                        ).dividerColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCompletionColor(stats['completionRate']),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).primaryColor,
      ),
      title: const Text('Tema'),
      subtitle: Text(themeProvider.isDarkMode ? 'Modo oscuro' : 'Modo claro'),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          UIHelpers.showSnackBar(
            context,
            value ? 'Modo oscuro activado' : 'Modo claro activado',
            backgroundColor: Theme.of(context).primaryColor,
          );
        },
      ),
    );
  }

  Widget _buildColorSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return ExpansionTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: themeProvider.accentColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: themeProvider.accentColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: const Text('Color de acento'),
      subtitle: const Text('Personaliza el color principal'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Colores disponibles',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    ThemeProvider.accentColors.map((color) {
                      final isSelected =
                          color.value == themeProvider.accentColor.value;
                      return GestureDetector(
                        onTap: () {
                          themeProvider.setAccentColor(color);
                          UIHelpers.showSnackBar(
                            context,
                            'Color de acento actualizado',
                            backgroundColor: color,
                          );
                        },
                        child: AnimatedContainer(
                          duration: AppConstants.getAnimationDuration('short'),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border:
                                isSelected
                                    ? Border.all(color: Colors.white, width: 3)
                                    : Border.all(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.2),
                                    ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                    : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                          ),
                          child:
                              isSelected
                                  ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                  : null,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.notifications_active,
            color: Theme.of(context).primaryColor,
          ),
          title: const Text('Notificaciones'),
          subtitle: const Text('Recibir recordatorios'),
          trailing: Switch(
            value: _storage.notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _storage.setNotificationsEnabled(value);
              });
              UIHelpers.showSnackBar(
                context,
                value
                    ? 'Notificaciones activadas'
                    : 'Notificaciones desactivadas',
                backgroundColor: value ? AppColors.success : AppColors.warning,
              );
            },
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.vibration, color: Theme.of(context).primaryColor),
          title: const Text('Vibración'),
          subtitle: const Text('Vibrar al recibir recordatorios'),
          trailing: Switch(
            value: _storage.vibrationEnabled,
            onChanged: (value) async {
              setState(() {
                _storage.setVibrationEnabled(value);
              });
              UIHelpers.showSnackBar(
                context,
                value ? 'Vibración activada' : 'Vibración desactivada',
                backgroundColor: value ? AppColors.success : AppColors.warning,
              );
              if (value) {
                await _checkAndPromptVibration(context);
              }
            },
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.schedule, color: Theme.of(context).primaryColor),
          title: const Text('Hora predeterminada'),
          subtitle: Text(
            '${_storage.defaultReminderTime.toString().padLeft(2, '0')}:00',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showTimePickerDialog(),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
          title: const Text('Sonido de notificación'),
          subtitle: Text(StringHelpers.capitalize(_storage.reminderSound)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showSoundSelector(),
        ),
      ],
    );
  }

  Widget _buildNotificationTestButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await _notificationService.scheduleTestNotification();
              UIHelpers.showSnackBar(
                context,
                '🧪 Notificación de prueba programada para 10 segundos',
                backgroundColor: AppColors.info,
              );
            },
            icon: const Icon(Icons.science),
            label: const Text('Probar Notificaciones'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.buttonBorderRadius,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cierra la app después de presionar el botón',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings(
    BuildContext context,
    ReminderProvider reminderProvider,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.cleaning_services,
            color: Theme.of(context).primaryColor,
          ),
          title: const Text('Limpieza automática'),
          subtitle: const Text('Eliminar recordatorios antiguos'),
          trailing: Switch(
            value: _storage.autoCleanupEnabled,
            onChanged: (value) {
              setState(() {
                _storage.setAutoCleanupEnabled(value);
              });
              UIHelpers.showSnackBar(
                context,
                value
                    ? 'Limpieza automática activada'
                    : 'Limpieza automática desactivada',
                backgroundColor: value ? AppColors.success : AppColors.warning,
              );
            },
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.download, color: Theme.of(context).primaryColor),
          title: const Text('Exportar datos'),
          subtitle: const Text('Crear copia de seguridad'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _exportData(context, reminderProvider),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.upload, color: Theme.of(context).primaryColor),
          title: const Text('Importar datos'),
          subtitle: const Text('Restaurar desde copia de seguridad'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _importData(context, reminderProvider),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.delete_sweep, color: AppColors.error),
          title: const Text('Limpiar datos'),
          subtitle: const Text('Eliminar recordatorios completados'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _cleanupData(context, reminderProvider),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.analytics, color: Theme.of(context).primaryColor),
          title: const Text('Estadísticas de uso'),
          subtitle: const Text('Ver métricas detalladas'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showUsageStats(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.storage, color: Theme.of(context).primaryColor),
          title: const Text('Uso de almacenamiento'),
          subtitle: const Text('Ver espacio utilizado'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showStorageInfo(context),
        ),
      ],
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.info, color: Theme.of(context).primaryColor),
          title: const Text('Versión'),
          subtitle: Text(AppConstants.getAppInfo()),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Actual',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.help, color: Theme.of(context).primaryColor),
          title: const Text('Ayuda'),
          subtitle: const Text('Soporte y preguntas frecuentes'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showHelpDialog(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.feedback, color: Theme.of(context).primaryColor),
          title: const Text('Enviar comentarios'),
          subtitle: const Text('Ayúdanos a mejorar la app'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showFeedbackDialog(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.star, color: AppColors.warning),
          title: const Text('Calificar app'),
          subtitle: const Text('Deja tu reseña en la tienda'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _rateApp(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(
            Icons.privacy_tip,
            color: Theme.of(context).primaryColor,
          ),
          title: const Text('Privacidad'),
          subtitle: const Text('Política de privacidad'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showPrivacyDialog(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.article, color: Theme.of(context).primaryColor),
          title: const Text('Términos de servicio'),
          subtitle: const Text('Condiciones de uso'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showTermsDialog(context),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.bug_report, color: AppColors.error),
          title: const Text('Reportar problema'),
          subtitle: const Text('Informar sobre errores'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _reportBug(context),
        ),
      ],
    );
  }

  Color _getCompletionColor(int percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _showTimePickerDialog() async {
    final currentTime = _storage.defaultReminderTime;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentTime, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      await _storage.setDefaultReminderTime(time.hour);
      setState(() {});
      UIHelpers.showSnackBar(
        context,
        'Hora predeterminada actualizada a ${time.hour.toString().padLeft(2, '0')}:00',
        backgroundColor: AppColors.success,
      );
    }
  }

  Future<void> _showSoundSelector() async {
    final currentSound = _storage.reminderSound;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sonido de Notificación',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...AppConstants.notificationSounds.map(
                  (sound) => RadioListTile<String>(
                    title: Text(StringHelpers.capitalize(sound)),
                    value: sound,
                    groupValue: currentSound,
                    onChanged: (value) {
                      if (value != null) {
                        _storage.setReminderSound(value);
                        setState(() {});
                        Navigator.pop(context);
                        UIHelpers.showSnackBar(
                          context,
                          'Sonido actualizado a ${StringHelpers.capitalize(value)}',
                          backgroundColor: AppColors.success,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _exportData(
    BuildContext context,
    ReminderProvider provider,
  ) async {
    final export = provider.exportReminders();

    // Simulación de exportación
    await Future.delayed(const Duration(seconds: 1));

    UIHelpers.showSnackBar(
      context,
      'Datos exportados exitosamente',
      backgroundColor: AppColors.success,
    );

    // En una implementación real, aquí guardarías el archivo
    print('Exported data length: ${export.length} characters');

    // Mostrar diálogo con información de exportación
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exportación Completa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Los datos han sido exportados exitosamente.'),
                const SizedBox(height: 12),
                Text('Tamaño: ${FormatHelpers.formatFileSize(export.length)}'),
                Text('Fecha: ${DateHelpers.formatDateTime(DateTime.now())}'),
                const SizedBox(height: 12),
                const Text(
                  'En una versión completa, se guardaría como archivo en tu dispositivo.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  Future<void> _importData(
    BuildContext context,
    ReminderProvider provider,
  ) async {
    // Simulación de importación
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Importar Datos'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Esta función permite restaurar recordatorios desde una copia de seguridad.',
                ),
                SizedBox(height: 12),
                Text(
                  'En una versión completa, podrías seleccionar un archivo de backup.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  UIHelpers.showSnackBar(
                    context,
                    'Función de importación en desarrollo',
                    backgroundColor: AppColors.info,
                  );
                },
                child: const Text('Próximamente'),
              ),
            ],
          ),
    );
  }

  Future<void> _cleanupData(
    BuildContext context,
    ReminderProvider provider,
  ) async {
    final confirmed = await UIHelpers.showConfirmationDialog(
      context,
      title: 'Limpiar datos',
      content:
          '¿Estás seguro de que quieres eliminar todos los recordatorios completados hace más de ${AppConstants.autoCleanupDays} días?',
      confirmText: 'Eliminar',
      confirmColor: AppColors.error,
    );

    if (confirmed == true) {
      await provider.cleanupOldReminders(daysOld: AppConstants.autoCleanupDays);
      UIHelpers.showSnackBar(
        context,
        'Datos limpiados exitosamente',
        backgroundColor: AppColors.success,
      );
    }
  }

  void _showUsageStats(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Estadísticas de Uso',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          if (usage.isEmpty)
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay estadísticas disponibles',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Las estadísticas se generarán mientras uses la app',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[500]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            ...usage.entries.map(
                              (entry) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    child: Icon(
                                      _getUsageIcon(entry.key),
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    StringHelpers.capitalizeWords(
                                      entry.key.replaceAll('_', ' '),
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      FormatHelpers.formatNumber(entry.value),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.storage, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Uso de Almacenamiento'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStorageItem('Base de datos', '2.1 MB', AppColors.info),
                _buildStorageItem(
                  'Configuraciones',
                  '12 KB',
                  AppColors.success,
                ),
                _buildStorageItem(
                  'Cache temporal',
                  '156 KB',
                  AppColors.warning,
                ),
                const Divider(),
                _buildStorageItem(
                  'Total utilizado',
                  '2.3 MB',
                  Theme.of(context).primaryColor,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  Widget _buildStorageItem(String label, String size, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getUsageIcon(String feature) {
    switch (feature.toLowerCase()) {
      case 'reminder_created':
        return Icons.add_circle;
      case 'reminder_completed':
        return Icons.check_circle;
      case 'app_opened':
        return Icons.launch;
      case 'settings_opened':
        return Icons.settings;
      case 'search_used':
        return Icons.search;
      case 'export_used':
        return Icons.download;
      default:
        return Icons.analytics;
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.help, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Ayuda'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Cómo usar No Me Olvido?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildHelpItem(
                    '1.',
                    'Toca el botón + para crear un recordatorio',
                  ),
                  _buildHelpItem('2.', 'Selecciona fecha, hora y categoría'),
                  _buildHelpItem(
                    '3.',
                    'Configura prioridad y recurrencia si es necesario',
                  ),
                  _buildHelpItem('4.', 'Recibirás una notificación a tiempo'),
                  _buildHelpItem('5.', 'Marca como completado cuando termines'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Consejos útiles:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Usa prioridad alta solo para cosas muy importantes',
                        ),
                        const Text(
                          '• Los recordatorios recurrentes son ideales para medicamentos',
                        ),
                        const Text(
                          '• Puedes editar recordatorios tocándolos en la lista',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Para más ayuda, contacta: ${AppConstants.supportEmail}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  UIHelpers.showSnackBar(
                    context,
                    'Visitando centro de ayuda...',
                    backgroundColor: AppColors.info,
                  );
                },
                child: const Text('Más Ayuda'),
              ),
            ],
          ),
    );
  }

  Widget _buildHelpItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.feedback, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Enviar Comentarios'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nos encantaría conocer tu opinión para mejorar la app:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText:
                        'Escribe tus comentarios, sugerencias o reporta problemas...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.inputBorderRadius,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _storage.incrementUsageCounter('feedback_sent');
                    UIHelpers.showSnackBar(
                      context,
                      '¡Gracias por tus comentarios! Los hemos recibido.',
                      backgroundColor: AppColors.success,
                    );
                  }
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
    );
  }

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.star, color: AppColors.warning),
                const SizedBox(width: 8),
                const Text('Calificar App'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Te gusta No Me Olvido?'),
                const SizedBox(height: 16),
                const Text(
                  'Tu calificación nos ayuda a llegar a más personas que necesitan organizarse mejor.',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) =>
                        Icon(Icons.star, color: AppColors.warning, size: 32),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ahora no'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _storage.incrementUsageCounter('app_rated');
                  UIHelpers.showSnackBar(
                    context,
                    '¡Gracias! Te dirigiremos a la tienda de apps.',
                    backgroundColor: AppColors.success,
                  );
                },
                child: const Text('Calificar'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.privacy_tip, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Política de Privacidad'),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu privacidad es importante para nosotros.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('🔒 Almacenamiento local'),
                  Text(
                    'Todos tus datos se almacenan localmente en tu dispositivo. No enviamos información a servidores externos.',
                  ),
                  SizedBox(height: 12),
                  Text('🚫 Sin recopilación de datos'),
                  Text(
                    'No recopilamos, almacenamos ni compartimos información personal.',
                  ),
                  SizedBox(height: 12),
                  Text('📱 Permisos mínimos'),
                  Text(
                    'Solo solicitamos permisos esenciales para el funcionamiento de las notificaciones.',
                  ),
                  SizedBox(height: 12),
                  Text('🗑️ Control total'),
                  Text(
                    'Puedes eliminar todos tus datos en cualquier momento desde la configuración de la app.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Para más información detallada, visita nuestra política completa en: ${AppConstants.privacyPolicyUrl}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  UIHelpers.showSnackBar(
                    context,
                    'Abriendo política completa...',
                    backgroundColor: AppColors.info,
                  );
                },
                child: const Text('Ver Completa'),
              ),
            ],
          ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.article, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Términos de Servicio'),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Condiciones de uso de No Me Olvido',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('📋 Uso previsto'),
                  Text(
                    'Esta aplicación está diseñada para ayudarte a organizar y recordar tareas importantes de manera personal.',
                  ),
                  SizedBox(height: 12),
                  Text('✅ Uso aceptable'),
                  Text(
                    '• Uso personal y no comercial\n• Contenido legal y apropiado\n• Respeto a los términos de la plataforma',
                  ),
                  SizedBox(height: 12),
                  Text('❌ Uso prohibido'),
                  Text(
                    '• Actividades ilegales\n• Contenido ofensivo o dañino\n• Intentos de hackear o dañar la app',
                  ),
                  SizedBox(height: 12),
                  Text('🛡️ Limitaciones'),
                  Text(
                    'La app se proporciona "tal como está". No garantizamos disponibilidad continua o ausencia de errores.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Términos completos en: ${AppConstants.termsOfServiceUrl}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  void _reportBug(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String selectedBugType = 'crash';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.bug_report, color: AppColors.error),
                      const SizedBox(width: 8),
                      const Text('Reportar Problema'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Ayúdanos a mejorar reportando el problema:'),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedBugType,
                        decoration: InputDecoration(
                          labelText: 'Tipo de problema',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.inputBorderRadius,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'crash',
                            child: Text('La app se cierra'),
                          ),
                          DropdownMenuItem(
                            value: 'notification',
                            child: Text('Problemas con notificaciones'),
                          ),
                          DropdownMenuItem(
                            value: 'ui',
                            child: Text('Problema de interfaz'),
                          ),
                          DropdownMenuItem(
                            value: 'data',
                            child: Text('Pérdida de datos'),
                          ),
                          DropdownMenuItem(
                            value: 'performance',
                            child: Text('App lenta'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Otro problema'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedBugType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: InputDecoration(
                          hintText: 'Describe el problema en detalle...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.inputBorderRadius,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          _storage.incrementUsageCounter('bug_reported');
                          UIHelpers.showSnackBar(
                            context,
                            '🐛 Problema reportado. ¡Gracias por ayudarnos a mejorar!',
                            backgroundColor: AppColors.success,
                          );
                        }
                      },
                      child: const Text('Enviar Reporte'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _checkAndPromptVibration(BuildContext context) async {
    try {
      const platform = MethodChannel('com.nomeolvido/vibrator');
      // Intentar vibrar con un patrón corto
      await platform.invokeMethod('vibrate', {
        'pattern': [0, 200],
        'repeat': -1,
      });
      await Future.delayed(const Duration(milliseconds: 300));
      await platform.invokeMethod('cancel');
    } catch (e) {
      // Si falla, mostrar diálogo para abrir configuración
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Vibración del sistema desactivada'),
              content: const Text(
                'La vibración del sistema está desactivada. Para que la app pueda vibrar, debes activarla en los ajustes de tu teléfono.',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await const MethodChannel(
                        'com.nomeolvido/vibrator',
                      ).invokeMethod('openVibrationSettings');
                    } catch (_) {}
                  },
                  child: const Text('Abrir configuración'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
      );
    }
  }
}
