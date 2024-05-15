
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class LogEntry {
  final int id;
  late final String type;
  final DateTime date;
  late final String readableDate;
  final int quantity;
  final String message;
  final String author;

  LogEntry({
    required this.id,
    type,
    required this.date,
    required this.quantity,
    required this.message,
    required this.author,
  }) {
    DateFormat formatter = DateFormat('MM-dd-yy');
    readableDate = formatter.format(date.toLocal());

    this.type = type.substring(0, 1).toUpperCase() + type.substring(1);
  }

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
    return Container(
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(logEntry.type, style: StyleConstants.h3Style),
          Text("QTY:${logEntry.quantity.toString()}", style: StyleConstants.h3Style),
          Text(logEntry.message, style: StyleConstants.h3Style),
          Text(logEntry.readableDate, style: StyleConstants.h3Style),
          Text(logEntry.author, style: StyleConstants.h3Style),
        ],
      ),
    );
  }
}