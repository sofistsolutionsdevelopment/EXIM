// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

GetBoxDetailsResultModel getBoxDetailsResultModelFromJson(String str) => GetBoxDetailsResultModel.fromJson(json.decode(str));

String getBoxDetailsResultModelToJson(GetBoxDetailsResultModel data) => json.encode(data.toJson());

class GetBoxDetailsResultModel {

  int ExportType_value;
  String ExportType;
  int BoxNo_value;
  String BoxNo;
  int RouteCode;
  String RouteName;
  String RouteDetails;
  String StepCaption;
  int StepCode;
  String InputValue;
  String RouteDate;
  String RouteTime;
  int RoutePerc;
  int CompCode;
  int InvoiceNo_Value;
  String InvoiceNo;
  String CustShortCode;

  GetBoxDetailsResultModel({
    this.ExportType_value,
    this.ExportType,
    this.BoxNo_value,
    this.BoxNo,
    this.RouteCode,
    this.RouteName,
    this.RouteDetails,
    this.StepCaption,
    this.StepCode,
    this.InputValue,
    this.RouteDate,
    this.RouteTime,
    this.RoutePerc,
    this.CompCode,
    this.InvoiceNo_Value,
    this.InvoiceNo,
    this.CustShortCode,
  });

  factory GetBoxDetailsResultModel.fromJson(Map<String, dynamic> json) => GetBoxDetailsResultModel(
    ExportType_value: json["ExportType_value"],
    ExportType: json["ExportType"],
    BoxNo_value: json["BoxNo_value"],
    BoxNo: json["BoxNo"],
    RouteCode: json["RouteCode"],
    RouteName: json["RouteName"],
    RouteDetails: json["RouteDetails"],
    StepCaption: json["StepCaption"],
    StepCode: json["StepCode"],
    InputValue: json["InputValue"],
    RouteDate: json["RouteDate"],
    RouteTime: json["RouteTime"],
    RoutePerc: json["RoutePerc"],
    CompCode: json["CompCode"],
    InvoiceNo_Value: json["InvoiceNo_Value"],
    InvoiceNo: json["InvoiceNo"],
    CustShortCode: json["CustShortCode"],
  );

  Map<String, dynamic> toJson() => {
    "ExportType_value": ExportType_value,
    "ExportType": ExportType,
    "BoxNo_value": BoxNo_value,
    "BoxNo": BoxNo,
    "RouteCode": RouteCode,
    "RouteName": RouteName,
    "RouteDetails": RouteDetails,
    "StepCaption": StepCaption,
    "StepCode": StepCode,
    "InputValue": InputValue,
    "RouteDate": RouteDate,
    "RouteTime": RouteTime,
    "RoutePerc": RoutePerc,
    "CompCode": CompCode,
    "InvoiceNo_Value": InvoiceNo_Value,
    "InvoiceNo": InvoiceNo,
    "CustShortCode": CustShortCode,
  };
}
