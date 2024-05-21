import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/account-pages/adminPanel.dart';
import 'package:sham_parts/account-pages/serverSelect.dart';
import 'package:sham_parts/account-pages/signIn.dart';
import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/api-util/projectSelect.dart';
import 'package:sham_parts/api-util/server.dart';
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api-util/user.dart';

class SettingsPage extends StatefulWidget {
  User? user;
  Project project;
  bool appbar;
  var loadProject;

  SettingsPage({super.key, required this.user, required this.project, this.appbar = false, required this.loadProject});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late User? user;

  List<String> roles = [];

  bool changingName = false;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    user = widget.user;

    changingName = false;

    loadRoles();
    loadUser();
  }

  void loadRoles() async {
    List<String> loaded = await User.getRoles();

    setState(() {
      roles = loaded;
    });
  }

  void changeName() async {
    if (user != null) {
      User newUser = await user!.changeName(nameController.text, context);

      setState(() {
        user = newUser;

        nameController.text = newUser.name;
        changingName = false;
      });
    }
  }

  void loadUser() async {
    User? newUser = await User.getUserFromPrefs();

    

    if (newUser != null) {
      setState(() {
        user = newUser;
        nameController.text = user?.name ?? "";
      });
    } else {
      setState(() {
        user = User.blank();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  final isMobile = Platform.isAndroid || Platform.isIOS;


    return user != null && user?.email != ""
        ? Scaffold(
           appBar: widget.appbar
            ? AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: const Text("Settings"))
            : null,
            body: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !changingName
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          user!.name,
                          style: StyleConstants.titleStyle,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              changingName = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          tooltip: "Change Name",
                        )
                      ])
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'New Name'),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              changeName();
                            },
                            icon: const Icon(Icons.save, color: Colors.green),
                            tooltip: "Save",
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                changingName = false;
                              });
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            tooltip: "Cancel",
                          )
                        ],
                      ),
                Text(
                  user!.email,
                  style: StyleConstants.h3Style,
                ),
                Text(
                  "Roles: ${user?.rolesListToString()}",
                  style: StyleConstants.subtitleStyle,
                ),
                user?.roles.contains("admin") ?? false
                    ? TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AdminPanel(
                                    user: user,
                                  )));
                        },
                        child: Text(
                          "Open Admin Panel",
                          style: StyleConstants.subtitleStyle,
                        ))
                    : Container(),
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove(APIConstants().userToken);
              
                    setState(() {
                      user = null;
                    });
                  },
                  child: Text(
                    "Logout",
                    style: StyleConstants.subtitleStyle,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ProjectSelect(project: widget.project, loadProject: widget.loadProject),
                const SizedBox(
                  height: 20,
                ),
                (user?.roles.contains("admin") ?? false) && !isMobile
                    ? Column(children: [
                        Text("Project Management",
                            style: !isMobile ? StyleConstants.titleStyle : StyleConstants.subtitleStyle,
                            textAlign: TextAlign.center,),
                        Text("Current Project: ${widget.project.name}",
                            style: StyleConstants.h3Style),
                        roleEditor(RoleType.read, context),
                        roleEditor(RoleType.write, context),
                        roleEditor(RoleType.admin, context)
                      ])
                    : Container(),
                    const ServerSelect()
              ],
                        ),
            ))
        : SignInWidget( appbar: widget.appbar, setUser: (User newUser) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();

            if (newUser.token.isNotEmpty) {
              prefs.setString(APIConstants().userToken, newUser.token);

              setState(() {
                user = newUser;
              });

              APISession.updateKeys();
            } else {
              APIConstants.showErrorToast("Missing Account Token!", context);
            }
          });
  }

  Row roleEditor(RoleType type, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: "Roles that can view the project",
          child: Text(Project.roleTypeToString(type),
              style: StyleConstants.h3Style),
        ),
        const SizedBox(
          width: 10,
        ),
        Row(
          children: widget.project
              .getListFromType(type)
              .map((e) => Role(
                  name: e,
                  removeSelf: () => {
                        widget.project
                            .removeRole(e, type, context)
                            .then((value) => setState(() {}))
                      }))
              .toList(),
        ),
        const SizedBox(
          width: 20,
        ),
        const Text("Add role:"),
        const SizedBox(
          width: 20,
        ),
        DropdownButton<String>(
          value: null,
          onChanged: (String? newValue) {
            if (newValue != null) {
              widget.project
                  .addRole(newValue, type, context)
                  .then((e) => setState(() {}));
            }
          },
          items: roles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        )
      ],
    );
  }
}
