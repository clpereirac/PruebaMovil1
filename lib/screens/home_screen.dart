import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';
import '../widgets/floating_add_button.dart';
import '../models/reminder.dart';
import 'add_reminder_screen.dart';
import 'calendar_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No Me Olvido',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, d MMMM', 'es_ES').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Probar notificaciones'),
                          onTap: () async {
                            Navigator.pop(context);
                            final notificationService = NotificationService();
                            await notificationService
                                .scheduleTestNotification();

                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Row(
                                        children: [
                                          Icon(
                                            Icons.science,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 8),
                                          Text('¡Prueba Programada!'),
                                        ],
                                      ),
                                      content: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '🧪 Notificación programada para 10 segundos',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            '📱 Para comprobar que funciona:',
                                          ),
                                          SizedBox(height: 8),
                                          Text('1. Presiona "OK"'),
                                          Text(
                                            '2. Sal de la app o ponla en segundo plano',
                                          ),
                                          Text('3. Espera 10 segundos'),
                                          Text(
                                            '4. ¡Deberías recibir la notificación!',
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            '✨ Si la recibes, las notificaciones funcionan perfectamente',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('Estado del sistema'),
                          onTap: () async {
                            Navigator.pop(context);
                            final notificationService = NotificationService();
                            await notificationService.debugPrintStatus();

                            final enabled =
                                await notificationService
                                    .areNotificationsEnabled();
                            final pending =
                                await notificationService
                                    .getPendingNotifications();

                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Estado del Sistema'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildStatusRow(
                                            'Notificaciones:',
                                            enabled
                                                ? '✅ Habilitadas'
                                                : '❌ Deshabilitadas',
                                          ),
                                          _buildStatusRow(
                                            'Sistema:',
                                            '✅ Inicializado',
                                          ),
                                          _buildStatusRow(
                                            'Recordatorios activos:',
                                            '${pending.length}',
                                          ),
                                          _buildStatusRow(
                                            'Persistencia:',
                                            '✅ SharedPreferences',
                                          ),
                                          const SizedBox(height: 12),
                                          if (!enabled)
                                            const Text(
                                              '⚠️ Habilita los permisos de notificación en Configuración > Apps > No Me Olvido > Notificaciones',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingReminders = reminderProvider.upcomingReminders;
          final todayReminders = reminderProvider.todayReminders;

          return CustomScrollView(
            slivers: [
              // Resumen del día
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoy tienes',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${todayReminders.length} recordatorios',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            upcomingReminders.isNotEmpty
                                ? 'Próximo: ${DateFormat('HH:mm').format(upcomingReminders.first.dateTime)}'
                                : 'No hay recordatorios pendientes',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Recordatorios de hoy
              if (todayReminders.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Hoy',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

              if (todayReminders.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final reminder = todayReminders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ReminderCard(
                        reminder: reminder,
                        onTap: () => _editReminder(reminder),
                        onCompletedToggle:
                            (value) => _completeReminder(reminder),
                      ),
                    );
                  }, childCount: todayReminders.length),
                ),

              // Próximos recordatorios
              if (upcomingReminders.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Próximos',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

              if (upcomingReminders.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final reminder = upcomingReminders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ReminderCard(
                        reminder: reminder,
                        onTap: () => _editReminder(reminder),
                        onCompletedToggle:
                            (value) => _completeReminder(reminder),
                      ),
                    );
                  }, childCount: upcomingReminders.length),
                ),

              // Estado vacío
              if (upcomingReminders.isEmpty && todayReminders.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          '¡No tienes recordatorios!',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca el botón + para agregar tu primer recordatorio',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _addReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReminderScreen()),
    );
  }

  void _editReminder(Reminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderScreen(reminder: reminder),
      ),
    );
  }

  void _completeReminder(Reminder reminder) {
    context.read<ReminderProvider>().markAsCompleted(reminder.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reminder.title} completado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            // Implementar deshacer
          },
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
