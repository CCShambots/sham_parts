
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/floating_widget/gf_floating_widget.dart';
import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:getwidget/getwidget.dart';
import 'package:sham_parts/api_util/part.dart';
import 'package:sham_parts/api_util/project.dart';

class PartsDisplay extends StatefulWidget{
  Project project;

  PartsDisplay({super.key, required this.project});

  @override
  State<PartsDisplay> createState() =>
      PartsDisplayState();
}

class PartsDisplayState extends State<PartsDisplay> {

  List<Part> currentParts = [];

  bool loadingImages = false;
  int partsWithLoadedImages = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      currentParts = widget.project.parts;
      partsWithLoadedImages = currentParts.where((element) => element.thumbnail != "unloaded").length;
    });
  }

  void loadPhotos() async {
    setState(() {
      loadingImages = true;
      partsWithLoadedImages = currentParts.where((element) => element.thumbnail != "unloaded").length;
    });

    for(var part in widget.project.parts) {
      if(part.thumbnail == "unloaded") {
        part.loadThumbnail().then((value) => {
          if(value) {
            setState(() {
              partsWithLoadedImages++;
            })
          }
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    if(!mounted) return const SizedBox.shrink();

    return Scaffold(
      body: GFFloatingWidget(
        showBlurness: loadingImages,
        body: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height, // or any other desired height
            ),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 5,
              children: widget.project.parts.map((e) => e.partListDisplay).toList(),
            )
        ),
        verticalPosition: MediaQuery.of(context).size.height* 0.5,
        child: loadingImages ? SizedBox(
          height: 200,
          child:Column(
            children: [
              GFProgressBar(
                percentage: partsWithLoadedImages/widget.project.parts.length,
                type: GFProgressType.circular,
                radius: 200,
                width: 400,
                progressBarColor: GFColors.SUCCESS,
                child: Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Text('$partsWithLoadedImages/${widget.project.parts.length}', textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          )
          ,
        ) : Container(),
      ),
          floatingActionButton: widget.project.parts.where((element) => element.thumbnail == "unloaded").isNotEmpty ?
          FloatingActionButton(
              onPressed: loadPhotos,
              tooltip: "Load Photos",
              child: const Icon(Icons.photo, color: Colors.white, size: 28),
          )
          : null,
    );
  }

}