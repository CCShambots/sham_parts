import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/compound-widgets/CompoundPage.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/part-widgets/CompoundListSelected.dart';
import 'package:sham_parts/part-widgets/CompoundListUnselected.dart';

class CompoundCreationMenu extends StatefulWidget {
  final Project project;

  const CompoundCreationMenu({super.key, required this.project});

  @override
  State<CompoundCreationMenu> createState() => _CompoundCreationMenuState();
}

class _CompoundCreationMenuState extends State<CompoundCreationMenu> {
  List<CompoundPart> selectedParts = [];
  TextEditingController textController = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController thicknessController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Part> filteredParts = widget.project.parts
        .where((e) => !selectedParts.map((e) => e.partId).contains(e.id))
        .where((e) =>
            e.material ==
            (selectedParts.firstOrNull?.part.material ?? e.material))
        .where((e) => e.number.contains(textController.text))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Create Compound"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(onPressed:
      () async {

        if(nameController.text.isEmpty) {
          APIConstants.showErrorToast("Compound Name cannot be empty", context);
        } else if(widget.project.compounds.where((e) => e.name == nameController.text).isNotEmpty) {
          APIConstants.showErrorToast("Compound Name already exists", context);
        } else if(selectedParts.isEmpty) {
          APIConstants.showErrorToast("Compounds must have at least one part", context);
        } else {
          Compound compound = Compound(
            id: 0,
            name: nameController.text,
            parts: selectedParts,
            material: selectedParts.first.part.material,
            thickness: thicknessController.text, 
            camDone: false,
            camInstructions: [],
            asigneeId: -1,
            asigneeName: "",
            logEntries: [],
            thumbnail: ""
          );
          Compound? generatedCompound = await compound.saveToDatabase(widget.project, context);
          if(generatedCompound != null) {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompoundPage(compound: compound),
              ),
            );
          }
        }  
      },
      tooltip: "Save to Database", child: const Icon(Icons.save),),
      body: Row(
        children: [
          Expanded(
              child: Column(
            children: [
              SizedBox(
                height: 92,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: OutlineInputBorder(),
                      ),
                      controller: textController,
                      onChanged: (String? val) {
                        setState(() {});
                      },
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('${filteredParts.length} Parts Shown',
                        style: StyleConstants.h3Style),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
              Expanded(
                  child: ListView(
                children: filteredParts
                    .map((e) => CompoundListUnselected(
                          part: e,
                          addToSelected: () {
                            setState(() {
                              CompoundPart part = CompoundPart(
                                  id: 0,
                                  partId: e.id,
                                  quantity: e.quantityNeeded);
                              part.acquireAndAssignPart(widget.project);
                              if(selectedParts.isEmpty) {
                                thicknessController.text = e.dimension1.toString();
                              }

                              selectedParts.add(part);
                            });
                          },
                        ))
                    .toList(),
              )),
            ],
          )),
          Expanded(
              child: Column(
            children: [
              SizedBox(
                height: 92,
                child: Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText:
                                'Name (Typically something like A-xx00 Compound 1)',
                            border: const OutlineInputBorder(),
                            errorText: widget.project.compounds
                                    .where((e) => e.name == nameController.text)
                                    .isNotEmpty
                                ? "Name Already Exists"
                                : (nameController.text.isEmpty
                                    ? "Name Cannot Be Empty"
                                    : null),
                          ),
                          controller: nameController,
                          onChanged: (String? val) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Thickness',
                            errorText: thicknessController.text.isEmpty
                                ? "Thickness Cannot Be Empty"
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                          controller: thicknessController,
                          onChanged: (String? val) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: ListView(
                children: selectedParts
                    .map((e) => CompoundListSelected(
                          compoundPart: e,
                          removeFromSelected: () {
                            setState(() {
                              selectedParts.remove(e);
                            });
                          },
                        ))
                    .toList(),
              ))
            ],
          )),
        ],
      ),
    );
  }
}
