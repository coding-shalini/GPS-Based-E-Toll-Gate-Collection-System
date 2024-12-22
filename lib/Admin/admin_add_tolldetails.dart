import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/Admin/admin_home.dart';
import 'package:gps_toll_gate_system/data_objects.dart';
import 'package:uuid/uuid.dart';

class AdminAddTollDetails extends StatefulWidget {
  const AdminAddTollDetails({super.key});

  @override
  State<AdminAddTollDetails> createState() => _AdminAddTollDetailsState();
}

class _AdminAddTollDetailsState extends State<AdminAddTollDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Add Toll Details"),
      ),
      body: const AdminAddTollDetailsPage(),
    );
  }
}

class AdminAddTollDetailsPage extends StatefulWidget {
  const AdminAddTollDetailsPage({super.key});

  @override
  State<AdminAddTollDetailsPage> createState() =>
      _AdminAddTollDetailsPageState();
}

class _AdminAddTollDetailsPageState extends State<AdminAddTollDetailsPage> {
  final latInputCntlr = TextEditingController();
  final longInputCntlr = TextEditingController();
  final tollNameCntlr = TextEditingController();
  String tollUUid = const Uuid().v4();

  @override
  Widget build(BuildContext context) {
    final crntWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: crntWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 3),
            child: Text(
              "Toll Latitude",
              style: TextStyle(color: Colors.green, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: latInputCntlr,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.location_searching_sharp),
                hintText: "Enter Toll Latitude",
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 3),
            child: Text(
              "Toll Longitude",
              style: TextStyle(color: Colors.green, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: longInputCntlr,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.location_searching_sharp),
                hintText: "Enter Toll Longitude",
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              "Toll Name",
              style: TextStyle(color: Colors.green, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: TextField(
              keyboardType: TextInputType.name,
              controller: tollNameCntlr,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.abc_sharp),
                hintText: "Enter Toll Name",
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                    onPressed: () {
                      DatabaseReference dbrefTollDetails =
                          FirebaseDatabase.instance.ref("/admin/tollDetails");
                      final tollDetails = TollDetails(latInputCntlr.text,
                          longInputCntlr.text, tollUUid, tollNameCntlr.text);
                      var tollDetailsJson = tollDetails.toJson();
                      var jsonTollDetailsData = jsonEncode(tollDetailsJson);
                      dbrefTollDetails.child(tollUUid).set(jsonTollDetailsData);
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminHomePage()));
                    },
                    child: const Text("Add")),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AdminHomePage()));
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
