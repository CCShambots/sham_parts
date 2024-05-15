import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/constants.dart';

class PartsDisplay extends StatefulWidget {
  final Project project;

  const PartsDisplay({super.key, required this.project});

  @override
  State<PartsDisplay> createState() => PartsDisplayState();
}

class PartsDisplayState extends State<PartsDisplay> {
  List<Part> currentParts = [];

  bool loadingImages = false;
  int partsWithLoadedImages = 0;

  bool showImages = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      currentParts = widget.project.parts;
      partsWithLoadedImages = currentParts
          .where((element) => element.thumbnail != "unloaded")
          .length;
    });
  }

  void loadPhotos(BuildContext context) async {
    if (mounted) {
      setState(() {
        loadingImages = true;
        partsWithLoadedImages = currentParts
            .where((element) => element.thumbnail != "unloaded")
            .length;
      });
    }

    for (var part in widget.project.parts) {
      if (part.thumbnail == "unloaded") {
        part.loadThumbnail().then((value) => {
              if (value)
                {
                  APIConstants.showSuccessToast(
                      "Loaded Image for ${part.number}", context)
                }
              else
                {
                  APIConstants.showErrorToast(
                      "Failed to Load Image for ${part.number}", context)
                }
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var numColumns = width > 1200 ? 2 : 1;

    if (!mounted) return const SizedBox.shrink();

    return Scaffold(
        body: ListView(
          children: widget.project.parts.map((e) => e.partListDisplay).toList(),
        ),
        floatingActionButton: widget.project.parts
                .where((element) => element.thumbnail == "unloaded")
                .isNotEmpty
            ? FloatingActionButton(
                onPressed: () {
                  loadPhotos(context);
                },
                tooltip: "Load Photos",
                child: const Icon(Icons.photo, color: Colors.white, size: 28),
              )
            : null);
  }
}
