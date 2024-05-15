
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/api-util/onshapeDocument.dart';
import 'package:sham_parts/constants.dart';


class OnshapeAssembly {

  String id;
  String name;
  String thumbnail;
  OnshapeDocument doc;

  Widget searchWidget = Container();

  OnshapeAssembly(
      this.id,
      this.name,
      this.thumbnail,
      this.doc,
      reloadProjectList
  ) {
    searchWidget = OnshapeAssemblyWidget(assembly: this, reloadProjectList: reloadProjectList,);
  }

  static Future<List<OnshapeAssembly>> queryAssemblies(OnshapeDocument doc, reloadProjectList) async {
    http.Response resp =
        await APISession.getWithParams("/onshape/assemblies", {'did': doc.id, 'wid': doc.workspace});

    dynamic json = jsonDecode(resp.body);

    return json.map<OnshapeAssembly>((e) {
      return OnshapeAssembly(e["id"], e["name"], e["thumbnail"], doc, reloadProjectList);
    }).toList();
  }

  Future<void> createProject(BuildContext context, reloadProjectList) async {
    http.Response resp = await APISession.post("/project/create", jsonEncode({
      "name": doc.name,
      "doc_id": doc.id,
      "main_assembly": id,
      "default_workspace": doc.workspace
    }));

    if(context.mounted) {
      if(resp.statusCode == 200) {
        APIConstants.showSuccessToast('Project Successfully Created!', context);
      } else {
        APIConstants.showErrorToast('Project Failed to Create. Error ${resp.statusCode}: ${resp.body}', context);
      }
    }

    reloadProjectList();
  }

}

class OnshapeAssemblyWidget extends StatelessWidget {
  final OnshapeAssembly assembly;
  final reloadProjectList;

  const OnshapeAssemblyWidget({super.key, required this.assembly, required this.reloadProjectList});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.2)
        ),
        height: 400,
        width: 300,
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                  child: Text(
                      assembly.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
               GFImageOverlay(
                  height: 250,
                  width: 250,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  image: APISession.getOnshapeImage(assembly.thumbnail),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                      onPressed: () {
                        assembly.createProject(context, reloadProjectList);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      child: Text(
                          "Select",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inverseSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0
                          ),
                      ),
                  ),
              )
            ],
          )
    );
  }
}

class AssemblySearchWindow extends StatefulWidget {
  final OnshapeDocument doc;
  final reloadProjectList;

  const AssemblySearchWindow({super.key, required this.doc, required this.reloadProjectList});

  @override
  State<AssemblySearchWindow> createState() =>
      AssemblySearchState();
}

class AssemblySearchState extends State<AssemblySearchWindow> {
  List<OnshapeAssembly> assemblies = [];

  @override
  void initState() {
    super.initState();

    loadAssemblyData();
  }

  void loadAssemblyData() async {
    List<OnshapeAssembly> assemblies = await OnshapeAssembly.queryAssemblies(widget.doc, widget.reloadProjectList);

    final check = RegExp(r'A-[0-9]{4}');

    assemblies.sort((a, b) {
      if(a.name.toLowerCase() == "full assembly") return -1;
      if(b.name.toLowerCase() == "full assembly") return 1;
      if(check.hasMatch(a.name)) return -1;
      if(check.hasMatch(a.name)) return 1;

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    setState(() {
      this.assemblies = assemblies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Select Main Assembly"),
      ),
      body:
          SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Center(
                  child: Wrap(
                              spacing: 16.0,
                              runSpacing: 16.0,
                              children: assemblies.map((e) => e.searchWidget).toList()
                          ),
                )
              ),

          )
    );
  }

}
