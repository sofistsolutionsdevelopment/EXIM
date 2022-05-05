// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'loginResult_model.dart';

LoginDataModel loginDataModelFromJson(String str) => LoginDataModel.fromJson(json.decode(str));


String loginDataModelToJson(LoginDataModel data) => json.encode(data.toJson());


class LoginDataModel {

  List<LoginResultModel> Data;

  LoginDataModel({
    this.Data,});



  LoginDataModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      Data = new List<LoginResultModel>();
      json['Data'].forEach((v) {
        Data.add(new LoginResultModel.fromJson(v));
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

