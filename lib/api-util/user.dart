import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:sham_parts/api-util/api_session.dart';
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  int id;
  String name;
  String email;
  String token;
  bool verified;

  List<String> roles;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.verified,
      required this.roles,
      required this.token});
  
  static User blank() {
    return User(id: -2, name: "", email: "", verified: false, roles: [], token: "");
  }

  static User fromJson(json) {
    return User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        verified: json["verified"],
        token: json["randomToken"] ?? "",
        roles: json["roles"].cast<String>());
  }

  String rolesListToString() {
    String rolesString = "";

    for (int i = 0; i < roles.length; i++) {
      rolesString += roles[i];
      if (i != roles.length - 1) rolesString += ",";
    }

    return rolesString;
  }

  Future<User> deleteUser(BuildContext context, {String token = ""}) async {
    var result = await APISession.deleteWithParams("/user/delete", {"email": email, "token": token});
    if(context.mounted) {
      if (result.statusCode == 200) {
        APIConstants.showSuccessToast("User deleted successfully", context);
      } else {
        APIConstants.showErrorToast("Failed to delete user: ${result.body}", context);
      }
    }

    return this;
  }

  Future<User> removeRole(String role, BuildContext context) async {
    var result = await APISession.patchWithParams(
        "/user/removeRole", {'email': email, 'role': role});

    if(context.mounted) {
      if (result.statusCode == 200) {
        APIConstants.showSuccessToast("Removed role: $role", context);
      } else {
        APIConstants.showErrorToast(
            "Failed to remove role: ${result.body}", context);
      }

    }

    return this;
  }

  Future<User> addRole(String role, BuildContext context) async {
    var result = await APISession.patchWithParams(
        "/user/addRole", {'email': email, 'role': role});

    if(context.mounted) {
      if (result.statusCode == 200) {
        APIConstants.showSuccessToast("Added role: $role", context);
      } else {
        APIConstants.showErrorToast(
            "Failed to add role: ${result.body}", context);
      }
    }

    return this;
  }

  Future<User> changeName(String newName, BuildContext context) async {
    var result = await APISession.patchWithParams(
        "/user/changeName", {'token': token, 'name': newName});

    if(context.mounted) {
      if (result.statusCode == 200) {
        APIConstants.showSuccessToast("Changed user name to: $newName", context);
      } else {
        APIConstants.showErrorToast(
            "Failed to change name: ${result.body}", context);
      }
    }

    return this;
  }

  static Future<User?> getFromToken(String token) async {
    var result =
        await APISession.getWithParams("/user/fromToken", {"token": token});

    if (result.statusCode == 200) {
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
    var result = await APISession.patchWithParams(
        "/user/setRoles", {'email': email, 'roles': rolesListToString()});

    if(context.mounted) {
      if (result.statusCode == 200) {
      } else {
        APIConstants.showErrorToast(
            "Failed to update roles: ${result.body}", context);
      }
    }

    return result.statusCode == 200;
  }

  static Future<User?> getUserFromPrefs() async {
    String? token = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString(APIConstants().userToken));
    if (token != null) {
      User? user = await getFromToken(token);
      user?.token = token;

      return user;
    } else {
      return null;
    }
  }

  static Future<List<User>> getAllUsers() async {
    var result = await APISession.get("/user/users");

    if (result.statusCode == 200) {
      var jsonDecoded = jsonDecode(result.body);
      List<User> users = jsonDecoded.map<User>((e) => fromJson(e)).toList();

      return users;
    } else {
      return [];
    }
  }

  static Future<List<User>> getUsersOfProject() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String projectKey = prefs.getString(APIConstants().currentProject) ?? "";

    var result = await APISession.getWithParams("/user/users", {"project": projectKey});

    if (result.statusCode == 200) {
      var jsonDecoded = jsonDecode(result.body);
      List<User> users = jsonDecoded.map<User>((e) => fromJson(e)).toList();

      return users;
    } else {
      return [];
    }
  }

  static Future<void> logOut() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userToken = prefs.getString(APIConstants().userToken) ?? "";
    
    String token = "none";
    bool isMobile = Platform.isAndroid || Platform.isIOS;
    if(isMobile) {
      token = await FirebaseMessaging.instance.getToken() ?? "none";
    }
    
    await APISession.deleteWithParams("/user/logout", {"token": userToken, "firebase_token": token});

    prefs.remove(APIConstants().userToken);

  }

  static Future<User?> authenticate(
      String email, String password, String firebaseToken, BuildContext context) async {
    var result = await APISession.getWithParams(
        "/user/authenticate", {"email": email, "password": password, "firebase_token": firebaseToken});
    
    if (result.statusCode == 200) {
      User user = fromJson(jsonDecode(result.body));
      if(context.mounted) {
        APIConstants.showSuccessToast(
            "Successfully logged in! Welcome ${user.name}!", context);
      }
      return user;
    } else {
      if(context.mounted) {
        APIConstants.showErrorToast("Failed to Log in: ${result.body}", context);
      }
      return null;
    }
  }

  static Future<bool> create(
      String email, String password, String name, String firebaseToken, BuildContext context) async {
    var result = await APISession.postWithParams(
        "/user/create", {"email": email, "password": password, "name": name, "firebase_token": firebaseToken});

    if (context.mounted) {
      if (result.statusCode == 200) {
        APIConstants.showSuccessToast(
            "Created Account! Verification Email Sent!", context);
      } else {
        APIConstants.showErrorToast(
            "Failed to Create Account: ${result.body}", context);
      }
    }

    return result.statusCode == 200;
  }
}
