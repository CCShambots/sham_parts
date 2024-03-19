
import 'package:sham_parts/api_util/part.dart';

class Assembly {
  String name;
  String onshape_id;
  List<Part> parts;

  Assembly({
    required this.name,
    required this.onshape_id,
    required this.parts
  });

  static Assembly fromJson(json) {
    return Assembly(
        name: json["name"],
        onshape_id: json["onshape_id"],
        parts: json["parts"].map<Part>((e) => Part.fromJson(e)).toList()
    );
  }
}