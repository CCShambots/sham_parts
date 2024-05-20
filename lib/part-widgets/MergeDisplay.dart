import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/part-widgets/MergePart.dart';

class MergePage extends StatefulWidget {
  final Project project;

  const MergePage({super.key, required this.project});

  @override
  State<MergePage> createState() => _MergePageState();
}

class _MergePageState extends State<MergePage> {
  List<List<Part>> duplicates = [];

  @override
  void initState() {
    super.initState();
    duplicates = widget.project.duplicatePartNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Merge Duplicate Parts (${duplicates.length} dupes)"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
          children:
              duplicates.map<Widget>((e) => MergePart(parts: e)).toList()),
    );
  }
}
