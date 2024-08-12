
import 'package:sham_parts/api-util/part.dart';

class Assembly {
  String name;
  String onshapeId;
  List<Part> parts;

  Assembly({
    required this.name,
    required this.onshapeId,
    required this.parts
  });

  static Assembly fromJson(json) {
    return Assembly(
        name: json["name"],
        onshapeId: json["onshape_id"],
        parts: json["parts"].map<Part>((e) => Part.fromJson(e)).toList()
    );
  }
}