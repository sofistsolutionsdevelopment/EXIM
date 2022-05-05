// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

SaveResultModel saveResultModelFromJson(String str) => SaveResultModel.fromJson(json.decode(str));

String saveResultModelToJson(SaveResultModel data) => json.encode(data.toJson());

class SaveResultModel {

  int BoxNo_value;
  int RouteCode;
  String RouteName;
  int StepCode;
  int StepOrdNo;
  int Action_value;
  String Action;
  String StepCaption;
  String StepIcon;
  String StepDetails;
  int IfYes;
  int IfNo;
  bool IsEnd;
  int IsScanRequired;

  SaveResultModel({
  this.BoxNo_value,
    this.RouteCode,
    this.RouteName,
    this.StepCode,
    this.StepOrdNo,
    this.Action_value,
    this.Action,
    this.StepCaption,
    this.StepIcon,
    this.StepDetails,
    this.IfYes,
    this.IfNo,
    this.IsEnd,
    this.IsScanRequired,
  });

  factory SaveResultModel.fromJson(Map<String, dynamic> json) => SaveResultModel(
  BoxNo_value: json["BoxNo_value"],
    RouteCode: json["RouteCode"],
    RouteName: json["RouteName"],
    StepCode: json["StepCode"],
    StepOrdNo: json["StepOrdNo"],
    Action_value: json["Action_value"],
    Action: json["Action"],
    StepCaption: json["StepCaption"],
    StepIcon: json["StepIcon"],
    StepDetails: json["StepDetails"],
    IfYes: json["IfYes"],
    IfNo: json["IfNo"],
    IsEnd: json["IsEnd"],
    IsScanRequired: json["IsScanRequired"],
  );

  Map<String, dynamic> toJson() => {
  "BoxNo_value": BoxNo_value,
    "RouteCode": RouteCode,
    "RouteName": RouteName,
    "StepCode": StepCode,
    "StepOrdNo": StepOrdNo,
    "Action_value": Action_value,
    "Action": Action,
    "StepCaption": StepCaption,
    "StepIcon": StepIcon,
    "StepDetails": StepDetails,
    "IfYes": IfYes,
    "IfNo": IfNo,
    "IsEnd": IsEnd,
    "IsScanRequired": IsScanRequired,
  };
}
