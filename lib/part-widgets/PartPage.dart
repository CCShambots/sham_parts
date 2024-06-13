import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/api-util/logEntry.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/constants.dart';

class PartPage extends StatefulWidget {
  final Part part;

  const PartPage({super.key, required this.part});

  @override
  State<PartPage> createState() => _PartPageState();
}

class _PartPageState extends State<PartPage> {
  final isMobile = Platform.isAndroid || Platform.isIOS;

  int userIndex = 0;
  late List<User> users = [];

  bool editingDimensions = false;

  TextEditingController d1Controller = TextEditingController();
  TextEditingController d2Controller = TextEditingController();
  TextEditingController d3Controller = TextEditingController();

  List<String> partTypes = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadPartTypes();

    setState(() {
      d1Controller.text = widget.part.dimension1;
      d2Controller.text = widget.part.dimension2;
      d3Controller.text = widget.part.dimension3;
    });
  }

  void loadPartTypes() async {
    List<String> types = await Part.getPartTypes();

    setState(() {
      partTypes = types;
    });
  }

  void loadUsers() async {
    List<User> result = await User.getAllUsers();

    int selected =
        result.indexWhere((element) => element.name == widget.part.asigneeName);

    setState(() {
      users = result;

      userIndex = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.part.number),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //This row centers the whole shabang
              const Row(),
              !isMobile
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PartImage(),
                        PartDetails(context, isMobile),
                      ],
                    )
                  : Column(
                      children: [
                        PartImage(),
                        PartDetails(context, isMobile),
                      ],
                    ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Tooltip(
                      message: "Report Break",
                      child: IconButton(
                          onPressed: () {
                            widget.part.reportBreak(context);
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.broken_image,
                            color: Colors.red,
                            size: 48,
                          ))),
                  Tooltip(
                      message: "Request Additional",
                      child: IconButton(
                          onPressed: () async {
                            await widget.part.requestPart(context);
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.shopping_cart,
                            color: Colors.green,
                            size: 48,
                          ))),
                  Tooltip(
                      message: "Fulfill 1 Part",
                      child: IconButton(
                          onPressed: () async {
                            await widget.part.fulfillRequest(context);
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.check,
                            color: Colors.blue,
                            size: 48,
                          ))),
                  Tooltip(
                      message: "Fulfill All Requested",
                      child: IconButton(
                          onPressed: () async {
                            await widget.part.fulfillRequest(context,
                                quantity: widget.part.quantityRequested);
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.done_all,
                            color: Colors.blue,
                            size: 48,
                          ))),
                ],
              ),
              Text("Part Log", style: StyleConstants.titleStyle),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: StyleConstants.shadedDecoration(context),
                  child: Column(
                    children: widget.part.logEntries
                        .map((e) => LogEntryWidget(logEntry: e))
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Padding PartDetails(BuildContext context, bool mobile) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(widget.part.material, style: StyleConstants.subtitleStyle),
          Text(
            "Part #: ${widget.part.id}",
            style: StyleConstants.subtitleStyle,
          ),
          Text(
            "On Bot: ${min<int>(widget.part.quantityInStock, widget.part.quantityNeeded)} / ${widget.part.quantityNeeded}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: StyleConstants.subtitleStyle.fontSize,
                color: widget.part.quantityInStock >= widget.part.quantityNeeded
                    ? Colors.green
                    : (widget.part.quantityInStock > 0)
                        ? Colors.yellow
                        : Colors.red),
          ),
          Text(
            "Extra: ${max<int>(widget.part.quantityInStock - widget.part.quantityNeeded, 0)}",
            style: StyleConstants.subtitleStyle,
          ),
          Text(
            "Requested: ${widget.part.quantityRequested}",
            style: StyleConstants.subtitleStyle,
          ),
          !isMobile
              ? Row(
                  children: [
                    editingDimensions
                        ? Row(
                            children: [
                              Text(
                                "Dimensions: ",
                                style: StyleConstants.subtitleStyle,
                              ),
                              SizedBox(
                                width: 75,
                                height: 45,
                                child: TextField(
                                  controller: d1Controller,
                                  decoration:
                                      const InputDecoration(hintText: 'D1'),
                                ),
                              ),
                              Text("\" x ",
                                  style: StyleConstants.subtitleStyle),
                              SizedBox(
                                width: 75,
                                height: 45,
                                child: TextField(
                                  controller: d2Controller,
                                  decoration:
                                      const InputDecoration(hintText: 'D2'),
                                ),
                              ),
                              Text("\" x ",
                                  style: StyleConstants.subtitleStyle),
                              SizedBox(
                                width: 75,
                                height: 45,
                                child: TextField(
                                  controller: d3Controller,
                                  decoration:
                                      const InputDecoration(hintText: 'D3'),
                                ),
                              ),
                              Text("\"", style: StyleConstants.subtitleStyle),
                            ],
                          )
                        : Text(
                            "Dimensions: ${widget.part.dimension1}\" x ${widget.part.dimension2}\" x ${widget.part.dimension3}\"",
                            style: StyleConstants.subtitleStyle,
                          ),
                    IconButton(
                        onPressed: () async {
                          if (editingDimensions) {
                            await widget.part.setDimensions(
                                context,
                                d1Controller.text,
                                d2Controller.text,
                                d3Controller.text);
                          }

                          setState(() {
                            editingDimensions = !editingDimensions;
                          });
                        },
                        icon: editingDimensions
                            ? const Icon(Icons.save)
                            : const Icon(Icons.edit)),
                  ],
                )
              : Text(
                  "${widget.part.dimension1}\" x ${widget.part.dimension2}\" x ${widget.part.dimension3}\"",
                  style: StyleConstants.subtitleStyle,
                ),
          widget.part.numCombines > 0
              ? Text("Combined with ${widget.part.numCombines} other parts",
                  style: StyleConstants.subtitleStyle)
              : const SizedBox(),
          const SizedBox(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Part Type:", style: StyleConstants.subtitleStyle),
              ),
              DropdownButton<String>(
                value: widget.part.partType,
                onChanged: (newValue) async {
                  await widget.part.setPartType(context, newValue!);
                  setState(() {});
                },
                items: partTypes.map<DropdownMenuItem<String>>((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                hint: const Text("Select Part Type"),
              ),
            ],
          ),
          users.isEmpty
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Assign${widget.part.asigneeName != "" ? "ed" : ""} To: ",
                      style: StyleConstants.subtitleStyle,
                    ),
                    DropdownButton<User>(
                      value: userIndex != -1 ? users[userIndex] : null,
                      onChanged: (newValue) async {
                        if (newValue != null) {
                          await widget.part.assignUser(context, newValue);

                          setState(() {
                            userIndex = users.indexWhere(
                                (element) => element.email == newValue.email);
                          });
                        } else {
                          //This means the user selected "None"
                          await widget.part.unassignUser(context);
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
                )
        ],
      ),
    );
  }

  GFImageOverlay PartImage() {
    return GFImageOverlay(
      height: isMobile ? 200 : 400,
      width: isMobile ? 200 : 400,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      image: APISession.getOnshapeImage(widget.part.thumbnail),
    );
  }
}
