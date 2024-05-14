import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:redacted/redacted.dart';
import 'dart:math';
import 'dart:io';

import 'package:sham_parts/api_util/apiSession.dart';
import 'package:sham_parts/api_util/logEntry.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/main.dart';

class Part {
  int id;
  String number;
  String thumbnail;
  String material;
  String onshapeElementID;
  int quantityNeeded;
  int quantityInStock;
  int quantityRequested;

  List<LogEntry> logEntries;

  late Widget partListDisplay;

  Part(
      {required this.id,
      required this.number,
      required this.thumbnail,
      required this.material,
      required this.onshapeElementID,
      required this.quantityNeeded,
      required this.quantityInStock,
      required this.quantityRequested, required this.logEntries}) {
    partListDisplay = PartListDisplay(part: this);
  }

  static Part fromJson(json) {
    return Part(
      id: json["id"],
      number: json["number"],
      thumbnail: json["thumbnail"],
      material: json["material"],
      quantityNeeded: json["quantityNeeded"],
      quantityInStock: json["quantityInStock"],
      quantityRequested: json["quantityRequested"],
      onshapeElementID: json["onshape_element_id"],
      logEntries: json["logEntries"].map<LogEntry>((e) => LogEntry.fromJson(e)).toList(),
    );
  }

  Future<void> reportBreak(BuildContext context) async {
    var response = await APISession.get("/part/$id/break");

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast("Reported Break on $number", context);

        quantityInStock--;
      } else {
        APIConstants.showErrorToast(
            "Failed to Report Break on $number: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
  }

  Future<void> requestPart(BuildContext context) async {
    var response = await APISession.get("/part/$id/request");

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast("Requested Additional $number", context);

        quantityRequested++;
      } else {
        APIConstants.showErrorToast(
            "Failed to Request Additional $number: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
  }

  Future<void> fulfillRequest(BuildContext context) async {
    var response = await APISession.get("/part/$id/fulfill");

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast(
            "Fulfilled Request for $number", MyApp.navigatorKey.currentContext);

        quantityInStock++;
      } else {
        APIConstants.showErrorToast(
            "Failed to Fulfill Request for $number: Code ${response.statusCode} - ${response.body}",
            MyApp.navigatorKey.currentContext);
      }
    }
  }

  Future<bool> loadThumbnail() async {
    var response = await APISession.get("/part/$id/loadImage");

    if (response.statusCode == 200) {
      thumbnail = response.body;
      return true;
    } else {
      return false;
    }
  }
}

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
            SizedBox(
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

class PartPage extends StatefulWidget {
  final Part part;

  const PartPage({super.key, required this.part});

  @override
  State<PartPage> createState() => _PartPageState();
}

class _PartPageState extends State<PartPage> {
  final isMobile = Platform.isAndroid || Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.part.number),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //This row centers the whole shabang
            Row(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GFImageOverlay(
                  height: isMobile ? 200 : 400,
                  width: isMobile ? 200 : 400,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  image: APISession.getOnshapeImage(widget.part.thumbnail),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(widget.part.material,
                          style: StyleConstants.subtitleStyle),
                      Text(
                        "On Bot: ${min<int>(widget.part.quantityInStock, widget.part.quantityNeeded)} / ${widget.part.quantityNeeded}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: StyleConstants.subtitleStyle.fontSize,
                            color: widget.part.quantityInStock >=
                                    widget.part.quantityNeeded
                                ? Colors.green
                                : (widget.part.quantityInStock > 0)
                                    ? Colors.yellow
                                    : Colors.red),
                      ),
                      Text(
                        "Extra: ${max<int>(widget.part.quantityInStock - widget.part.quantityNeeded, 0)}",
                        style: StyleConstants.subtitleStyle,
                      ),
                      Text(
                        "Requested: ${widget.part.quantityRequested}",
                        style: StyleConstants.subtitleStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Tooltip(
                    message: "Report Break",
                    child: IconButton(
                        onPressed: () {
                          widget.part.reportBreak(context);
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 48,
                        ))),
                Tooltip(
                    message: "Request Additional",
                    child: IconButton(
                        onPressed: () async {
                          await widget.part.requestPart(context);
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.green,
                          size: 48,
                        ))),
                Tooltip(
                    message: "Fulfill Request",
                    child: IconButton(
                        onPressed: () async {
                          await widget.part.fulfillRequest(context);
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.check,
                          color: Colors.blue,
                          size: 48,
                        ))),
              ],
            ),

            Text("Part Log", style: StyleConstants.titleStyle),
            ListView(
              children: widget.part.logEntries.map((e) => LogEntryWidget(logEntry: e)).toList(),
            )
          ],
        ));
  }
}
