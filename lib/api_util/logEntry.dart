
import 'package:flutter/material.dart';

class LogEntry {
  final int id;
  final String type;
  final DateTime date;
  final int quantity;
  final String message;
  final String author;

  LogEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.quantity,
    required this.message,
    required this.author,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity'],
      message: json['message'],
      author: json['author'],
    );
  }
}

class LogEntryWidget extends StatelessWidget {
  final LogEntry logEntry;

  const LogEntryWidget({required this.logEntry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(logEntry.type),
      subtitle: Text(logEntry.message),
      trailing: Text(logEntry.date.toString()),
    );
  }
}