// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

LoginResultModel loginResultModelFromJson(String str) => LoginResultModel.fromJson(json.decode(str));

String loginResultModelToJson(LoginResultModel data) => json.encode(data.toJson());

class LoginResultModel {
  int EmpCode;
  int MCUserCode;
  String Message;
  int Status;
  String OTPMessage;
  int SendMessage;
  String MobileNumber;
  String CountryCode;


  LoginResultModel({
    this.EmpCode,
    this.MCUserCode,
    this.Message,
    this.Status,
    this.OTPMessage,
    this.SendMessage,
    this.MobileNumber,
    this.CountryCode,
  });

  factory LoginResultModel.fromJson(Map<String, dynamic> json) => LoginResultModel(
    EmpCode: json["EmpCode"],
    MCUserCode: json["MCUserCode"],
    Message: json["Message"],
    Status: json["Status"],
    OTPMessage: json["OTPMessage"],
    SendMessage: json["SendMessage"],
    MobileNumber: json["MobileNumber"],
    CountryCode: json["CountryCode"],
  );

  Map<String, dynamic> toJson() => {
    "EmpCode": EmpCode,
    "MCUserCode": MCUserCode,
    "Message": Message,
    "Status": Status,
    "OTPMessage": OTPMessage,
    "SendMessage": SendMessage,
    "MobileNumber": MobileNumber,
    "CountryCode": CountryCode,
  };
}
