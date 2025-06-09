import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../models/category.dart';
import '../models/reminder_type.dart';
import '../providers/reminder_provider.dart';
import '../widgets/category_chip.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'personal';
  ReminderType _selectedType = ReminderType.otro;
  int _priority = 2;
  bool _isRecurring = false;
  String? _recurringType;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeWithReminder();
    } else {
      // Para nuevo recordatorio, establecer fecha y hora mínima en 1 hora
      final now = DateTime.now().add(const Duration(hours: 1));
      _selectedDate = now;
      _selectedTime = TimeOfDay.fromDateTime(now);
    }
  }

  void _initializeWithReminder() {
    final reminder = widget.reminder!;
    _titleController.text = reminder.title;
    _descriptionController.text = reminder.description ?? '';
    _selectedDate = reminder.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(reminder.dateTime);
    _selectedCategory = reminder.category;
    _selectedType = reminder.type;
    _priority = reminder.priority;
    _isRecurring = reminder.isRecurring;
    _recurringType = reminder.recurringType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Recordatorio' : 'Nuevo Recordatorio'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReminder,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ej: Visita al médico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Agrega más detalles...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Categorías
            Text(
              'Categoría',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  ReminderCategory.defaultCategories.map((category) {
                    return CategoryChip(
                      category: category,
                      isSelected: _selectedCategory == category.id,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category.id;
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // Tipo de recordatorio
            Text(
              'Tipo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  ReminderType.values.map((type) {
                    return ChoiceChip(
                      label: Text(_getTypeText(type)),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedType = type;
                          });
                        }
                      },
                      avatar: Icon(
                        type.typeIcon,
                        color:
                            _selectedType == type
                                ? Colors.white
                                : type.typeColor,
                        size: 18,
                      ),
                      backgroundColor: type.typeColor.withOpacity(0.1),
                      selectedColor: type.typeColor,
                      labelStyle: TextStyle(
                        color:
                            _selectedType == type
                                ? Colors.white
                                : type.typeColor,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // Fecha y hora
            Text(
              'Fecha y hora',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Prioridad
            Text(
              'Prioridad',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PriorityOption(
                    label: 'Baja',
                    color: Colors.blue,
                    value: 1,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PriorityOption(
                    label: 'Media',
                    color: Colors.orange,
                    value: 2,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PriorityOption(
                    label: 'Alta',
                    color: Colors.red,
                    value: 3,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recordatorio recurrente
            SwitchListTile(
              title: const Text('Recordatorio recurrente'),
              subtitle: const Text('Se repetirá automáticamente'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                  if (!value) _recurringType = null;
                });
              },
            ),

            if (_isRecurring) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Frecuencia',
                  border: OutlineInputBorder(),
                ),
                value: _recurringType,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Diario')),
                  DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                  DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                  DropdownMenuItem(value: 'yearly', child: Text('Anual')),
                ],
                onChanged: (value) {
                  setState(() {
                    _recurringType = value;
                  });
                },
                validator: (value) {
                  if (_isRecurring && value == null) {
                    return 'Selecciona la frecuencia';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            // Botón guardar
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isEditing ? 'Actualizar Recordatorio' : 'Crear Recordatorio',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveReminder() {
    if (!_formKey.currentState!.validate()) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Validar que la fecha no sea en el pasado
    if (dateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha y hora no puede ser en el pasado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final reminder = Reminder(
      id: _isEditing ? widget.reminder!.id : null,
      title: _titleController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      dateTime: dateTime,
      category: _selectedCategory,
      type: _selectedType,
      priority: _priority,
      isRecurring: _isRecurring,
      recurringType: _recurringType,
      createdAt: _isEditing ? widget.reminder!.createdAt : DateTime.now(),
    );

    final reminderProvider = context.read<ReminderProvider>();

    if (_isEditing) {
      reminderProvider.updateReminder(reminder);
    } else {
      reminderProvider.addReminder(reminder);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'Recordatorio actualizado' : 'Recordatorio creado',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteReminder() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar recordatorio'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este recordatorio?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ReminderProvider>().deleteReminder(
                    widget.reminder!.id!,
                  );
                  Navigator.pop(context); // Cerrar diálogo
                  Navigator.pop(context); // Cerrar pantalla
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recordatorio eliminado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

class _PriorityOption extends StatelessWidget {
  final String label;
  final Color color;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  const _PriorityOption({
    required this.label,
    required this.color,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: isSelected ? 0 : 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
