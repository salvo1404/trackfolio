// Firebase configuration.
// API key is loaded from --dart-define at build time.
// Pass locally: flutter run -d chrome --dart-define=FIREBASE_API_KEY=...
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    appId: '1:235464136837:web:ee32091dcca8c155d931ec',
    messagingSenderId: '235464136837',
    projectId: 'trackfolio-db',
    authDomain: 'trackfolio-db.firebaseapp.com',
    storageBucket: 'trackfolio-db.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: '1:235464136837:ios:07cf57cb1eb90711d931ec',
    messagingSenderId: '235464136837',
    projectId: 'trackfolio-db',
    storageBucket: 'trackfolio-db.firebasestorage.app',
    iosBundleId: 'com.infosb86.trackfolio',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: '1:235464136837:android:3e61cbf0b70c2c7ed931ec',
    messagingSenderId: '235464136837',
    projectId: 'trackfolio-db',
    storageBucket: 'trackfolio-db.firebasestorage.app',
  );
}
