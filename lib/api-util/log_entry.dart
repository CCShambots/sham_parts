import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class Contribution {
  final String author;
  int quantity;

  Contribution({required this.author, required this.quantity});
}

class LogEntry {
  final int id;
  late final String type;
  DateTime date;
  late String readableDate;
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

  static List<Contribution> generateContributionList(List<LogEntry> entries, String type) {

    DateTime startTime = DateTime.now().subtract(const Duration(days: 7)).toUtc();
    DateTime endTime = DateTime.now().toUtc();

    var filteredEntries = filterLogEntriesByType(entries, type);
    var filteredByDate = filterLogEntriesByTime(filteredEntries, startTime, endTime);

    List<Contribution> contributions = [];
    for (var entry in filteredByDate) {
      if(contributions.where((e) {return e.author == entry.author;}).isEmpty) {
        contributions.add(Contribution(author: entry.author, quantity: entry.quantity));
      } else {
        contributions.firstWhere((e) {return e.author == entry.author;}).quantity += entry.quantity;
      }
    }

    contributions.sort((a, b) => b.quantity.compareTo(a.quantity));

    return contributions;
  } 


  static List<FlSpot> generateSpots(List<LogEntry> entries, String type) {
    DateTime startTime = DateTime.now().subtract(const Duration(days: 7)).toUtc();
    DateTime endTime = DateTime.now().toUtc();

    var filteredEntries = filterLogEntriesByType(entries, type);
    var filterByDate = filterLogEntriesByTime(filteredEntries, startTime, endTime);
    var separatedLogs = separateLogsByDay(filterByDate);
    var concatenatedLogs = separatedLogs.map((day) => concatenateLogEntries(day)).toList();

    //Make sure there is a datapoint for each day
    var filledOutLogs = fillOutLogs(concatenatedLogs,  startTime, endTime);

    return filledOutLogs.map((entry) => entry.getSpot(endTime)).toList();
  }

  void adjustDay(DateTime newDate) {
    date = newDate;
    DateFormat formatter = DateFormat('MM-dd-yy');
    readableDate = formatter.format(date.toLocal());
  }

  static List<LogEntry> fillOutLogs(List<LogEntry> entries, DateTime startDate, DateTime endTime) {
    //Make sure there is a log entry for each day
    List<LogEntry> filledOutLogs = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endTime) || currentDate.isAtSameMomentAs(endTime)) {
      bool found = false;
      for (var entry in entries) {
        if (entry.date.day == currentDate.day &&
            entry.date.month == currentDate.month &&
            entry.date.year == currentDate.year) {
          entry.adjustDay(currentDate);
          filledOutLogs.add(entry);
          found = true;
          break;
        }
      }
      if (!found) {
        filledOutLogs.add(LogEntry(
          id: -1,
          type: "None",
          author: "system",
          date: currentDate,
          quantity: 0,
          message: "",
        ));
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return filledOutLogs;
  }

  static List<LogEntry> filterLogEntriesByTime(
      List<LogEntry> entries, DateTime start, DateTime end) {
    return entries
        .where((entry) => entry.date.isAfter(start) && entry.date.isBefore(end))
        .toList();
  }

  static List<LogEntry> filterLogEntriesByType(
      List<LogEntry> entries, String type) {
    return entries.where((entry) => entry.type == type).toList();
  }

  static List<List<LogEntry>> separateLogsByDay(List<LogEntry> logEntries) {

    List<List<LogEntry>> separatedLogs = [];

    for (var entry in logEntries) {
      bool found = false;
      for (var day in separatedLogs) {
        if (day[0].date.day == entry.date.day &&
            day[0].date.month == entry.date.month &&
            day[0].date.year == entry.date.year) {
          day.add(entry);
          found = true;
          break;
        }
      }

      if (!found) {
        separatedLogs.add([entry]);
      }
    }

    return separatedLogs;
  }


  static LogEntry concatenateLogEntries(List<LogEntry> entries) {
    String message = "";
    int quantity = 0;
    for (var entry in entries) {
      message += "${entry.message} ";
      quantity += entry.quantity;
    }

    return LogEntry(
        id: -1,
        type: "Concatenated",
        author: "system",
        date: entries[0].date,
        quantity: quantity,
        message: message,
    );
  }

  FlSpot getSpot(DateTime startDate) {
    return FlSpot(
        date.difference(startDate).inDays.toDouble(), quantity.toDouble());
  }
}

class LogEntryWidget extends StatelessWidget {
  final LogEntry logEntry;

  const LogEntryWidget({super.key, required this.logEntry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(logEntry.type, style: StyleConstants.h3Style),
          Text(logEntry.readableDate, style: StyleConstants.h3Style),
          IconButton(onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Log Entry Details'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ID: ${logEntry.id}'),
                      Text('Type: ${logEntry.type}'),
                      Text('Date: ${logEntry.readableDate}'),
                      Text('Quantity: ${logEntry.quantity}'),
                      Text('Message: ${logEntry.message}'),
                      Text('Author: ${logEntry.author}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          }, icon: const Icon(Icons.info))
        ],
      ),
    );
  }
}
