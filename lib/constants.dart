
import 'package:flutter/widgets.dart';
import 'package:sham_parts/main.dart';
import 'package:toastification/toastification.dart';

class APIConstants {
  String baseUrl = "http://localhost:3000";
  String onshapeKey = "onshape_key";
  String currentProject = "current_project";
  String userToken = "";

  static void showSuccessToast(String message, BuildContext? context, {int seconds = 5}) {
    if(context != null) {
        toastification.show(
            context: context,
            autoCloseDuration: Duration(seconds: seconds),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: Text(message)
        );
    }
  }

  static void showErrorToast(String message, BuildContext? context, {int seconds = 5}) {
    if(context != null) {
      toastification.show(
          context: context,
          autoCloseDuration: Duration(seconds: seconds),
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text(message)
      );
    }
  }
}

class StyleConstants {
  static TextStyle titleStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 48,
  );

  static TextStyle subtitleStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24,
  );
}