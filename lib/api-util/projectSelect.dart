import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef LoadProjectFunction = void Function(String projectKey);

class ProjectSelect extends StatefulWidget {
  final Project project;
  final LoadProjectFunction loadProject;

  ProjectSelect({super.key, required this.project, required this.loadProject});

  @override
  State<ProjectSelect> createState() => _ProjectSelectState();
}

class _ProjectSelectState extends State<ProjectSelect> {
  final TextEditingController activeProjectController = TextEditingController();
  List<String> projectKeys = [];

  @override
  void initState() {
    super.initState();

    reloadProjectList(true);

    Timer.periodic(const Duration(seconds: 10), (timer) {
      reloadProjectList(true);
    });
  }

  void reloadProjectList(bool shouldLoadProject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String projectKey = prefs.getString(APIConstants().currentProject) ?? "";

    List<String> projectList = await Project.loadProjects();

    if (projectList.isEmpty) {
      projectList = ["NO PROJECT"];
    }

    setState(() {
      projectKeys = projectList;
    });

    if (projectKey == "" && projectKeys.isNotEmpty) {
    } else if (shouldLoadProject) {
      widget.loadProject(projectKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownMenu<String>(
            label: const Text('Active Project'),
            controller: activeProjectController,
            initialSelection: widget.project.name,
            onSelected: (val) {
              widget.loadProject(val ?? "");
            },
            menuStyle: const MenuStyle(
                minimumSize: WidgetStatePropertyAll(Size.fromWidth(200))),
            dropdownMenuEntries: List.generate(
              projectKeys.length,
              (index) => DropdownMenuEntry(
                value: projectKeys[index],
                label: projectKeys[index],
              ),
            )),
      ],
    );
  }
}