import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/firebase_options.dart';
import 'package:gps_toll_gate_system/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
          body: LoginPage()),
    );
  }
}


// web       1:1021502003286:web:d011366cf698ab630c83f7
// android   1:1021502003286:android:e54d12965761d7050c83f7
// ios       1:1021502003286:ios:ba255bf8b4983ff40c83f7
// macos     1:1021502003286:ios:5d988877a3984aeb0c83f7