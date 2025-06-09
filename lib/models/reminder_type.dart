import 'package:flutter/material.dart';

enum ReminderType {
  salud,
  mercado,
  bono,
  evento,
  otro;

  Color get typeColor {
    switch (this) {
      case ReminderType.salud:
        return const Color(0xFFEF4444);
      case ReminderType.mercado:
        return const Color(0xFF10B981);
      case ReminderType.bono:
        return const Color(0xFFF59E0B);
      case ReminderType.evento:
        return const Color(0xFF8B5CF6);
      case ReminderType.otro:
        return const Color(0xFF6B7280);
    }
  }

  IconData get typeIcon {
    switch (this) {
      case ReminderType.salud:
        return Icons.local_hospital;
      case ReminderType.mercado:
        return Icons.shopping_cart;
      case ReminderType.bono:
        return Icons.account_balance_wallet;
      case ReminderType.evento:
        return Icons.event;
      case ReminderType.otro:
        return Icons.more_horiz;
    }
  }
}
