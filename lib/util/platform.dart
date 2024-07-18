
import 'dart:io';

import 'package:flutter/foundation.dart';

class PlatformInfo {
  static bool isMobile() {
    if(kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }
}