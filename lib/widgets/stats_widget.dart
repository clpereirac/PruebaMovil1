import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, child) {
        final stats = provider.getDetailedStatistics();

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Resumen',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (stats['completionRate'] > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCompletionColor(
                            stats['completionRate'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stats['completionRate']}% completado',
                          style: TextStyle(
                            color: _getCompletionColor(stats['completionRate']),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Grid de estadísticas principales
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.list_alt,
                        label: 'Total',
                        value: stats['total'].toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.schedule,
                        label: 'Pendientes',
                        value: stats['pending'].toString(),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        label: 'Completados',
                        value: stats['completed'].toString(),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                if (stats['overdue'] > 0 || stats['today'] > 0) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (stats['today'] > 0)
                        Expanded(
                          child: _AlertCard(
                            icon: Icons.today,
                            label: 'Hoy',
                            value: stats['today'].toString(),
                            color: Colors.blue,
                          ),
                        ),
                      if (stats['today'] > 0 && stats['overdue'] > 0)
                        const SizedBox(width: 12),
                      if (stats['overdue'] > 0)
                        Expanded(
                          child: _AlertCard(
                            icon: Icons.warning,
                            label: 'Atrasados',
                            value: stats['overdue'].toString(),
                            color: Colors.red,
                            isUrgent: true,
                          ),
                        ),
                    ],
                  ),
                ],

                // Botones de acción rápida
                if (stats['total'] > 0) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => provider.setFilter('pending'),
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: const Text('Ver Pendientes'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDetailedStats(context, stats),
                          icon: const Icon(Icons.insights, size: 18),
                          label: const Text('Más Detalles'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCompletionColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showDetailedStats(BuildContext context, Map<String, dynamic> stats) {
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
                      'Estadísticas Detalladas',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Estadísticas por categoría
                          _DetailSection(
                            title: 'Por Categoría',
                            icon: Icons.category,
                            children:
                                (stats['categoryStats'] as Map<String, int>)
                                    .entries
                                    .map(
                                      (entry) => _DetailItem(
                                        label: _getCategoryName(entry.key),
                                        value: entry.value.toString(),
                                        color: _getCategoryColor(entry.key),
                                      ),
                                    )
                                    .toList(),
                          ),

                          const SizedBox(height: 20),

                          // Estadísticas por prioridad
                          _DetailSection(
                            title: 'Por Prioridad',
                            icon: Icons.priority_high,
                            children:
                                (stats['priorityStats'] as Map<int, int>)
                                    .entries
                                    .map(
                                      (entry) => _DetailItem(
                                        label: _getPriorityName(entry.key),
                                        value: entry.value.toString(),
                                        color: _getPriorityColor(entry.key),
                                      ),
                                    )
                                    .toList(),
                          ),

                          const SizedBox(height: 20),

                          // Información adicional
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _InfoRow(
                                    'Esta semana',
                                    '${stats['thisWeek']} recordatorios',
                                  ),
                                  _InfoRow(
                                    'Recurrentes activos',
                                    '${stats['recurringCount']} recordatorios',
                                  ),
                                  _InfoRow(
                                    'Tasa de cumplimiento',
                                    '${stats['completionRate']}%',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  String _getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'health':
        return 'Salud';
      case 'finance':
        return 'Finanzas';
      case 'family':
        return 'Familia';
      case 'community':
        return 'Comunidad';
      case 'work':
        return 'Trabajo';
      case 'personal':
        return 'Personal';
      default:
        return categoryId;
    }
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'health':
        return const Color(0xFFEF4444);
      case 'finance':
        return const Color(0xFF10B981);
      case 'family':
        return const Color(0xFFF59E0B);
      case 'community':
        return const Color(0xFF8B5CF6);
      case 'work':
        return const Color(0xFF3B82F6);
      case 'personal':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  String _getPriorityName(int priority) {
    switch (priority) {
      case 1:
        return 'Baja';
      case 2:
        return 'Media';
      case 3:
        return 'Alta';
      default:
        return 'Desconocida';
    }
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isUrgent;

  const _AlertCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(isUrgent ? 0.5 : 0.2),
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
