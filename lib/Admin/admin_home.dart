import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/Admin/admin_add_tolldetails.dart';
import 'package:gps_toll_gate_system/data_objects.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return const AdminHomePageDetails();
  }
}

class AdminHomePageDetails extends StatefulWidget {
  const AdminHomePageDetails({super.key});

  @override
  State<AdminHomePageDetails> createState() => _AdminHomePageDetailsState();
}

class _AdminHomePageDetailsState extends State<AdminHomePageDetails> {
  final auth = FirebaseAuth.instance;
  get admin => auth.currentUser;
  List<TollDetails> tollDetails = [];
  List<TollFullTransaction> tollFullTransactions = [];
  TabController? tabController;

  static const List<Tab> myTabs = <Tab>[
    Tab(text: "Toll Details",),
    Tab(text: "Toll Transactions",)
  ];

  @override
  void initState() {
    super.initState();
    getTollDetails();
    tollTransactions();
  }

  void getTollDetails(){
    DatabaseReference dbrefTollDetails =
        FirebaseDatabase.instance.ref('/admin/tollDetails');
    dbrefTollDetails.onValue.listen((event) {
      if (event.snapshot.exists) {
        var valueTollDetails = event.snapshot.value;
        var valueTollDetailsJSON = jsonEncode(valueTollDetails);
        Map<dynamic, dynamic> result = jsonDecode(valueTollDetailsJSON);
        for (var value in result.values) {
          Map<String, dynamic> inResult = jsonDecode(value.toString());
          var tollDetailsModel = TollDetails(
              inResult['tollLatitude'],
              inResult['tollLongitude'],
              inResult['tollUUid'],
              inResult['tollName']);
          setState(() {
            tollDetails.add(tollDetailsModel);
          });
        }
      }
    });
  }

  void tollTransactions(){
    DatabaseReference dbreftollTrxns = FirebaseDatabase.instance.ref('/transactions');
    dbreftollTrxns.onValue.listen((event) {
      if (event.snapshot.exists){
        var value = event.snapshot.value;
        var valueJsonEncode = jsonEncode(value);
        Map<String,dynamic> valueDecode = jsonDecode(valueJsonEncode);
        for (var value in valueDecode.values) {
          Map<String,dynamic> valueJson = jsonDecode(value);
          TollFullTransaction tolltrxn = TollFullTransaction.fromJson(valueJson);
          setState(() {
            if (!tollFullTransactions.contains(tolltrxn)){
              tollFullTransactions.add(tolltrxn);
            }
          });
        }
        
    }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Home page"),
          bottom: const TabBar(tabs: myTabs ),
        ),
        body: TabBarView(
          children: [
            Stack(
                children: [
                  ListView.separated(
                  itemBuilder: (context,index){
                    return ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Toll Name : " , style: TextStyle(color: Colors.red[300]),),
                              Text(tollDetails[index].tollName ?? "No Name"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Latitude : " , style: TextStyle(color: Colors.red[300]),),
                              Text(tollDetails[index].tollLatitude),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Longitude: " , style: TextStyle(color: Colors.red[300]),),
                              Text(tollDetails[index].tollLongitude),
                            ],
                          )
                        ],),
                      )
                    );
                  },
                  separatorBuilder: (context,index) => const Divider(),
                  itemCount: tollDetails.length
                  ),
                  Column(
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: IconButton(
                              onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const AdminAddTollDetails()));
                              },
                              icon: const Icon(Icons.add_circle,size: 58,color: Colors.amber,)),
                          ),
                        ],
                      ),
                    ],
                  )
                ]
              ),
              ListView.separated(
                  itemBuilder: (context,index){
                    return ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(child: Text("Toll Entry Name : " , style: TextStyle(color: Colors.red[300]))),
                            Text(tollFullTransactions[index].tollEntryRecord.tollEntryDetails.tollName ?? "No Name",overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(child: Text("Toll Exit Name : " , style: TextStyle(color: Colors.red[300]))),
                            Text(tollFullTransactions[index].tollExitRecord.tollExitDetails.tollName ?? "No Name",overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Toll Charge : " , style: TextStyle(color: Colors.red[300]),),
                            Text(tollFullTransactions[index].tollFee.toString()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Toll Entry Time : " , style: TextStyle(color: Colors.red[300]),),
                            Text(tollFullTransactions[index].tollEntryRecord.timeStamp),
                          ],
                        ), 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Toll Exit Time : " , style: TextStyle(color: Colors.red[300]),),
                            Text(tollFullTransactions[index].tollExitRecord.timeStamp),
                          ],
                        ),                         
                      ],)
                    );
                  },
                  separatorBuilder: (context,index) => const Divider(),
                  itemCount: tollFullTransactions.length
                  ),
          ]
          ),
        )
      );
  }
}

