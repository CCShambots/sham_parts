import 'dart:convert';

import 'package:sham_parts/api-util/apiSession.dart';

class Server {
  final String ip;
  final String name;

  Server({required this.ip, required this.name});

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      ip: json['ip'],
      name: json['name'],
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
}