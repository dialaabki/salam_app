import 'package:flutter/material.dart';

enum ReminderType { medicine, activity }

class Reminder {
  final String id; // Unique ID for keys and removal
  final ReminderType type;
  final String name;
  final TimeOfDay time;
  final DateTime startDate;
  final DateTime endDate;
  final Set<int> selectedDays; // 1=Mon, 2=Tue, ..., 7=Sun
  final int? amount; // Nullable for activities
  final String? iconAsset; // Optional icon for display
  bool isCompleted;

  Reminder({
    required this.id,
    required this.type,
    required this.name,
    required this.time,
    required this.startDate,
    required this.endDate,
    required this.selectedDays,
    this.amount,
    this.iconAsset, // Assign appropriate icons based on type/name later
    this.isCompleted = false,
  });
}