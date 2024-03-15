import 'package:flutter/cupertino.dart';

class OnshapeDocumentDisplay extends StatelessWidget {
  final String name;

  const OnshapeDocumentDisplay(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(name)
    );
  }
}