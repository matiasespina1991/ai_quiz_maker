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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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
    apiKey: 'AIzaSyBfVKsOX_ujNruWLvv2HSK22Ss3_jrCfPE',
    appId: '1:612904823734:android:a4dcd3f349e346751d6f17',
    messagingSenderId: '612904823734',
    projectId: 'ai-quiz-maker',
    storageBucket: 'ai-quiz-maker.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFD3K3eTe8vO2iP1pXF0KWehRCWKP-zSo',
    appId: '1:612904823734:ios:b7e9a85f2ed3d8681d6f17',
    messagingSenderId: '612904823734',
    projectId: 'ai-quiz-maker',
    storageBucket: 'ai-quiz-maker.appspot.com',
    iosClientId: '612904823734-b4g12mc8p6kvt1rou3i4mei0b4c4n7gc.apps.googleusercontent.com',
    iosBundleId: 'com.matiasespina1991.aiquizmaker',
  );

}