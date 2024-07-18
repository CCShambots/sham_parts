import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/util/platform.dart';

class CamMenu extends StatefulWidget {
  final bool camDone;
  final Future<void> Function(bool, BuildContext) camDoneFunc;
  final List<String> camInstructions;
  final Future<void> Function(List<String>, BuildContext) updateCamInstructions;

  const CamMenu(
      {super.key,
      required this.camDone,
      required this.camDoneFunc,
      required this.camInstructions,
      required this.updateCamInstructions});

  @override
  State<CamMenu> createState() => _CamMenuState();
}

class _CamMenuState extends State<CamMenu> {
  bool editing = false;

  final isMobile = PlatformInfo.isMobile();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: widget.camDone,
              onChanged: (newValue) async {
                widget.camDoneFunc(newValue!, context);
              },
            ),
            Text(
              "CAM Done",
              style: StyleConstants.subtitleStyle,
            ),
          ],
        ),
        widget.camDone
            ? Column(
                children: [
                  Text(
                    "Instructions",
                    style: StyleConstants.subtitleStyle,
                  ),
                  ...widget.camInstructions.map((e) {
                    return !editing
                        ? Text(
                            "${widget.camInstructions.indexOf(e) + 1}. $e",
                            style: StyleConstants.h3Style,
                          )
                        : SizedBox(
                            width: 300,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: e,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "New Instruction",
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        widget.camInstructions[widget
                                            .camInstructions
                                            .indexOf(e)] = value;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                    tooltip: "Remove Instruction",
                                    onPressed: () {
                                      setState(() {
                                        widget.camInstructions.remove(e);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove,
                                      color: Colors.red,
                                    ))
                              ],
                            ),
                          );
                  }),
                  editing
                      ? Row(
                          children: [
                            IconButton(
                                tooltip: "Add Instruction",
                                onPressed: () {
                                  setState(() {
                                    widget.camInstructions.add("");
                                  });
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.green,
                                )),
                            IconButton(
                                tooltip: "Save Edit",
                                onPressed: () async {
                                  await widget.updateCamInstructions(
                                      widget.camInstructions, context);
                                  setState(() {
                                    editing = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.save,
                                  color: Colors.blue,
                                )),
                            IconButton(
                                tooltip: "Cancel Edit",
                                onPressed: () {
                                  setState(() {
                                    editing = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                )),
                          ],
                        )
                      : (!isMobile) ? IconButton(
                          tooltip: "Edit Cam Instructions",
                          onPressed: () {
                            setState(() {
                              editing = true;
                            });
                          },
                          icon: const Icon(Icons.edit)) : Container()
                ],
              )
            : Container(),
      ],
    );
  }
}
