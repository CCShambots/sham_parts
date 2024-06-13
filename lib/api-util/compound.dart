
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/constants.dart';

class Compound {
  int id;
  String name;
  String material;
  String thickness;
  List<CompoundPart> parts;
  bool camDone;
  List<String> camInstructions;

  Compound({
    required this.id,
    required this.name,
    required this.material,
    required this.thickness,
    required this.parts,
    required this.camDone,
    required this.camInstructions,
  });

  factory Compound.fromJson(Map<String, dynamic> json) {
    
    print(json);

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
    );
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

  factory CompoundPart.fromJson(Map<String, dynamic> json) {
    return CompoundPart(
      id: json['id'],
      partId: json['part_id'],
      quantity: json['quantity'],
    );
  }
}