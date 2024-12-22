
class TollDetails {
  late String tollLatitude;
  late String tollLongitude;
  late String? tollName;
  late String tollUUid;

  TollDetails(this.tollLatitude,this.tollLongitude,this.tollUUid,this.tollName);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tollLatitude'] = tollLatitude;
    data['tollLongitude'] = tollLongitude;
    data['tollUUid'] = tollUUid;
    data['tollName'] = tollName;
    return data;
  }
  factory TollDetails.fromJson(Map<String, dynamic> json) {
    return TollDetails(
      json['tollLatitude'] ?? '',
      json['tollLongitude'] ?? '',
      json['tollUUid'] ?? '',
      json['tollName'],
    );
  }
}

class TollEntryTransaction {
  late TollDetails tollEntryDetails;
  late String userUUid;
  late String tollEntryTransactionUUid;
  late String timeStamp;

  TollEntryTransaction(this.tollEntryDetails,this.userUUid,
      this.timeStamp, this.tollEntryTransactionUUid);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tollEntryDetails'] = tollEntryDetails.toJson();
    data['userUUid'] = userUUid;
    data['tollEntryTransactionUUid'] = tollEntryTransactionUUid;
    data['timeStamp'] = timeStamp;
    return data;
  }

  factory TollEntryTransaction.fromJson(Map<String, dynamic> json) {
    return TollEntryTransaction(
      TollDetails.fromJson(json['tollEntryDetails']),
      json['userUUid'] ?? '',
      json['timeStamp'] ?? '',
      json['tollEntryTransactionUUid'] ?? '',
    );
  }

}

class TollExitTransaction {
  late TollDetails tollExitDetails;
  late String userUUid;
  late String tollExitTransactionUUid;
  late String timeStamp;

  TollExitTransaction(this.tollExitDetails, this.userUUid,
      this.timeStamp, this.tollExitTransactionUUid);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tollExitDetails'] = tollExitDetails.toJson();
    data['userUUid'] = userUUid;
    data['tollExitTransactionUUid'] = tollExitTransactionUUid;
    data['timeStamp'] = timeStamp;
    return data;
  }

  factory TollExitTransaction.fromJson(Map<String, dynamic> json) {
    return TollExitTransaction(
      TollDetails.fromJson(json['tollExitDetails']),
      json['userUUid'] ?? '',
      json['timeStamp'] ?? '',
      json['tollExitTransactionUUid'] ?? '',
    );
  }
}



class TollFullTransaction{
  late TollEntryTransaction tollEntryRecord;
  late TollExitTransaction tollExitRecord;
  late double tollFee;
  late String tollFullTransactionUUid;

  TollFullTransaction(this.tollEntryRecord,this.tollExitRecord,this.tollFee,this.tollFullTransactionUUid);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tollEntryRecord'] = tollEntryRecord.toJson();
    data['tollExitRecord'] = tollExitRecord.toJson();
    data['tollFee'] = tollFee;
    data['tollFullTransactionUUid'] = tollFullTransactionUUid;
    return data;
  }

  factory TollFullTransaction.fromJson(Map<String, dynamic> json) {
    return TollFullTransaction(
      TollEntryTransaction.fromJson(json['tollEntryRecord']),
      TollExitTransaction.fromJson(json['tollExitRecord']),
      json['tollFee'] ?? 0.0,
      json['tollFullTransactionUUid'] ?? '',
    );
  }
  
}

class UserTollTransactions {
  late String userUUid;
  late double walletBalance;
  late List<TollFullTransaction> tollFullTransactions;

  UserTollTransactions(this.userUUid,this.walletBalance,this.tollFullTransactions);

  Map<String,dynamic> toJSON(){
    final Map<String,dynamic> data = <String,dynamic>{};
    data['userUUid'] = userUUid;
    data['walletBalance'] = walletBalance;
    data['tollFullTransactions'] = tollFullTransactions;
    return data;
  }
}

class UserDetails {
  late String userName;
  late String userEmail;
  late String vehicleNumber;
  late String vehicleType;
  late String userUUid;
  late double walletBalance;
  
  UserDetails(this.userEmail,this.userName,this.userUUid,this.vehicleNumber,this.walletBalance,this.vehicleType);

  Map<String,dynamic> toJSON(){
    final Map<String,dynamic> data = <String,dynamic>{};
    data['userName'] = userName;
    data['userEmail'] = userEmail;
    data['userUUid'] = userUUid;
    data['vehicleNumber'] = vehicleNumber;
    data['walletBalance'] = walletBalance;
    data['vehicleType'] = vehicleType;
    return data;
  }
}

class AdminDetails {
  late String adminName;
  late String adminEmail;
  late String adminUUid;
  AdminDetails(this.adminEmail,this.adminName,this.adminUUid);

  Map<String,dynamic> toJSON(){
    final Map<String,dynamic> data = <String,dynamic>{};
    data['adminName'] = adminName;
    data['adminEmail'] = adminEmail;
    data['adminUUid'] = adminUUid;
    return data;
  }

}