import 'package:flutter/material.dart';

class CircleDay extends StatelessWidget {
  final String day;
  final bool isSelected;
  final bool hasReminders;
  final Color? reminderColor;
  final VoidCallback onTap;

  const CircleDay({
    Key? key,
    required this.day,
    required this.isSelected,
    this.hasReminders = false,
    this.reminderColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? theme.primaryColor
              : hasReminders
                  ? reminderColor?.withOpacity(0.2) ??
                      theme.primaryColor.withOpacity(0.2)
                  : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : hasReminders
                    ? reminderColor ?? theme.primaryColor
                    : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected || hasReminders
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : hasReminders
                          ? reminderColor ?? theme.primaryColor
                          : theme.textTheme.bodyMedium?.color,
                ),
              ),
              if (hasReminders && !isSelected)
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: reminderColor ?? theme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
