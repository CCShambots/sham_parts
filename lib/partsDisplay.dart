
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sham_parts/api_util/part.dart';
import 'package:sham_parts/api_util/project.dart';

class PartsDisplay extends StatefulWidget{
  Project project;

  PartsDisplay({super.key, required this.project});

  @override
  State<PartsDisplay> createState() =>
      PartsDisplayState();
}

class PartsDisplayState extends State<PartsDisplay> {

  List<Part> currentParts = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      currentParts = widget.project.mainAssembly.parts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Wrap(
            children: widget.project.mainAssembly.parts.map((e) => e.partListDisplay).toList(),
          )
      ,
    );
  }

}