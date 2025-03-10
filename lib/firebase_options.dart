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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBaRxmjPMAX7FmriOHpW6gYY8gMd4eVEPM',
    appId: '1:864597870395:android:9ab7fd924a078fd961191e',
    messagingSenderId: '864597870395',
    projectId: 'dertam-a445f',
    storageBucket: 'dertam-a445f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAS_B1OaqXhataSAndnFDOIxQAN8Go-jiA',
    appId: '1:864597870395:ios:ef6927d9c6effc8c61191e',
    messagingSenderId: '864597870395',
    projectId: 'dertam-a445f',
    storageBucket: 'dertam-a445f.firebasestorage.app',
    androidClientId:
        '864597870395-5bjm9ve7cueh3mhjqdnlj4afbrm4s7sv.apps.googleusercontent.com',
    iosClientId:
        '864597870395-fij26l13vqjvo1geqtaecuvv6alp04pp.apps.googleusercontent.com',
    iosBundleId: 'com.example.tourismApp',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCh9rOYhPB2olsYsPxh5M1fFJxGu0n0dAE',
    appId: '1:864597870395:android:9ab7fd924a078fd961191e',
    messagingSenderId: '864597870395',
    projectId: 'dertam-a445f',
    storageBucket: 'dertam-a445f.firebasestorage.app',
  );
}
