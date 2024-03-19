
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/image/gf_image_overlay.dart';
import 'package:sham_parts/api_util/apiSession.dart';
import 'package:sham_parts/api_util/assembly.dart';

class Part {

  String number;
  String thumbnail;
  String material;
  String onshapeID;
  int quantityNeeded;
  int quantityInStock;
  int quantityRequested;

  late Widget partListDisplay;

  Part({
      required this.number,
      required this.thumbnail,
      required this.material,
      required this.onshapeID,
      required this.quantityNeeded,
      required this.quantityInStock,
      required this.quantityRequested
  }) {
    partListDisplay = PartListDisplay(part: this);
  }

  static Part fromJson(json) {
    return Part(
        number: json["number"],
        thumbnail: json["thumbnail"],
        material: json["material"],
        quantityNeeded: json["quantityNeeded"],
        quantityInStock: json["quantityInStock"],
        quantityRequested: json["quantityRequested"],
        onshapeID: json["onshape_id"],
    );
  }
}

class PartListDisplay extends StatelessWidget {
  Part part;

  PartListDisplay({super.key, required this.part});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.2)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GFImageOverlay(
            height: 100,
            width: 100,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            image: APISession.getOnshapeImage(part.thumbnail),
          ),
          Column(
            children: [
              Text(part.number),
              Text(part.material)
            ],
          )
        ],

      ),
    );
  }

}