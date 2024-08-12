import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/compound-widgets/compound_page.dart';
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
    final isMobile = Platform.isAndroid || Platform.isIOS;

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
          children: !isMobile ? [
            widget.compound.compoundName(isMobile),
            widget.compound.compoundMaterial(),
            widget.compound.compoundThickness(),
            widget.compound.asignee(),
            widget.compound.compoundPartQuantity(),
            widget.compound.compoundCamStatus(isMobile)
          ] : [
            widget.compound.compoundName(isMobile),
            widget.compound.compoundCamStatus(isMobile)
          ]
        ),
      ),
    );
  }
}
