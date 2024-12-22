
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/User/user_home.dart';
import 'package:gps_toll_gate_system/User/user_registration.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Login"),
      ),
      body: const UserLoginPage(),
    );
  }
}

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Spacer(),
        Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: userEmailController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter User Email",
                icon: Icon(
                  Icons.abc_sharp,
                  color: Colors.red,
                ),
              ),
            )),
        Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: userPasswordController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Password",
                icon: Icon(
                  Icons.password_sharp,
                  color: Colors.red,
                ),
              ),
            )),
        Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  if (userEmailController.text != "" && userPasswordController.text != ""){
                    await auth.signInWithEmailAndPassword(email: userEmailController.text, password: userPasswordController.text);
                  }
                  if (auth.currentUser != null){
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserHomePage() ));
                  }
                  if (kDebugMode){
                    print("user Logged In successfully");
                    
                  }
                }
                catch (err){
                  if (kDebugMode) {
                    print(err);
                  }
                }
              },
              child: const Text("Login"),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 2, 20),
                child: Text("Don't have an account?")),
            Padding(
              padding: const EdgeInsets.all(0),
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const UserRegistration()));
                  },
                  child: const Text(
                    "Sign Up here",
                    style: TextStyle(color: Colors.blue),
                  )),
            )
          ],
        ),
        const Spacer(),
      ],
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    auth.signOut();
    if (kDebugMode) {
      print("logged Out successfully");
    }
  }
}
