// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'package:exim/models/saveResult_model.dart';
import 'package:exim/models/validateScanBoxResult_model.dart';

import 'loginResult_model.dart';

SaveDataModel saveModelFromJson(String str) => SaveDataModel.fromJson(json.decode(str));

SaveDataModel saveDataModelFromJsonExe(String str) => SaveDataModel.fromJsonExe(json.decode(str));

String saveModelToJson(SaveDataModel data) => json.encode(data.toJson());


class SaveDataModel {

  List<SaveResultModel> Data;
  String ExceptionMessage;

  SaveDataModel({
    this.Data,
    this.ExceptionMessage,});



  SaveDataModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      Data = new List<SaveResultModel>();
      json['Data'].forEach((v) {
        Data.add(new SaveResultModel.fromJson(v));
      });
    }
  }

  factory SaveDataModel.fromJsonExe(Map<String, dynamic> json) => SaveDataModel(
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

