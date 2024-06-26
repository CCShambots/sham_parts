// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIqI0X21knb0dioS0FpSG664QqxA1ZtdQ',
    appId: '1:756674328834:android:ed8a2c928be7d8b004ea1b',
    messagingSenderId: '756674328834',
    projectId: 'shamparts-b52bc',
    storageBucket: 'shamparts-b52bc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCr5ycNta7jHQ1ObqFtSyFuT9nTrainYs',
    appId: '1:756674328834:ios:e6bc89d3d8e6b68304ea1b',
    messagingSenderId: '756674328834',
    projectId: 'shamparts-b52bc',
    storageBucket: 'shamparts-b52bc.appspot.com',
    iosBundleId: 'com.ccshambots.shamparts',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCCr5ycNta7jHQ1ObqFtSyFuT9nTrainYs',
    appId: '1:756674328834:ios:e6bc89d3d8e6b68304ea1b',
    messagingSenderId: '756674328834',
    projectId: 'shamparts-b52bc',
    storageBucket: 'shamparts-b52bc.appspot.com',
    iosBundleId: 'com.ccshambots.shamparts',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDUySKLk7vtFlW1OnpvOsiKvQT2hf3ghbY',
    appId: '1:756674328834:web:f735f3f21a06927104ea1b',
    messagingSenderId: '756674328834',
    projectId: 'shamparts-b52bc',
    authDomain: 'shamparts-b52bc.firebaseapp.com',
    storageBucket: 'shamparts-b52bc.appspot.com',
    measurementId: 'G-B3EGX2HG18',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUySKLk7vtFlW1OnpvOsiKvQT2hf3ghbY',
    appId: '1:756674328834:web:f735f3f21a06927104ea1b',
    messagingSenderId: '756674328834',
    projectId: 'shamparts-b52bc',
    authDomain: 'shamparts-b52bc.firebaseapp.com',
    storageBucket: 'shamparts-b52bc.appspot.com',
    measurementId: 'G-B3EGX2HG18',
  );

}