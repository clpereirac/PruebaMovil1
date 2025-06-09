import 'package:flutter/material.dart';
import 'reminder_type.dart';

class Reminder {
  final int? id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String category;
  final ReminderType type;
  final bool isCompleted;
  final bool isRecurring;
  final String? recurringType; // 'daily', 'weekly', 'monthly', 'yearly'
  final int priority; // 1=low, 2=medium, 3=high
  final DateTime createdAt;
  final DateTime? completedAt;

  Reminder({
    this.id,
    required this.title,
    this.description,
    required this.dateTime,
    required this.category,
    required this.type,
    this.isCompleted = false,
    this.isRecurring = false,
    this.recurringType,
    this.priority = 2,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'category': category,
      'type': type.name,
      'isCompleted': isCompleted ? 1 : 0,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringType': recurringType,
      'priority': priority,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      category: map['category'],
      type: ReminderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReminderType.otro,
      ),
      isCompleted: map['isCompleted'] == 1,
      isRecurring: map['isRecurring'] == 1,
      recurringType: map['recurringType'],
      priority: map['priority'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      completedAt:
          map['completedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
              : null,
    );
  }

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? category,
    ReminderType? type,
    bool? isCompleted,
    bool? isRecurring,
    String? recurringType,
    int? priority,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Color get typeColor => type.typeColor;
  IconData get typeIcon => type.typeIcon;
}
