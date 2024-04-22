
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:sham_parts/api_util/apiSession.dart';
import 'package:sham_parts/constants.dart';

class User {
  String name;
  String email;
  String token;
  bool verified;

  List<String> roles;

  User({required this.name, required this.email, required this.verified, required this.roles, required this.token});

  static User fromJson(json) {
    return User(
      name: json["name"],
      email: json["email"],
      verified: json["verified"],
      token: json["randomToken"] ?? "",
      roles: json["roles"].cast<String>()
    );
  }

  String rolesListToString() {
    String rolesString = "";

    for(int i = 0; i<roles.length; i++) {
      rolesString += roles[i];
      if(i != roles.length-1) rolesString += ",";
    }

    return rolesString;
  }

  Future<User> changeName(String newName, BuildContext context) async {
    var result = await APISession.patchWithParams("/user/changeName", {'token': token, 'name': newName});

    if(result.statusCode == 200) {
      APIConstants.showSuccessToast("Changed user name to: $newName", context);
    } else {
      APIConstants.showErrorToast("Failed to change name: ${result.body}", context);
    }

    return this;
  }
  
  static Future<User?> getFromToken(String token) async {
    var result = await APISession.getWithParams("/user/fromToken", {"token": token});

    if(result.statusCode == 200) {
      return fromJson(jsonDecode(result.body));
    } else {
      return null;
    }
  }

  static Future<List<String>> getRoles() async {
    var result = await APISession.get("/user/roles");

    return jsonDecode(result.body).cast<String>();
  }

  Future<bool> setRoles(List<String> newRoles, BuildContext context) async {
    var result = await APISession.patchWithParams("/user/setRoles", {'email': email, 'roles': rolesListToString()});

    if(result.statusCode == 200) {

    } else {
      APIConstants.showErrorToast("Failed to update roles: ${result.body}", context);
    }

    return result.statusCode == 200;
  }

  static Future<List<User>> getAllUsers() async {
    var result = await APISession.get("/user/users");

    print(result.body);

    if(result.statusCode == 200) {
      var jsonDecoded = jsonDecode(result.body);
      print(jsonDecoded);
      List<User> users = jsonDecoded.map<User>((e) => fromJson(e)).toList();

      print(users);

      return users;
    } else {
      return [];
    }
  }

  static Future<User?> authenticate(String email, String password, BuildContext context) async {
    var result = await APISession.getWithParams("/user/authenticate", {"email": email, "password":password});

    if(result.statusCode == 200) {
      User user = fromJson(jsonDecode(result.body));
      APIConstants.showSuccessToast("Successfully logged in! Welcome ${user.name}!", context);
      return user;
    } else {
      APIConstants.showErrorToast("Failed to Log in: ${result.body}", context);
      return null;
    }
  }

  static Future<bool> create(String email, String password, String name, BuildContext context) async {
    var result = await APISession.postWithParams("/user/create", {"email": email, "password":password, "name": name});

    if(context.mounted) {
      if(result.statusCode == 200) {
        APIConstants.showSuccessToast("Created Account! Verification Email Sent!", context);
      } else {
        APIConstants.showErrorToast("Failed to Create Account: ${result.body}", context);
      }
    }

    return result.statusCode == 200;
  }
}