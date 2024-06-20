import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/part-widgets/PartPage.dart';

class CompoundListSelected extends StatefulWidget {
  final CompoundPart compoundPart;
  late Part part;
  final removeFromSelected;
  final String thickness;

  CompoundListSelected(
      {super.key,
      required this.compoundPart,
      required this.removeFromSelected,
      required this.thickness
      }) {
    part = compoundPart.part;
  }

  @override
  State<StatefulWidget> createState() => CompoundListSelectedState();
}

class CompoundListSelectedState extends State<CompoundListSelected> {
  TextStyle statStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 32);

  final isMobile = Platform.isAndroid || Platform.isIOS;

  RegExp regex = RegExp(r'\d{1,4}-\d{4}-');


  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    final parseOut = widget.part.number.replaceAll(regex, "");

    final bool thicknessWarning = widget.thickness != widget.part.dimension1;

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
          children: [
            IconButton(
                onPressed: widget.removeFromSelected,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                  size: 48,
                )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        widget.compoundPart.quantity--;

                        if(widget.compoundPart.quantity == 0) {
                          widget.removeFromSelected();
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.red,
                      size: 48,
                    )),
                Tooltip(
                  message: "Number in Compound",
                  child: Text(widget.compoundPart.quantity.toString(),
                      style: StyleConstants.titleStyle),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        widget.compoundPart.quantity++;
                      });
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                      size: 48,
                    )),
              ],
            ),
            widget.part.ImageButton(context),
            widget.part.PartThickness(warning: thicknessWarning),
            widget.part.PartName(parseOut, isMobile),
            widget.part.QuantityHave(),
          ],
        ),
      ),
    );
  }
}
