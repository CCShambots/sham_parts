
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:redacted/redacted.dart';
import 'dart:math';
import 'dart:io';

import 'package:sham_parts/api_util/apiSession.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/main.dart';

class Part {

  int id;
  String number;
  String thumbnail;
  String material;
  String onshapeID;
  int quantityNeeded;
  int quantityInStock;
  int quantityRequested;

  late Widget partListDisplay;

  Part({
      required this.id,
      required this.number,
      required this.thumbnail,
      required this.material,
      required this.onshapeID,
      required this.quantityNeeded,
      required this.quantityInStock,
      required this.quantityRequested
  }) {
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
        onshapeID: json["onshape_id"],
    );
  }

  Future<void> reportBreak(BuildContext context) async {
    var response = await APISession.get("/part/$id/break");

    if(context.mounted) {
      if(response.statusCode == 200) {
        APIConstants.showSuccessToast(
            "Reported Break on $number",
            context
        );

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

    if(context.mounted) {
      if(response.statusCode == 200) {
        APIConstants.showSuccessToast("Requested Additional $number",
            context);

        quantityRequested++;
      } else {
        APIConstants.showErrorToast("Failed to Request Additional $number: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
  }

  Future<void> fulfillRequest(BuildContext context) async {
    var response = await APISession.get("/part/$id/fulfill");

    if(context.mounted) {
      if(response.statusCode == 200) {
        APIConstants.showSuccessToast("Fulfilled Request for $number",
            MyApp.navigatorKey.currentContext);

        quantityInStock++;
      } else {
        APIConstants.showErrorToast("Failed to Fulfill Request for $number: Code ${response.statusCode} - ${response.body}",
            MyApp.navigatorKey.currentContext);
      }
    }

  }

  Future<bool> loadThumbnail() async {
    var response = await APISession.get("/part/$id/loadImage");

    if(response.statusCode == 200) {
      thumbnail = jsonDecode(response.body);
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
  State<StatefulWidget> createState () => PartListDisplayState();

}

class PartListDisplayState extends State<PartListDisplay> {

  TextStyle statStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 32);

  final isMobile = Platform.isAndroid || Platform.isIOS;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.2)
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GFImageOverlay(
              height: 200,
              width: 200,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              image: APISession.getOnshapeImage(widget.part.thumbnail),
            ).redacted(context: context, redact: widget.part.thumbnail == "unloaded"),
            SizedBox(
              width: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.part.number, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                    Text(widget.part.material),
                    Text("${widget.part.id}")
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
                      color: widget.part.quantityInStock >= widget.part.quantityNeeded ?
                        Colors.green : (widget.part.quantityInStock > 0) ? Colors.yellow : Colors.red),
                ),
                const Text("For Robot")
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${max<int>(widget.part.quantityInStock-widget.part.quantityNeeded, 0)}", style: statStyle,),
                const Text("Extra")
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${widget.part.quantityRequested}", style: statStyle,),
                const Text("Requested")
              ],
            ),

            !isMobile ? Row(
              children: [
                Tooltip(
                  message: "Report Break",
                  child: IconButton(
                        onPressed: () {
                          widget.part.reportBreak(context);
                          setState(() {

                          });
                        },
                        icon: const Icon(Icons.broken_image, color: Colors.red, size: 48,)
                    )
                ),
                Tooltip(
                    message: "Request Additional",
                    child: IconButton(
                        onPressed: () async {
                          await widget.part.requestPart(context);
                          setState(() {

                          });
                        },
                        icon: const Icon(Icons.shopping_cart, color: Colors.green, size: 48,)
                    )
                )
              ],
            ) : Container()
          ],
        ),
      ),
    );
  }

}