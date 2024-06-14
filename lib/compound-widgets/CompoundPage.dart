import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/logEntry.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/compound-widgets/CompoundCreationMenu.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/part-widgets/PartPage.dart';
import 'package:sham_parts/util/camMenu.dart';

class CompoundPage extends StatefulWidget {
  final Project project;
  final Compound compound;

  const CompoundPage(
      {super.key, required this.compound, required this.project});

  @override
  State<CompoundPage> createState() => _CompoundPageState();
}

class _CompoundPageState extends State<CompoundPage> {
  final isMobile = Platform.isAndroid || Platform.isIOS;

  int userIndex = 0;
  late List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    List<User> result = await User.getAllUsers();

    int selected = result
        .indexWhere((element) => element.name == widget.compound.asigneeName);

    setState(() {
      users = result;

      userIndex = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.compound.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          //Centers stuff
          const Row(),
          !isMobile
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CompoundImage(),
                    CompoundDetails(context, isMobile),
                  ],
                )
              : Column(
                  children: [
                    CompoundImage(),
                    CompoundDetails(context, isMobile),
                  ],
                ),
          Text("Compound Log", style: StyleConstants.titleStyle),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: StyleConstants.shadedDecoration(context),
              child: Column(
                children: widget.compound.logEntries
                    .map((e) => LogEntryWidget(logEntry: e))
                    .toList(),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget CompoundDetails(BuildContext context, bool mobile) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(widget.compound.material, style: StyleConstants.subtitleStyle),
          Text(
            "Compound #: ${widget.compound.id}",
            style: StyleConstants.subtitleStyle,
          ),
          Text("Thickness: ${widget.compound.thickness}\"",
              style: StyleConstants.subtitleStyle),
          const SizedBox(
            height: 24,
          ),
          Text(
            "Parts",
            style: StyleConstants.subtitleStyle,
          ),
          ...widget.compound.parts.map((e) {
            return GestureDetector(
              onTap: () {
                // Navigate to part page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartPage(part: e.part),
                  ),
                );
              },
              child: Container(
                decoration: StyleConstants.shadedDecoration(context),
                padding: StyleConstants.padding,
                margin: StyleConstants.margin,
                child: Text(
                  e.toString(),
                  style: StyleConstants.h3Style,
                ),
              ),
            );
          }),
          const SizedBox(
            height: 24,
          ),
          users.isEmpty
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Assign${widget.compound.asigneeName != "" ? "ed" : ""} To: ",
                      style: StyleConstants.subtitleStyle,
                    ),
                    DropdownButton<User>(
                      value: userIndex != -1 ? users[userIndex] : null,
                      onChanged: (newValue) async {
                        if (newValue != null) {
                          await widget.compound.assignUser(context, newValue);

                          setState(() {
                            userIndex = users.indexWhere(
                                (element) => element.email == newValue.email);
                          });
                        } else {
                          //This means the user selected "None"
                          await widget.compound.unassignUser(context);
                          setState(() {
                            userIndex = -1;
                          });
                        }
                      },
                      items: [
                        const DropdownMenuItem<User>(
                          value: null,
                          child: Text("None"),
                        ),
                        ...users.map<DropdownMenuItem<User>>((User user) {
                          return DropdownMenuItem<User>(
                            value: user,
                            child: Text(user.name),
                          );
                        }),
                      ],
                      hint: userIndex != -1
                          ? Text(users[userIndex].name)
                          : const Text("None"),
                    ),
                  ],
                ),
          CamMenu(
              camDone: widget.compound.camDone,
              camDoneFunc: (bool done, BuildContext context) async {
                await widget.compound.setCamDone(done, context);
                setState(() {});
              },
              camInstructions: widget.compound.camInstructions,
              updateCamInstructions: (List<String> instructions, BuildContext context) async {
                await widget.compound.updateCamInstructions(instructions, context);
                setState(() {});
              } 
              ,
          ),
          Row(
            children: [
              IconButton(
                  tooltip: "Fulfill Compound",
                  onPressed: () {
                    widget.compound.fulfill(context);
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 48,
                  )),
              IconButton(
                  tooltip: "Edit Parts in Compound",
                  onPressed: () {
                    // Navigate to part page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompoundCreationMenu(
                          project: widget.project,
                          compound: widget.compound,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.yellow,
                    size: 48,
                  )),
              IconButton(
                  tooltip: "Delete forever",
                  onPressed: () {
                    showDeleteDialog(context);
                  },
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 48,
                  )),
            ],
          )
        ],
      ),
    );
  }

  Future<dynamic> showDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this compound?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                widget.compound.deleteFromDatabase(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget CompoundImage() {
    bool imageValid = true;
    Image? image;

    try {
      image = Image.memory(base64Decode(widget.compound.thumbnail));
    } catch (e) {
      imageValid = false;
    }

    return Column(
      children: [
        imageValid
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(image: image!.image))
            : Container(),
        !isMobile
            ? Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                              allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp']);

                      if (result != null) {
                        File file = File(result.files.single.path!);

                        widget.compound
                            .uploadImage(file.readAsBytesSync(), context);

                        setState(() {});
                      } else {
                        // User canceled the picker
                      }
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text("Add New Image"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final imageBytes = await Pasteboard.image;

                      if (imageBytes != null) {
                        widget.compound.uploadImage(imageBytes, context);
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.paste),
                    label: const Text("Upload from Clipboard"),
                  ),
                ],
              )
            : Container()
      ],
    );
  }
}
