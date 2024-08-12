import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/compound-widgets/compound_creation_menu.dart';
import 'package:sham_parts/compound-widgets/compound_list_display.dart';

class CompoundsPage extends StatefulWidget {
  final Project project;

  const CompoundsPage({super.key, required this.project});

  @override
  State<CompoundsPage> createState() => _CompoundsPageState();
}

class _CompoundsPageState extends State<CompoundsPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return Scaffold(
      body: 
      ListView(
        children: widget.project.compounds.map((compound) => 
          CompoundListDisplay(compound: compound, project: widget.project,)
        ).toList()
      ),
      floatingActionButton: !isMobile ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompoundCreationMenu(project: widget.project,),
            ),
          );
        },
        child: const Icon(Icons.add),
      ) : null,

    );
  }
}