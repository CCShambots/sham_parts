import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/compound-widgets/CompoundPage.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/util/platform.dart';

class AssignedCompoundDisplay extends StatefulWidget {
  final Project project;
  final Compound compound;

  const AssignedCompoundDisplay({super.key, required this.compound, required this.project});

  @override
  State<AssignedCompoundDisplay> createState() => _AssignedCompoundDisplayState();
}

class _AssignedCompoundDisplayState extends State<AssignedCompoundDisplay> {
  final isMobile = PlatformInfo.isMobile();

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
        height: 111-16,
        decoration: StyleConstants.shadedDecoration(context),
        margin: StyleConstants.margin,
        padding: StyleConstants.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: !isMobile ? [
            widget.compound.CompoundName(isMobile),
            widget.compound.CompoundPartQuantity(),
            widget.compound.CompoundCamStatus(isMobile)
          ] : [
            widget.compound.CompoundName(isMobile),
            widget.compound.CompoundCamStatus(isMobile)
          ],
        ),
      ),
    );
  }
}
