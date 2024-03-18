
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:sham_parts/api_util/apiSession.dart';
import 'package:sham_parts/api_util/onshapeDocument.dart';
import 'package:toastification/toastification.dart';


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
      this.doc
  ) {
    searchWidget = OnshapeAssemblyWidget(assembly: this);
  }

  static Future<List<OnshapeAssembly>> queryAssemblies(OnshapeDocument doc) async {
    http.Response resp =
        await APISession.getWithParams("/onshape/assemblies", {'did': doc.id, 'wid': doc.workspace});

    dynamic json = jsonDecode(resp.body);

    return json.map<OnshapeAssembly>((e) {
      return OnshapeAssembly(e["id"], e["name"], e["thumbnail"], doc);
    }).toList();
  }

  Future<void> createProject(BuildContext context) async {
    print("running create :)");
    http.Response resp = await APISession.post("/project/create", jsonEncode({
      "name": doc.name,
      "doc_id": doc.id,
      "main_assembly": id,
      "default_workspace": doc.workspace
    }));

    print(resp);

    if(context.mounted) {
      if(resp.statusCode == 200) {
        toastification.show(
          context: context,
          autoCloseDuration: const Duration(seconds: 10),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text('Project Successfully Created! Indexing parts now...')
        );
      } else {
        toastification.show(
            context: context,
            autoCloseDuration: const Duration(seconds: 10),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            title: Text("Project Failed to Create. Error Code ${resp.statusCode}: ${resp.body}")
        );
      }
    }
  }

}

class OnshapeAssemblyWidget extends StatelessWidget {
  OnshapeAssembly assembly;

  OnshapeAssemblyWidget({super.key, required this.assembly});

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
                        assembly.createProject(context);
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

  const AssemblySearchWindow({super.key, required this.doc});

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
    List<OnshapeAssembly> assemblies = await OnshapeAssembly.queryAssemblies(widget.doc);

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
