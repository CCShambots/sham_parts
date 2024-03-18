
import 'dart:convert';

import 'package:sham_parts/api_util/part.dart';
import 'package:sham_parts/api_util/apiSession.dart';
import 'package:sham_parts/api_util/assembly.dart';

class Project {
  String name;
  String default_workspace;

  Assembly mainAssembly;
  List<Part> individualParts;

  Project({
    required this.name,
    required this.default_workspace,
    required this.mainAssembly,
    required this.individualParts
  });

  static blank() {
    return Project(
        name: "NO PROJECT",
        default_workspace: "",
        mainAssembly: Assembly(
            name: "",
            onshape_id: "",
            parts: []),
        individualParts: []
    );
  }

  static Future<Project> loadProject(String key) async {
    var response = await APISession.get("/project/key");

    var json = jsonDecode(response.body);

    return Project(
        name: json.name,
        default_workspace: json.default_workspace,
        mainAssembly: Assembly.fromJson(json.main_assembly),
        individualParts: json.individual_parts.map((e) => Part.fromJson(e))
    );
  }
  
  static Future<List<String>> loadProjects() async {
    return List<String>.from(jsonDecode((await APISession.get("/project/list")).body));
  }
}