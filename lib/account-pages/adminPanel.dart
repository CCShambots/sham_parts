import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sham_parts/constants.dart';

import '../api_util/user.dart';

class AdminPanel extends StatefulWidget {
  AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => AdminPanelState();
}

class AdminPanelState extends State<AdminPanel> {
  List<User> users = [];
  List<String> roles = [];

  @override
  void initState() {
    loadUsers();
  }

  void loadUsers() async {
    List<User> newUsers = await User.getAllUsers();

    List<String> roles = await User.getRoles();

    setState(() {
      users = newUsers;

      this.roles = roles;
    });

    print(newUsers);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 250,
      child: ListView(
          children: users
              .map((e) => UserAdminView(
                    user: e,
                    repullUsers: () {
                      loadUsers();
                    },
                    roles: roles,
                  ))
              .toList()),
    );
    // shrinkWrap: true,
  }
}

class UserAdminView extends StatefulWidget {
  var repullUsers;
  User user;
  List<String> roles;

  UserAdminView(
      {super.key,
      required this.repullUsers,
      required this.user,
      required this.roles});

  @override
  State<UserAdminView> createState() => UserAdminViewState();
}

class UserAdminViewState extends State<UserAdminView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Text(widget.user.name, style: StyleConstants.titleStyle),
          MultiSelectDialogField(
            items: widget.roles.map((e) => MultiSelectItem(e, e)).toList(),
            listType: MultiSelectListType.CHIP,
            onConfirm: (values) {
              // widget.user
            },
          ),
        ],
      ),
    );
  }
}
