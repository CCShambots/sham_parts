import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/compound-widgets/CompoundPage.dart';
import 'package:sham_parts/constants.dart';

class CompoundListDisplay extends StatefulWidget {
  final Project project;
  final Compound compound;

  const CompoundListDisplay({super.key, required this.compound, required this.project});

  @override
  State<CompoundListDisplay> createState() => _CompoundListDisplayState();
}

class _CompoundListDisplayState extends State<CompoundListDisplay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompoundPage(compound: widget.compound, project: widget.project,)));
      },
      child: Container(
        decoration: StyleConstants.shadedDecoration(context),
        margin: StyleConstants.margin,
        padding: StyleConstants.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.compound.name, style: StyleConstants.subtitleStyle,),
            Text(widget.compound.material, style: StyleConstants.subtitleStyle),
            Tooltip(
              message: "Thickness",
              child: Text("${widget.compound.thickness}\"", style: StyleConstants.subtitleStyle)),
            Tooltip(
              message: widget.compound.generatePartsTooltip(),
              child: Text("${widget.compound.parts.length} Part${widget.compound.parts.length != 1 ? 's' : ''}", style: StyleConstants.subtitleStyle)),
            Row(children: [
              Text("CAM ", style: StyleConstants.subtitleStyle),
              Icon(widget.compound.camDone ? Icons.check_circle : Icons.cancel, color: widget.compound.camDone ? Colors.green : Colors.red, size: 48,)
            ],)
          ],
        ),
      ),
    );
  }
}
