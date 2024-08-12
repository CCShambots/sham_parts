import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/log_entry.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/compound-widgets/assigned_compound_display.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/part-widgets/assigned_part_display.dart';
import 'package:sham_parts/util/indicator.dart';

class Home extends StatefulWidget {
  final User user;
  final Project project;

  const Home({super.key, required this.user, required this.project});

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  int touchedIndexGraph1 = -1;
  int touchedIndexGraph2 = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    bool oneRowGraph = MediaQuery.of(context).size.width > 650;

    var contributions = LogEntry.generateContributionList(
        widget.project.getLogEntries(), "Fulfill");

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.project.name,
              style: !isMobile
                  ? StyleConstants.titleStyle
                  : StyleConstants.subtitleStyle,
              textAlign: TextAlign.center,
            ),
            oneRowGraph
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      pieChart(),
                      lineGraph(),
                      topProducers(contributions),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      pieChart(),
                      lineGraph(),
                      topProducers(contributions)
                    ],
                  ),
            !isMobile
                ? SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(flex: 1, child: assignedParts(isMobile)),
                        Flexible(flex: 1, child: assignedCompounds(isMobile))
                      ],
                    ),
                  )
                : Column(
                    children: [
                      assignedParts(isMobile),
                      assignedCompounds(isMobile)
                    ],
                  )
          ],
        ),
      ),
    );
  }

  Flexible topProducers(List<Contribution> contributions) {
    return Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Text("Top Producers This Week",
                                style: StyleConstants.subtitleStyle),
                          ),
                          ...contributions.map((e) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                          "${contributions.indexOf(e) + 1}. ${e.author}",
                                          style: StyleConstants.h3Style),
                                      Text(
                                        "${e.quantity.toString()} parts",
                                        style: StyleConstants.h3Style,
                                      )
                                    ]),
                                    const Divider(height: 20,)
                              ]),
                            );
                          })
                        ],
                      ),
                    );
  }

  Widget assignedCompounds(bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "Assigned Compounds",
          style: !isMobile
              ? StyleConstants.titleStyle
              : StyleConstants.subtitleStyle,
          textAlign: TextAlign.center,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.project.compounds
              .where((e) {
                return e.asigneeId == widget.user.id;
              })
              .map((e) => AssignedCompoundDisplay(
                    compound: e,
                    project: widget.project,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget assignedParts(bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "Assigned Parts",
          style: !isMobile
              ? StyleConstants.titleStyle
              : StyleConstants.subtitleStyle,
          textAlign: TextAlign.center,
        ),
        ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.min,
          children: widget.project.parts
              .where((e) {
                return e.quantityRequested > 0 &&
                    e.asigneeId == widget.user.id &&
                    e.asigneeName == widget.user.name;
              })
              .map((e) => AssignedPartDisplay(part: e))
              .toList(),
        ),
      ],
    );
  }

  Widget lineGraph() {
    return Flexible(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Indicator(
                        color: Colors.red,
                        text: 'Broke',
                        isSquare: true,
                        size: touchedIndexGraph2 == 0 ? 18 : 16,
                      ),
                      Indicator(
                        color: Colors.green,
                        text: "Fulfilled",
                        isSquare: true,
                        size: touchedIndexGraph2 == 1 ? 18 : 16,
                      ),
                      Indicator(
                          color: Colors.blue,
                          text: 'Your Parts',
                          isSquare: true,
                          size: touchedIndexGraph2 == 2 ? 18 : 16)
                    ]),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LineChart(LineChartData(
                      titlesData: const FlTitlesData(
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 32)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  // interval: ,
                                  reservedSize: 40)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          ))),
                      lineBarsData: [
                        LineChartBarData(
                            spots: LogEntry.generateSpots(
                                widget.project.getLogEntries(), "Break"),
                            color: Colors.red,
                            isCurved: true,
                            preventCurveOverShooting: true),
                        LineChartBarData(
                            spots: LogEntry.generateSpots(
                                widget.project.getLogEntries(), "Fulfill"),
                            color: Colors.green,
                            isCurved: true,
                            preventCurveOverShooting: true),
                        LineChartBarData(
                            spots: LogEntry.generateSpots(
                                widget.project
                                    .getLogEntries()
                                    .where((e) => e.author == widget.user.name)
                                    .toList(),
                                "Fulfill"),
                            color: Colors.blue,
                            isCurved: true,
                            preventCurveOverShooting: true)
                      ])),
                ),
              )
            ],
          )),
    );
  }

  Flexible pieChart() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Indicator(
                  color: Colors.red,
                  text: 'Needed',
                  isSquare: true,
                  size: touchedIndexGraph1 == 0 ? 18 : 16,
                ),
                Indicator(
                  color: Colors.green,
                  text: 'In Stock',
                  isSquare: true,
                  size: touchedIndexGraph1 == 1 ? 18 : 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            fit: FlexFit.loose,
            flex: 1,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.red,
                      value: Part.getTotalNumberOfPartsNeeded(
                          widget.project.parts),
                      title:
                          '${Part.getTotalNumberOfPartsNeeded(widget.project.parts)}',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: Part.getTotalNumberOfPartsInStock(
                          widget.project.parts),
                      // value: 20,
                      title:
                          '${Part.getTotalNumberOfPartsInStock(widget.project.parts)}',
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
