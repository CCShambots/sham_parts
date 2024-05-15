import 'package:flutter/material.dart';
import 'package:sham_parts/account-pages/adminPanel.dart';
import 'package:sham_parts/account-pages/signIn.dart';
import 'package:sham_parts/api_util/apiSession.dart';
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_util/user.dart';

class AccountPage extends StatefulWidget {
  User? user;

  AccountPage({super.key, required this.user});

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  late User? user;

  bool changingName = false;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    user = widget.user;

    changingName = false;

    loadUser();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return user != null
        ? Scaffold(
            body: Center(
            child: Column(
              children: [
                !changingName
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                    user: widget.user,
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
                )
              ],
            ),
          ))
        : SignInWidget(setUser: (User newUser) async {
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
}
