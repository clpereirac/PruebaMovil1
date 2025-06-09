import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../widgets/custom_button.dart';
import '../models/reminder.dart';
import '../models/reminder_type.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de apariencia
          _buildSectionHeader(context, 'Apariencia'),

          // Modo oscuro / claro
          _buildSettingCard(
            context,
            icon: Icons.brightness_4,
            title: 'Tema de la aplicación',
            subtitle: themeProvider.isDarkMode ? 'Modo oscuro' : 'Modo claro',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),

          // Tamaño del texto
          _buildSettingCard(
            context,
            icon: Icons.text_fields,
            title: 'Tamaño del texto',
            subtitle: 'Ajustar el tamaño del texto en la aplicación',
            onTap: () => _showTextSizeDialog(context, themeProvider),
          ),

          const SizedBox(height: 16),

          // Sección de notificaciones
          _buildSectionHeader(context, 'Notificaciones'),

          // Sonido de notificación
          _buildSettingCard(
            context,
            icon: Icons.notifications_active,
            title: 'Sonido de notificación',
            subtitle: 'Activar sonido para las notificaciones',
            trailing: Switch(
              value: themeProvider.notificationsEnabled,
              onChanged: (value) async {
                if (value) {
                  final hasPermission =
                      await _notificationService.requestPermissions();
                  if (!hasPermission) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Es necesario conceder permisos de notificación en la configuración del sistema',
                          ),
                          duration: Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Configuración',
                            onPressed: openAppSettings,
                          ),
                        ),
                      );
                    }
                    return;
                  }
                }
                themeProvider.toggleNotifications();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),

          // Vibración
          _buildSettingCard(
            context,
            icon: Icons.vibration,
            title: 'Vibración',
            subtitle: 'Activar vibración para las notificaciones',
            trailing: Switch(
              value: themeProvider.vibrationEnabled,
              onChanged: (value) async {
                if (value) {
                  final hasPermission =
                      await _notificationService.requestPermissions();
                  if (!hasPermission) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Es necesario conceder permisos de notificación en la configuración del sistema',
                          ),
                          duration: Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Configuración',
                            onPressed: openAppSettings,
                          ),
                        ),
                      );
                    }
                    return;
                  }
                }
                themeProvider.toggleVibration();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Botón de prueba de notificaciones
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final hasPermission =
                          await _notificationService.requestPermissions();
                      if (hasPermission) {
                        // Programar una notificación de prueba para 10 segundos después
                        final testReminder = Reminder(
                          title: 'Notificación de prueba',
                          description:
                              'Esta es una notificación de prueba para verificar que todo funciona correctamente',
                          dateTime: DateTime.now().add(
                            const Duration(seconds: 10),
                          ),
                          category: 'personal',
                          type: ReminderType.otro,
                          createdAt: DateTime.now(),
                        );
                        await _notificationService.scheduleReminder(
                          testReminder,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notificación de prueba programada para 10 segundos después',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Es necesario conceder permisos de notificación en la configuración del sistema',
                              ),
                              duration: Duration(seconds: 5),
                              action: SnackBarAction(
                                label: 'Configuración',
                                onPressed: openAppSettings,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Probar notificación'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Si las notificaciones no funcionan, asegúrate de:\n'
                    '1. Conceder todos los permisos necesarios\n'
                    '2. Desactivar la optimización de batería para esta app\n'
                    '3. Permitir que la app se ejecute en segundo plano\n'
                    '4. Activar el inicio automático de la app',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección de accesibilidad
          _buildSectionHeader(context, 'Accesibilidad'),

          // Lectura por voz
          _buildSettingCard(
            context,
            icon: Icons.record_voice_over,
            title: 'Lectura de recordatorios',
            subtitle: 'Leer recordatorios en voz alta',
            trailing: Switch(
              value: themeProvider.textToSpeechEnabled,
              onChanged: (value) {
                themeProvider.toggleTextToSpeech();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),

          // Alto contraste
          _buildSettingCard(
            context,
            icon: Icons.contrast,
            title: 'Alto contraste',
            subtitle: 'Mejora la visibilidad de los elementos',
            trailing: Switch(
              value: themeProvider.highContrastEnabled,
              onChanged: (value) {
                themeProvider.toggleHighContrast();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Sección de datos
          _buildSectionHeader(context, 'Datos'),

          // Respaldo en la nube
          _buildSettingCard(
            context,
            icon: Icons.cloud_upload,
            title: 'Respaldo en la nube',
            subtitle: 'Sincronizar recordatorios en la nube',
            trailing: Switch(
              value: themeProvider.cloudBackupEnabled,
              onChanged: (value) {
                themeProvider.toggleCloudBackup();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ),

          // Contactos de emergencia
          _buildSettingCard(
            context,
            icon: Icons.contact_phone,
            title: 'Contactos de apoyo',
            subtitle: 'Añadir familiares o cuidadores',
            onTap: () {
              // Implementar pantalla de contactos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función disponible en próximas versiones'),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Botones de acción
          Center(
            child: CustomButton(
              text: 'Restablecer configuración',
              icon: Icons.restore,
              isOutlined: true,
              onPressed: () => _showResetConfirmation(context, themeProvider),
            ),
          ),

          const SizedBox(height: 16),

          // Versión
          Center(
            child: Text(
              'Versión: 1.0.0',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showTextSizeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tamaño del texto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextSizeOption(
                  context,
                  'Pequeño',
                  TextSize.small,
                  themeProvider,
                ),
                _buildTextSizeOption(
                  context,
                  'Normal',
                  TextSize.medium,
                  themeProvider,
                ),
                _buildTextSizeOption(
                  context,
                  'Grande',
                  TextSize.large,
                  themeProvider,
                ),
                _buildTextSizeOption(
                  context,
                  'Extra grande',
                  TextSize.extraLarge,
                  themeProvider,
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

  Widget _buildTextSizeOption(
    BuildContext context,
    String label,
    TextSize size,
    ThemeProvider themeProvider,
  ) {
    return RadioListTile<TextSize>(
      title: Text(
        label,
        style: TextStyle(
          fontSize:
              size == TextSize.small
                  ? 14
                  : size == TextSize.medium
                  ? 16
                  : size == TextSize.large
                  ? 18
                  : 20,
        ),
      ),
      value: size,
      groupValue: themeProvider.textSize,
      onChanged: (value) {
        if (value != null) {
          themeProvider.setTextSize(value);
          Navigator.pop(context);
        }
      },
      activeColor: Theme.of(context).primaryColor,
    );
  }

  Future<void> _showResetConfirmation(
    BuildContext context,
    ThemeProvider themeProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Restablecer configuración'),
            content: const Text(
              '¿Está seguro que desea restablecer todas las configuraciones a sus valores predeterminados?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restablecer'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      themeProvider.resetSettings();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La configuración ha sido restablecida')),
      );
    }
  }
}
