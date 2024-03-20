
import 'package:flutter/widgets.dart';
import 'package:sham_parts/main.dart';
import 'package:toastification/toastification.dart';

class APIConstants {
  String baseUrl = "http://localhost:3000";
  String onshapeKey = "onshape_key";
  String currentProject = "current_project";

  static void showSuccessToast(String message, BuildContext? context, {int seconds = 3}) {
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

  static void showErrorToast(String message, BuildContext? context, {int seconds = 3}) {
    BuildContext? context = MyApp.navigatorKey.currentState?.context;

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