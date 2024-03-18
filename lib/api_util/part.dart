
import 'package:sham_parts/api_util/assembly.dart';

class Part {

  String number;
  String thumbnail;
  String material;
  String onshapeID;
  String quantityNeeded;
  String quantityInStock;
  String quantityRequested;

  Part({
      required this.number,
      required this.thumbnail,
      required this.material,
      required this.onshapeID,
      required this.quantityNeeded,
      required this.quantityInStock,
      required this.quantityRequested
  });

  static Part fromJson(json) {
    return Part(
        number: json.number,
        thumbnail: json.thumbnail,
        material: json.material,
        quantityNeeded: json.quantityNeeded,
        quantityInStock: json.quantityInStock,
        quantityRequested: json.quantityRequested,
        onshapeID: json.onshape_id,
    );
  }
}