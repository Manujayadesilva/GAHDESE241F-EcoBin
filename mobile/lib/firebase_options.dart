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
    apiKey: 'secrets.FREBASE',
    appId: '1:378788627505:web:bc05cb057b77fc74e50110',
    messagingSenderId: '378788627505',
    projectId: 'smart-waste-management-3041a',
    authDomain: 'smart-waste-management-3041a.firebaseapp.com',
    databaseURL:
        'https://smart-waste-management-3041a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smart-waste-management-3041a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'secrets.FREBASE',
    appId: '1:378788627505:android:d18cd3c952595044e50110',
    messagingSenderId: '378788627505',
    projectId: 'smart-waste-management-3041a',
    databaseURL:
        'https://smart-waste-management-3041a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smart-waste-management-3041a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'secrets.FREBASE',
    appId: '1:378788627505:ios:d3401ff39eefd738e50110',
    messagingSenderId: '378788627505',
    projectId: 'smart-waste-management-3041a',
    databaseURL:
        'https://smart-waste-management-3041a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smart-waste-management-3041a.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'secrets.FREBASE',
    appId: '1:378788627505:ios:d3401ff39eefd738e50110',
    messagingSenderId: '378788627505',
    projectId: 'smart-waste-management-3041a',
    databaseURL:
        'https://smart-waste-management-3041a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smart-waste-management-3041a.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'secrets.FREBASE',
    appId: '1:378788627505:web:b0b8f430f7633560e50110',
    messagingSenderId: '378788627505',
    projectId: 'smart-waste-management-3041a',
    authDomain: 'smart-waste-management-3041a.firebaseapp.com',
    databaseURL:
        'https://smart-waste-management-3041a-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smart-waste-management-3041a.firebasestorage.app',
  );
}
