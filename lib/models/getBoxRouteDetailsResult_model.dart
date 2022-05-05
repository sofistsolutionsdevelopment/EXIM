// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

GetBoxRouteDetailsResultModel getBoxRouteDetailsResultModelFromJson(String str) => GetBoxRouteDetailsResultModel.fromJson(json.decode(str));

String getBoxRouteDetailsResultModelToJson(GetBoxRouteDetailsResultModel data) => json.encode(data.toJson());

class GetBoxRouteDetailsResultModel {

  int RouteCode;
  String RouteName;
  String RouteDetails;
  int StepCode;
  int StepOrdNo;
  int BoxNo_value;
  int Action_value;
  String Action;
  String StepCaption;
  String StepIcon;
  String StepDetails;
  int IfYes;
  int IfNo;
  bool IsEnd;
  bool IsScanRequired;
  bool IsStepComplete;
  String RouteDate;
  String RouteTime;
  String ProcessingTime;
  int CompCode;

  GetBoxRouteDetailsResultModel({
    this.RouteCode,
    this.RouteName,
    this.RouteDetails,
    this.StepCode,
    this.StepOrdNo,
    this.BoxNo_value,
    this.Action_value,
    this.Action,
    this.StepCaption,
    this.StepIcon,
    this.StepDetails,
    this.IfYes,
    this.IfNo,
    this.IsEnd,
    this.IsScanRequired,
    this.IsStepComplete,
    this.RouteDate,
    this.RouteTime,
    this.ProcessingTime,
    this.CompCode,
  });

  factory GetBoxRouteDetailsResultModel.fromJson(Map<String, dynamic> json) => GetBoxRouteDetailsResultModel(
  RouteCode: json["RouteCode"],
  RouteName: json["RouteName"],
  RouteDetails: json["RouteDetails"],
  StepCode: json["StepCode"],
  StepOrdNo: json["StepOrdNo"],
  BoxNo_value: json["BoxNo_value"],
  Action_value: json["Action_value"],
  Action: json["Action"],
  StepCaption: json["StepCaption"],
  StepIcon: json["StepIcon"],
  StepDetails: json["StepDetails"],
  IfYes: json["IfYes"],
  IfNo: json["IfNo"],
  IsEnd: json["IsEnd"],
  IsScanRequired: json["IsScanRequired"],
  IsStepComplete: json["IsStepComplete"],
  RouteDate: json["RouteDate"],
  RouteTime: json["RouteTime"],
  ProcessingTime: json["ProcessingTime"],
  CompCode: json["CompCode"],
  );

  Map<String, dynamic> toJson() => {
    "RouteCode": RouteCode,
    "RouteName": RouteName,
    "RouteDetails": RouteDetails,
    "StepCode": StepCode,
    "StepOrdNo": StepOrdNo,
    "BoxNo_value":BoxNo_value,
    "Action_value": Action_value,
    "Action": Action,
    "StepCaption": StepCaption,
    "StepIcon": StepIcon,
    "StepDetails": StepDetails,
    "IfYes": IfYes,
    "IfNo": IfNo,
    "IsEnd": IsEnd,
    "IsScanRequired": IsScanRequired,
    "IsStepComplete": IsStepComplete,
    "RouteDate": RouteDate,
    "RouteTime": RouteTime,
    "ProcessingTime": ProcessingTime,
    "CompCode": CompCode,
  };
}
