import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBEcp9g6m_6ok9VcQjxNc7_Xiz47FPdQh8',
    appId: '1:354331878995:web:your-web-app-id',
    messagingSenderId: '354331878995',
    projectId: 'ecommerceapp-7268d',
    authDomain: 'ecommerceapp-7268d.firebaseapp.com',
    storageBucket: 'ecommerceapp-7268d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEcp9g6m_6ok9VcQjxNc7_Xiz47FPdQh8',
    appId: '1:354331878995:android:b8714dc4d90fd0bb0348a6',
    messagingSenderId: '354331878995',
    projectId: 'ecommerceapp-7268d',
    storageBucket: 'ecommerceapp-7268d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBl1ZSEoXXGDBuT8MmQpb6R5yDjdCuMTF0',
    appId: '1:354331878995:ios:694b92bab603c6620348a6',
    messagingSenderId: '354331878995',
    projectId: 'ecommerceapp-7268d',
    storageBucket: 'ecommerceapp-7268d.firebasestorage.app',
    iosBundleId: 'com.example.ecommerceAppFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBl1ZSEoXXGDBuT8MmQpb6R5yDjdCuMTF0',
    appId: '1:354331878995:ios:694b92bab603c6620348a6',
    messagingSenderId: '354331878995',
    projectId: 'ecommerceapp-7268d',
    storageBucket: 'ecommerceapp-7268d.firebasestorage.app',
    iosBundleId: 'com.example.ecommerceAppFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBEcp9g6m_6ok9VcQjxNc7_Xiz47FPdQh8',
    appId: '1:354331878995:web:your-web-app-id',
    messagingSenderId: '354331878995',
    projectId: 'ecommerceapp-7268d',
    authDomain: 'ecommerceapp-7268d.firebaseapp.com',
    storageBucket: 'ecommerceapp-7268d.firebasestorage.app',
  );
}
