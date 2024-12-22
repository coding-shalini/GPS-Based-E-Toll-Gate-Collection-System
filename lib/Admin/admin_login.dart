import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/Admin/admin_home.dart';
import 'package:gps_toll_gate_system/Admin/admin_registration.dart';
import 'package:gps_toll_gate_system/login_page.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()));
          },
          icon: const Icon(Icons.home , color: Colors.amber, size: 36,))
        ],
      ),
      body: const AdminLoginPage(),
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
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
                hintText: "Enter Admin Email",
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminHomePage() ));
                  }
                  if (kDebugMode){
                    print("Admin Logged In successfully");
                    
                  }
                }
                catch (err){
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Doesn't Exist. Please register")));
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
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const AdminRegistration()));
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
}
