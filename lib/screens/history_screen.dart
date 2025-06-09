import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../models/reminder_type.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Reminder> _historyReminders = [];
  bool _isLoading = true;
  ReminderType? _filterType;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print("Cargando historial");
      // Obtener todos los recordatorios
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      final allReminders = await provider.getAllReminders();

      print("Recordatorios totales: ${allReminders.length}");

      // Usar todos los recordatorios
      _historyReminders = allReminders;

      // Ordenar por fecha (desde hoy hacia el futuro, luego el pasado)
      // Ordenar por fecha (el día actual primero, luego orden cronológico)
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      _historyReminders.sort((a, b) {
        final dateA = DateTime(
          a.dateTime.year,
          a.dateTime.month,
          a.dateTime.day,
        );
        final dateB = DateTime(
          b.dateTime.year,
          b.dateTime.month,
          b.dateTime.day,
        );

        // Si A es hoy
        if (dateA.isAtSameMomentAs(today)) return -1;
        // Si B es hoy
        if (dateB.isAtSameMomentAs(today)) return 1;

        // Para el resto, orden cronológico
        return a.dateTime.compareTo(b.dateTime);
      });

      print("Recordatorios en historial: ${_historyReminders.length}");
    } catch (e) {
      print('Error al cargar el historial: $e');
      // Inicializar con lista vacía en caso de error
      _historyReminders = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Reminder> get _filteredReminders {
    if (_filterType == null) {
      return _historyReminders;
    }
    return _historyReminders
        .where((reminder) => reminder.type == _filterType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Recordatorios'),
        actions: [
          // Botón para filtrar
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredReminders.isEmpty
              ? _buildEmptyState()
              : _buildReminderList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _filterType == null
                ? 'No hay recordatorios pasados'
                : 'No hay recordatorios pasados de este tipo',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList() {
    // Agrupar por fecha
    final remindersByDate = <DateTime, List<Reminder>>{};
    for (final reminder in _filteredReminders) {
      final date = DateTime(
        reminder.dateTime.year,
        reminder.dateTime.month,
        reminder.dateTime.day,
      );
      if (!remindersByDate.containsKey(date)) {
        remindersByDate[date] = [];
      }
      remindersByDate[date]!.add(reminder);
    }

    // Obtener la fecha actual
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Ordenar las fechas (día actual primero, luego orden cronológico)
    final dates =
        remindersByDate.keys.toList()..sort((a, b) {
          // Si a es hoy
          if (a.isAtSameMomentAs(today)) return -1;
          // Si b es hoy
          if (b.isAtSameMomentAs(today)) return 1;
          // Orden cronológico para el resto
          return a.compareTo(b);
        });

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final reminders = remindersByDate[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de fecha
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy', 'es').format(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Recordatorios de ese día
            ...reminders.map(
              (reminder) => ReminderCard(
                reminder: reminder,
                onTap: () => _showReminderDetails(reminder),
                onDelete: () => _showDeleteConfirmation(context, reminder.id!),
                onCompletedToggle: (value) {
                  Provider.of<ReminderProvider>(
                    context,
                    listen: false,
                  ).toggleReminderCompleted(reminder.id!, value);
                  setState(() {}); // Actualizar la UI
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Filtrar por tipo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                _buildFilterOption('Todos', null),
                _buildFilterOption('Salud', ReminderType.salud),
                _buildFilterOption('Mercado', ReminderType.mercado),
                _buildFilterOption('Bono', ReminderType.bono),
                _buildFilterOption('Evento', ReminderType.evento),
                _buildFilterOption('Otro', ReminderType.otro),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, ReminderType? type) {
    final reminder =
        type != null
            ? Reminder(
              title: '',
              dateTime: DateTime.now(),
              type: type,
              category: 'personal',
              createdAt: DateTime.now(),
            )
            : null;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            reminder?.typeColor.withOpacity(0.2) ?? Colors.grey[300],
        child: Icon(
          reminder?.typeIcon ?? Icons.filter_list,
          color: reminder?.typeColor ?? Colors.grey[600],
        ),
      ),
      title: Text(label),
      trailing:
          _filterType == type
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
      onTap: () {
        setState(() {
          _filterType = type;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showReminderDetails(Reminder reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: reminder.typeColor.withOpacity(0.2),
                    radius: 24,
                    child: Icon(
                      reminder.typeIcon,
                      color: reminder.typeColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Detalles
              if (reminder.description?.isNotEmpty ?? false) ...[
                const Text(
                  'Descripción:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  reminder.description ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
              ],

              // Fecha y hora
              const Text(
                'Fecha y hora:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat(
                  'EEEE, d MMMM yyyy - HH:mm',
                  'es',
                ).format(reminder.dateTime),
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 16),

              // Tipo
              const Text(
                'Tipo:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(reminder.typeIcon, color: reminder.typeColor),
                  const SizedBox(width: 8),
                  Text(
                    _getTypeText(reminder.type),
                    style: TextStyle(
                      fontSize: 16,
                      color: reminder.typeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Estado
              Row(
                children: [
                  const Text(
                    'Estado:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          reminder.isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      reminder.isCompleted ? 'Completado' : 'Pendiente',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            reminder.isCompleted ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar recordatorio'),
            content: const Text(
              '¿Está seguro que desea eliminar este recordatorio del historial?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      await provider.deleteReminder(id);

      // Recargar el historial
      _loadHistory();
    }
  }

  String _getTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.salud:
        return 'Salud';
      case ReminderType.mercado:
        return 'Mercado';
      case ReminderType.bono:
        return 'Bono';
      case ReminderType.evento:
        return 'Evento';
      case ReminderType.otro:
        return 'Otro';
    }
  }
}
