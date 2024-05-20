import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/constants.dart';

class MergePart extends StatefulWidget {
  final List<Part> parts;
  const MergePart({super.key, required this.parts});

  @override
  State<MergePart> createState() => _MergePartState();
}

class _MergePartState extends State<MergePart> {
  late Part main;

  @override
  void initState() {
    super.initState();
    main = widget.parts.first;
  }

  void claimMain(Part part) {
    setState(() {
      main = part;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: StyleConstants.shadedDecoration(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Text(widget.parts.first.number, style: StyleConstants.subtitleStyle,),
              IconButton(onPressed: () {
                main.merge(context, widget.parts);
              }, icon: const Icon(Icons.merge), tooltip: "Apply merge", color: Colors.green,)
            ],),
          ),
          ...widget.parts.map((e) => IndividualPart(main: main == e, claimMain: claimMain, part: e))
        ],
      ),
    );
  }
}

typedef PartClaimFunction = void Function(Part part);

class IndividualPart extends StatefulWidget {
  final PartClaimFunction claimMain;
  final bool main;
  final Part part;

  const IndividualPart({super.key, required this.main, required this.claimMain, required this.part});

  @override
  State<IndividualPart> createState() => _IndividualPartState();
}

class _IndividualPartState extends State<IndividualPart> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Checkbox(
          value: widget.main,
          onChanged: (value) {
            if (value ?? false) {
              widget.claimMain(widget.part);
            }
          },
        ),
        Text("BOM QTY: ${widget.part.quantityNeeded}"),
        Text("DB ID: ${widget.part.id}"),
        Text(widget.part.onshapePartID),
        Text(widget.part.onshapeDocumentID),
        Text(widget.part.onshapeElementID),
    ],);
  }
}