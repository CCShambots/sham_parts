import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/constants.dart';

class CompoundPage extends StatefulWidget {
  final Compound compound;

  const CompoundPage({super.key, required this.compound});

  @override
  State<CompoundPage> createState() => _CompoundPageState();
}

class _CompoundPageState extends State<CompoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.compound.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Text(widget.compound.name, style: StyleConstants.titleStyle,)

        ]
      ),
    );
  }
}