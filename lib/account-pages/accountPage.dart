
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sham_parts/account-pages/signIn.dart';
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_util/user.dart';

class AccountPage extends StatefulWidget {

  User? user;

  AccountPage({super.key, required this.user});

  @override
  State<AccountPage> createState() =>
      AccountPageState();

}

class AccountPageState extends State<AccountPage> {
  late User? user;

  @override
  void initState() {
    user = widget.user ?? null;

    loadUser();
  }

  void loadUser() async {
    print("loading user");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString(APIConstants().userToken) ?? "";

    print(token);

    if(token.isNotEmpty) {
      User? newUser = await User.getFromToken(token);

      print(newUser);

      if(newUser != null) {
          setState(() {
            user = newUser;
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return user != null ? Scaffold(
      body: Center(
        child:
          Column(
            children: [
              Text(user!.name, style: StyleConstants.titleStyle,),
              Text(user!.email, style: StyleConstants.subtitleStyle,),
              Text("Roles"),
            ],
          ),
      )
    ) : SignInWidget(setUser: (User newUser) async {

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if(newUser.token.isNotEmpty) {
        prefs.setString(APIConstants().userToken, newUser.token);

        setState(() {
          user = newUser;
        });

      } else {
        APIConstants.showErrorToast("Missing Account Token!", context);
      }

    });
  }

}