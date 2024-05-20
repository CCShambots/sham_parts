import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:sham_parts/api-util/apiSession.dart';
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

  Widget buildImagePopup(BuildContext context) {
    return AlertDialog(
      title: Text(widget.part.number),
      content: widget.part.thumbnail != "unloaded"
          ? GFImageOverlay(
              height: 200,
              width: 200,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              image: APISession.getOnshapeImage(widget.part.thumbnail),
            )
          : const Text("No Image Loaded..."),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          children: [
            IconButton(
                onPressed: () {
                  showDialog(context: context, builder: buildImagePopup);
                },
                tooltip: "Show Part Image",
                icon: const Icon(
                  Icons.image,
                  color: Colors.blue,
                  size: 48,
                )),
            Tooltip(
              message: widget.part.number,
              child: SizedBox(
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      parseOut,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Text(widget.part.material),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${min<int>(widget.part.quantityInStock, widget.part.quantityNeeded)}/${widget.part.quantityNeeded}",
                  style: TextStyle(
                      fontWeight: statStyle.fontWeight,
                      fontSize: statStyle.fontSize,
                      color: widget.part.quantityInStock >=
                              widget.part.quantityNeeded
                          ? Colors.green
                          : (widget.part.quantityInStock > 0)
                              ? Colors.yellow
                              : Colors.red),
                ),
                const Text("Robot")
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${max<int>(widget.part.quantityInStock - widget.part.quantityNeeded, 0)}",
                  style: statStyle,
                ),
                const Text("Extra")
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.part.quantityRequested}",
                  style: statStyle,
                ),
                const Text("Requested")
              ],
            ),
          ],
        ),
      ),
    );
  }
}

