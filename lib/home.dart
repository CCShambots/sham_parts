import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/logEntry.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/constants.dart';
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
    bool oneRowGraph = MediaQuery.of(context).size.width > 650;

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.project.name,
              style: StyleConstants.titleStyle,
              overflow: TextOverflow.ellipsis,
            ),
            oneRowGraph
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      pieChart(),
                      lineGraph(),
                      const Flexible(child: Text("More graph coming soon ™️"))
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      pieChart(),
                      lineGraph(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Flexible lineGraph() {
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
                                    interval: 1,
                                    reservedSize: 32)),
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
                                      .where(
                                          (e) => e.author == widget.user.name)
                                      .toList(),
                                  "Fulfill"),
                              color: Colors.blue,
                              isCurved: true,
                              preventCurveOverShooting: true)
                        ])),
                  ),
                )
              ],
            )));
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
                  // pieTouchData: PieTouchData(
                  //   touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  //     setState(() {
                  //       if (!event.isInterestedForInteractions ||
                  //           pieTouchResponse == null ||
                  //           pieTouchResponse.touchedSection == null) {
                  //         touchedIndexGraph1 = -1;
                  //         return;
                  //       }
                  //       touchedIndexGraph1 = pieTouchResponse
                  //           .touchedSection!.touchedSectionIndex;
                  //     });
                  //   },
                  // ),
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
