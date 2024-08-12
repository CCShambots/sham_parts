import 'dart:convert';

import 'package:sham_parts/api-util/api_session.dart';
import 'package:sham_parts/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Server {
  final String ip;
  final String name;
  final String key;

  Server({required this.ip, required this.name, required this.key});

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      ip: json['ip'],
      name: json['name'],
      key: json['key'],
    );
  }

  static Future<List<Server>> getAllServers() async {
    var result = await APISession.getFromLeader("/server/list");

    if (result.statusCode == 200) {
      var jsonDecoded = jsonDecode(result.body);
      List<Server> servers =
          jsonDecoded.map<Server>((e) => Server.fromJson(e)).toList();

      return servers;
    } else {
      return [];
    }
  }

  static Future<List<Server>> getServersFromKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> serverKeys =
        prefs.getStringList(APIConstants().serverKeys) ?? [""];

    var result = await APISession.getFromLeaderWithParams(
        "/server/get", {"keys": serverKeys.join(",")});

    if (result.statusCode == 200) {
      var jsonDecoded = jsonDecode(result.body);
      List<Server> servers =
          jsonDecoded.map<Server>((e) => Server.fromJson(e)).toList();

      return servers;
    } else {
      return [];
    }
  }

  static Future<void> addServer(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> serverKeys =
        prefs.getStringList(APIConstants().serverKeys) ?? [""];

    if(!serverKeys.contains(key)) {
      serverKeys.add(key);
    }

    prefs.setStringList(APIConstants().serverKeys, serverKeys);
  }
}
