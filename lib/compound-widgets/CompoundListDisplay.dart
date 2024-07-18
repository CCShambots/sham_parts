import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/compound-widgets/CompoundPage.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/util/platform.dart';

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
    final isMobile = PlatformInfo.isMobile();

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
            widget.compound.CompoundName(isMobile),
            widget.compound.CompoundMaterial(),
            widget.compound.CompoundThickness(),
            widget.compound.Asignee(),
            widget.compound.CompoundPartQuantity(),
            widget.compound.CompoundCamStatus(isMobile)
          ] : [
            widget.compound.CompoundName(isMobile),
            widget.compound.CompoundCamStatus(isMobile)
          ]
        ),
      ),
    );
  }
}
