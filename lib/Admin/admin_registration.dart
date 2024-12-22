import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/Admin/admin_login.dart';
import 'package:gps_toll_gate_system/data_objects.dart';

class AdminRegistration extends StatefulWidget {
  const AdminRegistration({super.key});

  @override
  State<AdminRegistration> createState() => _AdminRegistrationState();
}

class _AdminRegistrationState extends State<AdminRegistration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Registration"),
      ),
      body: const AdminRegistrationPage(),
    );
  }
}

class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({super.key});
  @override
  State<AdminRegistrationPage> createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
  final adminNameController = TextEditingController();
  final adminEmailController = TextEditingController();
  final adminPassword = TextEditingController();
  final adminPassword2 = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextField(
              keyboardType: TextInputType.name,
              controller: adminNameController,
              decoration: const InputDecoration(
                hintText: "Enter Admin Name",
                icon: Icon(
                  Icons.abc,
                  color: Colors.red,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextField(
              keyboardType: TextInputType.name,
              controller: adminEmailController,
              decoration: const InputDecoration(
                hintText: "Enter Admin Email",
                icon: Icon(
                  Icons.email_outlined,
                  color: Colors.red,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextField(
              keyboardType: TextInputType.name,
              controller: adminPassword,
              decoration: const InputDecoration(
                hintText: "Enter Password",
                icon: Icon(
                  Icons.password,
                  color: Colors.red,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextField(
              keyboardType: TextInputType.name,
              controller: adminPassword2,
              decoration: const InputDecoration(
                hintText: "Re-Enter Password",
                icon: Icon(
                  Icons.password,
                  color: Colors.red,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (adminNameController.text != "" &&
                            adminEmailController.text != "" &&
                            adminPassword.text == adminPassword2.text) {
                          await auth.createUserWithEmailAndPassword(
                              email: adminEmailController.text,
                              password: adminPassword.text);
                          final admin = auth.currentUser;
                          final adminUUid = admin!.uid;
                          // user details
                          DatabaseReference dbref =
                              FirebaseDatabase.instance.ref('/Admins/$adminUUid');
                          final adminData = AdminDetails(
                              adminEmailController.text,
                              adminNameController.text,
                              adminUUid);
                          final admindataJSON = adminData.toJSON();
                          final jsonEncodedAdminData = jsonEncode(admindataJSON);
                          dbref.set(jsonEncodedAdminData);
                        }
                      } catch (err) {
                        if (kDebugMode) {
                          print(err);
                        }
                      }
                      if (auth.currentUser != null) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AdminLogin()));
                      }
                    },
                    child: const Text("Sign Up")),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AdminLogin()));
                    },
                    child: const Text("Cancel")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
