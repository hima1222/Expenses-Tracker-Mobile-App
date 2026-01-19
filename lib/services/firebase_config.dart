import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: kIsWeb
          ? const FirebaseOptions(
              apiKey: "AIzaSyCONNTLOpXgIQhqt_JSSXyPp46L-LVj5Lw",
              authDomain: "expense-tracker-d669a.firebaseapp.com",
              projectId: "expense-tracker-d669a",
              storageBucket: "expense-tracker-d669a.firebasestorage.app",
              messagingSenderId: "201493999604",
              appId: "1:201493999604:web:a063ed4baa2f5b0d4553a1",
              measurementId: "G-LHF3NCQ8TD"
            )
          : null, // For mobile, Firebase will use google-services.json
    );
  }
}
