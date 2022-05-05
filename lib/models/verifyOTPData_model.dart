// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'package:exim/models/verifyOTPResult_model.dart';

import 'loginResult_model.dart';

VerifyDataModel verifydataModelFromJson(String str) => VerifyDataModel.fromJson(json.decode(str));


String verifydataModelToJson(VerifyDataModel data) => json.encode(data.toJson());


class VerifyDataModel {

  List<VerifyOTPResultModel> Data;

  VerifyDataModel({
    this.Data,});



  VerifyDataModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      Data = new List<VerifyOTPResultModel>();
      json['Data'].forEach((v) {
        Data.add(new VerifyOTPResultModel.fromJson(v));
      });
    }
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.Data != null) {
      data['Data'] = this.Data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

