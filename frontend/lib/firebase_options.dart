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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyADueRhPLlRpIai8ZN1rVun5-hDC3vC_6Y',
    appId: '1:435311257389:web:51a4529b77398fe4d555a4',
    messagingSenderId: '435311257389',
    projectId: 'star23sharp-fc78b',
    authDomain: 'star23sharp-fc78b.firebaseapp.com',
    storageBucket: 'star23sharp-fc78b.appspot.com',
    measurementId: 'G-D7F1R6STRL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBq_8coWrsvIZoxGLROPLtiZhUhXtPpyXI',
    appId: '1:435311257389:android:1ce10277b913a90bd555a4',
    messagingSenderId: '435311257389',
    projectId: 'star23sharp-fc78b',
    storageBucket: 'star23sharp-fc78b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCpn58-rfpMcVTdN8-wZL6KKEDsmGKfneQ',
    appId: '1:435311257389:ios:53df3a2e7da7e6dcd555a4',
    messagingSenderId: '435311257389',
    projectId: 'star23sharp-fc78b',
    storageBucket: 'star23sharp-fc78b.appspot.com',
    iosBundleId: 'com.example.star23sharp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCpn58-rfpMcVTdN8-wZL6KKEDsmGKfneQ',
    appId: '1:435311257389:ios:53df3a2e7da7e6dcd555a4',
    messagingSenderId: '435311257389',
    projectId: 'star23sharp-fc78b',
    storageBucket: 'star23sharp-fc78b.appspot.com',
    iosBundleId: 'com.example.star23sharp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyADueRhPLlRpIai8ZN1rVun5-hDC3vC_6Y',
    appId: '1:435311257389:web:be3c7871a5689be0d555a4',
    messagingSenderId: '435311257389',
    projectId: 'star23sharp-fc78b',
    authDomain: 'star23sharp-fc78b.firebaseapp.com',
    storageBucket: 'star23sharp-fc78b.appspot.com',
    measurementId: 'G-00FMVGG4QZ',
  );
}