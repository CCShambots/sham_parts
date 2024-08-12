import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sham_parts/constants.dart';

import '../api-util/user.dart';

class AdminPanel extends StatefulWidget {
  final User? user;

  const AdminPanel({super.key, required this.user});

  @override
  State<AdminPanel> createState() => AdminPanelState();
}

class AdminPanelState extends State<AdminPanel> {
  List<User> users = [];
  List<String> roles = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    List<User> newUsers = await User.getAllUsers();

    List<String> roles = await User.getRoles();

    newUsers.sort((a, b) {
      //If name matches the user's name, put it at the top, otherwise sort alphabetically by name
      if (a.name == (widget.user?.name ?? "name not found")) {
        return -1;
      } else if (b.name == (widget.user?.name ?? "name not found")) {
        return 1;
      } else {
        return a.name.compareTo(b.name);
      }
    });

    setState(() {
      users = newUsers;

      this.roles = roles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reload users",
            onPressed: () {
              loadUsers();
            },
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
            children: users
                .map((e) => UserAdminView(
                      //Check if the user name matches this name and pass you if true
                      you: e.name == (widget.user?.name ?? "name not found"),
                      user: e,
                      repullUsers: () {
                        loadUsers();
                      },
                      roles: roles,
                    ))
                .toList()),
      ),
    );
  }
}

class UserAdminView extends StatefulWidget {
  var repullUsers;
  User user;
  List<String> roles;
  bool you;

  UserAdminView(
      {super.key,
      required this.repullUsers,
      required this.user,
      required this.roles,
      required this.you});

  @override
  State<UserAdminView> createState() => UserAdminViewState();
}

class UserAdminViewState extends State<UserAdminView> {
  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: !widget.you ? StyleConstants.shadedDecoration(context) : StyleConstants.alternateShadedDecoration(context),
        margin: StyleConstants.margin,
        padding: const EdgeInsets.all(8),
        height: 75,
        width: MediaQuery.of(context).size.width - 32,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            !isMobile ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                deleteUser(context),
                verifiedMethod(),
                const Padding(padding: EdgeInsets.only(left: 8)),
                UserName(),
                const SizedBox(width: 8),
                widget.you
                    ? Text("(you)", style: StyleConstants.h3Style)
                    : Container(),
              ],
            ) : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                UserName(),
            ],),

            !isMobile ? Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.user.roles
                  .map((e) => Role(
                        name: e,
                        removeSelf: () async {
                          await widget.user.removeRole(e, context);
                          widget.repullUsers();
                        },
                      ))
                  .toList(),
            ) : Tooltip(
              message: "Roles: ${widget.user.roles.join(", ")}",
              child: Text("Roles", style: StyleConstants.subtitleStyle),
            ),

            //Add role button
            PopupMenuButton<String>(
              onSelected: (String value) async {

                if(!isMobile) {
                  await widget.user.addRole(value, context);
                } else {
                  if(widget.user.roles.contains(value)) {
                    await widget.user.removeRole(value, context);
                  } else {
                    await widget.user.addRole(value, context);
                  }
                }

                widget.repullUsers();
              },
              itemBuilder: (BuildContext context) {
                return widget.roles
                    .map((e) => PopupMenuItem<String>(
                          value: e,
                          child: Text((!isMobile ? "" : (widget.user.roles.contains(e) ? "- " : "+ ")) + e,
                            style: TextStyle(
                              color: !isMobile ? null : (widget.user.roles.contains(e) ? Colors.red : Colors.green)
                            ),
                          ),
                        ))
                    .toList();
              },
              tooltip: !isMobile ? "Add New Role" : "Add/Remove Roles",
              child: !isMobile ? const Icon(
                Icons.add_circle_outline,
                color: Colors.green,
                size: 35,
              ) : const Icon(
                Icons.edit,
                color: Colors.yellow,
                size: 35,
              ),
            )
          ],
        ),
      ),
    );
  }

  Tooltip UserName() {
    return Tooltip(
                  message: "Email: ${widget.user.email}",
                  child: Text(widget.user.name,
                      style: StyleConstants.subtitleStyle));
  }

  Tooltip verifiedMethod() {
    return Tooltip(
                message: widget.user.verified ? "Verified" : "Not Verified",
                child: Icon(
                  widget.user.verified
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: widget.user.verified ? Colors.green : Colors.red,
                  size: 35,
                ),
              );
  }

  IconButton deleteUser(BuildContext context) {
    return IconButton(
                  tooltip: "Delete User",
                  onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete User"),
                            content: const Text("Are you sure you want to delete this user?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Delete"),
                                onPressed: () async {
                                  // Perform the delete operation here
                                  await widget.user.deleteUser(context);
                                  // Call the delete user function and pass the user object
                                  // Then call loadUsers() to refresh the user list
                                  await widget.repullUsers();
                                  if(context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                  },
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 35,
                  ));
  }
}

class Role extends StatefulWidget {
  final dynamic removeSelf;
  final String name;

  const Role({super.key, required this.removeSelf, required this.name});

  @override
  State<Role> createState() => _RoleState();
}

class _RoleState extends State<Role> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        height: 36,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            color:
                Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
            border: Border.all(
                color: Theme.of(context).colorScheme.inverseSurface)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.name,
              style: const TextStyle(
                height: 1,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: Tooltip(
                message: "Remove Role",
                child: GestureDetector(
                  onTap: () {
                    widget.removeSelf();
                  },
                  child: const Icon(
                    Icons.remove_circle_outline,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
