import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RoleType {
  admin,
  write,
  read,
}

class Project {
  String name;
  String default_workspace;

  String assembly_name;
  String assembly_onshape_id;
  List<Part> parts;

  List<Part> individualParts;

  List<String> readRoles;
  List<String> writeRoles;
  List<String> adminRoles;

  Project(
      {required this.name,
      required this.default_workspace,
      required this.assembly_name,
      required this.assembly_onshape_id,
      required this.parts,
      required this.individualParts,
      required this.adminRoles,
      required this.readRoles,
      required this.writeRoles});

  static blank() {
    return Project(
        name: "NO PROJECT",
        default_workspace: "",
        assembly_name: "",
        assembly_onshape_id: "",
        readRoles: [],
        writeRoles: [],
        adminRoles: [],
        parts: [],
        individualParts: []);
  }

  List<String> getListFromType(RoleType type) {
    switch (type) {
      case RoleType.admin:
        return adminRoles;
      case RoleType.write:
        return writeRoles;
      case RoleType.read:
        return readRoles;
      default:
        return [];
    }
  }

  static String roleTypeToString(RoleType type) {
      switch (type) {
        case RoleType.read:
          return "Read Roles";
        case RoleType.write:
          return "Write Roles";
        case RoleType.admin:
          return "Admin Roles";
        default:
          return "";
      }
    }
  
  Future<void> addRole(String role, RoleType type, BuildContext context) async {
    var response = await APISession.patch("/project/$name/addRole", jsonEncode({"role": role, "type" :type.name}));

    if(response.statusCode == 200) {
      if (type == RoleType.admin) {
        adminRoles.add(role);
      } else if (type == RoleType.write) {
        writeRoles.add(role);
      } else if (type == RoleType.read) {
        readRoles.add(role);
      }
      if(context.mounted) {
        APIConstants.showSuccessToast('Role added successfully.', context);
      }
    } else {
      if(context.mounted) {
        APIConstants.showErrorToast('Failed to add role. Status code: ${response.statusCode}, Error message: ${response.body}', context);
      }
    }
  }

  Future<void> removeRole(String role, RoleType type, BuildContext context) async {
    var response = await APISession.patch("/project/$name/removeRole", jsonEncode({"role": role, "type": type.name}));

    if (response.statusCode == 200) {
      if (type == RoleType.admin) {
        adminRoles.remove(role);
      } else if (type == RoleType.write) {
        writeRoles.remove(role);
      } else if (type == RoleType.read) {
        readRoles.remove(role);
      }
      APIConstants.showSuccessToast('Role removed successfully.', context);
    } else {
      APIConstants.showErrorToast('Failed to remove role. Status code: ${response.statusCode}, Error message: ${response.body}', context);
    }
  }

  List<String> getMaterials() {
    List<String> materials = [];

    for (var part in parts) {
      String material = part.material!;
      bool doneSomething = false;

      for (var existingMaterial in materials) {
        if (existingMaterial.contains(material)) {
          materials.add(material);
          materials.remove(existingMaterial);

          doneSomething = true;
          break;
        } else if (material.contains(existingMaterial)) {
          doneSomething = true;
          break;
        }
      }

      if (!doneSomething) {
        materials.add(material);
      }

      materials.sort();
    }
    return materials;
  }

  static Future<Project> loadProject(String key) async {
    var response = await APISession.get("/project/$key");

    if (response.statusCode == 404) {
      //Old project doesn't exist - clear it
      BuildContext? context = MyApp.navigatorKey.currentState?.context;

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString(APIConstants().currentProject, "");

      if (context != null && context.mounted) {
        APIConstants.showErrorToast(
            'Old Project No Longer Exists... Resetting to Default.', context);
      }

      return Project.blank();
    }

    var json = jsonDecode(response.body);

    Project proj = Project(
        name: json["name"],
        default_workspace: json["default_workspace"],
        assembly_name: json["assembly_name"],
        assembly_onshape_id: json["assembly_onshape_id"],
        readRoles: json["read_roles"]?.cast<String>() ?? [],
        writeRoles: json["write_roles"]?.cast<String>() ?? [],
        adminRoles: json["admin_roles"]?.cast<String>() ?? [],
        parts: json["parts"]?.map<Part>((e) => Part.fromJson(e)).toList() ?? [],
        individualParts: json["individual_parts"]
            .map<Part>((e) => Part.fromJson(e))
            .toList());

    RegExp regex = RegExp("[0-9]{2,}-20[0-9]{2}-P-[0-9]{4}");

    proj.parts.sort((a, b) {
      //Any part in the form ####-20##-P-#### should be before all others, then sorted by the last four numbers

      try {
        if (regex.hasMatch(a.number) && regex.hasMatch(b.number)) {
          int aNum = int.parse(a.number.split("-").last);
          int bNum = int.parse(b.number.split("-").last);

          return aNum.compareTo(bNum);
        } else if (regex.hasMatch(a.number)) {
          return -1;
        } else if (regex.hasMatch(b.number)) {
          return 1;
        } else {
          return a.number.compareTo(b.number);
        }
      } catch (e) {
        return -1;
      }
    });

    return proj;
  }

  static Future<List<String>> loadProjects() async {
    try {
      return List<String>.from(
          jsonDecode((await APISession.get("/project/list")).body));
    } catch (e) {
      return [""];
    }
  }
}
