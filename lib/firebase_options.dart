import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyDLsFe9UIfI4JSdW7UoJYN34bVW80z0wH4",
        authDomain: "neuroindex-e4f5b.firebaseapp.com",
        projectId: "neuroindex-e4f5b",
        storageBucket: "neuroindex-e4f5b.appspot.com",
        messagingSenderId: "107961647459",
        appId: "1:107961647459:web:abb467d4e85b8ed98b1356",
      );
    }
    // Configuration pour Android
    else if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDLsFe9UIfI4JSdW7UoJYN34bVW80z0wH4',
        appId: '1:107961647459:android:abb467d4e85b8ed98b1356',
        messagingSenderId: '107961647459',
        projectId: 'neuroindex-e4f5b',
        storageBucket: 'neuroindex-e4f5b.appspot.com',
      );
    }
    // Configuration pour iOS
    else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyBU4Kb65ni3D4u-z_yslBRZTD0purRUe70',
        appId: '1:107961647459:ios:9509ca5c537ee6f48b1356',
        messagingSenderId: '107961647459',
        projectId: 'neuroindex-e4f5b',
        storageBucket: 'neuroindex-e4f5b.appspot.com',
        iosBundleId: 'com.example.neuroindex',
      );
    }
    // Par défaut, utilise la configuration Web
    else {
      return const FirebaseOptions(
        apiKey: "AIzaSyDLsFe9UIfI4JSdW7UoJYN34bVW80z0wH4",
        authDomain: "neuroindex-e4f5b.firebaseapp.com",
        projectId: "neuroindex-e4f5b",
        storageBucket: "neuroindex-e4f5b.appspot.com",
        messagingSenderId: "107961647459",
        appId: "1:107961647459:web:abb467d4e85b8ed98b1356",
      );
    }
  }
}