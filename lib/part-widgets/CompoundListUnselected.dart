import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/part-widgets/PartPage.dart';

class CompoundListUnselected extends StatefulWidget {
  final Part part;
  final addToSelected;

  const CompoundListUnselected({super.key, required this.part, required this.addToSelected});

  @override
  State<StatefulWidget> createState() => CompoundListUnselectedState();
}

class CompoundListUnselectedState extends State<CompoundListUnselected> {
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
          children:  [
            widget.part.ImageButton(context),
            widget.part.PartName(parseOut, isMobile),
            widget.part.PartThickness(),
            widget.part.QuantityHave(),
            IconButton(onPressed: widget.addToSelected, icon: const Icon(Icons.arrow_forward, color: Colors.blue, size: 48,))
          ],
        ),
      ),
    );
  }
}

