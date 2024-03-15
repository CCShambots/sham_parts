
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/floating_widget/gf_floating_widget.dart';
import 'package:getwidget/components/search_bar/gf_search_bar.dart';
import 'package:http/http.dart' as http;
import 'package:sham_parts/api_util/apiSession.dart';

class OnshapeAssembly {

  String id;
  String name;
  String os_key;

  Widget searchWidget = Container();

  OnshapeAssembly(
    this.id,
    this.name,
    this.os_key
  ) {
    searchWidget = OnshapeAssemblyWidget(assembly: this);
  }

  static Future<List<OnshapeAssembly>> queryAssemblies(String did, String wid) async {
    http.Response resp =
        await APISession.getWithParams("/onshape/assemblies", {'did': did, 'wid': wid});

    dynamic json = jsonDecode(resp.body);

    return json.map<OnshapeAssembly>((e) {
      String workspace;
      return OnshapeAssembly(e["id"], e["name"], e["os_key"]);
    }).toList();

  }

}

class OnshapeAssemblyWidget extends StatelessWidget {
  OnshapeAssembly assembly;

  OnshapeAssemblyWidget({super.key, required this.assembly});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Column(
            children: [
              Text(assembly.name),
              Text(assembly.id)
            ],
          ),
          GFButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward),
          )
        ],
      ),
    );
  }
}

class AssemblySearchWindow extends StatefulWidget {

  const AssemblySearchWindow({super.key});

  @override
  State<AssemblySearchWindow> createState() =>
      AssemblySearchState();
}

class AssemblySearchState extends State<AssemblySearchWindow> {
  List<OnshapeAssembly> assemblies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Select Main Assembly!"),
      ),
      body: GFFloatingWidget(
          body: Column(children: assemblies.map((e) => e.searchWidget).toList()),
          verticalPosition: MediaQuery.of(context).size.height* 0.2,
          horizontalPosition: MediaQuery.of(context).size.width* 0.8,
          child: GFSearchBar(
            searchList: assemblies,
            overlaySearchListItemBuilder: (item) {
              return Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  item.name,
                  style: const TextStyle(fontSize: 18),
                ),
              );
            },
            searchQueryBuilder: (String query, List<dynamic> list) {
                return list
                    .where((element) => element.name.toLowerCase().contains(query.toLowerCase()))
                    .toList();
            },

          ),
      )
    ,
    );
  }

}
