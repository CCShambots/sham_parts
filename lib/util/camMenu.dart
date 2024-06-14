import 'package:flutter/material.dart';
import 'package:sham_parts/constants.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
                  ...widget.camInstructions.map((e) {
                    return Text(
                      e,
                      style: StyleConstants.subtitleStyle,
                    );
                  }),
                  editing
                      ? Row(
                          children: [
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
                      : IconButton(
                          tooltip: "Edit Cam Instructions",
                          onPressed: () {
                            setState(() {
                              editing = true;
                            });
                          },
                          icon: const Icon(Icons.edit))
                ],
              )
            : Container(),
      ],
    );
  }
}
