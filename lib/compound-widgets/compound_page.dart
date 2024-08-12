import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sham_parts/api-util/compound.dart';
import 'package:sham_parts/api-util/log_entry.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/compound-widgets/compound_creation_menu.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/part-widgets/part_page.dart';
import 'package:sham_parts/util/cam_menu.dart';

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

  bool hasThumbnail = false;
  bool imageValid = true;
  Image? image;

  bool editingDimensions = false;
  bool inches = true;

  @override
  void initState() {
    super.initState();
    loadUsers();

    setState(() {
      inches = true;
    });

    loadThumbnail();
  }

  void loadThumbnail() async {
    bool thumbnail = await widget.compound.loadThumbnail();

    setState(() {
      hasThumbnail = thumbnail;
    });

    if (thumbnail) {
      if (hasThumbnail) {
        try {
          setState(() {
            image = Image.memory(base64Decode(widget.compound.thumbnail));
          });
        } catch (e) {
          setState(() {
            imageValid = false;
          });
        }
      }
    }
  }

  void loadUsers() async {
    List<User> result = await User.getUsersOfProject();

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
                    compoundImage(),
                    compoundDetails(context, isMobile),
                  ],
                )
              : Column(
                  children: [
                    compoundImage(),
                    compoundDetails(context, isMobile),
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

  Widget compoundDetails(BuildContext context, bool mobile) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CompoundDimension(
                      editing: editingDimensions,
                      label: "X Dimension",
                      inches: inches,
                      value: widget.compound.xDimension,
                      setValue: (value) {
                        widget.compound.xDimension = value;
                        setState(() {});
                      }),
                  CompoundDimension(
                      editing: editingDimensions,
                      label: "Y Dimension",
                      inches: inches,
                      value: widget.compound.yDimension,
                      setValue: (value) {
                        widget.compound.yDimension = value;
                        setState(() {});
                      }),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            inches = true;
                          });
                        },
                        icon: Icon(inches
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked)),
                    Text("In.", style: StyleConstants.h3Style),
                  ]),
                  Row(children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            inches = false;
                          });
                        },
                        icon: Icon(!inches
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked)),
                    Text("mm", style: StyleConstants.h3Style)
                  ])
                ],
              ),
              !editingDimensions
                  ? IconButton(
                      tooltip: "Edit Dimensions",
                      onPressed: () {
                        setState(() {
                          editingDimensions = true;
                        });
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.yellow,
                        size: 36,
                      ))
                  : IconButton(
                      tooltip: "Save Changes",
                      onPressed: () {
                        setState(() {
                          editingDimensions = false;
                        });
                        widget.compound.setDimensions(context);
                      },
                      icon: const Icon(
                        Icons.save,
                        color: Colors.blue,
                        size: 36,
                      )),
            ],
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
            updateCamInstructions:
                (List<String> instructions, BuildContext context) async {
              await widget.compound
                  .updateCamInstructions(instructions, context);
              setState(() {});
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: !isMobile
                ? [
                    fulfillCompound(context),
                    editCompound(context),
                    deleteCompound(context),
                  ]
                : [fulfillCompound(context), deleteCompound(context)],
          )
        ],
      ),
    );
  }

  IconButton deleteCompound(BuildContext context) {
    return IconButton(
        tooltip: "Delete forever",
        onPressed: () {
          showDeleteDialog(context);
        },
        icon: const Icon(
          Icons.delete_forever,
          color: Colors.red,
          size: 48,
        ));
  }

  IconButton editCompound(BuildContext context) {
    return IconButton(
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
        ));
  }

  IconButton fulfillCompound(BuildContext context) {
    return IconButton(
        tooltip: "Fulfill Compound",
        onPressed: () {
          widget.compound.fulfill(context);
          setState(() {});
        },
        icon: const Icon(
          Icons.check,
          color: Colors.blue,
          size: 48,
        ));
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

  Widget compoundImage() {
    return Column(
      children: [
        hasThumbnail && imageValid
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
                              // ignore: use_build_context_synchronously
                              .uploadImage(file.readAsBytesSync(), context);

                        setState(() {});
                      } else {
                        // User canceled the picker
                      }
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text("Add New Image"),
                  ),
                ],
              )
            : Container()
      ],
    );
  }
}

class CompoundDimension extends StatefulWidget {
  const CompoundDimension(
      {super.key,
      required this.editing,
      required this.label,
      required this.value,
      required this.inches,
      required this.setValue});

  final bool editing;
  final String label;
  final String value;
  final bool inches;
  final Function(String) setValue;

  @override
  State<CompoundDimension> createState() => _CompoundDimensionState();
}

class _CompoundDimensionState extends State<CompoundDimension> {
  TextEditingController controller = TextEditingController();

  bool prevInches = false;

  @override
  void initState() {
    super.initState();

    prevInches = widget.inches;

    setState(() {
      controller.text = widget.value;
    });
  }

  String convertFromIn() {
    String newValue = controller.text;

    return (double.parse(newValue) * 25.4).toString();
  }

  String convertFromMM() {
    String newValue = controller.text;

    return (double.parse(newValue) / 25.4).toString();
  }

  void _handleValueChange(String value) {
    try {
      controller.text = value; // Directly setting the controller's text

      if (!widget.inches) {
        widget.setValue(convertFromMM());
      } else {
        widget.setValue(value);
      }
    } catch (e) {
      // Handle error or do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.inches && !prevInches) {
      setState(() {
        controller.text = convertFromMM();
      });
    } else if (!widget.inches && prevInches) {
      setState(() {
        controller.text = convertFromIn();
      });
    }

    prevInches = widget.inches;

    return !widget.editing
        ? Text(
            "${widget.label}: ${widget.inches ? widget.value : (double.parse(widget.value) * 25.4)}${widget.inches ? "\"" : " mm"}",
            style: StyleConstants.subtitleStyle)
        : Row(
            children: [
              Text("${widget.label}: ", style: StyleConstants.subtitleStyle),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _handleValueChange,
                ),
              ),
            ],
          );
  }
}
