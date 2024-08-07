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
    apiKey: 'AIzaSyCjuY4AM5oUr1x3VX-Oby4lI0egx9RJ_sM',
    appId: '1:556732933314:web:ddd14cc23ce5e2ed0a875b',
    messagingSenderId: '556732933314',
    projectId: 'aepalnew',
    authDomain: 'aepalnew.firebaseapp.com',
    storageBucket: 'aepalnew.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjKIKar5S5tmv5XAKma7eokgyEVcBeYTo',
    appId: '1:556732933314:android:1d8dc6cdfa49c1ce0a875b',
    messagingSenderId: '556732933314',
    projectId: 'aepalnew',
    storageBucket: 'aepalnew.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAYNij_-92NtSwJ6zuE58b_0WhqvLVS8c',
    appId: '1:556732933314:ios:cb146375773d5c920a875b',
    messagingSenderId: '556732933314',
    projectId: 'aepalnew',
    storageBucket: 'aepalnew.appspot.com',
    iosBundleId: 'com.example.aepal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAAYNij_-92NtSwJ6zuE58b_0WhqvLVS8c',
    appId: '1:556732933314:ios:cb146375773d5c920a875b',
    messagingSenderId: '556732933314',
    projectId: 'aepalnew',
    storageBucket: 'aepalnew.appspot.com',
    iosBundleId: 'com.example.aepal',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCjuY4AM5oUr1x3VX-Oby4lI0egx9RJ_sM',
    appId: '1:556732933314:web:47e9e30f605d0fe50a875b',
    messagingSenderId: '556732933314',
    projectId: 'aepalnew',
    authDomain: 'aepalnew.firebaseapp.com',
    storageBucket: 'aepalnew.appspot.com',
  );

}