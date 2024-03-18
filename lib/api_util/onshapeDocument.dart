
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:sham_parts/api_util/apiSession.dart';
import 'package:http/http.dart' as http;
import 'package:sham_parts/api_util/onshapeAssembly.dart';


class OnshapeDocument {
  String id;
  String name;
  String thumbnail;
  String workspace;

  Widget searchWidget = Container();

  OnshapeDocument(
      this.id,
      this.name,
      this.thumbnail,
      this.workspace
      ) {
    searchWidget = OnshapeSearchWidget(doc: this);
  }
  
  static Future<List<OnshapeDocument>> queryDocuments(String query) async{
     http.Response resp =
     await APISession.getWithParams("/onshape/documents", {'query': query});

     dynamic json = jsonDecode(resp.body);

     List<OnshapeDocument> returns =  json.map<OnshapeDocument>((e) {
       return OnshapeDocument(e["id"], e["name"], e["thumbnail"], e["default_workspace"]);
     }).toList();

     return returns;
  }
}

class OnshapeSearchWidget extends StatelessWidget {

  final OnshapeDocument doc;

  const OnshapeSearchWidget({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AssemblySearchWindow(doc: doc)));
        },
        child:  Container(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                GFImageOverlay(
                  height: 150,
                  width: 150,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  image: APISession.getOnshapeImage(doc.thumbnail),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(doc.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),),
                      Text(doc.id, style: TextStyle(fontWeight: FontWeight.w200))
                    ],
                  )
    
                )
              ],
            )
          )
        )
    );
  }
}