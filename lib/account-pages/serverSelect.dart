import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/api-util/server.dart';
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerSelect extends StatefulWidget {
  final Function logOut;
  const ServerSelect({super.key, required this.logOut});

  @override
  State<ServerSelect> createState() => _ServerSelectState();
}

class _ServerSelectState extends State<ServerSelect> {
  List<Server> servers = [];
  String activeServer = "";

  TextEditingController addServerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadServers();
  }

  Future<void> loadServers() async {

    List<Server> loaded = await Server.getServersFromKeys();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String serverKey =
        prefs.getString(APIConstants().serverKey) ?? APIConstants().baseUrl;

    setState(() {
      servers = loaded;
      activeServer = serverKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Servers", style: StyleConstants.subtitleStyle),
          IconButton(
            tooltip: "Add new server",
            onPressed: () {
                 addServerDialog(context);

          }, icon: const Icon(Icons.add, color: Colors.green))
        ],
      ),
      ...servers.map((e) => ServerWidget(
            server: e,
            isActive: e.key == activeServer,
            setParentState: () async {
              await loadServers();
              widget.logOut();
              setState(() {});
            },
          )),
    ]);
  }

  Future<dynamic> addServerDialog(BuildContext context) {
    return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                   title: const Text('Add New Server'),
                   content: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Server Key',
                    ),
                    onChanged: (value) {
                        addServerController.text = value.toUpperCase();
                    },
                    controller: addServerController,
                   ),
                   actions: [
                    TextButton(
                      onPressed: () {
                       Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await Server.addServer(addServerController.text);
                        
                        await loadServers();
                        
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                   ],
                  );
                },
               );
  }
}

class ServerWidget extends StatefulWidget {
  final Server server;
  final bool isActive;
  final setParentState;
  const ServerWidget(
      {super.key,
      required this.server,
      required this.isActive,
      required this.setParentState});

  @override
  State<ServerWidget> createState() => _ServerWidgetState();
}

class _ServerWidgetState extends State<ServerWidget> {
  bool alive = false;

  @override
  void initState() {
    super.initState();

    checkServer();
  }

  Future<void> checkServer() async {
    bool aliveValue = await APISession.ping(widget.server.ip);

    setState(() {
      alive = aliveValue;
    });
  }

  void setActiveServer(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await checkServer();

    if(!alive) {
      if(context.mounted) {
        APIConstants.showErrorToast("Server is not connected", context);
      }
      return;
    }

    prefs.setString(APIConstants().serverKey, widget.server.ip);

    setState(() {});
    widget.setParentState();

    APISession.updateKeys();

    APIConstants.showSuccessToast("Set new API to: ${widget.server.name}", context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;


    return Container(
      decoration: widget.isActive ? StyleConstants.alternateShadedDecoration(context) : StyleConstants.shadedDecoration(context),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: !isMobile ? [
          StatusIcon(),
          Name(isMobile),
          IP(),
          SelectButton(context)
        ] : [
          StatusIcon(),
          Name(isMobile),
          SelectButton(context)
        ],
      ),
    );
  }

  ElevatedButton SelectButton(BuildContext context) {
    return ElevatedButton(
            onPressed: () {setActiveServer(context);}, child: const Text("Select"));
  }

  Text IP() => Text(widget.server.ip);

  Tooltip Name(bool isMobile) {
    return Tooltip(
          message: widget.isActive ? "Active" : "Not active",
          child: 
          Text("${widget.server.name} ${widget.isActive && !isMobile ? '(Active)' : ''}"),
        );
  }

  IconButton StatusIcon() {
    return IconButton(
            onPressed: () {
              checkServer();
            },
            tooltip: "Check server status",
            icon: alive ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.close, color: Colors.red)
        );
  }
}
