
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/api-util/logEntry.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/constants.dart';

class Compound {
  int id;
  String name;
  String material;
  String thickness;
  List<CompoundPart> parts;
  bool camDone;
  List<String> camInstructions;

  String asigneeName;
  int asigneeId;

  List<LogEntry> logEntries;

  String thumbnail;


  Compound({
    required this.id,
    required this.name,
    required this.material,
    required this.thickness,
    required this.parts,
    required this.camDone,
    required this.camInstructions,
    required this.asigneeId,
    required this.asigneeName,
    required this.logEntries,
    required this.thumbnail,
  });

  factory Compound.fromJson(Map<String, dynamic> json) {
  
    return Compound(
      id: json['id'],
      name: json['name'],
      material: json['material'],
      thickness: json['thickness'],
      parts: (json['parts'] as List<dynamic>)
          .map((part) => CompoundPart.fromJson(part))
          .toList(),
      camDone: json['camDone'],
      camInstructions: (json['camInstructions'] as List<dynamic>)
          .map((instruction) => instruction.toString())
          .toList(),
      asigneeId: json['asigneeId'],
      asigneeName: json['asigneeName'],
      thumbnail: json['thumbnail'],
      logEntries: (json['logEntries'] as List<dynamic>)
          .map((entry) => LogEntry.fromJson(entry))
          .toList(),
    );
  }

  Future<void> uploadImage(Uint8List imageBytes, BuildContext context) async {
    // Convert the image bytes to base64 string
    String base64Image = base64Encode(imageBytes);

    // Make the API request to upload the image
    Response response = await APISession.post("/compound/$id/uploadImage", jsonEncode({
      "image": base64Image,
    }));

    if (response.statusCode == 200) {
      if (context.mounted) {
        APIConstants.showSuccessToast("Image uploaded successfully", context);
      }

      thumbnail = base64Image;
    } else {
      if (context.mounted) {
        APIConstants.showErrorToast("Failed to upload image. Status code: ${response.statusCode}", context);
      }
    }
  }

  Future<void> setCamDone(bool done, BuildContext context) async {
    // Make the API request to update the camDone status
    Response response = await APISession.patch("/compound/$id/setCamDone", jsonEncode({
      "done": done,
    }));

    if (response.statusCode == 200) {
      if (context.mounted) {
        APIConstants.showSuccessToast("CAM done status updated successfully", context);
      }

      camDone = done;
    } else {
      if (context.mounted) {
        APIConstants.showErrorToast("Failed to update CAM done status. Status code: ${response.statusCode}", context);
      }
    }
  }

  Future<void> fulfill(BuildContext context) async {
    // Make the API request to fulfill the compound
    Response response = await APISession.post("/compound/$id/fulfill", jsonEncode({}));

    if (response.statusCode == 200) {
      if (context.mounted) {
        APIConstants.showSuccessToast("Compound fulfilled successfully", context);
      }
    } else {
      if (context.mounted) {
        APIConstants.showErrorToast("Failed to fulfill compound. Status code: ${response.statusCode}", context);
      }
    }
  }

  Future<Compound?> saveToDatabase(Project project, BuildContext context) async {
    Response response = await APISession.post("/compound/create", jsonEncode({
      "projectName":project.name,
      "name": name,
      "material": material,
      "thickness": thickness,
      "parts": parts.map((part) => {
        "partId": part.partId,
        "quantity": part.quantity,
      }).toList(),

    }));

    if (response.statusCode == 200) {
      if(context.mounted) {
        APIConstants.showSuccessToast("Compound successfully created", context);
      }
      return Compound.fromJson(jsonDecode(response.body));
    } else {
      if(context.mounted) {
        APIConstants.showErrorToast("Failed to create compound. Status code: ${response.statusCode}", context);
      }
      return null;
    }
  }

  Future<void> assignUser(BuildContext context, User user) async {
    var response = await APISession.patch(
        "/compound/$id/assign", jsonEncode({"email": user.email}));

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast(
            "Assigned $name to ${user.email}", context);

        asigneeName = user.name;
      } else {
        APIConstants.showErrorToast(
            "Failed to Assign $name to ${user.email}: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
  }

  Future<void> unassignUser(BuildContext context) async {
    var response = await APISession.delete("/compound/$id/unAssign");

    if (context.mounted) {
      if (response.statusCode == 200) {
        APIConstants.showSuccessToast("Unassigned $name", context);

        asigneeName = "";
      } else {
        APIConstants.showErrorToast(
            "Failed to Unassign $name: Code ${response.statusCode} - ${response.body}",
            context);
      }
    }
  }

  String generatePartsTooltip() {
    String tooltip = '';
    for (var part in parts) {
      tooltip += part.toString();

      if(parts.last != part) tooltip += '\n';
    }
    return tooltip;
  }

}


class CompoundPart {
  int id;
  int partId;
  int quantity;

  //Manually assign part after the fact for display purposes
  Part part = Part.blank();

  CompoundPart({
    required this.id,
    required this.partId,
    required this.quantity,
  });

  void assignPart(Part part) {
    this.part = part;
  }

  void acquireAndAssignPart(Project project) {
    Part part = project.getPartById(partId);
    assignPart(part);
  }

  @override
  String toString() {
    return '${quantity}x ${part.number}';
  }

  factory CompoundPart.fromJson(Map<String, dynamic> json) {
    return CompoundPart(
      id: json['id'],
      partId: json['part_id'],
      quantity: json['quantity'],
    );
  }
}