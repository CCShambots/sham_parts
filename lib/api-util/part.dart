import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';

import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/api-util/logEntry.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/part-widgets/PartListDisplay.dart';

class Part {
  int id;
  String number;
  String thumbnail;
  String material;

  String onshapeElementID;
  String onshapeDocumentID;
  String onshapeWVMID;
  String onshapeWVMType;
  String onshapePartID;

  int quantityNeeded;
  int quantityInStock;
  int quantityRequested;

  String dimension1;
  String dimension2;
  String dimension3;

  String partType;

  String asigneeName;
  int asigneeId;

  List<LogEntry> logEntries;

  int numCombines;

  late Widget partListDisplay;

  Part(
      {required this.id,
      required this.number,
      required this.thumbnail,
      required this.material,
      required this.onshapeElementID,
      required this.onshapeDocumentID,
      required this.onshapeWVMID,
      required this.onshapeWVMType,
      required this.onshapePartID,
      required this.quantityNeeded,
      required this.quantityInStock,
      required this.quantityRequested,
      required this.logEntries,
      required this.asigneeName,
      required this.dimension1,
      required this.dimension2,
      required this.dimension3,
      required this.numCombines,
      required this.partType,
      required this.asigneeId}) {
    partListDisplay = PartListDisplay(part: this);
  }

  factory Part.blank() {
    return Part(
      id: 0,
      number: '',
      thumbnail: '',
      material: '',
      onshapeElementID: '',
      onshapeDocumentID: '',
      onshapeWVMID: '',
      onshapeWVMType: '',
      onshapePartID: '',
      quantityNeeded: 0,
      quantityInStock: 0,
      quantityRequested: 0,
      logEntries: [],
      asigneeName: '',
      dimension1: '',
      dimension2: '',
      dimension3: '',
      numCombines: 0,
      partType: '',
      asigneeId: 0,
    );
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
      onshapeDocumentID: json["onshape_document_id"],
      onshapeWVMID: json["onshape_wvm_id"],
      onshapeWVMType: json["onshape_wvm_type"],
      onshapePartID: json["onshape_part_id"],
      dimension1: json["dimension1"],
      dimension2: json["dimension2"],
      dimension3: json["dimension3"],
      asigneeName: json["asigneeName"] ?? "",
      asigneeId: json["asigneeId"] ?? -1,
      partType: json["partType"],
      numCombines: json["part_combines"].length,
      logEntries: json["logEntries"]
          .map<LogEntry>((e) => LogEntry.fromJson(e))
          .toList(),
    );
  }

  static double getTotalNumberOfPartsInStock(List<Part> parts) {
    double total = 0;

    for (Part part in parts) {
      total += min<int>(part.quantityInStock, part.quantityNeeded);
    }

    return total;
  }

  static double getTotalNumberOfPartsRequested(List<Part> parts) {
    double total = 0;

    for (Part part in parts) {
      total += part.quantityRequested;
    }

    return total;
  }

  static double getTotalNumberOfPartsNeeded(List<Part> parts) {
    double total = 0;

    for (Part part in parts) {
      total += part.quantityNeeded;
    }

    return total;
  }


  static Future<List<String>> getPartTypes() async {
    var response = await APISession.get("/part/types");

    if (response.statusCode == 200) {
      return jsonDecode(response.body).cast<String>();
    } else {
      return [];
    }
  }

  Future<void> merge(BuildContext context, List<Part> parts) async {
    var response = await APISession.post("/part/$id/merge", jsonEncode({
      "parts": parts.where((e) => e.id != id).map((e) => e.id).toList()
    }));

    if(context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast("Merged Parts", context);
      } else {
        APIConstants.showErrorToast(
            "Failed to Merge Parts: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
  }


  Future<void> setPartType(BuildContext context, String newType) async {
    var response = await APISession.patch(
        "/part/$id/setPartType", jsonEncode({"partType": newType}));

    if (response.statusCode == 200) {
      APIConstants.showSuccessToast("Set Part Type for $number", context);

      partType = newType;
    } else {
      APIConstants.showErrorToast(
          "Failed to Set Part Type for $number: Code ${response.statusCode} - ${response.body}",
          context);
    }
  }

  Future<void> setDimensions(
      BuildContext context, String d1, String d2, String d3) async {
    var response = await APISession.patch(
        "/part/$id/setDimensions", jsonEncode({"d1": d1, "d2": d2, "d3": d3}));

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast("Set Dimensions for $number", context);

        dimension1 = d1;
        dimension2 = d2;
        dimension3 = d3;
      } else {
        APIConstants.showErrorToast(
            "Failed to Set Dimensions for $number: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
  }

  Future<void> assignUser(BuildContext context, User user) async {
    var response = await APISession.patch(
        "/part/$id/assign", jsonEncode({"email": user.email}));

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast(
            "Assigned $number to ${user.email}", context);

        asigneeName = user.name;
      } else {
        APIConstants.showErrorToast(
            "Failed to Assign $number to ${user.email}: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
  }

  Future<void> unassignUser(BuildContext context) async {
    var response = await APISession.delete("/part/$id/unAssign");

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast("Unassigned $number", context);

        asigneeName = "";
      } else {
        APIConstants.showErrorToast(
            "Failed to Unassign $number: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
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

  Future<void> fulfillRequest(BuildContext context, {int quantity = 1}) async {
    var response = await APISession.get("/part/$id/fulfill?quantity=$quantity");

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast(
            "Fulfilled Request for $number", context);

        quantityInStock += quantity;
        quantityRequested -= quantity;
        quantityRequested = max<int>(quantityRequested, 0);
      } else {
        APIConstants.showErrorToast(
            "Failed to Fulfill Request for $number: Code ${response.statusCode} - ${response.body}",
            context);
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


  //Methods for widget display stuff
  Column QuantityRequested() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$quantityRequested",
          style: StyleConstants.statStyle,
        ),
        const Text("Requested")
      ],
    );
  }

  Column QuantityExtra() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${max<int>(quantityInStock - quantityNeeded, 0)}",
          style: StyleConstants.statStyle,
        ),
        const Text("Extra")
      ],
    );
  }

  Column QuantityHave() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${min<int>(quantityInStock, quantityNeeded)}/${quantityNeeded}",
          style: TextStyle(
              fontWeight: StyleConstants.statStyle.fontWeight,
              fontSize: StyleConstants.statStyle.fontSize,
              color: quantityInStock >= quantityNeeded
                  ? Colors.green
                  : (quantityInStock > 0)
                      ? Colors.yellow
                      : Colors.red),
        ),
        const Text("Robot")
      ],
    );
  }

  Text PartType() {
    return Text(
      partType,
      style: StyleConstants.subtitleStyle,
    );
  }

  Tooltip PartThickness() {
    return Tooltip(
      message: "$dimension1\" x $dimension2\" x $dimension3\"",
      child: Text(
        "$dimension1\"",
        style: StyleConstants.subtitleStyle,
      ),
    );
  }

  Tooltip PartName(String parseOut, bool mobile) {
    return Tooltip(
      message: number,
      child: SizedBox(
        width: !mobile ? 250 : 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              parseOut,
              overflow: TextOverflow.ellipsis,
              style: StyleConstants.subtitleStyle,
            ),
            Text(
              material,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImagePopup(BuildContext context) {
    return AlertDialog(
      title: Text(number),
      content: thumbnail != "unloaded"
          ? GFImageOverlay(
              height: 200,
              width: 200,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              image: APISession.getOnshapeImage(thumbnail),
            )
          : const Text("No Image Loaded..."),
    );
  }

  IconButton ImageButton(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(context: context, builder: buildImagePopup);
        },
        tooltip: "Show Part Image",
        icon: const Icon(
          Icons.image,
          color: Colors.blue,
          size: 48,
        ));
  }
}