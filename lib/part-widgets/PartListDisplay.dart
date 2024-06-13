import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/part-widgets/PartPage.dart';

class PartListDisplay extends StatefulWidget {
  final Part part;

  const PartListDisplay({super.key, required this.part});

  @override
  State<StatefulWidget> createState() => PartListDisplayState();
}

class PartListDisplayState extends State<PartListDisplay> {
  TextStyle statStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 32);

  final isMobile = Platform.isAndroid || Platform.isIOS;

  RegExp regex = RegExp(r'\d{1,4}-\d{4}-');

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    final parseOut = widget.part.number.replaceAll(regex, "");

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PartPage(part: widget.part)));
      },
      child: Container(
        decoration: StyleConstants.shadedDecoration(context),
        margin: StyleConstants.margin,
        padding: StyleConstants.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: !isMobile ? [
            widget.part.ImageButton(context),
            widget.part.PartName(parseOut, isMobile),
            widget.part.PartType(),
            widget.part.Asignee(),
            widget.part.QuantityHave(),
            widget.part.QuantityExtra(),
            widget.part.QuantityRequested(),
          ] : [
            widget.part.PartName(parseOut, isMobile),
            widget.part.QuantityHave(),
            widget.part.QuantityExtra(),
          ],
        ),
      ),
    );
  }
}

