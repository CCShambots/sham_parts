import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/log_entry.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/api_session.dart';
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RoleType {
  admin,
  write,
  read,
}

class Project {
  String name;
  String defaultWorkspace;

  String assemblyName;
  String assemblyOnshapeId;
  List<Part> parts;
  List<String> readRoles;
  List<String> writeRoles;
  List<String> adminRoles;

  List<Compound> compounds;

  DateTime lastSync;

  late String readableLastSync;
  late String moreDetailedSyncDate;

  Project({
    required this.name,
    required this.defaultWorkspace,
    required this.assemblyName,
    required this.assemblyOnshapeId,
    required this.parts,
    required this.adminRoles,
    required this.readRoles,
    required this.writeRoles,
    required this.compounds,
    required this.lastSync,
  }) {
    DateFormat formatter = DateFormat('MM-dd-yy');
    readableLastSync = formatter.format(lastSync.toLocal());

    DateFormat moreDetailedFormatter = DateFormat('MM-dd-yy hh:mm');
    moreDetailedSyncDate = moreDetailedFormatter.format(lastSync.toLocal());
  }

  static blank() {
    return Project(
        name: "NO PROJECT",
        defaultWorkspace: "",
        assemblyName: "",
        assemblyOnshapeId: "",
        readRoles: [],
        writeRoles: [],
        adminRoles: [],
        parts: [],
        compounds: [],
        lastSync: DateTime.now());
  }

  Part getPartById(int id) {
    return parts.firstWhere((part) => part.id == id,
        orElse: () => Part.blank());
  }

  List<List<Part>> duplicatePartNames() {
    List<List<Part>> duplicates = [];

    for (var part in parts) {
      List<Part> matchingParts = parts
          .where((element) => element.number == part.number && element != part)
          .toList();

      if (matchingParts.isNotEmpty &&
          !duplicates.any((list) => list.contains(part))) {
        matchingParts.add(part);
        duplicates.add(matchingParts);
      }
    }

    return duplicates;
  }

  List<LogEntry> getLogEntries() {
    List<LogEntry> entries = [];

    for (var part in parts) {
      entries.addAll(part.logEntries);
    }

    entries.sort((a, b) => b.date.compareTo(a.date));

    return entries;
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

  Future<void> sync(BuildContext context) async {
    var response =
        await APISession.patch("/project/$name/sync", jsonEncode({}));

    if (response.statusCode == 200) {
      if (context.mounted) {
        APIConstants.showSuccessToast('Sync successful.', context);
      }
    } else {
      if (context.mounted) {
        APIConstants.showErrorToast(
            'Failed to sync project. Status code: ${response.statusCode}, Error message: ${response.body}',
            context);
      }
    }
  }

  Future<void> addRole(String role, RoleType type, BuildContext context) async {
    var response = await APISession.patch("/project/$name/addRole",
        jsonEncode({"role": role, "type": type.name}));

    if (response.statusCode == 200) {
      if (type == RoleType.admin) {
        adminRoles.add(role);
      } else if (type == RoleType.write) {
        writeRoles.add(role);
      } else if (type == RoleType.read) {
        readRoles.add(role);
      }
      if (context.mounted) {
        APIConstants.showSuccessToast('Role added successfully.', context);
      }
    } else {
      if (context.mounted) {
        APIConstants.showErrorToast(
            'Failed to add role. Status code: ${response.statusCode}, Error message: ${response.body}',
            context);
      }
    }
  }

  Future<void> removeRole(
      String role, RoleType type, BuildContext context) async {
    var response = await APISession.patch("/project/$name/removeRole",
        jsonEncode({"role": role, "type": type.name}));

    if (context.mounted) {
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
        APIConstants.showErrorToast(
            'Failed to remove role. Status code: ${response.statusCode}, Error message: ${response.body}',
            context);
      }
    }
  }

  List<String> getMaterials() {
    List<String> materials = [];

    for (var part in parts) {
      String material = part.material;
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

  static Future<Project> loadProject(String key, BuildContext context) async {
    //Make sure keys are updated
    await APISession.updateKeys();

    var response = await APISession.get("/project/$key");

    if (response.statusCode == 404) {
      //Old project doesn't exist - clear it

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString(APIConstants().currentProject, "");

      if (context.mounted) {
        APIConstants.showErrorToast(
            'Old Project No Longer Exists... Resetting to Default.', context);
      }

      return Project.blank();
    }

    var json = jsonDecode(response.body);

    Project proj = Project(
      name: json["name"],
      defaultWorkspace: json["default_workspace"],
      assemblyName: json["assembly_name"],
      assemblyOnshapeId: json["assembly_onshape_id"],
      readRoles: json["read_roles"]?.cast<String>() ?? [],
      writeRoles: json["write_roles"]?.cast<String>() ?? [],
      adminRoles: json["admin_roles"]?.cast<String>() ?? [],
      parts: json["parts"]?.map<Part>((e) => Part.fromJson(e)).toList() ?? [],
      compounds: json["compounds"]
              ?.map<Compound>((e) => Compound.fromJson(e))
              .toList() ??
          [],
      lastSync: DateTime.parse(json["lastSyncDate"]),
    );

    for (var e in proj.compounds) {
      for (var part in e.parts) {
        part.acquireAndAssignPart(proj);
      }
    }

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
