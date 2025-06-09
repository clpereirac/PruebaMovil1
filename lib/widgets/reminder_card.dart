import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../models/category.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(bool)? onCompletedToggle;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onDelete,
    this.onCompletedToggle,
  });

  @override
  Widget build(BuildContext context) {
    final category = ReminderCategory.getCategoryById(reminder.category);
    final isToday = _isToday(reminder.dateTime);
    final isPast = reminder.dateTime.isBefore(DateTime.now());
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM d');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicador de prioridad y estado
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      reminder.isCompleted
                          ? Colors.green
                          : _getPriorityColor(reminder.priority),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Icono de categoría
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 24),
              ),
              const SizedBox(width: 16),

              // Contenido del recordatorio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            reminder.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color: reminder.isCompleted ? Colors.grey[600] : null,
                      ),
                    ),
                    if (reminder.description != null &&
                        reminder.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        reminder.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: isPast ? Colors.red : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isToday
                              ? timeFormat.format(reminder.dateTime)
                              : '${dateFormat.format(reminder.dateTime)} • ${timeFormat.format(reminder.dateTime)}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: isPast ? Colors.red : Colors.grey[600],
                            fontWeight: isPast ? FontWeight.w600 : null,
                          ),
                        ),
                        if (reminder.isRecurring) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.repeat, size: 16, color: Colors.grey[500]),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Botón de completar
              if (!reminder.isCompleted && onCompletedToggle != null)
                IconButton(
                  onPressed: () => onCompletedToggle!(reminder.isCompleted),
                  icon: Icon(
                    reminder.isCompleted
                        ? Icons.check_circle_outline
                        : Icons.check_circle,
                    color: Colors.green[600],
                  ),
                  tooltip:
                      reminder.isCompleted
                          ? 'Marcar como incompleto'
                          : 'Marcar como completado',
                ),

              // Indicador de completado
              if (reminder.isCompleted)
                Icon(Icons.check_circle, color: Colors.green[600]),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
