import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gps_toll_gate_system/data_objects.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});
  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  Widget build(BuildContext context) {
    return const UserHomePageDetails();
  }
}

class UserHomePageDetails extends StatefulWidget {
  const UserHomePageDetails({super.key});
  @override
  State<UserHomePageDetails> createState() => _UserHomePageDetailsState();
}

class _UserHomePageDetailsState extends State<UserHomePageDetails> {
  late UserDetails? userDetailsModel;
  List<TollDetails> tollDetails = [];
  late Map<TollDetails, double> tollDistMap = <TollDetails, double>{};
  List<TollFullTransaction> tollFullTransactions = [];

  var movingLat = 0.0;
  var movingLong = 0.0;
  var movingDistance = 0.0;
  late LocationData movingLocationData;

  final walletTec = TextEditingController();
  final movingTollName = TextEditingController();
  late var isTrxnDone = false;

  @override
  void initState() {
    super.initState();

    userDetailsModel = null;
    getUserDetails();
    getTollDetails();
    getLocation();
    getTollDistances();
    tollTransactions();
  }
  
  @override
  void dispose() {
    final auth = FirebaseAuth.instance;
    auth.signOut();
    super.dispose();
  }

  void getUserDetails() {
    final auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    var userUUid = user!.uid;
    DatabaseReference dbrefUser =
        FirebaseDatabase.instance.ref('/users/$userUUid');
    dbrefUser.onValue.listen((event) {
      if (event.snapshot.exists) {
        var userDetailsValue = event.snapshot.value;
        Map<dynamic, dynamic> result = jsonDecode(userDetailsValue.toString());
        var userDetailsModelRes = UserDetails(
            result['userEmail'],
            result['userName'],
            result['userUUid'],
            result['vehicleNumber'],
            result['walletBalance'],
            result['vehicleType']);
        setState(() {
          userDetailsModel = userDetailsModelRes;
        });
      }
    });
  }

  void tollTransactions() {
    DatabaseReference dbreftollTrxns =
        FirebaseDatabase.instance.ref('/transactions');
    dbreftollTrxns.onValue.listen((event) {
      if (event.snapshot.exists) {
        var value = event.snapshot.value;
        var valueJsonEncode = jsonEncode(value);
        Map<String, dynamic> valueDecode = jsonDecode(valueJsonEncode);
        for (var value in valueDecode.values) {
          Map<String, dynamic> valueJson = jsonDecode(value);
          TollFullTransaction tolltrxn =
              TollFullTransaction.fromJson(valueJson);
          if (tolltrxn.tollEntryRecord.userUUid == userDetailsModel?.userUUid) {
            if (!tollFullTransactions.contains(tolltrxn)) {
                tollFullTransactions.add(tolltrxn);
              }
          }
        }
      }
    });
  }

  void getTollDetails() {
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

  void getLocation() async {
    Location location = Location();
    late PermissionStatus permissionGranted;
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
    }
    location.onLocationChanged.listen((movingLocationData) {
      getTollDistances();
      setState(() {
        movingLat = movingLocationData.latitude!;
        movingLong = movingLocationData.longitude!;
      });
    });
  }

  TabController? tabController;

  static const List<Tab> myTabs = <Tab>[
    Tab(
      text: "User Details",
    ),
    Tab(
      text: "User Transactions",
    )
  ];

  void getTollDistances() {
    final distancesDict = <TollDetails, double>{};
    for (var toll in tollDetails) {
      var earthRadius = 6371;
      var dLat = deg2rad(double.parse(toll.tollLatitude) - movingLat);
      var dLon = deg2rad(double.parse(toll.tollLongitude) - movingLong);
      var arcLength = sin(dLat / 2) * sin(dLat / 2) +
          cos(deg2rad(double.parse(toll.tollLatitude)) *
                  cos(deg2rad(movingLat))) *
              sin(dLon / 2) *
              sin(dLon / 2);
      double curvature;
      if (arcLength > 1) {
        curvature = 2 * atan2(sqrt(arcLength), sqrt(arcLength - 1));
      } else {
        curvature = 2 * atan2(sqrt(arcLength), sqrt(1 - arcLength));
      }

      var distance = earthRadius * curvature;
      setState(() {
        distancesDict[toll] = distance;
      });
    }
    var sort = SplayTreeMap<TollDetails, double>.from(
        distancesDict,
        ((key1, key2) =>
            distancesDict[key1]!.compareTo(distancesDict[key2] as num)));
    setState(() {
      tollDistMap.addEntries(sort.entries);
    });
    if (kDebugMode) {
      print(tollDistMap);
    }
  }

  double deg2rad(double deg) {
    if ((deg * pi / 180) < 0) {
      return ((deg * pi / 180) * -1);
    } else {
      return (deg * pi / 180);
    }
  }

  

  void createTollTransaction2() {

    final auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    var userUUid = user!.uid;
    
    var earthRadius = 6371;
      var dLat = deg2rad(
          movingLat - double.parse(tollDistMap.entries.first.key.tollLatitude));
      var dLon = deg2rad(movingLong -
          double.parse(tollDistMap.entries.first.key.tollLongitude));
      var arcLength = sin(dLat / 2) * sin(dLat / 2) +
          cos(deg2rad(movingLat)) *
              cos(deg2rad(
                  double.parse(tollDistMap.entries.first.key.tollLatitude))) *
              sin(dLon / 2) *
              sin(dLon / 2);
      double curvature;
      if (arcLength > 1) {
        curvature = 2 * atan2(sqrt(arcLength), sqrt(arcLength - 1));
      } else {
        curvature = 2 * atan2(sqrt(arcLength), sqrt(1 - arcLength));
      }

      var distance = earthRadius * curvature;
      var priceMultiplier = 1.0;
      switch (userDetailsModel?.vehicleType) {
        case "Car":
          priceMultiplier = 1.0;
          break;
        case "Bus":
          priceMultiplier = 1.4;
          break;
        case "Truck":
          priceMultiplier = 1.7;
          break;
        case "Heavy Truck":
          priceMultiplier = 2.0;
          break;
        default:
      }
      var pricePerKM = 4.0;

      var tollCharge = distance * pricePerKM * priceMultiplier;

      final tollUUID = const Uuid().v4obj();
      final tollUUIDstr = tollUUID.uuid;
      final tollEntryTranUUID = const Uuid().v4obj();
      final tollEntryTranUUIDstr = tollEntryTranUUID.uuid;
      final tollExitTranUUID = const Uuid().v4obj();
      final tollExitTranUUIDstr = tollExitTranUUID.uuid;
      final tollFullTranUUID = const Uuid().v4obj();
      final tollFullTranUUIDstr = tollFullTranUUID.uuid;
      
      var timeStamp = DateTime.now();
      DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
      String formattedDateTime = formatter.format(timeStamp);
      
      TollDetails entryToll =
          TollDetails(movingLat.toString(),movingLong.toString(), tollUUIDstr,movingTollName.text);
      TollEntryTransaction tollEntryTransaction = TollEntryTransaction(
          entryToll, userUUid, formattedDateTime, tollEntryTranUUIDstr);
      var nearToll = tollDistMap.entries.first.key;
      TollExitTransaction tollExitTransaction = TollExitTransaction(
          nearToll, userUUid, formattedDateTime, tollExitTranUUIDstr);
      TollFullTransaction tollFullTRXN = TollFullTransaction(
          tollEntryTransaction,
          tollExitTransaction,
          tollCharge,
          tollFullTranUUIDstr);
      DatabaseReference dbreftransactions =
          FirebaseDatabase.instance.ref('/transactions/$tollFullTranUUIDstr');
      var tolltrnxJSONdata = tollFullTRXN.toJson();
      var tollFullTRXNjson = jsonEncode(tolltrnxJSONdata);
      dbreftransactions.set(tollFullTRXNjson);
      updateWalletBalance(tollCharge);
      dbreftransactions.onValue.listen((event) {
        if (event.snapshot.exists){
          setState(() {
            isTrxnDone = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transaction Recorded"),
        duration: Duration(seconds: 2),
      ));

        }else{
          setState(() {
            isTrxnDone = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transaction not Recorded"),
        duration: Duration(seconds: 2),
      ));
        }
      });
      
  }

  void updateWalletBalance(double amount) {
    final auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    var userUUid = user!.uid;
    DatabaseReference dbrefUser =
        FirebaseDatabase.instance.ref('/users/$userUUid');

    if (walletTec.text.isEmpty) {
      UserDetails newUser = UserDetails(
          userDetailsModel!.userEmail,
          userDetailsModel!.userName,
          userUUid,
          userDetailsModel!.vehicleNumber,
          userDetailsModel!.walletBalance - amount,
          userDetailsModel!.vehicleType);
      final newUserJSon = newUser.toJSON();
      final newUserJsonStr = jsonEncode(newUserJSon);
      dbrefUser.set(newUserJsonStr);
      setState(() {
        userDetailsModel = newUser;
      });
    }
    if (walletTec.text.isNotEmpty) {
      UserDetails newUser = UserDetails(
          userDetailsModel!.userEmail,
          userDetailsModel!.userName,
          userUUid,
          userDetailsModel!.vehicleNumber,
          userDetailsModel!.walletBalance + amount,
          userDetailsModel!.vehicleType);
      final newUserJSon = newUser.toJSON();
      final newUserJsonStr = jsonEncode(newUserJSon);
      dbrefUser.set(newUserJsonStr);
      setState(() {
        userDetailsModel = newUser;
      });
    }
  }

  void userTransactions() {
    DatabaseReference dbreftollTrxns = FirebaseDatabase.instance.ref('/transactions');
    dbreftollTrxns.onValue.listen((event) {
      if (event.snapshot.exists){
        var value = event.snapshot.value;
        var valueJsonEncode = jsonEncode(value);
        Map<String,dynamic> valueDecode = jsonDecode(valueJsonEncode);
        for (var value in valueDecode.values) {
          Map<String,dynamic> valueJson = jsonDecode(value);
          TollFullTransaction tolltrxn = TollFullTransaction.fromJson(valueJson);
          if (tolltrxn.tollEntryRecord.userUUid == userDetailsModel?.userUUid){
            setState(() {
            if (!tollFullTransactions.contains(tolltrxn)){
              tollFullTransactions.add(tolltrxn);
            }
          });
        }
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
            title: const Text("User Home Page"),
            bottom: const TabBar(tabs: myTabs),
            
          ),
          body: TabBarView(children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "User Name",
                              style: TextStyle(
                                  color: Colors.red[300], fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "User E-mail",
                              style: TextStyle(
                                  color: Colors.red[300], fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Vehicle Number",
                              style: TextStyle(
                                  color: Colors.red[300], fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Vehicle Type",
                              style: TextStyle(
                                  color: Colors.red[300], fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Wallet Balance",
                              style: TextStyle(
                                  color: Colors.red[300], fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Moving Latitude",
                              style: TextStyle(
                                  color: Colors.red[300], fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Moving Longitude",
                              style: TextStyle(
                                  color: Colors.red[300], fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Upcoming Toll : ",
                                style: TextStyle(
                                    color: Colors.red[300], fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Distance : ",
                                style: TextStyle(
                                    color: Colors.red[300], fontSize: 16)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              userDetailsModel == null
                                  ? "no user"
                                  : userDetailsModel!.userName.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              userDetailsModel == null
                                  ? "no user"
                                  : userDetailsModel!.userEmail,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              userDetailsModel == null
                                  ? "no user"
                                  : userDetailsModel!.vehicleNumber
                                      .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              userDetailsModel == null
                                  ? "no user"
                                  : userDetailsModel!.vehicleType.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              userDetailsModel == null
                                  ? "no user"
                                  : userDetailsModel!.walletBalance.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              movingLat.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              movingLong.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                tollDistMap.entries.isEmpty
                                    ? "no Near Tolls"
                                    : tollDistMap.entries.first.key.tollName ??
                                        "No Name",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                tollDistMap.entries.isEmpty
                                    ? "no Near Tolls "
                                    : tollDistMap.entries.first.value
                                        .toString(),
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: movingTollName,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Moving Toll Name",
                          icon: Icon(
                            Icons.password_sharp,
                            color: Colors.red,
                          ),
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: walletTec,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Wallet Balance",
                          icon: Icon(
                            Icons.password_sharp,
                            color: Colors.red,
                          ),
                        ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            createTollTransaction2();
                            movingTollName.text = "";
                          },
                          child: const Text("Create Transaction")),
                      ElevatedButton(
                          onPressed: () {
                            if (walletTec.text.isNotEmpty) {
                              updateWalletBalance(double.parse(walletTec.text));
                            }
                            walletTec.text = "";
                          },
                          child: const Text("Recharge Wallet"))
                    ],
                  ),
                ],
              ),
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
          ]),
        ));
  }
}



// void createTollTransaction() {
//     final auth = FirebaseAuth.instance;
//     var user = auth.currentUser;
//     var userUUid = user!.uid;

//     var inputLat = double.parse(latTec.text);
//     var inputLong = double.parse(longTec.text);
//     if (inputLat == double.parse(tollDistMap.entries.first.key.tollLatitude) &&
//         inputLong ==
//             double.parse(tollDistMap.entries.first.key.tollLongitude)) {
//       var earthRadius = 6371;
//       var dLat = deg2rad(inputLat - movingLat);
//       var dLon = deg2rad(inputLong - movingLong);
//       var arcLength = sin(dLat / 2) * sin(dLat / 2) +
//           cos(deg2rad(inputLat)) *
//               cos(deg2rad(movingLat)) *
//               sin(dLon / 2) *
//               sin(dLon / 2);
//       double curvature;
//       if (arcLength > 1) {
//         curvature = 2 * atan2(sqrt(arcLength), sqrt(arcLength - 1));
//       } else {
//         curvature = 2 * atan2(sqrt(arcLength), sqrt(1 - arcLength));
//       }

//       var distance = earthRadius * curvature;
//       var priceMultiplier = 1.0;
//       switch (userDetailsModel?.vehicleType) {
//         case "Car":
//           priceMultiplier = 1.0;
//           break;
//         case "Bus":
//           priceMultiplier = 1.4;
//           break;
//         case "Truck":
//           priceMultiplier = 1.7;
//           break;
//         case "Heavy Truck":
//           priceMultiplier = 2.0;
//           break;
//         default:
//       }
//       var pricePerKM = 4.0;

//       var tollCharge = distance * pricePerKM * priceMultiplier * 0.7;

//       final tollUUID = const Uuid().v4obj();
//       final tollUUIDstr = tollUUID.uuid;
//       final tollEntryTranUUID = const Uuid().v4obj();
//       final tollEntryTranUUIDstr = tollEntryTranUUID.uuid;
//       final tollExitTranUUID = const Uuid().v4obj();
//       final tollExitTranUUIDstr = tollExitTranUUID.uuid;
//       final tollFullTranUUID = const Uuid().v4obj();
//       final tollFullTranUUIDstr = tollFullTranUUID.uuid;
//       var tollName = "";
//       var timeStamp = DateTime.now();
//       DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
//       String formattedDateTime = formatter.format(timeStamp);
//       for (var toll in tollDetails) {
//         if (toll.tollLatitude == latTec.text &&
//             toll.tollLongitude == longTec.text) {
//           setState(() {
//             tollName = toll.tollName ?? "NO NAME";
//           });
//         }
//       }
//       TollDetails entryToll =
//           TollDetails(latTec.text, longTec.text, tollUUIDstr, tollName);
//       TollEntryTransaction tollEntryTransaction = TollEntryTransaction(
//           entryToll, userUUid, formattedDateTime, tollEntryTranUUIDstr);
//       var nearToll = tollDistMap.entries.first.key;
//       TollExitTransaction tollExitTransaction = TollExitTransaction(
//           nearToll, userUUid, formattedDateTime, tollExitTranUUIDstr);
//       TollFullTransaction tollFullTRXN = TollFullTransaction(
//           tollEntryTransaction,
//           tollExitTransaction,
//           tollCharge,
//           tollFullTranUUIDstr);
//       DatabaseReference dbreftransactions =
//           FirebaseDatabase.instance.ref('/transactions/$userUUid');
//       var tolltrnxJSONdata = tollFullTRXN.toJson();
//       var tollFullTRXNjson = jsonEncode(tolltrnxJSONdata);
//       dbreftransactions.set(tollFullTRXNjson);
//     }

//     if (inputLat != double.parse(tollDistMap.entries.first.key.tollLatitude) &&
//         inputLong !=
//             double.parse(tollDistMap.entries.first.key.tollLongitude)) {
//       var earthRadius = 6371;
//       var dLat = deg2rad(
//           inputLat - double.parse(tollDistMap.entries.first.key.tollLatitude));
//       var dLon = deg2rad(inputLong -
//           double.parse(tollDistMap.entries.first.key.tollLongitude));
//       var arcLength = sin(dLat / 2) * sin(dLat / 2) +
//           cos(deg2rad(inputLat)) *
//               cos(deg2rad(
//                   double.parse(tollDistMap.entries.first.key.tollLatitude))) *
//               sin(dLon / 2) *
//               sin(dLon / 2);
//       double curvature;
//       if (arcLength > 1) {
//         curvature = 2 * atan2(sqrt(arcLength), sqrt(arcLength - 1));
//       } else {
//         curvature = 2 * atan2(sqrt(arcLength), sqrt(1 - arcLength));
//       }

//       var distance = earthRadius * curvature;
//       var priceMultiplier = 1.0;
//       switch (userDetailsModel?.vehicleType) {
//         case "Car":
//           priceMultiplier = 1.0;
//           break;
//         case "Bus":
//           priceMultiplier = 1.4;
//           break;
//         case "Truck":
//           priceMultiplier = 1.7;
//           break;
//         case "Heavy Truck":
//           priceMultiplier = 2.0;
//           break;
//         default:
//       }
//       var pricePerKM = 4.0;

//       var tollCharge = distance * pricePerKM * priceMultiplier;

//       final tollUUID = const Uuid().v4obj();
//       final tollUUIDstr = tollUUID.uuid;
//       final tollEntryTranUUID = const Uuid().v4obj();
//       final tollEntryTranUUIDstr = tollEntryTranUUID.uuid;
//       final tollExitTranUUID = const Uuid().v4obj();
//       final tollExitTranUUIDstr = tollExitTranUUID.uuid;
//       final tollFullTranUUID = const Uuid().v4obj();
//       final tollFullTranUUIDstr = tollFullTranUUID.uuid;
//       var tollName = "";
//       var timeStamp = DateTime.now();
//       DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
//       String formattedDateTime = formatter.format(timeStamp);
//       for (var toll in tollDetails) {
//         if (toll.tollLatitude == latTec.text &&
//             toll.tollLongitude == longTec.text) {
//           setState(() {
//             tollName = toll.tollName ?? "NO NAME";
//           });
//         }
//       }
//       TollDetails entryToll =
//           TollDetails(latTec.text, longTec.text, tollUUIDstr, tollName);
//       TollEntryTransaction tollEntryTransaction = TollEntryTransaction(
//           entryToll, userUUid, formattedDateTime, tollEntryTranUUIDstr);
//       var nearToll = tollDistMap.entries.first.key;
//       TollExitTransaction tollExitTransaction = TollExitTransaction(
//           nearToll, userUUid, formattedDateTime, tollExitTranUUIDstr);
//       TollFullTransaction tollFullTRXN = TollFullTransaction(
//           tollEntryTransaction,
//           tollExitTransaction,
//           tollCharge,
//           tollFullTranUUIDstr);
//       DatabaseReference dbreftransactions =
//           FirebaseDatabase.instance.ref('/transactions/$tollFullTranUUIDstr');
//       var tolltrnxJSONdata = tollFullTRXN.toJson();
//       var tollFullTRXNjson = jsonEncode(tolltrnxJSONdata);
//       dbreftransactions.set(tollFullTRXNjson);
//       updateWalletBalance(tollCharge);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text("Transaction Recorded"),
//         duration: Duration(seconds: 2),
//       ));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text("Transaction not Recorded"),
//         duration: Duration(seconds: 2),
//       ));
//     }
//   }