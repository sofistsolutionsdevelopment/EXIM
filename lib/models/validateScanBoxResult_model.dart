// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

ValidateScanBoxResultModel validateScanBoxResultModelFromJson(String str) => ValidateScanBoxResultModel.fromJson(json.decode(str));

String validateScanBoxResultModelToJson(ValidateScanBoxResultModel data) => json.encode(data.toJson());

class ValidateScanBoxResultModel {
  int Validate;
  int BoxNo_Value;
  String BoxNo;
  String InvoiceNo;
  String CustShortCode;
  String ScanMessage;


  ValidateScanBoxResultModel({
    this.Validate,
    this.BoxNo_Value,
    this.BoxNo,
    this.InvoiceNo,
    this.CustShortCode,
    this.ScanMessage,
  });

  factory ValidateScanBoxResultModel.fromJson(Map<String, dynamic> json) => ValidateScanBoxResultModel(
    Validate: json["Validate"],
    BoxNo_Value: json["BoxNo_Value"],
    BoxNo: json["BoxNo"],
    InvoiceNo: json["InvoiceNo"],
    CustShortCode: json["CustShortCode"],
    ScanMessage: json["ScanMessage"],
  );

  Map<String, dynamic> toJson() => {
    "Validate": Validate,
    "BoxNo_Value": BoxNo_Value,
    "BoxNo": BoxNo,
    "InvoiceNo": InvoiceNo,
    "CustShortCode": CustShortCode,
    "ScanMessage": ScanMessage,

  };
}
