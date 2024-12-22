import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/User/user_login.dart';
import 'package:gps_toll_gate_system/data_objects.dart';
import 'package:uuid/uuid.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Registration"),
      ),
      body: const UserRegistrationPage(),
    );
  }
}

class UserRegistrationPage extends StatefulWidget {
  const UserRegistrationPage({super.key});
  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final userNameController = TextEditingController();
  final userEmailController = TextEditingController();
  final userVehicleNumber = TextEditingController();
  final userPassword = TextEditingController();
  final userPassword2 = TextEditingController();
  final vehicleType = ["Car","Bus","Truck","Heavy Truck"];
  final auth = FirebaseAuth.instance;
  final walletID = const Uuid().v4obj();
  get walletIDstr => walletID.uuid;
  String selectedVehicleType = "";
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
              controller: userNameController,
              decoration: const InputDecoration(
                hintText: "Enter User Name",
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
              controller: userEmailController,
              decoration: const InputDecoration(
                hintText: "Enter User Email",
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
              controller: userPassword,
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
              controller: userPassword2,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextField(
              keyboardType: TextInputType.name,
              controller: userVehicleNumber,
              decoration: const InputDecoration(
                hintText: "Enter Vehicle Number",
                icon: Icon(
                  Icons.car_rental,
                  color: Colors.red,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.all(5),
                child: Text("Select Vehicle Type"),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: DropdownButton(
                  value: vehicleType[0],
                  items: vehicleType.map((vType) {
                    return DropdownMenuItem(
                      value: vType,
                      child: Text(vType)
                      );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicleType = value!;
                    });
                    },
                  )
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (userNameController.text != "" &&
                            userEmailController.text != "" &&
                            userPassword.text == userPassword2.text) {
                          await auth.createUserWithEmailAndPassword(
                              email: userEmailController.text,
                              password: userPassword.text);
                          final user = auth.currentUser;
                          final userUUid = user!.uid;
                          // user details
                          DatabaseReference dbref =
                              FirebaseDatabase.instance.ref('/users/$userUUid');
                          final userData = UserDetails(userEmailController.text, userNameController.text, userUUid, userVehicleNumber.text,10000,selectedVehicleType);
                          final userdataJSON = userData.toJSON();
                          final jsonEncodedUserData = jsonEncode(userdataJSON);
                          dbref.set(jsonEncodedUserData);
                        }
                      } catch (err) {
                        if (kDebugMode) {
                          print(err);
                        }
                      }
                      if (auth.currentUser != null) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const UserLogin()));
                      }
                    },
                    child: const Text("Sign Up")),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const UserLogin()));
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
