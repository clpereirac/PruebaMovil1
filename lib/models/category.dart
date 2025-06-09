import 'package:flutter/material.dart';

class ReminderCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ReminderCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<ReminderCategory> defaultCategories = [
    ReminderCategory(
      id: 'health',
      name: 'Salud',
      icon: Icons.local_hospital,
      color: Color(0xFFEF4444),
    ),
    ReminderCategory(
      id: 'finance',
      name: 'Finanzas',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF10B981),
    ),
    ReminderCategory(
      id: 'family',
      name: 'Familia',
      icon: Icons.family_restroom,
      color: Color(0xFFF59E0B),
    ),
    ReminderCategory(
      id: 'community',
      name: 'Comunidad',
      icon: Icons.people,
      color: Color(0xFF8B5CF6),
    ),
    ReminderCategory(
      id: 'work',
      name: 'Trabajo',
      icon: Icons.work,
      color: Color(0xFF3B82F6),
    ),
    ReminderCategory(
      id: 'personal',
      name: 'Personal',
      icon: Icons.person,
      color: Color(0xFF6B7280),
    ),
  ];

  static ReminderCategory getCategoryById(String id) {
    return defaultCategories.firstWhere(
      (category) => category.id == id,
      orElse: () => defaultCategories.last,
    );
  }
}
