// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'package:exim/models/validateScanBoxResult_model.dart';

import 'loginResult_model.dart';

ValidateScanBoxDataModel validateScanBoxDataModelFromJson(String str) => ValidateScanBoxDataModel.fromJson(json.decode(str));

ValidateScanBoxDataModel validateScanBoxDataModelFromJsonExe(String str) => ValidateScanBoxDataModel.fromJsonExe(json.decode(str));

String validateScanBoxDataModelToJson(ValidateScanBoxDataModel data) => json.encode(data.toJson());


class ValidateScanBoxDataModel {

  List<ValidateScanBoxResultModel> Data;
  String ExceptionMessage;

  ValidateScanBoxDataModel({
    this.Data,
    this.ExceptionMessage,});



  ValidateScanBoxDataModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      Data = new List<ValidateScanBoxResultModel>();
      json['Data'].forEach((v) {
        Data.add(new ValidateScanBoxResultModel.fromJson(v));
      });
    }
  }

  factory ValidateScanBoxDataModel.fromJsonExe(Map<String, dynamic> json) => ValidateScanBoxDataModel(
    ExceptionMessage: json["ExceptionMessage"],
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.Data != null) {
      data['Data'] = this.Data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

