// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

VerifyOTPResultModel verifyOTPResultModelFromJson(String str) => VerifyOTPResultModel.fromJson(json.decode(str));

String verifyOTPResultModelToJson(VerifyOTPResultModel data) => json.encode(data.toJson());

class VerifyOTPResultModel {

  String Message;
  int Status;
  int MC_EmpCode;
  int MC_UserCode;
  int SessionID;
  String MobileNo;
  String Token;
  String Username;
  int ReadOnlyUser;

  VerifyOTPResultModel({
    this.Message,
    this.Status,
    this.MC_EmpCode,
    this.MC_UserCode,
    this.SessionID,
    this.MobileNo,
    this.Token,
    this.Username,
    this.ReadOnlyUser,
  });

  factory VerifyOTPResultModel.fromJson(Map<String, dynamic> json) => VerifyOTPResultModel(
    Message: json["Message"],
    Status: json["Status"],
    MC_EmpCode: json["MC_EmpCode"],
    MC_UserCode: json["MC_UserCode"],
    SessionID: json["SessionID"],
    MobileNo: json["MobileNo"],
    Token: json["Token"],
    Username: json["Username"],
    ReadOnlyUser: json["ReadOnlyUser"],
  );

  Map<String, dynamic> toJson() => {
    "Message": Message,
    "Status": Status,
    "MC_EmpCode": MC_EmpCode,
    "MC_UserCode": MC_UserCode,
    "SessionID": SessionID,
    "MobileNo": MobileNo,
    "Token": Token,
    "Username": Username,
    "ReadOnlyUser": ReadOnlyUser,
  };
}
