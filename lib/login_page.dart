
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/Admin/admin_login.dart';
import 'package:gps_toll_gate_system/User/user_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminLogin()));
            },
            child: const Text("Admin"),
          ),
          ),
          Padding(padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserLogin()));
            },
            child: const Text("User"),
          ),
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}